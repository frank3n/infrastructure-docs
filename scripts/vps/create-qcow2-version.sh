#!/bin/bash
# Create QCOW2 version after VHDX is done
# Run this AFTER process-win11-backup.sh completes

set -e

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

log "=== Creating QCOW2 Version ==="

# Check if IMG file still exists
if [ -f "$STORAGE/win11-backup.img" ]; then
    log "✅ Found IMG file, converting directly to QCOW2"
    SOURCE="$STORAGE/win11-backup.img"
    SOURCE_FORMAT="raw"
else
    log "IMG file deleted, looking for VHDX..."

    # Find the VHDX file
    VHDX=$(find "$STORAGE" -name "*.vhdx" -type f | head -1)

    if [ -z "$VHDX" ]; then
        # Check Hetzner storage
        log "Checking Hetzner storage..."
        REMOTE_VHDX=$(rclone lsf hetzner-storage:/windows-backups/ | grep .vhdx | head -1)

        if [ -n "$REMOTE_VHDX" ]; then
            log "Found VHDX on Hetzner: $REMOTE_VHDX"
            log "Downloading for conversion..."
            rclone copy "hetzner-storage:/windows-backups/$REMOTE_VHDX" "$STORAGE/" --progress
            SOURCE="$STORAGE/$REMOTE_VHDX"
            SOURCE_FORMAT="vhdx"
        else
            error "❌ No source file found!"
            exit 1
        fi
    else
        log "✅ Found local VHDX: $VHDX"
        SOURCE="$VHDX"
        SOURCE_FORMAT="vhdx"
    fi
fi

log "Source: $SOURCE"
log "Format: $SOURCE_FORMAT"

# Check space
df -h "$STORAGE"
AVAILABLE=$(df -BG "$STORAGE" | tail -1 | awk '{print $4}' | sed 's/G//')
log "Available: ${AVAILABLE}GB"

if [ "$AVAILABLE" -lt 100 ]; then
    error "❌ Less than 100GB free!"
    exit 1
fi

# Convert to QCOW2
log "=== Converting to QCOW2 ==="
QCOW2_FILE="$STORAGE/win11-backup-${TIMESTAMP}.qcow2"

warn "Converting with compression (smaller file size)..."
log "This may take 30-60 minutes..."

qemu-img convert -f "$SOURCE_FORMAT" -O qcow2 \
    -o compression_type=zstd \
    -o cluster_size=64k \
    "$SOURCE" \
    "$QCOW2_FILE" \
    -p

log "✅ Conversion complete!"
QCOW2_SIZE=$(du -h "$QCOW2_FILE" | cut -f1)
log "QCOW2 size: $QCOW2_SIZE"

# Upload to Hetzner
log "=== Uploading QCOW2 to Hetzner ==="
LOG_FILE="$STORAGE/upload-qcow2-${TIMESTAMP}.log"

rclone copy "$QCOW2_FILE" "$HETZNER_REMOTE/" \
    --progress \
    --stats 10s \
    --transfers 4 \
    --buffer-size 256M \
    --log-file="$LOG_FILE" \
    -v

log "✅ Upload complete!"

# Verify
log "=== Verifying upload ==="
REMOTE_FILE="$HETZNER_REMOTE/$(basename "$QCOW2_FILE")"

if rclone ls "$REMOTE_FILE" &> /dev/null; then
    log "✅ Verification successful!"

    warn "Deleting local QCOW2..."
    rm -f "$QCOW2_FILE"

    # Clean up source if it was downloaded VHDX
    if [ "$SOURCE_FORMAT" = "vhdx" ] && [[ "$SOURCE" == *"$STORAGE"* ]]; then
        warn "Deleting downloaded VHDX..."
        rm -f "$SOURCE"
    fi

    log "✅ All done!"
else
    error "❌ Verification failed! Keeping local copy."
    exit 1
fi

# Summary
log "=== Summary ==="
log "✅ VHDX on Hetzner: Check hetzner-storage:/windows-backups/"
log "✅ QCOW2 on Hetzner: $REMOTE_FILE"
log "📝 Upload log: $LOG_FILE"
log "💾 Final storage:"
df -h "$STORAGE"

log "=== Files on Hetzner ==="
rclone ls "$HETZNER_REMOTE/" | grep -E "\.vhdx|\.qcow2"

log "🎉 Both formats available!"
