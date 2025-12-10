#!/bin/bash
# Decompress → Convert → Upload to Hetzner workflow
# Space-efficient: Does one operation at a time

set -e  # Exit on error

# Configuration
STORAGE="/mnt/storage"
HETZNER_REMOTE="hetzner-storage:/windows-backups"
TIMESTAMP=$(date +%Y-%m-%d-%H%M%S)

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +%H:%M:%S)]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date +%H:%M:%S)]${NC} $1"
}

error() {
    echo -e "${RED}[$(date +%H:%M:%S)]${NC} $1"
}

check_space() {
    local needed_gb=$1
    local available=$(df -BG "$STORAGE" | tail -1 | awk '{print $4}' | sed 's/G//')
    log "Available space: ${available}GB (need ${needed_gb}GB)"

    if [ "$available" -lt "$needed_gb" ]; then
        error "Not enough space! Need ${needed_gb}GB, have ${available}GB"
        return 1
    fi
}

# Step 1: Find compressed backup
log "=== Step 1: Finding compressed backup ==="
COMPRESSED=$(find "$STORAGE" -maxdepth 1 -type f \( -name "*.zip" -o -name "*.7z" -o -name "*.tar.gz" -o -name "*.tar.xz" \) | head -1)

if [ -z "$COMPRESSED" ]; then
    error "No compressed backup found in $STORAGE"
    exit 1
fi

COMPRESSED_SIZE=$(du -BG "$COMPRESSED" | cut -f1 | sed 's/G//')
log "Found: $COMPRESSED (${COMPRESSED_SIZE}GB)"

# Step 2: Decompress
log "=== Step 2: Decompressing backup ==="
check_space 250  # Need space for decompressed files

EXTRACT_DIR="$STORAGE/extracted"
mkdir -p "$EXTRACT_DIR"

case "$COMPRESSED" in
    *.zip)
        log "Extracting ZIP..."
        unzip -q "$COMPRESSED" -d "$EXTRACT_DIR"
        ;;
    *.7z)
        log "Extracting 7z..."
        7z x "$COMPRESSED" -o"$EXTRACT_DIR" -y
        ;;
    *.tar.gz)
        log "Extracting tar.gz..."
        tar xzf "$COMPRESSED" -C "$EXTRACT_DIR"
        ;;
    *.tar.xz)
        log "Extracting tar.xz..."
        tar xJf "$COMPRESSED" -C "$EXTRACT_DIR"
        ;;
    *)
        error "Unknown compression format"
        exit 1
        ;;
esac

log "Extraction complete!"

# Step 3: Delete compressed file
log "=== Step 3: Removing compressed file to free space ==="
warn "Deleting: $COMPRESSED"
rm -f "$COMPRESSED"
log "Freed up ${COMPRESSED_SIZE}GB"

# Step 4: Find disk image
log "=== Step 4: Finding disk image ==="
DISK_IMAGE=$(find "$EXTRACT_DIR" -type f \( -name "*.vhd" -o -name "*.vhdx" -o -name "*.vmdk" -o -name "*.img" -o -name "*.raw" \) | head -1)

if [ -z "$DISK_IMAGE" ]; then
    error "No disk image found in extracted files"
    find "$EXTRACT_DIR" -type f | head -10
    exit 1
fi

IMAGE_SIZE=$(du -BG "$DISK_IMAGE" | cut -f1 | sed 's/G//')
log "Found disk image: $DISK_IMAGE (${IMAGE_SIZE}GB)"

# Step 5: Convert to VHDX if needed
log "=== Step 5: Converting to VHDX ==="
OUTPUT_VHDX="$STORAGE/windows-backup-${TIMESTAMP}.vhdx"

if [[ "$DISK_IMAGE" == *.vhdx ]]; then
    log "Already VHDX format, moving..."
    mv "$DISK_IMAGE" "$OUTPUT_VHDX"
else
    check_space 250

    log "Installing qemu-img if needed..."
    if ! command -v qemu-img &> /dev/null; then
        sudo dnf install -y qemu-img
    fi

    log "Converting to VHDX (this may take a while)..."
    qemu-img convert -f raw -O vhdx -o subformat=dynamic "$DISK_IMAGE" "$OUTPUT_VHDX" -p
    log "Conversion complete!"
fi

# Step 6: Delete extracted files
log "=== Step 6: Cleaning up extracted files ==="
rm -rf "$EXTRACT_DIR"
log "Freed up space"

# Step 7: Upload to Hetzner
log "=== Step 7: Uploading to Hetzner Storage ==="
FINAL_SIZE=$(du -h "$OUTPUT_VHDX" | cut -f1)
log "VHDX size: $FINAL_SIZE"

check_space 10  # Just need a bit of buffer

log "Starting upload to Hetzner..."
log "Destination: $HETZNER_REMOTE/"

rclone copy "$OUTPUT_VHDX" "$HETZNER_REMOTE/" \
    --progress \
    --stats 10s \
    --transfers 4 \
    --buffer-size 256M \
    --log-file="$STORAGE/upload-${TIMESTAMP}.log" \
    -v

log "Upload complete!"

# Step 8: Verify upload
log "=== Step 8: Verifying upload ==="
REMOTE_FILE="$HETZNER_REMOTE/$(basename "$OUTPUT_VHDX")"
if rclone ls "$REMOTE_FILE" &> /dev/null; then
    log "✅ Verification successful!"

    warn "Deleting local VHDX to free space..."
    rm -f "$OUTPUT_VHDX"
    log "All done! VHDX is now on Hetzner Storage"
else
    error "❌ Upload verification failed! Keeping local copy."
    exit 1
fi

# Summary
log "=== Summary ==="
log "Remote file: $REMOTE_FILE"
log "Upload log: $STORAGE/upload-${TIMESTAMP}.log"
log "Final VPS storage usage:"
df -h "$STORAGE" | tail -1

log "✅ Workflow complete!"
