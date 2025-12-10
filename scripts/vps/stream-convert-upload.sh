#!/bin/bash
# Stream conversion - decompress → convert → upload in one pipeline
# ZERO disk usage (except final output on Hetzner)

set -e

SOURCE_GZ="/mnt/storage/windows-backups/win11-direct-stream.img.gz"
HETZNER_DEST="hetzner-storage:windows-backups"

echo "============================================="
echo "Stream Convert & Upload (Zero Disk Usage)"
echo "============================================="
echo ""

cd /mnt/storage/windows-backups

echo "Source: $SOURCE_GZ"
echo "Destination: $HETZNER_DEST"
echo ""

echo "This will:"
echo "  1. Decompress on-the-fly"
echo "  2. Convert to QCOW2 in memory"
echo "  3. Upload directly to Hetzner"
echo "  4. Then do the same for VHDX"
echo ""
echo "⚠️  Limitations:"
echo "  - Can't easily resume if interrupted"
echo "  - No local copies kept"
echo "  - Slower than with temp files"
echo ""

read -p "Continue? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo "Cancelled"
    exit 0
fi

# Method 1: QCOW2 via streaming
echo ""
echo "[1/2] Creating QCOW2 and uploading..."
echo "Time: 1-3 hours"
echo ""

# Decompress → convert → upload
# Using named pipe to avoid disk writes
FIFO_RAW="/tmp/raw-stream.fifo"
FIFO_QCOW2="/tmp/qcow2-stream.fifo"

mkfifo "$FIFO_RAW" "$FIFO_QCOW2"

# Start the pipeline
(
    # Decompress to pipe
    gunzip -c "$SOURCE_GZ" > "$FIFO_RAW"
) &

(
    # Convert from pipe to pipe
    qemu-img convert -f raw -O qcow2 -c "$FIFO_RAW" "$FIFO_QCOW2"
) &

(
    # Upload from pipe
    rclone rcat "$HETZNER_DEST/win11-backup.qcow2" < "$FIFO_QCOW2" --progress --stats 30s
) &

# Wait for all to complete
wait

# Cleanup pipes
rm -f "$FIFO_RAW" "$FIFO_QCOW2"

echo "✓ QCOW2 uploaded"
echo ""

# Method 2: VHDX via streaming
echo "[2/2] Creating VHDX and uploading..."
echo "Time: 1-3 hours"
echo ""

mkfifo "$FIFO_RAW" "$FIFO_QCOW2"

(
    gunzip -c "$SOURCE_GZ" > "$FIFO_RAW"
) &

(
    qemu-img convert -f raw -O vhdx -o subformat=dynamic "$FIFO_RAW" "$FIFO_QCOW2"
) &

(
    rclone rcat "$HETZNER_DEST/win11-backup.vhdx" < "$FIFO_QCOW2" --progress --stats 30s
) &

wait

rm -f "$FIFO_RAW" "$FIFO_QCOW2"

echo "✓ VHDX uploaded"
echo ""

echo "============================================="
echo "✓ Complete!"
echo "============================================="
echo ""
echo "Both formats on Hetzner (no disk space used):"
rclone ls "$HETZNER_DEST/" | grep -E "qcow2|vhdx"
echo ""
echo "Local disk usage unchanged:"
df -h /mnt/storage
