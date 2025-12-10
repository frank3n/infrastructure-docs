#!/bin/bash
# Space-efficient conversion - streams without keeping raw image

set -e

SOURCE_GZ="/mnt/storage/windows-backups/win11-direct-stream.img.gz"
WORK_DIR="/mnt/storage/windows-backups"
BASE_NAME="win11-backup"

echo "============================================="
echo "Space-Efficient Streaming Conversion"
echo "============================================="
echo ""

cd "$WORK_DIR"

echo "Source: $SOURCE_GZ"
echo "Size: $(du -h "$SOURCE_GZ" | cut -f1)"
echo ""

echo "Available space: $(df -h /mnt/storage | grep /dev/sda | awk '{print $4}')"
echo ""

echo "Strategy:"
echo "  1. Stream decompress → QCOW2 (no raw .img stored)"
echo "  2. Upload QCOW2 to Hetzner"
echo "  3. Delete QCOW2"
echo "  4. Stream decompress → VHDX (no raw .img stored)"
echo "  5. Upload VHDX to Hetzner"
echo "  6. Keep original .gz for safety"
echo ""

# Auto-confirm if run non-interactively
if [ -t 0 ]; then
    read -p "Continue? (yes/no): " CONFIRM
    if [ "$CONFIRM" != "yes" ]; then
        echo "Cancelled."
        exit 0
    fi
else
    echo "Running in non-interactive mode - auto-confirming"
fi

# Step 1: Convert to QCOW2 via streaming
QCOW2_FILE="${BASE_NAME}.qcow2"

if [ ! -f "$QCOW2_FILE" ]; then
    echo ""
    echo "[1/5] Creating QCOW2 via streaming..."
    echo "Time: 30-90 minutes"
    echo ""

    # Stream: gunzip | qemu-img convert from stdin
    gunzip -c "$SOURCE_GZ" | qemu-img convert -f raw -O qcow2 -c -p - "$QCOW2_FILE"

    echo ""
    echo "✓ QCOW2 created: $QCOW2_FILE"
    echo "Size: $(du -h "$QCOW2_FILE" | cut -f1)"
    echo "Space remaining: $(df -h /mnt/storage | grep /dev/sda | awk '{print $4}')"
    echo ""
else
    echo "[1/5] QCOW2 already exists ✓"
    echo ""
fi

# Step 2: Upload QCOW2 to Hetzner
echo "[2/5] Uploading QCOW2 to Hetzner..."
echo "Time: 2-6 hours"
echo ""

rclone copy "$QCOW2_FILE" hetzner-storage:windows-backups/ \
    --progress \
    --stats 30s \
    --transfers 4

echo ""
echo "✓ QCOW2 uploaded to Hetzner"
echo ""

# Step 3: Verify and delete QCOW2 to free space
echo "[3/5] Verifying upload and freeing space..."
REMOTE_SIZE=$(rclone size hetzner-storage:windows-backups/$QCOW2_FILE --json | grep -o '"bytes":[0-9]*' | cut -d: -f2)
LOCAL_SIZE=$(stat -c%s "$QCOW2_FILE")

if [ "$REMOTE_SIZE" = "$LOCAL_SIZE" ]; then
    echo "✓ Sizes match - safe to delete local QCOW2"
    rm -f "$QCOW2_FILE"
    echo "✓ Local QCOW2 deleted to free space"
    echo "Space now: $(df -h /mnt/storage | grep /dev/sda | awk '{print $4}')"
else
    echo "⚠ Size mismatch - keeping local copy for safety"
    echo "Local: $LOCAL_SIZE bytes"
    echo "Remote: $REMOTE_SIZE bytes"
fi
echo ""

# Step 4: Convert to VHDX via streaming
VHDX_FILE="${BASE_NAME}.vhdx"

if [ ! -f "$VHDX_FILE" ]; then
    echo "[4/5] Creating VHDX via streaming..."
    echo "Time: 30-90 minutes"
    echo ""

    # Stream: gunzip | qemu-img convert from stdin
    gunzip -c "$SOURCE_GZ" | qemu-img convert -f raw -O vhdx -o subformat=dynamic -p - "$VHDX_FILE"

    echo ""
    echo "✓ VHDX created: $VHDX_FILE"
    echo "Size: $(du -h "$VHDX_FILE" | cut -f1)"
    echo "Space remaining: $(df -h /mnt/storage | grep /dev/sda | awk '{print $4}')"
    echo ""
else
    echo "[4/5] VHDX already exists ✓"
    echo ""
fi

# Step 5: Upload VHDX to Hetzner
echo "[5/5] Uploading VHDX to Hetzner..."
echo "Time: 2-6 hours"
echo ""

rclone copy "$VHDX_FILE" hetzner-storage:windows-backups/ \
    --progress \
    --stats 30s \
    --transfers 4

echo ""
echo "✓ VHDX uploaded to Hetzner"
echo ""

# Verify and optionally delete VHDX
echo "Verifying VHDX upload..."
REMOTE_SIZE=$(rclone size hetzner-storage:windows-backups/$VHDX_FILE --json | grep -o '"bytes":[0-9]*' | cut -d: -f2)
LOCAL_SIZE=$(stat -c%s "$VHDX_FILE")

if [ "$REMOTE_SIZE" = "$LOCAL_SIZE" ]; then
    echo "✓ Sizes match"
    # Auto-delete to free space when non-interactive
    if [ -t 0 ]; then
        read -p "Delete local VHDX to free space? (yes/no): " DELETE_VHDX
        if [ "$DELETE_VHDX" = "yes" ]; then
            rm -f "$VHDX_FILE"
            echo "✓ Local VHDX deleted"
        fi
    else
        echo "Auto-deleting local VHDX to free space"
        rm -f "$VHDX_FILE"
        echo "✓ Local VHDX deleted"
    fi
else
    echo "⚠ Size mismatch - keeping local copy"
fi

echo ""
echo "============================================="
echo "✓ All Conversions & Uploads Complete!"
echo "============================================="
echo ""

echo "Files on Hetzner Storage Box:"
rclone ls hetzner-storage:windows-backups/ | grep -E "qcow2|vhdx"
echo ""

echo "Local files:"
ls -lh "$WORK_DIR" | grep -E "img.gz|qcow2|vhdx"
echo ""

echo "Space usage:"
df -h /mnt/storage
echo ""

echo "✨ Done!"
