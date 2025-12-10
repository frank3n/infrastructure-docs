# Decompress → Convert → Upload Workflow

## Overview

Space-efficient workflow for processing Windows backup on VPS with 500GB storage.

**Your Setup:**
- Source: C drive backup (< 200GB compressed)
- VPS Storage: 500GB at /mnt/storage
- Destination: Hetzner Storage Box

**Space Usage at Each Step:**
```
1. Compressed uploaded    → ~200GB used
2. Decompressed          → ~400GB used (peak)
3. Delete compressed     → ~200GB used
4. Convert to VHDX       → ~400GB used (peak)
5. Delete intermediate   → ~200GB used
6. Upload & delete       → ~0GB used
```

## ✅ Automated Script (SSH Timeout-Safe)

Upload your compressed backup to VPS first, then run:

```bash
# Upload compressed backup to VPS
scp -i vps-management/ssh-keys/fedora-vps-key your-backup.zip root@138.199.218.115:/mnt/storage/

# Run the automated script (uses screen sessions - won't die on SSH timeout)
ssh fedora-vps "bash -s" < vps-management/process-win11-backup-safe.sh
```

**⚡ SSH Timeout Protection:**
- Uses `screen` sessions for long operations
- Won't fail if your SSH connection drops
- Can monitor progress anytime with `screen -r`

The script will:
1. Find your compressed backup
2. Decompress it (in screen session)
3. Delete compressed file (free space)
4. Convert to VHDX (in screen session)
5. Delete intermediate files (free space)
6. Upload to Hetzner (in screen session)
7. Verify and delete local copy

## 📋 Manual Step-by-Step (If You Prefer Control)

### ⚡ Pro Tip: Use Screen for Long Operations

**Prevent SSH timeouts for long-running commands:**

```bash
# Start a screen session
ssh fedora-vps
screen -S mywork

# Run your long commands here
# If SSH disconnects, reconnect and resume:
ssh fedora-vps
screen -r mywork

# Detach without stopping: Ctrl+A then D
# List sessions: screen -ls
# Kill session: screen -X -S mywork quit
```

### Step 1: Upload Compressed Backup

**Option A: From Windows (SCP)**
```powershell
scp -i C:\2025-claude-code-laptop\projects\vps-management\ssh-keys\fedora-vps-key `
    D:\your-backup.zip `
    root@138.199.218.115:/mnt/storage/
```

**Option B: Via mounted X: drive**
```powershell
# If X: is mounted via SSHFS
copy D:\your-backup.zip X:\
```

**Option C: Using rclone (if configured)**
```bash
rclone copy D:\your-backup.zip fedora-vps:/mnt/storage/ --progress
```

### Step 2: Connect to VPS and Check Space

```bash
ssh fedora-vps
df -h /mnt/storage
```

### Step 3: Decompress

**For ZIP:**
```bash
cd /mnt/storage
unzip your-backup.zip -d extracted/
```

**For 7z:**
```bash
# Install 7z if needed
sudo dnf install -y p7zip

# Extract
7z x your-backup.7z -o/mnt/storage/extracted/
```

**For tar.gz:**
```bash
tar xzf your-backup.tar.gz -C /mnt/storage/extracted/
```

**For tar.xz:**
```bash
tar xJf your-backup.tar.xz -C /mnt/storage/extracted/
```

### Step 4: Delete Compressed File

```bash
# Check what you're deleting
ls -lh /mnt/storage/*.zip

# Delete to free space
rm /mnt/storage/your-backup.zip

# Check freed space
df -h /mnt/storage
```

### Step 5: Find Disk Image

```bash
# Find the disk image
find /mnt/storage/extracted -type f \( -name "*.vhd" -o -name "*.vhdx" -o -name "*.vmdk" -o -name "*.img" \)

# Check size
du -h /mnt/storage/extracted/*.vhdx
```

### Step 6: Convert to VHDX (if needed)

**If already VHDX:**
```bash
mv /mnt/storage/extracted/disk.vhdx /mnt/storage/windows-backup.vhdx
```

**If VHD/VMDK/IMG:**
```bash
# Install qemu-img
sudo dnf install -y qemu-img

# Convert to VHDX
qemu-img convert -f raw -O vhdx \
    -o subformat=dynamic \
    /mnt/storage/extracted/disk.img \
    /mnt/storage/windows-backup.vhdx \
    -p
```

### Step 7: Delete Intermediate Files

```bash
# Remove extracted directory
rm -rf /mnt/storage/extracted/

# Check space
df -h /mnt/storage
```

### Step 8: Upload to Hetzner

```bash
# Upload with progress
rclone copy /mnt/storage/windows-backup.vhdx hetzner-storage:/windows-backups/ \
    --progress \
    --stats 10s \
    --transfers 4 \
    --buffer-size 256M \
    -v

# Verify upload
rclone ls hetzner-storage:/windows-backups/
```

### Step 9: Verify and Cleanup

```bash
# Check file is on Hetzner
rclone ls hetzner-storage:/windows-backups/windows-backup.vhdx

# If verified, delete local copy
rm /mnt/storage/windows-backup.vhdx

# Final space check
df -h /mnt/storage
```

## 🚀 Quick Commands Reference

### Check Space at Any Time
```bash
ssh fedora-vps "df -h /mnt/storage"
```

### Monitor Upload Progress
```bash
ssh fedora-vps "rclone size hetzner-storage:/windows-backups/"
```

### List Files on Hetzner
```bash
ssh fedora-vps "rclone ls hetzner-storage:/windows-backups/"
```

### Check Upload Log
```bash
ssh fedora-vps "tail -f /mnt/storage/upload-*.log"
```

## 📊 Disk Format Conversion Options

### Convert VHD → VHDX
```bash
qemu-img convert -f vpc -O vhdx disk.vhd disk.vhdx -p
```

### Convert VMDK → VHDX
```bash
qemu-img convert -f vmdk -O vhdx disk.vmdk disk.vhdx -p
```

### Convert IMG/RAW → VHDX
```bash
qemu-img convert -f raw -O vhdx disk.img disk.vhdx -p
```

### Dynamic VHDX (Space-Efficient)
```bash
qemu-img convert -f raw -O vhdx -o subformat=dynamic disk.img disk.vhdx -p
```

### Fixed VHDX (Better Performance)
```bash
qemu-img convert -f raw -O vhdx -o subformat=fixed disk.img disk.vhdx -p
```

## 🔍 Troubleshooting

### Not Enough Space Error

**Check current usage:**
```bash
ssh fedora-vps "df -h /mnt/storage"
ssh fedora-vps "du -sh /mnt/storage/*"
```

**Clear space:**
```bash
# Remove old files
ssh fedora-vps "rm -rf /mnt/storage/extracted/"
ssh fedora-vps "rm /mnt/storage/*.zip"
```

### Conversion is Too Slow

**Check progress:**
```bash
# In another terminal
ssh fedora-vps "watch -n 5 'du -h /mnt/storage/windows-backup.vhdx'"
```

**Use screen/tmux for long operations:**
```bash
ssh fedora-vps
screen  # or tmux
# Run conversion
# Detach: Ctrl+A, D
```

### Upload Failed or Interrupted

**Resume upload:**
```bash
# Rclone will skip already uploaded parts
ssh fedora-vps "rclone copy /mnt/storage/windows-backup.vhdx hetzner-storage:/windows-backups/ --progress"
```

**Verify what's uploaded:**
```bash
ssh fedora-vps "rclone check /mnt/storage/windows-backup.vhdx hetzner-storage:/windows-backups/"
```

## 💡 Pro Tips

### 1. Use Screen for Long Operations
```bash
ssh fedora-vps
screen -S backup
# Run your operations
# Detach: Ctrl+A, D
# Reattach: screen -r backup
```

### 2. Monitor from Windows
```bash
# Monitor disk space
watch -n 5 ssh fedora-vps "df -h /mnt/storage"

# Monitor upload progress
watch -n 10 ssh fedora-vps "rclone size hetzner-storage:/windows-backups/"
```

### 3. Parallel Compression (Faster)
```bash
# Use pigz instead of gzip
sudo dnf install -y pigz
tar --use-compress-program=pigz -xf backup.tar.gz
```

### 4. Direct Stream to Avoid Local Storage
```bash
# Advanced: Stream directly from Windows to VPS to Hetzner
# (requires more setup, but uses less space)
```

## 📁 Expected File Structure

**Before:**
```
/mnt/storage/
├── your-backup.zip          (200GB)
└── (free space: 300GB)
```

**During Decompression:**
```
/mnt/storage/
├── your-backup.zip          (200GB)
├── extracted/
│   └── disk.vhdx           (180GB)
└── (free space: 120GB)
```

**After Compression Delete:**
```
/mnt/storage/
├── extracted/
│   └── disk.vhdx           (180GB)
└── (free space: 320GB)
```

**After Conversion:**
```
/mnt/storage/
├── windows-backup.vhdx      (180GB)
└── (free space: 320GB)
```

**After Upload:**
```
/mnt/storage/
└── (free space: 500GB)

hetzner-storage:/windows-backups/
└── windows-backup.vhdx      (180GB)
```

## 🔐 Security Notes

- Backups contain sensitive data - keep credentials secure
- Consider encrypting VHDX before upload
- Use strong passwords for Hetzner storage
- Delete local copies after verified upload

## 📝 Checklist

- [ ] VPS storage mounted: `df -h /mnt/storage`
- [ ] Rclone configured: `ssh fedora-vps "rclone lsd hetzner-storage:"`
- [ ] Backup uploaded to VPS
- [ ] Run automated script or follow manual steps
- [ ] Verify upload to Hetzner
- [ ] Delete local copy from VPS
- [ ] Confirm Hetzner storage: `rclone ls hetzner-storage:/windows-backups/`

## ⚡ Ultra-Fast Workflow (One Command)

```bash
# Upload and process in one go
scp -i vps-management/ssh-keys/fedora-vps-key your-backup.zip root@138.199.218.115:/mnt/storage/ && \
ssh fedora-vps "bash -s" < vps-management/decompress-convert-upload.sh
```

## 📞 Need Help?

Check logs:
```bash
ssh fedora-vps "ls -lh /mnt/storage/*.log"
ssh fedora-vps "tail -100 /mnt/storage/upload-*.log"
```

Monitor in real-time:
```bash
ssh fedora-vps "tail -f /mnt/storage/upload-*.log"
```
