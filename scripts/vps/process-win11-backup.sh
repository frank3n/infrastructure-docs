#!/bin/bash
# Process win11-direct-stream.img.gz → VHDX → Hetzner
# Space-optimized for tight disk space

set -e

# Configuration
COMPRESSED="/mnt/storage/windows-backups/win11-direct-stream.img.gz"
STORAGE="/mnt/storage"
HETZNER_REMOTE="hetzner-storage:/windows-backups"
TIMESTAMP=$(date +%Y-%m-%d-%H%M%S)

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +%H:%M:%S)]${NC} $1"; }
warn() { echo -e "${YELLOW}[$(date +%H:%M:%S)]${NC} $1"; }
error() { echo -e "${RED}[$(date +%H:%M:%S)]${NC} $1"; }

check_space() {
    df -h "$STORAGE"
    local available=$(df -BG "$STORAGE" | tail -1 | awk '{print $4}' | sed 's/G//')
    log "Available: ${available}GB"

    if [ "$available" -lt 50 ]; then
        error "❌ Less than 50GB free! Risky to continue."
        return 1
    fi
}

log "=== Windows 11 Backup Processing ==="
log "Source: $COMPRESSED"
check_space

# Step 1: Decompress img.gz
log "=== Step 1: Decompressing .img.gz ==="
IMG_FILE="$STORAGE/win11-backup.img"

log "Decompressing with gunzip (streaming to save memory)..."
warn "This will take a while for 190GB..."

# Use pv if available for progress
if command -v pv &> /dev/null; then
    pv "$COMPRESSED" | gunzip > "$IMG_FILE"
else
    gunzip -c "$COMPRESSED" > "$IMG_FILE"
fi

log "✅ Decompression complete!"
log "Image size: $(du -h "$IMG_FILE" | cut -f1)"
check_space

# Step 2: Delete compressed file IMMEDIATELY
log "=== Step 2: Deleting compressed file to free space ==="
warn "Deleting: $COMPRESSED (190GB)"
rm -f "$COMPRESSED"
log "✅ Freed 190GB!"
check_space

# Step 3: Convert to VHDX (dynamic format for space efficiency)
log "=== Step 3: Converting IMG → VHDX ==="
VHDX_FILE="$STORAGE/win11-backup-${TIMESTAMP}.vhdx"

log "Installing qemu-img if needed..."
if ! command -v qemu-img &> /dev/null; then
    sudo dnf install -y qemu-img
fi

log "Converting to dynamic VHDX..."
warn "This may take 30-60 minutes..."

qemu-img convert -f raw -O vhdx \
    -o subformat=dynamic \
    "$IMG_FILE" \
    "$VHDX_FILE" \
    -p

log "✅ Conversion complete!"
log "VHDX size: $(du -h "$VHDX_FILE" | cut -f1)"
check_space

# Step 4: Delete IMG file
log "=== Step 4: Deleting IMG file ==="
warn "Deleting: $IMG_FILE"
rm -f "$IMG_FILE"
log "✅ Freed space!"
check_space

# Step 5: Upload to Hetzner
log "=== Step 5: Uploading to Hetzner ==="
log "Destination: $HETZNER_REMOTE/"

# Create log file
LOG_FILE="$STORAGE/upload-${TIMESTAMP}.log"

rclone copy "$VHDX_FILE" "$HETZNER_REMOTE/" \
    --progress \
    --stats 10s \
    --transfers 4 \
    --buffer-size 256M \
    --log-file="$LOG_FILE" \
    -v

log "✅ Upload complete!"

# Step 6: Verify
log "=== Step 6: Verifying upload ==="
REMOTE_FILE="$HETZNER_REMOTE/$(basename "$VHDX_FILE")"

if rclone ls "$REMOTE_FILE" &> /dev/null; then
    log "✅ Verification successful!"

    warn "Deleting local VHDX..."
    rm -f "$VHDX_FILE"
    log "✅ All done!"
else
    error "❌ Verification failed! Keeping local copy."
    exit 1
fi

# Summary
log "=== Summary ==="
log "✅ File on Hetzner: $REMOTE_FILE"
log "📝 Upload log: $LOG_FILE"
log "💾 Final storage:"
df -h "$STORAGE"

log "🎉 Workflow complete!"
