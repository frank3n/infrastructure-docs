#!/bin/bash
# Direct Stream Disk to VPS (TRUE Zero Local Storage)
# Run from Git Bash as Administrator

set -e

VPS_HOST="138.199.218.115"
VPS_USER="root"
VPS_KEY="C:/2025-claude-code-laptop/projects/vps-management/ssh-keys/fedora-vps-key"
VPS_DEST="/mnt/storage/windows-backups/win11-direct-stream.img.gz"

echo "============================================="
echo "Direct Stream Disk to VPS (Zero Local Space)"
echo "============================================="
echo ""

# Get Windows drive info
echo "Checking disk configuration..."
powershell.exe -Command "Get-Disk | Format-Table Number, FriendlyName, Size, PartitionStyle"
echo ""

read -p "Enter disk number to capture (usually 0): " DISK_NUM

# Convert to /dev/sdX format
DISK_LETTER=$(printf \\$(printf '%03o' $((97 + DISK_NUM))))
DISK_DEV="/dev/sd${DISK_LETTER}"

echo ""
echo "Configuration:"
echo "  Source: $DISK_DEV (Disk $DISK_NUM)"
echo "  Destination: ${VPS_USER}@${VPS_HOST}:${VPS_DEST}"
echo "  Method: dd -> gzip -> ssh -> VPS"
echo ""

# Get disk size
DISK_SIZE=$(powershell.exe -Command "(Get-Disk -Number $DISK_NUM).Size / 1GB")
echo "  Disk size: ${DISK_SIZE} GB"
echo ""

echo "⚠️  WARNING: This will capture the ENTIRE disk including:"
echo "   - EFI partition"
echo "   - Recovery partitions"
echo "   - All data on the disk"
echo ""
echo "⏱️  Estimated time: 4-12 hours"
echo "🔌 Keep computer plugged in and awake"
echo "🌐 Maintain stable internet connection"
echo ""

read -p "Continue? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "Starting stream..."
echo "Press Ctrl+C to abort (will lose partial data)"
echo ""
echo "Progress will be shown below:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Stream with progress monitoring
if command -v pv &> /dev/null; then
    echo "Using pv for progress monitoring..."
    dd if="$DISK_DEV" bs=4M 2>&1 | \
        gzip -1 | \
        pv -s $(powershell.exe -Command "(Get-Disk -Number $DISK_NUM).Size") | \
        ssh -i "$VPS_KEY" -o StrictHostKeyChecking=no "${VPS_USER}@${VPS_HOST}" "cat > '$VPS_DEST'"
else
    echo "Note: Install 'pv' for better progress display"
    echo "Using dd built-in progress..."
    dd if="$DISK_DEV" bs=4M status=progress 2>&1 | \
        gzip -1 | \
        ssh -i "$VPS_KEY" -o StrictHostKeyChecking=no "${VPS_USER}@${VPS_HOST}" "cat > '$VPS_DEST'"
fi

EXIT_CODE=$?

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Stream completed successfully!"
    echo ""

    # Get remote file size
    REMOTE_SIZE=$(ssh -i "$VPS_KEY" "${VPS_USER}@${VPS_HOST}" "stat -c%s '$VPS_DEST' 2>/dev/null || echo 0")
    REMOTE_SIZE_GB=$(echo "scale=2; $REMOTE_SIZE / 1073741824" | bc)

    echo "Remote file: $VPS_DEST"
    echo "Size: ${REMOTE_SIZE_GB} GB (compressed)"
    echo ""
    echo "To restore:"
    echo "  ssh $VPS_USER@$VPS_HOST"
    echo "  gunzip -c $VPS_DEST | dd of=/dev/sdX bs=4M"

else
    echo "❌ Stream failed with exit code: $EXIT_CODE"
    echo "Check your connection and try again."
fi

echo ""
read -p "Press Enter to exit..."
