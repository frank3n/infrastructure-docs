# Rclone with Hetzner Storage Box

## ✅ Configuration Complete

- **Remote Name**: `hetzner-storage`
- **Server**: u516587.your-storagebox.de
- **Username**: u516587
- **Protocol**: SFTP (SSH File Transfer)
- **Port**: 23
- **Status**: ✅ Connected and tested

## 🚀 Quick Start Commands

### List Directories
```bash
ssh fedora-vps "rclone lsd hetzner-storage:"
```

### List All Files
```bash
ssh fedora-vps "rclone ls hetzner-storage:"
```

### Detailed Listing
```bash
ssh fedora-vps "rclone lsl hetzner-storage:"
```

### Check Storage Usage
```bash
ssh fedora-vps "rclone size hetzner-storage:"
```

### Tree View
```bash
ssh fedora-vps "rclone tree hetzner-storage:"
```

## 📤 Upload Files

### Upload Single File
```bash
ssh fedora-vps "rclone copy /path/to/file.txt hetzner-storage:/"
```

### Upload to Specific Folder
```bash
ssh fedora-vps "rclone copy /path/to/file.txt hetzner-storage:/backups/"
```

### Upload Directory
```bash
ssh fedora-vps "rclone copy /path/to/directory hetzner-storage:/mydata/"
```

### Upload with Progress
```bash
ssh fedora-vps "rclone copy /path/to/file hetzner-storage:/ --progress"
```

### Upload Multiple Files
```bash
ssh fedora-vps "rclone copy /source/folder hetzner-storage:/destination/ --transfers 4"
```

## 📥 Download Files

### Download Single File
```bash
ssh fedora-vps "rclone copy hetzner-storage:/file.txt /local/path/"
```

### Download Directory
```bash
ssh fedora-vps "rclone copy hetzner-storage:/backups /local/backups/"
```

### Download with Progress
```bash
ssh fedora-vps "rclone copy hetzner-storage:/large-file.zip /tmp/ --progress -v"
```

## 🔄 Sync & Backup

### One-Way Sync (Local → Hetzner)
```bash
ssh fedora-vps "rclone sync /local/folder hetzner-storage:/backup/"
```

### One-Way Sync (Hetzner → Local)
```bash
ssh fedora-vps "rclone sync hetzner-storage:/backup /local/restore/"
```

### Two-Way Sync (Bidirectional)
```bash
ssh fedora-vps "rclone bisync /local/folder hetzner-storage:/sync/"
```

### Incremental Backup
```bash
ssh fedora-vps "rclone copy /data hetzner-storage:/backup/ --update"
```

### Daily Backup Script
```bash
ssh fedora-vps "rclone sync /important/data hetzner-storage:/daily-backup-$(date +%Y-%m-%d)/"
```

## 📁 Directory Operations

### Create Directory
```bash
ssh fedora-vps "rclone mkdir hetzner-storage:/newfolder"
```

### Delete Directory (and contents)
```bash
ssh fedora-vps "rclone purge hetzner-storage:/oldfolder"
```

### Remove Empty Directories
```bash
ssh fedora-vps "rclone rmdirs hetzner-storage:/ --leave-root"
```

### Copy Between Directories
```bash
ssh fedora-vps "rclone copy hetzner-storage:/source hetzner-storage:/destination"
```

## 🗑️ Delete Operations

### Delete Single File
```bash
ssh fedora-vps "rclone delete hetzner-storage:/file.txt"
```

### Delete Files Matching Pattern
```bash
ssh fedora-vps "rclone delete hetzner-storage:/ --include '*.tmp'"
```

### Delete Old Files (older than 30 days)
```bash
ssh fedora-vps "rclone delete hetzner-storage:/backups --min-age 30d"
```

## 🔍 Search & Filter

### Find Specific Files
```bash
ssh fedora-vps "rclone ls hetzner-storage:/ --include '*.jpg'"
```

### Exclude Patterns
```bash
ssh fedora-vps "rclone copy /data hetzner-storage:/backup/ --exclude '*.tmp' --exclude '*.log'"
```

### Filter by Size
```bash
ssh fedora-vps "rclone ls hetzner-storage:/ --min-size 100M --max-size 1G"
```

## 🔐 Advanced Features

### Mount as Filesystem
```bash
# Install fuse first
ssh fedora-vps "sudo dnf install -y fuse"

# Create mount point
ssh fedora-vps "mkdir -p ~/hetzner-mount"

# Mount
ssh fedora-vps "rclone mount hetzner-storage:/ ~/hetzner-mount --daemon --vfs-cache-mode writes"

# Access files
ssh fedora-vps "ls ~/hetzner-mount"

# Unmount
ssh fedora-vps "fusermount -u ~/hetzner-mount"
```

### Encrypted Uploads (Recommended)
```bash
# Setup encryption (one-time)
ssh fedora-vps "rclone config create hetzner-crypt crypt remote hetzner-storage: password mySecurePassword"

# Use encrypted remote
ssh fedora-vps "rclone copy /sensitive/data hetzner-crypt:"
```

### Compress Before Upload
```bash
ssh fedora-vps "tar czf - /data | rclone rcat hetzner-storage:/backup.tar.gz"
```

### Verify Upload Integrity
```bash
ssh fedora-vps "rclone check /local/path hetzner-storage:/backup/"
```

## 📊 Monitoring & Stats

### Show Transfer Speed
```bash
ssh fedora-vps "rclone copy file.zip hetzner-storage:/ --progress --stats 1s"
```

### Bandwidth Limit
```bash
ssh fedora-vps "rclone copy bigfile.zip hetzner-storage:/ --bwlimit 10M"
```

### Detailed Log
```bash
ssh fedora-vps "rclone copy /data hetzner-storage:/ -v --log-file=/tmp/rclone.log"
```

### Interactive Disk Usage (ncdu)
```bash
ssh fedora-vps "rclone ncdu hetzner-storage:"
```

## 🔄 Copy Between Storages

### Hetzner → Vultr S3
```bash
ssh fedora-vps "rclone copy hetzner-storage:/data vultr-s3:london-vhdx/backup/"
```

### Vultr S3 → Hetzner
```bash
ssh fedora-vps "rclone copy vultr-s3:london-vhdx/file.zip hetzner-storage:/vultr-backup/"
```

### Sync Both Ways
```bash
ssh fedora-vps "rclone sync hetzner-storage:/shared vultr-s3:london-vhdx/shared/"
```

## 🛠️ Useful Flags

| Flag | Description |
|------|-------------|
| `--progress` | Show transfer progress |
| `-v` | Verbose output |
| `--dry-run` | Test without changes |
| `--update` | Skip newer files on destination |
| `--transfers 8` | Parallel transfers (default: 4) |
| `--bwlimit 10M` | Limit bandwidth |
| `--exclude "*.tmp"` | Exclude pattern |
| `--min-age 30d` | Files older than 30 days |
| `--max-age 7d` | Files newer than 7 days |
| `--checksum` | Use checksums for comparison |

## 📝 Automated Backup Script

Create a backup script on the VPS:

```bash
ssh fedora-vps "cat > ~/backup-to-hetzner.sh << 'EOF'
#!/bin/bash
# Automated backup to Hetzner Storage Box

BACKUP_DATE=\$(date +%Y-%m-%d)
SOURCE_DIR=\"/data\"
DEST_DIR=\"hetzner-storage:/backups/\$BACKUP_DATE\"

echo \"Starting backup to Hetzner Storage Box...\"
rclone sync \"\$SOURCE_DIR\" \"\$DEST_DIR\" --progress --log-file=/var/log/hetzner-backup.log

echo \"Backup completed: \$BACKUP_DATE\"
EOF
chmod +x ~/backup-to-hetzner.sh"
```

Run it:
```bash
ssh fedora-vps "~/backup-to-hetzner.sh"
```

## ⏰ Schedule with Cron

```bash
# Edit crontab
ssh fedora-vps "crontab -e"

# Add daily backup at 2 AM
# 0 2 * * * ~/backup-to-hetzner.sh

# Or use systemd timer (better)
ssh fedora-vps "sudo systemctl edit --force --full hetzner-backup.timer"
```

## 🔐 Security Best Practices

1. **Use SSH Keys (Optional)**
   - You can add SSH keys to Hetzner Storage Box
   - More secure than password authentication

2. **Enable Encryption**
   ```bash
   ssh fedora-vps "rclone config create hetzner-encrypted crypt remote hetzner-storage: password your-strong-password"
   ```

3. **Limit Access**
   - Hetzner Storage Box supports sub-accounts
   - Create restricted users for different purposes

4. **Regular Backups**
   - Set up automated backups with cron
   - Keep multiple versions (dated folders)

## 🌐 Direct SFTP Access (Alternative)

You can also access directly via SFTP:

```bash
# Using sftp command
sftp -P 23 u516587@u516587.your-storagebox.de

# Using FileZilla / WinSCP
Host: u516587.your-storagebox.de
Port: 23
Protocol: SFTP
Username: u516587
Password: G3%kvUc8jkhSP^cs
```

## 📊 Hetzner Storage Box Features

- **Protocol Support**: SFTP, SCP, rsync, WebDAV, Samba/CIFS
- **Snapshots**: Daily snapshots (if enabled)
- **Sub-accounts**: Create additional users
- **SSH Keys**: Support for key-based authentication
- **WebDAV**: Access via web browser
- **Samba**: Mount as network drive

## 💾 Storage Information

### Check Your Quota
```bash
ssh fedora-vps "rclone about hetzner-storage:"
```

### Check Current Usage
```bash
ssh fedora-vps "rclone size hetzner-storage:/"
```

### List Largest Files
```bash
ssh fedora-vps "rclone size hetzner-storage:/ --json | jq"
```

## 🆘 Troubleshooting

### Connection Issues
```bash
# Test connection
ssh fedora-vps "rclone lsd hetzner-storage: -vv"

# Test SSH directly
ssh -p 23 u516587@u516587.your-storagebox.de
```

### Slow Transfers
```bash
# Increase parallel transfers
ssh fedora-vps "rclone copy /data hetzner-storage:/ --transfers 16"

# Use compression for small files
ssh fedora-vps "rclone copy /data hetzner-storage:/ --sftp-use-fstat=false"
```

### Permission Denied
- Check credentials in config
- Verify SSH port (23, not 22)
- Test with direct SFTP connection

## 📚 Quick Reference

```bash
# List
rclone lsd hetzner-storage:           # Directories
rclone ls hetzner-storage:            # Files
rclone tree hetzner-storage:          # Tree view

# Upload
rclone copy /local hetzner-storage:/  # Copy files
rclone sync /local hetzner-storage:/  # Mirror

# Download
rclone copy hetzner-storage:/ /local  # Copy files
rclone sync hetzner-storage:/ /local  # Mirror

# Info
rclone size hetzner-storage:/         # Show size
rclone about hetzner-storage:         # Show quota
rclone check /local hetzner-storage:/ # Verify
```

## 🔗 Your Configuration

```
Remote: hetzner-storage
Server: u516587.your-storagebox.de
User: u516587
Port: 23
Protocol: SFTP
Status: ✅ Connected and tested
```

## 📖 More Information

- Hetzner Storage Box: https://www.hetzner.com/storage/storage-box
- Hetzner Docs: https://docs.hetzner.com/robot/storage-box/
- Rclone SFTP: https://rclone.org/sftp/
