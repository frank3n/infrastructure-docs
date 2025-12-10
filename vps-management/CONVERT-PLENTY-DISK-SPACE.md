# Convert Disk Image with Plenty of Disk Space

## 🎯 Situation
You have a 190GB compressed disk image (`.img.gz`) and **800GB+ free space** on the VPS. Can keep all formats simultaneously for faster processing and maximum flexibility.

## ✅ Advantages
- Keep all formats locally for quick access
- No waiting for downloads from Hetzner
- Faster workflow - run conversions in parallel
- Easy format comparison and testing

---

## 📊 Process Overview

```
190GB .img.gz (compressed)
    ↓ decompress (30-60 min)
~500GB .img (raw disk image)
    ├─ convert to QCOW2 (30-90 min) ───→ ~190GB .qcow2
    └─ convert to VHDX (30-90 min) ────→ ~190GB .vhdx
         ↓ parallel uploads (2-6 hours each)
    Both formats uploaded to Hetzner

Keep all files locally:
- win11-direct-stream.img.gz (190GB) - Original
- win11-backup.img (500GB) - Raw for quick re-conversion
- win11-backup.qcow2 (190GB) - For KVM/QEMU
- win11-backup.vhdx (190GB) - For Hyper-V
```

**Total space used:** ~1,070GB
**Required:** 800GB+ available

---

## 🚀 Quick Start

### Run the Full Script:

```bash
ssh fedora-vps "nohup /tmp/convert-and-upload.sh > /tmp/convert-full.log 2>&1 &"
```

### Monitor Progress:

```bash
# Watch live
ssh fedora-vps "tail -f /tmp/convert-full.log"

# Check all files
ssh fedora-vps "ls -lh /mnt/storage/windows-backups/"

# Watch space
ssh fedora-vps "watch -n 10 'df -h /mnt/storage'"
```

---

## 📝 Detailed Steps

### Step 1: Decompress (30-60 min)

```bash
cd /mnt/storage/windows-backups
gunzip -c win11-direct-stream.img.gz > win11-backup.img
```

**Space needed:** +500GB
**Result:** Raw disk image ready for multiple conversions

### Step 2A & 2B: Convert Both Formats (Can Run in Parallel!)

#### QCOW2 Conversion:
```bash
qemu-img convert -f raw -O qcow2 -c -p win11-backup.img win11-backup.qcow2 &
```

#### VHDX Conversion:
```bash
qemu-img convert -f raw -O vhdx -o subformat=dynamic -p win11-backup.img win11-backup.vhdx &
```

**Space needed:** +380GB (both formats)
**Time:** 30-90 min (parallel = same time as one!)

### Step 3: Upload Both to Hetzner (Parallel)

```bash
# Upload QCOW2
rclone copy win11-backup.qcow2 hetzner-storage:windows-backups/ \
    --progress \
    --stats 30s \
    --transfers 4 \
    --log-file /tmp/qcow2-upload.log &

# Upload VHDX
rclone copy win11-backup.vhdx hetzner-storage:windows-backups/ \
    --progress \
    --stats 30s \
    --transfers 4 \
    --log-file /tmp/vhdx-upload.log &

# Wait for both
wait
```

**Time:** 2-6 hours (both uploading simultaneously)

### Step 4: Verify All Files

```bash
echo "=== Local Files ==="
ls -lh /mnt/storage/windows-backups/

echo ""
echo "=== Hetzner Files ==="
rclone ls hetzner-storage:windows-backups/

echo ""
echo "=== Space Usage ==="
df -h /mnt/storage
```

---

## ⚡ Parallel Processing Script

```bash
#!/bin/bash
# Fast parallel conversion when space isn't limited

SOURCE_GZ="/mnt/storage/windows-backups/win11-direct-stream.img.gz"
WORK_DIR="/mnt/storage/windows-backups"
BASE_NAME="win11-backup"

cd "$WORK_DIR"

# Step 1: Decompress
echo "[1/3] Decompressing..."
gunzip -c "$SOURCE_GZ" > "${BASE_NAME}.img"

# Step 2: Convert both formats in parallel
echo "[2/3] Converting to both formats (parallel)..."
qemu-img convert -f raw -O qcow2 -c -p "${BASE_NAME}.img" "${BASE_NAME}.qcow2" &
PID_QCOW2=$!

qemu-img convert -f raw -O vhdx -o subformat=dynamic -p "${BASE_NAME}.img" "${BASE_NAME}.vhdx" &
PID_VHDX=$!

# Wait for both conversions
wait $PID_QCOW2
echo "✓ QCOW2 done"

wait $PID_VHDX
echo "✓ VHDX done"

# Step 3: Upload both in parallel
echo "[3/3] Uploading to Hetzner (parallel)..."
rclone copy "${BASE_NAME}.qcow2" hetzner-storage:windows-backups/ --progress &
PID_UP_QCOW2=$!

rclone copy "${BASE_NAME}.vhdx" hetzner-storage:windows-backups/ --progress &
PID_UP_VHDX=$!

# Wait for both uploads
wait $PID_UP_QCOW2
echo "✓ QCOW2 uploaded"

wait $PID_UP_VHDX
echo "✓ VHDX uploaded"

echo ""
echo "✅ All done! All formats kept locally + backed up to Hetzner"
df -h /mnt/storage
```

Save as `/tmp/convert-parallel.sh` and run:
```bash
ssh fedora-vps "nohup /tmp/convert-parallel.sh > /tmp/convert-parallel.log 2>&1 &"
```

---

## ⏱️ Timeline Comparison

| Approach | Time | Reason |
|----------|------|--------|
| **Sequential** | 6-14 hours | One format at a time |
| **Parallel** | 4-8 hours | Both conversions + uploads at once |

### Parallel Timeline:
1. Decompress: 30-60 min
2. Convert both: 30-90 min (parallel, not 2x)
3. Upload both: 2-6 hours (parallel, limited by bandwidth)

**Total: 4-8 hours** (vs 6-14 hours sequential)

---

## 💾 Space Requirements

### Full Process:

| File | Size | Purpose |
|------|------|---------|
| `win11-direct-stream.img.gz` | 190GB | Original compressed |
| `win11-backup.img` | 500GB | Raw disk image |
| `win11-backup.qcow2` | 190GB | KVM/QEMU format |
| `win11-backup.vhdx` | 190GB | Hyper-V format |
| **Total** | **1,070GB** | All formats |

### Why Keep Everything?

1. **Quick access** - No download wait from Hetzner
2. **Fast re-conversion** - Have raw .img for other formats
3. **Testing** - Try both formats without re-downloading
4. **Redundancy** - Local + remote backups
5. **Flexibility** - Switch formats instantly

---

## 🎯 Use Cases for Each Format

### Keep .img.gz (Compressed Original)
- **Size:** 190GB
- **Use:** Archive, long-term storage
- **Decompress to restore:** `gunzip`

### Keep .img (Raw)
- **Size:** 500GB
- **Use:** Direct disk restore with `dd`
- **Fast conversions:** Source for any format

### Keep .qcow2
- **Size:** 190GB
- **Use:** Proxmox, KVM, QEMU virtualization
- **Boot directly:** Mount as VM disk

### Keep .vhdx
- **Size:** 190GB
- **Use:** Hyper-V, Azure VMs
- **Boot directly:** Attach to Hyper-V VM

---

## 🔄 Additional Format Conversions

With the raw .img available, create more formats instantly:

### VDI (VirtualBox):
```bash
qemu-img convert -f raw -O vdi win11-backup.img win11-backup.vdi
```

### VMDK (VMware):
```bash
qemu-img convert -f raw -O vmdk win11-backup.img win11-backup.vmdk
```

### VHD (Legacy Hyper-V):
```bash
qemu-img convert -f raw -O vpc win11-backup.img win11-backup.vhd
```

### Split into Chunks (for FAT32):
```bash
split -b 4000M win11-backup.img win11-backup.img.part-
```

---

## 📊 Monitoring with Plenty of Space

### Watch All Processes:

```bash
watch -n 5 '
echo "=== Processes ==="
ps aux | grep -E "gunzip|qemu-img|rclone" | grep -v grep

echo ""
echo "=== Disk Usage ==="
df -h /mnt/storage

echo ""
echo "=== Files ==="
ls -lh /mnt/storage/windows-backups/

echo ""
echo "=== Uploads ==="
tail -3 /tmp/qcow2-upload.log
tail -3 /tmp/vhdx-upload.log
'
```

### Progress Summary:

```bash
ssh fedora-vps "
echo '=== Conversion Progress ==='
ls -lh /mnt/storage/windows-backups/*.{qcow2,vhdx} 2>/dev/null || echo 'Not started yet'

echo ''
echo '=== Upload Progress ==='
grep 'Transferred' /tmp/*.log 2>/dev/null | tail -5

echo ''
echo '=== Hetzner Status ==='
rclone ls hetzner-storage:windows-backups/ | grep -E 'qcow2|vhdx'
"
```

---

## 🔧 Advanced: Triple-Speed Uploads

If your VPS has good bandwidth, upload while converting:

```bash
#!/bin/bash
# Convert and upload simultaneously

cd /mnt/storage/windows-backups

# Decompress
gunzip -c win11-direct-stream.img.gz > win11-backup.img

# Convert QCOW2 and upload immediately
qemu-img convert -f raw -O qcow2 -c win11-backup.img win11-backup.qcow2 && \
rclone copy win11-backup.qcow2 hetzner-storage:windows-backups/ --progress &

# Convert VHDX and upload immediately
qemu-img convert -f raw -O vhdx -o subformat=dynamic win11-backup.img win11-backup.vhdx && \
rclone copy win11-backup.vhdx hetzner-storage:windows-backups/ --progress &

# Upload original while conversions run
rclone copy win11-direct-stream.img.gz hetzner-storage:windows-backups/ --progress &

wait
echo "✅ Everything uploaded!"
```

---

## 💡 Optimization Tips

### 1. Faster Decompression:
```bash
# Use pigz (parallel gzip) if available
pigz -dc win11-direct-stream.img.gz > win11-backup.img
```

### 2. Faster Conversions:
```bash
# Increase I/O priority
ionice -c2 -n0 qemu-img convert -f raw -O qcow2 ...
```

### 3. Faster Uploads:
```bash
# More parallel transfers
rclone copy file.qcow2 hetzner-storage:windows-backups/ \
    --transfers 16 \
    --checkers 16 \
    --buffer-size 128M
```

### 4. CPU Optimization:
```bash
# Run conversions with more threads
qemu-img convert -m 4 -f raw -O qcow2 ...
```

---

## 🎮 Interactive Workflow

### Start Everything:

```bash
# 1. Start decompression
ssh fedora-vps "cd /mnt/storage/windows-backups && nohup gunzip -c win11-direct-stream.img.gz > win11-backup.img 2>&1 &"

# Wait 30-60 min...

# 2. Start conversions (parallel)
ssh fedora-vps "cd /mnt/storage/windows-backups && \
    nohup qemu-img convert -f raw -O qcow2 -c -p win11-backup.img win11-backup.qcow2 > /tmp/qcow2.log 2>&1 & \
    nohup qemu-img convert -f raw -O vhdx -o subformat=dynamic -p win11-backup.img win11-backup.vhdx > /tmp/vhdx.log 2>&1 &"

# Wait 30-90 min...

# 3. Start uploads (parallel)
ssh fedora-vps "cd /mnt/storage/windows-backups && \
    nohup rclone copy win11-backup.qcow2 hetzner-storage:windows-backups/ --progress > /tmp/qcow2-upload.log 2>&1 & \
    nohup rclone copy win11-backup.vhdx hetzner-storage:windows-backups/ --progress > /tmp/vhdx-upload.log 2>&1 &"
```

---

## 🗂️ File Organization

### Recommended Structure:

```
/mnt/storage/windows-backups/
├── originals/
│   └── win11-direct-stream.img.gz (190GB)
├── raw/
│   └── win11-backup.img (500GB)
├── qcow2/
│   └── win11-backup.qcow2 (190GB)
└── vhdx/
    └── win11-backup.vhdx (190GB)
```

Create structure:
```bash
ssh fedora-vps "cd /mnt/storage/windows-backups && \
    mkdir -p originals raw qcow2 vhdx && \
    mv *.img.gz originals/ && \
    mv *.img raw/ && \
    mv *.qcow2 qcow2/ && \
    mv *.vhdx vhdx/"
```

---

## ✅ Final Checklist

- [ ] 800GB+ free space confirmed
- [ ] Decompression completed
- [ ] QCOW2 conversion completed
- [ ] VHDX conversion completed
- [ ] Both formats uploaded to Hetzner
- [ ] All uploads verified (sizes match)
- [ ] All files organized locally
- [ ] Tested mounting one format
- [ ] Documentation updated with file locations
- [ ] Backup plan in place

---

## 📈 Space Management

### Current Usage:

```bash
ssh fedora-vps "
echo '=== Total Usage ==='
du -sh /mnt/storage/windows-backups/*

echo ''
echo '=== By Type ==='
du -sh /mnt/storage/windows-backups/*.{gz,img,qcow2,vhdx} 2>/dev/null

echo ''
echo '=== Available ==='
df -h /mnt/storage | grep /dev/sda
"
```

### Optional Cleanup:

If you later need space, delete in this order:

1. **Keep:** .qcow2 and .vhdx (bootable formats)
2. **Delete first:** .img (can recreate from .gz)
3. **Delete next:** .gz (if formats are safely on Hetzner)

---

## 🔄 Re-conversion Workflow

With .img kept locally, quickly create new formats:

```bash
# Need VDI for VirtualBox?
qemu-img convert -f raw -O vdi -p win11-backup.img win11-backup.vdi

# Need VMDK for VMware?
qemu-img convert -f raw -O vmdk -p win11-backup.img win11-backup.vmdk

# Takes 30-60 min per format vs hours to download and decompress
```

---

## 🎯 Best Practices

1. **Verify before deleting** - Always check Hetzner copies
2. **Document formats** - Note which works best for your use
3. **Test restore** - Try mounting/booting before deleting originals
4. **Keep checksums** - Save MD5/SHA256 of each file
5. **Regular testing** - Verify backups are bootable

---

## 📚 Quick Reference

### All-in-One Command:

```bash
# Decompress, convert both, upload both (sequential)
ssh fedora-vps 'cd /mnt/storage/windows-backups && \
gunzip -c win11-direct-stream.img.gz > win11-backup.img && \
qemu-img convert -f raw -O qcow2 -c -p win11-backup.img win11-backup.qcow2 && \
qemu-img convert -f raw -O vhdx -o subformat=dynamic -p win11-backup.img win11-backup.vhdx && \
rclone copy win11-backup.qcow2 hetzner-storage:windows-backups/ --progress && \
rclone copy win11-backup.vhdx hetzner-storage:windows-backups/ --progress && \
echo "✅ Done!"'
```

---

**Advantage:** Keep all formats locally for maximum flexibility and speed

**Cost:** ~1TB storage space

**Time saved:** Hours (no downloads, instant format switching)
