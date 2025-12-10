# Convert Disk Image with Low Disk Space

## 🎯 Problem
You have a 190GB compressed disk image (`.img.gz`) and only ~240GB free space on the VPS. Need to convert to QCOW2 and VHDX formats, but the raw decompressed image would be ~500GB.

## ✅ Solution
Convert and upload one format at a time, deleting intermediates to free space.

---

## 📊 Process Overview

```
190GB .img.gz (compressed)
    ↓ decompress (30-60 min)
~500GB .img (raw disk image)
    ↓ convert (30-90 min)
~190GB .qcow2 (compressed)
    ↓ upload to Hetzner (2-6 hours)
    ↓ verify & delete local QCOW2
    ↓
Use same .img to convert (30-90 min)
~190GB .vhdx (dynamic)
    ↓ upload to Hetzner (2-6 hours)
    ↓ verify & delete local VHDX
    ↓ delete .img
Keep only original .img.gz
```

**Peak space usage:** ~690GB (during conversion)
**Final space usage:** 190GB (just the .gz)

---

## 🚀 Quick Start

### Run the Script:

```bash
ssh fedora-vps "nohup /tmp/convert-space-efficient.sh > /tmp/convert.log 2>&1 &"
```

### Monitor Progress:

```bash
# Watch live
ssh fedora-vps "tail -f /tmp/convert.log"

# Quick check
ssh fedora-vps "tail -30 /tmp/convert.log"

# Check space
ssh fedora-vps "df -h /mnt/storage"

# See what files exist
ssh fedora-vps "ls -lh /mnt/storage/windows-backups/"
```

---

## 📝 Detailed Steps

### Step 1: Decompress (30-60 min)

```bash
cd /mnt/storage/windows-backups
gunzip -c win11-direct-stream.img.gz > win11-backup.img
```

**Space needed:** ~500GB
**Result:** Raw disk image

### Step 2: Convert to QCOW2 (30-90 min)

```bash
qemu-img convert -f raw -O qcow2 -c -p win11-backup.img win11-backup.qcow2
```

**Options:**
- `-c` = Compress (saves space)
- `-p` = Show progress
- `-O qcow2` = Output format

**Result:** ~190GB QCOW2 file

### Step 3: Upload QCOW2 (2-6 hours)

```bash
rclone copy win11-backup.qcow2 hetzner-storage:windows-backups/ \
    --progress \
    --stats 30s \
    --transfers 4
```

### Step 4: Verify & Delete QCOW2

```bash
# Check sizes match
REMOTE=$(rclone size hetzner-storage:windows-backups/win11-backup.qcow2 --json | grep -o '"bytes":[0-9]*' | cut -d: -f2)
LOCAL=$(stat -c%s win11-backup.qcow2)

if [ "$REMOTE" = "$LOCAL" ]; then
    rm win11-backup.qcow2
    echo "QCOW2 deleted - space freed"
fi
```

**Space freed:** ~190GB

### Step 5: Convert to VHDX (30-90 min)

```bash
qemu-img convert -f raw -O vhdx -o subformat=dynamic -p win11-backup.img win11-backup.vhdx
```

**Result:** ~190GB VHDX file

### Step 6: Upload VHDX (2-6 hours)

```bash
rclone copy win11-backup.vhdx hetzner-storage:windows-backups/ \
    --progress \
    --stats 30s \
    --transfers 4
```

### Step 7: Cleanup

```bash
# Verify upload
REMOTE=$(rclone size hetzner-storage:windows-backups/win11-backup.vhdx --json | grep -o '"bytes":[0-9]*' | cut -d: -f2)
LOCAL=$(stat -c%s win11-backup.vhdx)

if [ "$REMOTE" = "$LOCAL" ]; then
    rm win11-backup.vhdx
    rm win11-backup.img
    echo "All intermediates deleted"
fi
```

**Final state:**
- VPS: Only `win11-direct-stream.img.gz` (190GB)
- Hetzner: `win11-backup.qcow2` + `win11-backup.vhdx`

---

## ⏱️ Timeline

| Step | Duration | Space Used |
|------|----------|------------|
| Decompress | 30-60 min | +500GB |
| Convert QCOW2 | 30-90 min | +190GB (690GB peak) |
| Upload QCOW2 | 2-6 hours | Same |
| Delete QCOW2 | Instant | -190GB (500GB) |
| Convert VHDX | 30-90 min | +190GB (690GB peak) |
| Upload VHDX | 2-6 hours | Same |
| Delete all | Instant | -500GB (190GB final) |

**Total time:** 6-14 hours (can run overnight)

---

## 💾 Space Requirements

### Minimum Required:
- Original .gz: 190GB
- Raw .img: 500GB
- One conversion: 190GB
- **Total:** 880GB (but we have 240GB)

### How We Fit:
1. We already have 190GB used (.gz)
2. Need 500GB for decompression = **690GB total** ✓ (fits in 731GB total space)
3. Add 190GB for conversion = **880GB** ❌ (doesn't fit)
4. **Solution:** Delete QCOW2 after upload before creating VHDX

### Peak Space Moments:
- **690GB** - During QCOW2 conversion (raw + QCOW2)
- **690GB** - During VHDX conversion (raw + VHDX)

Both fit in 731GB total! ✓

---

## 🔍 Monitoring Commands

### Check Current Step:

```bash
ssh fedora-vps "ps aux | grep -E 'gunzip|qemu-img|rclone' | grep -v grep"
```

### Watch Disk Space:

```bash
ssh fedora-vps "watch -n 10 'df -h /mnt/storage && du -sh /mnt/storage/windows-backups/*'"
```

### Check Hetzner Storage:

```bash
ssh fedora-vps "rclone ls hetzner-storage:windows-backups/ | grep -E 'qcow2|vhdx'"
```

### Monitor Transfer Speed:

```bash
ssh fedora-vps "tail -f /tmp/convert.log | grep -E 'Transferred|ETA'"
```

---

## 🆘 Troubleshooting

### Out of Space During Decompression

**Problem:** Disk fills up before decompress completes

**Solution:**
```bash
# Delete any other large files first
ssh fedora-vps "du -h /mnt/storage | sort -hr | head -20"

# Or upload .gz to Hetzner first, then delete it
ssh fedora-vps "rclone copy /mnt/storage/windows-backups/win11-direct-stream.img.gz hetzner-storage:windows-backups/"
# Then download when more space available
```

### Conversion Fails

**Problem:** qemu-img crashes or errors

**Check:**
```bash
# Verify raw image isn't corrupted
ssh fedora-vps "file /mnt/storage/windows-backups/win11-backup.img"

# Try without compression
ssh fedora-vps "qemu-img convert -f raw -O qcow2 -p win11-backup.img test.qcow2"
```

### Upload Interrupted

**Good news:** Rclone can resume!

```bash
# Just run the same command again
rclone copy win11-backup.qcow2 hetzner-storage:windows-backups/ --progress
```

### Process Killed

**Check logs:**
```bash
ssh fedora-vps "dmesg | tail -50"  # Check for OOM killer
ssh fedora-vps "journalctl -xe"    # Check system logs
```

**Restart from last successful step**

---

## 🔄 Resume After Failure

The script is idempotent - you can re-run it and it will skip completed steps:

```bash
ssh fedora-vps "/tmp/convert-space-efficient.sh"
```

**It will:**
- Skip decompression if .img exists
- Skip QCOW2 if already on Hetzner
- Skip VHDX if already on Hetzner

---

## 📈 What Each Format Is For

### QCOW2 (QEMU Copy-On-Write v2)
- **Use:** KVM, QEMU, Proxmox, oVirt
- **Features:** Snapshots, compression, encryption
- **Best for:** Linux virtualization
- **Size:** ~40-60% of raw (with compression)

### VHDX (Virtual Hard Disk v2)
- **Use:** Hyper-V, Azure, Windows Server
- **Features:** 64TB max size, corruption resistance
- **Best for:** Windows virtualization
- **Size:** Similar to QCOW2 with dynamic allocation

### Raw .IMG
- **Use:** Direct disk restore, dd operations
- **Features:** Maximum compatibility
- **Best for:** Physical restore, disk cloning
- **Size:** Full disk size (uncompressed)

---

## ✅ Success Indicators

After completion:

```bash
ssh fedora-vps "
echo '=== VPS Files ==='
ls -lh /mnt/storage/windows-backups/

echo ''
echo '=== Hetzner Files ==='
rclone ls hetzner-storage:windows-backups/

echo ''
echo '=== Space ==='
df -h /mnt/storage
"
```

**Expected:**
- VPS: Only `win11-direct-stream.img.gz` (190GB)
- Hetzner: Both `.qcow2` and `.vhdx` files
- Space: Back to ~240GB free

---

## 🔐 Verify Integrity

### Check Hetzner Files:

```bash
# Get sizes
ssh fedora-vps "rclone size hetzner-storage:windows-backups/win11-backup.qcow2"
ssh fedora-vps "rclone size hetzner-storage:windows-backups/win11-backup.vhdx"

# Optional: Calculate checksums (slow)
ssh fedora-vps "rclone md5sum hetzner-storage:windows-backups/win11-backup.qcow2"
```

### Test QCOW2:

```bash
# Check image info
ssh fedora-vps "qemu-img info /path/to/win11-backup.qcow2"

# Test mounting (if downloaded)
ssh fedora-vps "qemu-img check win11-backup.qcow2"
```

---

## 💡 Tips

1. **Run overnight** - Start before bed, complete by morning

2. **Use screen/tmux** - Persist if SSH disconnects:
   ```bash
   ssh fedora-vps
   tmux new -s convert
   /tmp/convert-space-efficient.sh
   # Detach: Ctrl+B then D
   # Reattach: tmux attach -t convert
   ```

3. **Monitor remotely** - Set up cron to email progress

4. **Keep backups** - Don't delete .gz until verified

5. **Document** - Note which format works best for your use case

---

## 📋 Automation Script Location

**Script:** `/tmp/convert-space-efficient.sh`

**Log:** `/tmp/convert.log`

**Run again:**
```bash
ssh fedora-vps "nohup /tmp/convert-space-efficient.sh > /tmp/convert.log 2>&1 &"
```

---

## 🎯 Final Checklist

- [ ] Decompression completed
- [ ] QCOW2 created and uploaded
- [ ] QCOW2 verified on Hetzner
- [ ] Local QCOW2 deleted
- [ ] VHDX created and uploaded
- [ ] VHDX verified on Hetzner
- [ ] Local VHDX deleted
- [ ] Raw .img deleted
- [ ] Only .img.gz remains locally
- [ ] Both formats on Hetzner Storage Box
- [ ] Disk space recovered (~240GB free)

---

**Process Status:** ✅ Optimized for 240GB available space

**Result:** Both bootable formats safely stored on Hetzner, minimal VPS space used
