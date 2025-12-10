#!/bin/bash
# Space-efficient conversion - decompress once, convert twice, delete intermediates

set -e

SOURCE_GZ="/mnt/storage/windows-backups/win11-direct-stream.img.gz"
WORK_DIR="/mnt/storage/windows-backups"
BASE_NAME="win11-backup"
RAW_IMG="${BASE_NAME}.img"

echo "============================================="
echo "Space-Efficient Conversion (Optimized)"
echo "============================================="
echo ""

cd "$WORK_DIR"

echo "Source: $SOURCE_GZ ($(du -h "$SOURCE_GZ" | cut -f1))"
echo "Available: $(df -h /mnt/storage | grep /dev/sda | awk '{print $4}')"
echo ""

echo "Process:"
echo "  1. Decompress to raw .img"
echo "  2. Convert to QCOW2, upload, delete QCOW2"
echo "  3. Convert to VHDX, upload, delete VHDX"
echo "  4. Delete raw .img"
echo "  5. Keep original .gz"
echo ""
echo "Starting in 5 seconds..."
sleep 5

# Step 1: Decompress
if [ ! -f "$RAW_IMG" ]; then
    echo ""
    echo "[1/5] Decompressing (30-60 min)..."
    gunzip -c "$SOURCE_GZ" > "$RAW_IMG"
    echo "✓ Raw image: $(du -h "$RAW_IMG" | cut -f1)"
    echo "  Space left: $(df -h /mnt/storage | grep /dev/sda | awk '{print $4}')"
else
    echo "[1/5] Raw image exists ✓"
fi

# Step 2: QCOW2
QCOW2_FILE="${BASE_NAME}.qcow2"
echo ""
echo "[2/5] Converting to QCOW2 (30-90 min)..."
qemu-img convert -f raw -O qcow2 -c -p "$RAW_IMG" "$QCOW2_FILE"
echo "✓ QCOW2: $(du -h "$QCOW2_FILE" | cut -f1)"
echo "  Space left: $(df -h /mnt/storage | grep /dev/sda | awk '{print $4}')"

echo ""
echo "Uploading QCOW2 to Hetzner (2-6 hours)..."
rclone copy "$QCOW2_FILE" hetzner-storage:windows-backups/ --progress --stats 30s
echo "✓ Uploaded"

# Verify and delete
REMOTE_SIZE=$(rclone size hetzner-storage:windows-backups/$QCOW2_FILE --json | grep -o '"bytes":[0-9]*' | cut -d: -f2 || echo "0")
LOCAL_SIZE=$(stat -c%s "$QCOW2_FILE")
if [ "$REMOTE_SIZE" = "$LOCAL_SIZE" ] && [ "$REMOTE_SIZE" != "0" ]; then
    rm -f "$QCOW2_FILE"
    echo "✓ Local QCOW2 deleted"
    echo "  Space freed: $(df -h /mnt/storage | grep /dev/sda | awk '{print $4}')"
fi

# Step 3: VHDX
VHDX_FILE="${BASE_NAME}.vhdx"
echo ""
echo "[3/5] Converting to VHDX (30-90 min)..."
qemu-img convert -f raw -O vhdx -o subformat=dynamic -p "$RAW_IMG" "$VHDX_FILE"
echo "✓ VHDX: $(du -h "$VHDX_FILE" | cut -f1)"
echo "  Space left: $(df -h /mnt/storage | grep /dev/sda | awk '{print $4}')"

echo ""
echo "[4/5] Uploading VHDX to Hetzner (2-6 hours)..."
rclone copy "$VHDX_FILE" hetzner-storage:windows-backups/ --progress --stats 30s
echo "✓ Uploaded"

# Verify and delete
REMOTE_SIZE=$(rclone size hetzner-storage:windows-backups/$VHDX_FILE --json | grep -o '"bytes":[0-9]*' | cut -d: -f2 || echo "0")
LOCAL_SIZE=$(stat -c%s "$VHDX_FILE")
if [ "$REMOTE_SIZE" = "$LOCAL_SIZE" ] && [ "$REMOTE_SIZE" != "0" ]; then
    rm -f "$VHDX_FILE"
    echo "✓ Local VHDX deleted"
    echo "  Space freed: $(df -h /mnt/storage | grep /dev/sda | awk '{print $4}')"
fi

# Step 4: Delete raw image
echo ""
echo "[5/5] Cleaning up raw image..."
rm -f "$RAW_IMG"
echo "✓ Raw image deleted"
echo "  Final space: $(df -h /mnt/storage | grep /dev/sda | awk '{print $4}')"

echo ""
echo "============================================="
echo "✓ Complete!"
echo "============================================="
echo ""
echo "Hetzner Storage Box:"
rclone ls hetzner-storage:windows-backups/ | grep -E "qcow2|vhdx"
echo ""
echo "Local (only .gz kept):"
ls -lh "$WORK_DIR"/*.gz
echo ""
df -h /mnt/storage
echo ""
echo "✨ Done!"
