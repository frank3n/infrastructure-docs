#!/bin/bash
# Convert disk image to bootable formats and upload to Hetzner

set -e

SOURCE_FILE="/mnt/storage/windows-backups/win11-direct-stream.img.gz"
WORK_DIR="/mnt/storage/windows-backups"
BASE_NAME="win11-backup"

echo "============================================="
echo "Convert to Bootable Formats & Upload"
echo "============================================="
echo ""

cd "$WORK_DIR"

echo "Source: $SOURCE_FILE"
echo "Size: $(du -h "$SOURCE_FILE" | cut -f1)"
echo ""

# Check if qemu-img is installed
if ! command -v qemu-img &> /dev/null; then
    echo "[1/6] Installing qemu-img..."
    sudo dnf install -y qemu-img
    echo "✓ Installed"
    echo ""
else
    echo "[1/6] qemu-img already installed ✓"
    echo ""
fi

# Step 2: Decompress to raw image
RAW_IMG="${BASE_NAME}.img"

if [ ! -f "$RAW_IMG" ]; then
    echo "[2/6] Decompressing to raw image..."
    echo "This will take 30-60 minutes..."
    echo ""

    gunzip -c "$SOURCE_FILE" > "$RAW_IMG"

    echo "✓ Decompressed: $RAW_IMG"
    echo "Size: $(du -h "$RAW_IMG" | cut -f1)"
    echo ""
else
    echo "[2/6] Raw image already exists ✓"
    echo "Size: $(du -h "$RAW_IMG" | cut -f1)"
    echo ""
fi

# Step 3: Convert to QCOW2 (KVM/QEMU format - most versatile)
QCOW2_IMG="${BASE_NAME}.qcow2"

if [ ! -f "$QCOW2_IMG" ]; then
    echo "[3/6] Converting to QCOW2 (KVM/QEMU)..."
    echo "This will take 30-60 minutes..."
    echo ""

    qemu-img convert -f raw -O qcow2 -c -p "$RAW_IMG" "$QCOW2_IMG"

    echo "✓ Created: $QCOW2_IMG"
    echo "Size: $(du -h "$QCOW2_IMG" | cut -f1)"
    echo ""
else
    echo "[3/6] QCOW2 already exists ✓"
    echo "Size: $(du -h "$QCOW2_IMG" | cut -f1)"
    echo ""
fi

# Step 4: Convert to VHDX (Hyper-V format)
VHDX_IMG="${BASE_NAME}.vhdx"

if [ ! -f "$VHDX_IMG" ]; then
    echo "[4/6] Converting to VHDX (Hyper-V)..."
    echo "This will take 30-60 minutes..."
    echo ""

    qemu-img convert -f raw -O vhdx -o subformat=dynamic -p "$RAW_IMG" "$VHDX_IMG"

    echo "✓ Created: $VHDX_IMG"
    echo "Size: $(du -h "$VHDX_IMG" | cut -f1)"
    echo ""
else
    echo "[4/6] VHDX already exists ✓"
    echo "Size: $(du -h "$VHDX_IMG" | cut -f1)"
    echo ""
fi

# Step 5: Upload QCOW2 to Hetzner
echo "[5/6] Uploading QCOW2 to Hetzner Storage Box..."
echo "This will take 2-6 hours..."
echo ""

rclone copy "$QCOW2_IMG" hetzner-storage:windows-backups/ \
    --progress \
    --stats 30s \
    --transfers 4 \
    --checkers 4

echo "✓ QCOW2 uploaded to Hetzner"
echo ""

# Step 6: Upload VHDX to Hetzner
echo "[6/6] Uploading VHDX to Hetzner Storage Box..."
echo "This will take 2-6 hours..."
echo ""

rclone copy "$VHDX_IMG" hetzner-storage:windows-backups/ \
    --progress \
    --stats 30s \
    --transfers 4 \
    --checkers 4

echo "✓ VHDX uploaded to Hetzner"
echo ""

# Summary
echo "============================================="
echo "✓ All Conversions & Uploads Complete!"
echo "============================================="
echo ""

echo "Local files on VPS:"
ls -lh "$WORK_DIR" | grep -E "img|qcow2|vhdx"
echo ""

echo "Files on Hetzner Storage Box:"
rclone ls hetzner-storage:windows-backups/ | grep -E "img|qcow2|vhdx"
echo ""

echo "File formats created:"
echo "  1. ${BASE_NAME}.img.gz    - Compressed raw (original)"
echo "  2. ${BASE_NAME}.img       - Raw disk image"
echo "  3. ${BASE_NAME}.qcow2     - QCOW2 (KVM/QEMU/Proxmox)"
echo "  4. ${BASE_NAME}.vhdx      - VHDX (Hyper-V/Azure)"
echo ""

echo "You can now:"
echo "  - Use QCOW2 with KVM/QEMU/Proxmox"
echo "  - Use VHDX with Hyper-V or Azure"
echo "  - Delete raw .img to save space if needed"
echo ""

echo "Space usage:"
df -h /mnt/storage
echo ""

echo "Done! ✨"
