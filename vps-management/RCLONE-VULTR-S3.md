# Rclone with Vultr S3 Storage

## ✅ Configuration Complete

- **Remote Name**: `vultr-s3`
- **Location**: London (lhr1)
- **Endpoint**: lhr1.vultrobjects.com
- **Status**: ✅ Connected and tested

## 📦 Your Storage

**Bucket**: `london-vhdx`
**Contents**: DESKTOP-c.VHDX (239 GB)

## 🚀 Common Commands

### List Buckets
```bash
ssh fedora-vps "rclone lsd vultr-s3:"
```

### List Files in Bucket
```bash
ssh fedora-vps "rclone ls vultr-s3:london-vhdx"
```

### Detailed Listing (with dates/sizes)
```bash
ssh fedora-vps "rclone lsl vultr-s3:london-vhdx"
```

### Check Storage Usage
```bash
ssh fedora-vps "rclone size vultr-s3:london-vhdx"
```

## 📤 Upload Files

### Upload Single File
```bash
ssh fedora-vps "rclone copy /path/to/file.txt vultr-s3:london-vhdx/"
```

### Upload Directory
```bash
ssh fedora-vps "rclone copy /path/to/directory vultr-s3:london-vhdx/folder/"
```

### Upload with Progress
```bash
ssh fedora-vps "rclone copy /path/to/file vultr-s3:london-vhdx/ --progress"
```

### Sync Directory (mirror)
```bash
ssh fedora-vps "rclone sync /local/path vultr-s3:london-vhdx/backup/"
```

## 📥 Download Files

### Download Single File
```bash
ssh fedora-vps "rclone copy vultr-s3:london-vhdx/DESKTOP-c.VHDX /local/path/"
```

### Download with Progress Bar
```bash
ssh fedora-vps "rclone copy vultr-s3:london-vhdx/file.txt /tmp/ --progress -v"
```

### Download Entire Bucket
```bash
ssh fedora-vps "rclone sync vultr-s3:london-vhdx /local/backup/"
```

## 🔄 Sync & Backup

### One-Way Sync (Local → S3)
```bash
ssh fedora-vps "rclone sync /local/folder vultr-s3:london-vhdx/backup/"
```

### Two-Way Sync (Bidirectional)
```bash
ssh fedora-vps "rclone bisync /local/folder vultr-s3:london-vhdx/sync/"
```

### Incremental Backup
```bash
ssh fedora-vps "rclone copy /data vultr-s3:london-vhdx/backup/ --update --checksum"
```

## 🗑️ Delete Operations

### Delete Single File
```bash
ssh fedora-vps "rclone delete vultr-s3:london-vhdx/filename.txt"
```

### Delete Directory
```bash
ssh fedora-vps "rclone purge vultr-s3:london-vhdx/old-folder/"
```

### Clean Empty Directories
```bash
ssh fedora-vps "rclone rmdirs vultr-s3:london-vhdx/ --leave-root"
```

## 🔍 Advanced Operations

### Mount S3 as Filesystem (requires FUSE)
```bash
ssh fedora-vps "mkdir -p ~/s3-mount"
ssh fedora-vps "rclone mount vultr-s3:london-vhdx ~/s3-mount --daemon --vfs-cache-mode writes"
```

### Unmount
```bash
ssh fedora-vps "fusermount -u ~/s3-mount"
```

### Check Differences (Dry Run)
```bash
ssh fedora-vps "rclone sync /source vultr-s3:london-vhdx/dest/ --dry-run -v"
```

### Copy with Bandwidth Limit
```bash
ssh fedora-vps "rclone copy file.zip vultr-s3:london-vhdx/ --bwlimit 10M"
```

### Encrypt Files During Upload
```bash
# First set up crypt remote (one-time setup)
ssh fedora-vps "rclone config create vultr-crypt crypt remote vultr-s3:london-vhdx password your_password"

# Then copy with encryption
ssh fedora-vps "rclone copy /data vultr-crypt:"
```

## 📊 Monitoring & Stats

### Show Transfer Progress
```bash
ssh fedora-vps "rclone copy file.zip vultr-s3:london-vhdx/ --progress --stats 1s"
```

### Detailed Transfer Info
```bash
ssh fedora-vps "rclone copy file.zip vultr-s3:london-vhdx/ -v --stats-one-line"
```

### Check File Integrity
```bash
ssh fedora-vps "rclone check /local/path vultr-s3:london-vhdx/"
```

## 🛠️ Useful Flags

| Flag | Description |
|------|-------------|
| `--progress` | Show progress during transfer |
| `-v` | Verbose output |
| `-vv` | Very verbose (debug) |
| `--dry-run` | Test without actual changes |
| `--checksum` | Use checksums instead of mod-time |
| `--update` | Skip files that are newer on destination |
| `--transfers 4` | Number of parallel transfers |
| `--bwlimit 10M` | Bandwidth limit |
| `--exclude "*.tmp"` | Exclude patterns |
| `--include "*.jpg"` | Include only patterns |

## 📝 Configuration File Location

**On VPS**: `~/.config/rclone/rclone.conf`

View config:
```bash
ssh fedora-vps "cat ~/.config/rclone/rclone.conf"
```

## 🔐 Security Notes

- Credentials are stored in: `~/.config/rclone/rclone.conf`
- File permissions: 600 (readable by owner only)
- Consider encrypting sensitive data before upload
- Use `rclone crypt` for end-to-end encryption

## 📱 Access from Local Machine

### Copy rclone config to local machine:

**Windows:**
```powershell
scp fedora-vps:~/.config/rclone/rclone.conf %USERPROFILE%\.config\rclone\
```

**macOS/Linux:**
```bash
mkdir -p ~/.config/rclone
scp fedora-vps:~/.config/rclone/rclone.conf ~/.config/rclone/
```

Then use rclone locally:
```bash
rclone ls vultr-s3:london-vhdx
```

## 🎯 Quick Reference Card

```bash
# List
rclone lsd vultr-s3:                    # List buckets
rclone ls vultr-s3:london-vhdx          # List files
rclone tree vultr-s3:london-vhdx        # Tree view

# Transfer
rclone copy source dest                 # Copy new/changed files
rclone sync source dest                 # Make dest identical to source
rclone move source dest                 # Move files (delete source)

# Info
rclone size vultr-s3:london-vhdx        # Show size
rclone about vultr-s3:                  # Show quota/usage
rclone ncdu vultr-s3:london-vhdx        # Interactive disk usage

# Delete
rclone delete path                      # Delete files
rclone purge path                       # Delete dir and contents
```

## 💡 Pro Tips

1. **Always test with --dry-run first!**
   ```bash
   rclone sync /data vultr-s3:london-vhdx/backup/ --dry-run
   ```

2. **Use checksums for important data**
   ```bash
   rclone copy /data vultr-s3:london-vhdx/ --checksum
   ```

3. **Monitor large transfers**
   ```bash
   rclone copy bigfile.zip vultr-s3:london-vhdx/ --progress --stats 5s
   ```

4. **Parallel transfers for speed**
   ```bash
   rclone copy /data vultr-s3:london-vhdx/ --transfers 8
   ```

## 🆘 Troubleshooting

### Connection Issues
```bash
# Test connection
ssh fedora-vps "rclone lsd vultr-s3: -vv"

# Check config
ssh fedora-vps "rclone config show vultr-s3"
```

### Slow Transfers
```bash
# Increase parallel transfers
ssh fedora-vps "rclone copy file vultr-s3:london-vhdx/ --transfers 16"

# Use multi-part uploads for large files
ssh fedora-vps "rclone copy bigfile.zip vultr-s3:london-vhdx/ --s3-upload-concurrency 8"
```

## 📚 More Information

- Official docs: https://rclone.org/s3/
- Vultr Object Storage: https://www.vultr.com/docs/vultr-object-storage/
- Rclone commands: https://rclone.org/commands/

## 🔗 Your Configuration

```
Remote: vultr-s3
Endpoint: lhr1.vultrobjects.com
Location: London
Bucket: london-vhdx
Access: Configured and tested ✅
```
