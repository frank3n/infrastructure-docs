# Quick Start - SSH Timeout-Safe Workflow

## 🎯 One-Command Solution

```bash
# Upload compressed backup, then run safe script
scp -i vps-management/ssh-keys/fedora-vps-key your-backup.zip root@138.199.218.115:/mnt/storage/ && \
ssh fedora-vps "bash -s" < vps-management/process-win11-backup-safe.sh
```

**✅ Features:**
- Uses screen sessions (SSH timeout-proof)
- Automatic progress monitoring
- Can reconnect anytime
- Creates both VHDX and QCOW2

## 📊 Monitor Progress

```bash
# Check screen sessions
ssh fedora-vps "screen -ls"

# Attach to active session
ssh fedora-vps "screen -r decompress-step"   # Decompression
ssh fedora-vps "screen -r convert-step"      # Conversion
ssh fedora-vps "screen -r upload-step"       # Upload

# Detach without stopping: Ctrl+A then D
```

## 🔍 Quick Status Check

```bash
# Disk space and file sizes
ssh fedora-vps "df -h /mnt/storage && echo && du -h /mnt/storage/*.{img,vhdx,qcow2} 2>/dev/null"
```

## 📁 Expected Timeline

| Step | Duration | Safe Method |
|------|----------|-------------|
| Upload | Varies | SCP/rsync (resumable) |
| Decompress 190GB | 30-45 min | ✅ screen session |
| Convert to VHDX | 30-60 min | ✅ screen session |
| Upload VHDX | 30-90 min | ✅ screen session |
| Convert to QCOW2 | 30-60 min | ✅ screen session |
| Upload QCOW2 | 30-90 min | ✅ screen session |

**Total: 3-6 hours** (all protected from SSH timeout!)

## 🛠️ Individual Steps (Manual Control)

### 1. Decompress in Screen

```bash
ssh fedora-vps "bash -s" < vps-management/resume-decompression.sh
```

### 2. Convert to VHDX

```bash
ssh fedora-vps
screen -S convert
qemu-img convert -f raw -O vhdx -o subformat=dynamic \
    /mnt/storage/win11-backup.img \
    /mnt/storage/win11.vhdx -p
# Detach: Ctrl+A, D
```

### 3. Upload to Hetzner

```bash
ssh fedora-vps
screen -S upload
rclone copy /mnt/storage/win11.vhdx hetzner-storage:/windows-backups/ --progress
# Detach: Ctrl+A, D
```

### 4. Create QCOW2 Version

```bash
ssh fedora-vps "bash -s" < vps-management/create-qcow2-version.sh
```

## 🚨 If Something Goes Wrong

### SSH Connection Lost

```bash
# Just reconnect and check status
ssh fedora-vps "screen -ls"

# Reattach to any running session
ssh fedora-vps "screen -r"
```

### Process Stuck

```bash
# Check if actually running
ssh fedora-vps "ps aux | grep -E 'gunzip|qemu-img|rclone'"

# Kill if needed
ssh fedora-vps "screen -X -S session-name quit"
```

### Out of Disk Space

```bash
# Check space
ssh fedora-vps "df -h /mnt/storage"

# Delete temporary files
ssh fedora-vps "rm -f /mnt/storage/win11-backup.img"  # After VHDX created
ssh fedora-vps "rm -f /mnt/storage/*.vhdx"            # After uploaded
```

## 📝 Files Created

**Scripts:**
- `process-win11-backup-safe.sh` - Full automated workflow with screen
- `resume-decompression.sh` - Decompress with progress bar in screen
- `create-qcow2-version.sh` - Create QCOW2 after VHDX

**Guides:**
- `SCREEN-GUIDE.md` - Complete screen session tutorial
- `DECOMPRESS-CONVERT-WORKFLOW.md` - Updated with screen tips
- `QUICK-START-SAFE.md` - This file

## 💡 Pro Tips

1. **Always use screen for operations > 30 minutes**
2. **Monitor with `watch`** instead of keeping SSH open:
   ```bash
   watch -n 30 'ssh fedora-vps "du -h /mnt/storage/win11-backup.img"'
   ```
3. **Check logs** if something fails:
   ```bash
   ssh fedora-vps "tail -100 /mnt/storage/upload-*.log"
   ```
4. **Keep .gz backup** until verification complete
5. **Verify uploads** before deleting local copies

## 🎓 Learn Screen

See `SCREEN-GUIDE.md` for complete tutorial on using screen sessions.

**Essential commands:**
```bash
screen -S name          # Start session
Ctrl+A, D               # Detach (keep running)
screen -r name          # Reattach
screen -ls              # List sessions
```

## ✅ Verification Checklist

- [ ] Screen sessions running: `screen -ls`
- [ ] Disk space sufficient: `df -h /mnt/storage`
- [ ] Progress visible: `screen -r session-name`
- [ ] Files on Hetzner: `rclone ls hetzner-storage:/windows-backups/`
- [ ] Local files cleaned up after upload
- [ ] Both VHDX and QCOW2 formats available

## 🔗 Related Docs

- `SCREEN-GUIDE.md` - Screen session tutorial
- `DECOMPRESS-CONVERT-WORKFLOW.md` - Complete workflow guide
- `RCLONE-HETZNER-STORAGE.md` - Rclone usage
- `CAPTURE-WIN11-TO-VPS.md` - Initial backup creation
