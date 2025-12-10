#!/bin/bash
# Process win11 backup with screen sessions (SSH timeout-safe)
# Usage: ssh fedora-vps "bash -s" < process-win11-backup-safe.sh

set -e

COMPRESSED="/mnt/storage/windows-backups/win11-direct-stream.img.gz"
STORAGE="/mnt/storage"
HETZNER_REMOTE="hetzner-storage:/windows-backups"
TIMESTAMP=$(date +%Y-%m-%d-%H%M%S)

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +%H:%M:%S)]${NC} $1"; }
warn() { echo -e "${YELLOW}[$(date +%H:%M:%S)]${NC} $1"; }
error() { echo -e "${RED}[$(date +%H:%M:%S)]${NC} $1"; }

log "=== Windows 11 Backup Processing (SSH Timeout-Safe) ==="

# Install dependencies
log "Installing required tools..."
if ! command -v screen &> /dev/null; then
    sudo dnf install -y screen
fi
if ! command -v pv &> /dev/null; then
    sudo dnf install -y pv
fi
if ! command -v qemu-img &> /dev/null; then
    sudo dnf install -y qemu-img
fi

# Check space
df -h "$STORAGE"
AVAILABLE=$(df -BG "$STORAGE" | tail -1 | awk '{print $4}' | sed 's/G//')
log "Available space: ${AVAILABLE}GB"

if [ "$AVAILABLE" -lt 100 ]; then
    error "Need at least 100GB free!"
    exit 1
fi

# =============================================================================
# STEP 1: DECOMPRESS (in screen session)
# =============================================================================

log "=== Step 1: Decompression ==="

cat > /tmp/step1-decompress.sh << 'EOFSTEP1'
#!/bin/bash
echo "[$(date +%H:%M:%S)] Starting decompression..."
pv -pterb "/mnt/storage/windows-backups/win11-direct-stream.img.gz" | \
    gunzip > /mnt/storage/win11-backup.img
EXIT_CODE=$?
if [ $EXIT_CODE -eq 0 ]; then
    echo "[$(date +%H:%M:%S)] ✅ Decompression complete!"
    du -h /mnt/storage/win11-backup.img
else
    echo "[$(date +%H:%M:%S)] ❌ Decompression failed!"
    exit 1
fi
EOFSTEP1

chmod +x /tmp/step1-decompress.sh

log "Starting decompression in screen..."
screen -dmS decompress-step bash -c "/tmp/step1-decompress.sh; echo 'STEP1_DONE' > /tmp/step1.status; exec bash"

log "Waiting for decompression to complete..."
log "Monitor with: screen -r decompress-step"

# Wait for completion
while [ ! -f /tmp/step1.status ]; do
    if [ -f /mnt/storage/win11-backup.img ]; then
        SIZE=$(du -h /mnt/storage/win11-backup.img 2>/dev/null | cut -f1 || echo "0")
        echo -ne "\rProgress: $SIZE    "
    fi
    sleep 10
done
echo ""
log "✅ Decompression complete!"

# =============================================================================
# STEP 2: DELETE COMPRESSED FILE
# =============================================================================

log "=== Step 2: Deleting compressed file ==="
rm -f "$COMPRESSED"
log "✅ Freed 190GB"
df -h "$STORAGE" | tail -1

# =============================================================================
# STEP 3: CONVERT TO VHDX (in screen session)
# =============================================================================

log "=== Step 3: Converting to VHDX ==="

VHDX_FILE="$STORAGE/win11-backup-${TIMESTAMP}.vhdx"

cat > /tmp/step3-convert.sh << EOFSTEP3
#!/bin/bash
echo "[$(date +%H:%M:%S)] Converting IMG → VHDX..."
qemu-img convert -f raw -O vhdx \\
    -o subformat=dynamic \\
    "$STORAGE/win11-backup.img" \\
    "$VHDX_FILE" \\
    -p
EXIT_CODE=\$?
if [ \$EXIT_CODE -eq 0 ]; then
    echo "[$(date +%H:%M:%S)] ✅ Conversion complete!"
    du -h "$VHDX_FILE"
else
    echo "[$(date +%H:%M:%S)] ❌ Conversion failed!"
    exit 1
fi
EOFSTEP3

chmod +x /tmp/step3-convert.sh

rm -f /tmp/step3.status
log "Starting conversion in screen..."
screen -dmS convert-step bash -c "/tmp/step3-convert.sh; echo 'STEP3_DONE' > /tmp/step3.status; exec bash"

log "Waiting for conversion to complete..."
log "Monitor with: screen -r convert-step"

while [ ! -f /tmp/step3.status ]; do
    if [ -f "$VHDX_FILE" ]; then
        SIZE=$(du -h "$VHDX_FILE" 2>/dev/null | cut -f1 || echo "0")
        echo -ne "\rProgress: $SIZE    "
    fi
    sleep 10
done
echo ""
log "✅ Conversion complete!"

# =============================================================================
# STEP 4: DELETE IMG FILE
# =============================================================================

log "=== Step 4: Deleting IMG file ==="
rm -f "$STORAGE/win11-backup.img"
log "✅ Freed space"
df -h "$STORAGE" | tail -1

# =============================================================================
# STEP 5: UPLOAD TO HETZNER (in screen session)
# =============================================================================

log "=== Step 5: Uploading to Hetzner ==="

LOG_FILE="$STORAGE/upload-${TIMESTAMP}.log"

cat > /tmp/step5-upload.sh << EOFSTEP5
#!/bin/bash
echo "[$(date +%H:%M:%S)] Uploading to Hetzner..."
rclone copy "$VHDX_FILE" "$HETZNER_REMOTE/" \\
    --progress \\
    --stats 10s \\
    --transfers 4 \\
    --buffer-size 256M \\
    --log-file="$LOG_FILE" \\
    -v
EXIT_CODE=\$?
if [ \$EXIT_CODE -eq 0 ]; then
    echo "[$(date +%H:%M:%S)] ✅ Upload complete!"
else
    echo "[$(date +%H:%M:%S)] ❌ Upload failed!"
    exit 1
fi
EOFSTEP5

chmod +x /tmp/step5-upload.sh

rm -f /tmp/step5.status
log "Starting upload in screen..."
screen -dmS upload-step bash -c "/tmp/step5-upload.sh; echo 'STEP5_DONE' > /tmp/step5.status; exec bash"

log "Waiting for upload to complete..."
log "Monitor with: screen -r upload-step"
log "Check log: tail -f $LOG_FILE"

while [ ! -f /tmp/step5.status ]; do
    sleep 15
    echo -ne "\rUploading...    "
done
echo ""
log "✅ Upload complete!"

# =============================================================================
# STEP 6: VERIFY AND CLEANUP
# =============================================================================

log "=== Step 6: Verification ==="
REMOTE_FILE="$HETZNER_REMOTE/$(basename "$VHDX_FILE")"

if rclone ls "$REMOTE_FILE" &> /dev/null; then
    log "✅ Verification successful!"

    warn "Deleting local VHDX..."
    rm -f "$VHDX_FILE"
    log "✅ Cleanup complete!"
else
    error "❌ Verification failed! Keeping local copy."
    exit 1
fi

# Cleanup temp files
rm -f /tmp/step*.status /tmp/step*.sh

# =============================================================================
# SUMMARY
# =============================================================================

log "=== Summary ==="
log "✅ VHDX uploaded: $REMOTE_FILE"
log "📝 Upload log: $LOG_FILE"
log "💾 Final storage:"
df -h "$STORAGE"

log ""
log "🎉 Phase 1 (VHDX) Complete!"
log ""
log "Next: Create QCOW2 version"
log "Run: ssh fedora-vps \"bash -s\" < vps-management/create-qcow2-version.sh"
