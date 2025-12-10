# VPS Storage Configuration

## 💾 Storage Overview

### Drives

| Device | Size | Mount Point | Filesystem | Purpose |
|--------|------|-------------|------------|---------|
| /dev/sda | 500 GB | /mnt/storage | ext4 | Data storage |
| /dev/sdb1 | 75 GB | / | ext4 | System root |
| /dev/sdb14 | 64 MB | /boot/efi | vfat | EFI boot |

### Storage Summary

```
System Drive: 75 GB (7% used)
Data Drive:   500 GB (467 GB available)
Total:        575 GB
```

## 📁 Primary Storage: /mnt/storage

**Location**: `/mnt/storage`
**Size**: 500 GB
**Available**: 467 GB
**Filesystem**: ext4
**Status**: ✅ Permanently mounted

### Usage

```bash
# Access the storage
cd /mnt/storage

# Check space
df -h /mnt/storage

# Create directories
sudo mkdir -p /mnt/storage/backups
sudo mkdir -p /mnt/storage/data
sudo mkdir -p /mnt/storage/downloads
```

### Permissions

```bash
# Make writable by current user
sudo chown -R $USER:$USER /mnt/storage

# Or make writable by all users
sudo chmod 777 /mnt/storage
```

## 🔧 Configuration

### fstab Entry

```
/dev/disk/by-id/scsi-0HC_Volume_104162016 /mnt/storage ext4 discard,nofail,defaults 0 0
```

**Location**: `/etc/fstab`
**Backup**: `/etc/fstab.backup`

### Mount Options Explained

- `discard`: Enables TRIM for SSD optimization
- `nofail`: System boots even if drive fails to mount
- `defaults`: Standard mount options (rw, suid, dev, exec, auto, nouser, async)

## 📊 Storage Commands

### Check Disk Usage

```bash
# Overall usage
ssh fedora-vps "df -h"

# Storage drive only
ssh fedora-vps "df -h /mnt/storage"

# Detailed usage by directory
ssh fedora-vps "du -h --max-depth=1 /mnt/storage | sort -hr"
```

### Check Disk Health

```bash
# SMART status (if available)
ssh fedora-vps "sudo smartctl -a /dev/sda"

# Filesystem check (unmounted only)
ssh fedora-vps "sudo fsck -n /dev/sda"
```

### Monitor Disk I/O

```bash
# Real-time I/O stats
ssh fedora-vps "iostat -x 1"

# Per-process I/O
ssh fedora-vps "sudo iotop"
```

## 🔄 Remount if Needed

```bash
# Remount all from fstab
ssh fedora-vps "sudo mount -a"

# Remount specific drive
ssh fedora-vps "sudo mount /mnt/storage"

# Unmount
ssh fedora-vps "sudo umount /mnt/storage"
```

## 🗂️ Recommended Directory Structure

```
/mnt/storage/
├── backups/          # Backup data
├── data/             # General data storage
├── downloads/        # Download cache
├── media/            # Media files
├── projects/         # Project files
├── rclone-cache/     # Rclone mount cache
└── temp/             # Temporary files
```

Create structure:
```bash
ssh fedora-vps "sudo mkdir -p /mnt/storage/{backups,data,downloads,media,projects,rclone-cache,temp}"
```

## 💡 Usage Examples

### Backup to Storage Drive

```bash
# Local backup
ssh fedora-vps "rsync -av /home/ /mnt/storage/backups/home/"

# Rclone backup
ssh fedora-vps "rclone sync /data /mnt/storage/backups/data/"
```

### Download to Storage

```bash
# Download directly to storage
ssh fedora-vps "cd /mnt/storage/downloads && wget https://example.com/file.zip"

# Rclone download
ssh fedora-vps "rclone copy hetzner-storage:file.zip /mnt/storage/downloads/"
```

### Use as Rclone Mount Cache

```bash
# Mount with cache on storage drive
ssh fedora-vps "rclone mount hetzner-storage:/ /mnt/hetzner --cache-dir=/mnt/storage/rclone-cache --vfs-cache-mode writes"
```

## 🔐 Security

### Set Permissions

```bash
# Owner only (700)
ssh fedora-vps "sudo chmod 700 /mnt/storage/backups"

# Owner and group (750)
ssh fedora-vps "sudo chmod 750 /mnt/storage/data"

# Everyone (755 - read/execute, owner write)
ssh fedora-vps "sudo chmod 755 /mnt/storage/downloads"
```

### Encryption (Optional)

If you need encryption, consider:
- LUKS full disk encryption
- EncFS for directory encryption
- Rclone crypt for cloud sync

## 🆘 Troubleshooting

### Drive Not Mounting

```bash
# Check fstab syntax
ssh fedora-vps "sudo mount -a"

# Check for errors
ssh fedora-vps "sudo dmesg | grep sda"

# Manual mount
ssh fedora-vps "sudo mount /dev/sda /mnt/storage"
```

### Out of Space

```bash
# Find large files
ssh fedora-vps "sudo find /mnt/storage -type f -size +1G -exec ls -lh {} \\;"

# Find large directories
ssh fedora-vps "sudo du -h /mnt/storage | sort -rh | head -20"

# Clean temp files
ssh fedora-vps "sudo rm -rf /mnt/storage/temp/*"
```

### Performance Issues

```bash
# Check I/O wait
ssh fedora-vps "top"  # Look at 'wa' in CPU line

# Check disk stats
ssh fedora-vps "iostat -x 1 5"

# Check for disk errors
ssh fedora-vps "sudo dmesg | grep -i error"
```

## 📈 Monitoring

### Disk Space Alert Script

```bash
ssh fedora-vps "cat > ~/check-storage.sh << 'EOF'
#!/bin/bash
USAGE=\$(df -h /mnt/storage | awk 'NR==2 {print \$5}' | sed 's/%//')
if [ \$USAGE -gt 90 ]; then
    echo \"WARNING: Storage is \${USAGE}% full\"
fi
EOF
chmod +x ~/check-storage.sh"
```

### Add to Cron

```bash
# Check daily
ssh fedora-vps "crontab -e"
# Add: 0 9 * * * /root/check-storage.sh
```

## 🔗 Integration with Services

### Use with Docker

```bash
# Store Docker volumes on storage drive
ssh fedora-vps "sudo mkdir -p /mnt/storage/docker"
# Update Docker daemon.json to use /mnt/storage/docker
```

### Use with Rclone

```bash
# Cache directory
--cache-dir=/mnt/storage/rclone-cache

# Temp directory
--temp-dir=/mnt/storage/temp
```

## ✅ Verification

**Current Status:**
```bash
ssh fedora-vps "df -h /mnt/storage"
```

**Expected Output:**
```
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda        492G   28K  467G   1% /mnt/storage
```

**Test Write:**
```bash
ssh fedora-vps "echo 'test' | sudo tee /mnt/storage/test.txt && cat /mnt/storage/test.txt && rm /mnt/storage/test.txt"
```

---

**Storage is ready to use!** 🎉

Access it at: `/mnt/storage`
