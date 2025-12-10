#!/bin/bash
# Resume decompression in screen session (prevents SSH timeout)

set -e

COMPRESSED="/mnt/storage/windows-backups/win11-direct-stream.img.gz"
IMG_FILE="/mnt/storage/win11-backup.img"
STORAGE="/mnt/storage"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +%H:%M:%S)]${NC} $1"; }
warn() { echo -e "${YELLOW}[$(date +%H:%M:%S)]${NC} $1"; }
error() { echo -e "${RED}[$(date +%H:%M:%S)]${NC} $1"; }

log "=== Resuming Decompression with Screen ==="

# Check current state
if [ -f "$IMG_FILE" ]; then
    CURRENT_SIZE=$(stat -c%s "$IMG_FILE")
    CURRENT_GB=$((CURRENT_SIZE / 1024 / 1024 / 1024))
    warn "Found existing IMG file: ${CURRENT_GB}GB"
    warn "Deleting to restart cleanly..."
    rm -f "$IMG_FILE"
fi

# Check space
df -h "$STORAGE"
AVAILABLE=$(df -BG "$STORAGE" | tail -1 | awk '{print $4}' | sed 's/G//')
log "Available space: ${AVAILABLE}GB"

if [ "$AVAILABLE" -lt 200 ]; then
    error "Need at least 200GB free!"
    exit 1
fi

# Install screen if needed
if ! command -v screen &> /dev/null; then
    log "Installing screen..."
    sudo dnf install -y screen
fi

# Install pv for progress monitoring
if ! command -v pv &> /dev/null; then
    log "Installing pv (for progress bar)..."
    sudo dnf install -y pv
fi

log "Starting decompression in screen session..."
log "Session name: decompress-win11"

# Create a script for screen to run
cat > /tmp/decompress-script.sh << 'EOFSCRIPT'
#!/bin/bash
echo "[$(date +%H:%M:%S)] Starting decompression..."
echo "[$(date +%H:%M:%S)] Source: /mnt/storage/windows-backups/win11-direct-stream.img.gz"
echo "[$(date +%H:%M:%S)] Output: /mnt/storage/win11-backup.img"
echo ""

# Get compressed file size
COMPRESSED_SIZE=$(stat -c%s "/mnt/storage/windows-backups/win11-direct-stream.img.gz")
echo "Compressed size: $((COMPRESSED_SIZE / 1024 / 1024 / 1024))GB"
echo ""

# Decompress with progress bar
pv -pterb "/mnt/storage/windows-backups/win11-direct-stream.img.gz" | gunzip > /mnt/storage/win11-backup.img

EXIT_CODE=$?
echo ""
echo "[$(date +%H:%M:%S)] Decompression completed with exit code: $EXIT_CODE"

if [ $EXIT_CODE -eq 0 ]; then
    FINAL_SIZE=$(du -h /mnt/storage/win11-backup.img | cut -f1)
    echo "[$(date +%H:%M:%S)] Final IMG size: $FINAL_SIZE"
    echo "[$(date +%H:%M:%S)] SUCCESS!"
else
    echo "[$(date +%H:%M:%S)] FAILED!"
fi

echo ""
echo "Press Ctrl+A then D to detach from screen"
echo "Or wait 10 seconds for auto-exit..."
sleep 10
EOFSCRIPT

chmod +x /tmp/decompress-script.sh

# Start screen session
screen -dmS decompress-win11 bash /tmp/decompress-script.sh

log "✅ Screen session started!"
log ""
log "Monitor progress with:"
log "  ssh fedora-vps 'screen -r decompress-win11'"
log ""
log "Detach from screen: Ctrl+A then D"
log ""
log "Check if running:"
log "  ssh fedora-vps 'screen -ls'"
log ""
log "Check IMG growth:"
log "  watch -n 10 'ssh fedora-vps \"du -h /mnt/storage/win11-backup.img\"'"

sleep 2

# Show initial progress
log "Initial status:"
screen -ls
echo ""
df -h "$STORAGE"
