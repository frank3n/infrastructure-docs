# 🚀 Stream to VPS with ZERO Local Storage

## Problem
You have low free disk space and cannot store a VHDX locally before uploading.

## Solution
Stream the disk image directly to VPS during capture - no local storage used!

---

## ⚡ Method 1: Direct Bash Stream (Recommended)

**Best for**: True zero storage, captures entire disk

### Run This:

```bash
cd /c/2025-claude-code-laptop/projects/vps-management
./stream-direct.sh
```

**What it does:**
1. Reads disk directly using `dd`
2. Compresses on-the-fly with `gzip`
3. Streams through SSH pipe to VPS
4. **Zero local disk usage** (only memory buffer)

**Requirements:**
- Git Bash (already have)
- Run as Administrator
- 4-12 hours streaming time

**Output:**
- VPS: `/mnt/storage/windows-backups/win11-direct-stream.img.gz`
- Format: Compressed raw disk image

---

## 🔧 Method 2: Command Line One-Liner

If you prefer to run the command directly:

```bash
# For C: drive (usually Disk 0)
dd if=/dev/sda bs=4M status=progress | gzip -1 | ssh -i "C:/2025-claude-code-laptop/projects/vps-management/ssh-keys/fedora-vps-key" root@138.199.218.115 "cat > /mnt/storage/windows-backups/win11-stream-$(date +%Y%m%d).img.gz"
```

**Breakdown:**
- `dd if=/dev/sda` - Read disk 0 (adjust if needed)
- `bs=4M` - 4MB block size (good balance)
- `status=progress` - Show progress
- `gzip -1` - Fast compression
- `ssh ... "cat > file"` - Stream to VPS

**To check your disk:**
```powershell
# Run in PowerShell to see disk layout
Get-Disk | Format-Table Number, FriendlyName, Size
```

Most likely:
- Disk 0 = `/dev/sda` (C: drive)
- Disk 1 = `/dev/sdb`
- etc.

---

## 💾 Method 3: Partclone (Only Used Space)

**More efficient**: Only captures used blocks

### Install Partclone:

```bash
# Using Chocolatey (if installed)
choco install partclone

# Or download from: https://partclone.org/download/
```

### Stream with Partclone:

```bash
# NTFS partition (usually C:)
partclone.ntfs -c -s /dev/sda2 | \
    gzip -1 | \
    ssh -i "C:/2025-claude-code-laptop/projects/vps-management/ssh-keys/fedora-vps-key" \
    root@138.199.218.115 "cat > /mnt/storage/windows-backups/win11-partclone.img.gz"
```

**Advantage**: Only captures used space (much smaller and faster)

---

## 📊 Comparison

| Method | Local Storage | Speed | File Size | Captures |
|--------|---------------|-------|-----------|----------|
| **stream-direct.sh** | 0 GB | Medium | Full disk | Everything |
| **dd one-liner** | 0 GB | Medium | Full disk | Everything |
| **partclone** | 0 GB | Fast | Used space only | Data only |
| disk2vhd+upload | Need ~100GB | Slow | Compressed | Live system |

---

## ⚙️ Optimization Flags

### Faster Compression (less CPU):
```bash
gzip -1  # Fast compression (default in scripts)
gzip -9  # Maximum compression (slower)
```

### Larger Block Size (faster transfer):
```bash
dd if=/dev/sda bs=8M  # 8MB blocks (faster but more memory)
dd if=/dev/sda bs=16M # 16MB blocks (even faster)
```

### Show Progress:
```bash
# Install pv (pipe viewer) for better progress
dd if=/dev/sda bs=4M | pv | gzip | ssh ...
```

---

## 🎯 Quick Start (Easiest)

1. **Open Git Bash as Administrator**
   - Right-click Git Bash
   - "Run as Administrator"

2. **Navigate to scripts:**
   ```bash
   cd /c/2025-claude-code-laptop/projects/vps-management
   ```

3. **Run the stream script:**
   ```bash
   ./stream-direct.sh
   ```

4. **Follow prompts:**
   - Select disk number (usually 0)
   - Type "yes" to confirm
   - Wait 4-12 hours

5. **Keep computer awake:**
   - Disable sleep: Settings → Power → Never
   - Keep plugged in
   - Don't close Git Bash window

---

## 📈 What to Expect

### Timeline:
- **250GB disk** = ~6 hours @ 10MB/s
- **500GB disk** = ~12 hours @ 10MB/s
- **1TB disk** = ~24 hours @ 10MB/s

### Compressed Size:
- Windows 11 with ~100GB used = ~40-60GB compressed
- Compression ratio: ~40-60% reduction

### Network Usage:
- Constant upload stream
- ~40-120 Mbps sustained upload needed
- Check your upload speed: fast.com

---

## 🔍 Monitoring Progress

### During streaming:

```bash
# Check remote file size growing on VPS
ssh fedora-vps "watch -n 5 ls -lh /mnt/storage/windows-backups/"

# Or in another terminal
ssh fedora-vps "du -h /mnt/storage/windows-backups/win11-*.img.gz"
```

### Calculate progress:

```bash
# Get current compressed size on VPS
ssh fedora-vps "stat -c%s /mnt/storage/windows-backups/win11-*.img.gz"

# Estimate: ~40-60% of used space on C: drive
```

---

## 🛡️ Safety & Resume

### ⚠️ Important:
- **This stream CANNOT be resumed if interrupted**
- Ensure stable internet before starting
- Consider running overnight on wired connection
- If fails: start over from beginning

### Power Management:

```powershell
# Disable sleep temporarily
powercfg /change standby-timeout-ac 0
powercfg /change monitor-timeout-ac 0

# Re-enable after (15 min):
powercfg /change standby-timeout-ac 15
powercfg /change monitor-timeout-ac 15
```

---

## 🔄 Restoring the Image

### On VPS:
```bash
# Decompress and restore to disk
ssh fedora-vps
gunzip -c /mnt/storage/windows-backups/win11-stream.img.gz | dd of=/dev/sdX bs=4M
```

### On Windows:
```bash
# Download first
scp -i "C:/2025-claude-code-laptop/projects/vps-management/ssh-keys/fedora-vps-key" \
    root@138.199.218.115:/mnt/storage/windows-backups/win11-stream.img.gz \
    /d/restore.img.gz

# Decompress
gunzip restore.img.gz

# Restore with Win32DiskImager or similar
```

---

## 🆘 Troubleshooting

### "Permission denied" on /dev/sda
- **Solution**: Run Git Bash as Administrator

### "Broken pipe" during transfer
- **Cause**: Network interrupted or SSH disconnected
- **Solution**: Start over, ensure stable connection

### Transfer very slow
- **Check**: `ssh fedora-vps "iftop"` - monitor bandwidth
- **Try**: Disable compression (`gzip -1` or remove gzip)
- **Test**: `ssh fedora-vps "dd if=/dev/zero bs=1M count=100"` - test speed

### Disk not accessible
- **Check disk number**:
  ```powershell
  Get-Disk
  ```
- **Try**: Different device (sda, sdb, sdc)

---

## 💡 Pro Tips

1. **Run overnight** - Start before bed, complete by morning

2. **Use tmux/screen on VPS** - Won't lose progress if SSH disconnects:
   ```bash
   ssh fedora-vps "screen -S backup"
   # Then run streaming command
   # Detach: Ctrl+A, then D
   # Reattach: ssh fedora-vps "screen -r backup"
   ```

3. **Test speed first**:
   ```bash
   dd if=/dev/zero bs=1M count=1000 | gzip | ssh fedora-vps "cat > /dev/null"
   # This shows your realistic transfer speed
   ```

4. **Compress on VPS side** (if low local CPU):
   ```bash
   dd if=/dev/sda bs=4M | ssh fedora-vps "gzip > /mnt/storage/backup.img.gz"
   ```

5. **Multiple partitions** instead of whole disk:
   ```bash
   # Just C: partition (usually /dev/sda2)
   dd if=/dev/sda2 bs=4M | gzip | ssh fedora-vps "cat > /mnt/storage/c-drive.img.gz"
   ```

---

## ✅ Ready to Stream?

**Quick Command:**

```bash
cd /c/2025-claude-code-laptop/projects/vps-management && ./stream-direct.sh
```

**Or manual command:**

```bash
dd if=/dev/sda bs=4M status=progress | gzip -1 | ssh -i "C:/2025-claude-code-laptop/projects/vps-management/ssh-keys/fedora-vps-key" root@138.199.218.115 "cat > /mnt/storage/windows-backups/win11-$(date +%Y%m%d-%H%M).img.gz"
```

---

**Need help?** Check the output messages - they'll guide you through any issues.

**VPS Space**: 467GB available - plenty of room! ✅
