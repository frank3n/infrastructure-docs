#!/bin/bash
# Ultra space-efficient: Stream decompress → convert → upload
# NO intermediate files stored!

set -e

COMPRESSED="/mnt/storage/windows-backups/win11-direct-stream.img.gz"
STORAGE="/mnt/storage"
HETZNER_REMOTE="hetzner-storage:/windows-backups"
TIMESTAMP=$(date +%Y-%m-%d-%H%M%S)
OUTPUT_NAME="win11-backup-${TIMESTAMP}.vhdx"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +%H:%M:%S)]${NC} $1"; }
warn() { echo -e "${YELLOW}[$(date +%H:%M:%S)]${NC} $1"; }
error() { echo -e "${RED}[$(date +%H:%M:%S)]${NC} $1"; }

log "=== Ultra Space-Efficient Streaming Method ==="
warn "This uses almost NO extra disk space!"
warn "Trade-off: No resume if interrupted"

# Method 1: Direct streaming (most space efficient)
log "Option: Stream through conversion"
warn "If interrupted, you'll need to start over"
warn "But uses minimal disk space!"

read -p "Use streaming method? (y/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    log "=== Streaming: Decompress → Convert → Upload ==="

    # Install needed tools
    if ! command -v qemu-img &> /dev/null; then
        log "Installing qemu-img..."
        sudo dnf install -y qemu-img
    fi

    log "Step 1: Decompress and convert in one go..."
    warn "This creates the VHDX directly"

    # Decompress to pipe, convert directly
    gunzip -c "$COMPRESSED" | \
        qemu-img convert -f raw -O vhdx -o subformat=dynamic - "$STORAGE/$OUTPUT_NAME"

    log "✅ Conversion complete!"

    log "Step 2: Delete compressed file"
    rm -f "$COMPRESSED"
    log "✅ Freed 190GB!"

    log "Step 3: Upload to Hetzner"
    rclone copy "$STORAGE/$OUTPUT_NAME" "$HETZNER_REMOTE/" \
        --progress --stats 10s --transfers 4 -v

    log "Step 4: Verify and cleanup"
    if rclone ls "$HETZNER_REMOTE/$OUTPUT_NAME" &> /dev/null; then
        log "✅ Verified!"
        rm -f "$STORAGE/$OUTPUT_NAME"
        log "✅ All done!"
    else
        error "❌ Upload verification failed!"
        exit 1
    fi
else
    log "Using standard method with intermediate files..."
    log "Running process-win11-backup.sh instead..."
    exec bash "$(dirname "$0")/process-win11-backup.sh"
fi

log "🎉 Complete!"
df -h "$STORAGE"
