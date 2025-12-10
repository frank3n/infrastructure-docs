#!/bin/bash
# Check conversion progress

echo "============================================="
echo "Conversion & Upload Status"
echo "============================================="
echo ""

echo "=== Process Status ==="
ssh fedora-vps "ps aux | grep -E 'convert-and-upload|qemu-img|gunzip|rclone' | grep -v grep" || echo "No active conversion processes"
echo ""

echo "=== Latest Log Output ==="
ssh fedora-vps "tail -20 /tmp/convert-upload.log"
echo ""

echo "=== Files on VPS ==="
ssh fedora-vps "ls -lh /mnt/storage/windows-backups/ | grep -E 'img|qcow2|vhdx'"
echo ""

echo "=== VPS Storage Space ==="
ssh fedora-vps "df -h /mnt/storage"
echo ""

echo "=== Files on Hetzner ==="
echo "(This may be empty until upload starts)"
ssh fedora-vps "rclone ls hetzner-storage:windows-backups/ 2>/dev/null | tail -10" || echo "No files yet"
echo ""

echo "============================================="
echo "To follow live progress:"
echo "  ssh fedora-vps \"tail -f /tmp/convert-upload.log\""
echo "============================================="
