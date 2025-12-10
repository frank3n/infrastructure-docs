# Expand VPS Storage Disk

## 🎯 Goal
Expand the 500GB `/mnt/storage` drive to give more space for conversions.

## 📊 Current State

```
Disk: /dev/sda (500GB)
Mount: /mnt/storage
Used: 190GB
Free: 277GB
Filesystem: ext4
```

**Problem:** Need ~800GB+ to keep all formats during conversion.

---

## 🔧 Expansion Process

### Step 1: Expand Volume in Hetzner Cloud Console

1. **Log into Hetzner Cloud**
   - https://console.hetzner.cloud/

2. **Select your VPS**
   - Find server: 138.199.218.115

3. **Go to Volumes section**
   - Find volume attached as `/mnt/storage`
   - Current size: 500GB

4. **Click "Resize"**
   - Choose new size (e.g., 1000GB or 1500GB)
   - Confirm expansion
   - **Note:** Can only expand, not shrink!

5. **Wait for completion**
   - Usually takes 1-5 minutes
   - Volume stays mounted during resize

### Step 2: Resize Partition on VPS

After expanding in Hetzner console, the disk is bigger but the partition and filesystem don't know yet:

```bash
ssh fedora-vps

# Check current disk size (should show new size)
lsblk

# Example output:
# NAME   SIZE
# sda   1000G  (new size)
# └─sda1 500G  (old partition size)

# Resize the partition to use all space
sudo growpart /dev/sda 1

# Resize the ext4 filesystem
sudo resize2fs /dev/sda
```

**Alternative if no partition table:**
```bash
# If /dev/sda is used directly without partitions
sudo resize2fs /dev/sda
```

### Step 3: Verify Expansion

```bash
# Check new size
df -h /mnt/storage

# Should show new total size
# Example:
# Filesystem      Size  Used Avail Use% Mounted on
# /dev/sda        985G  190G  795G  20% /mnt/storage
```

---

## 💰 Cost Considerations

### Hetzner Volume Pricing (as of 2024):

- **500GB:** ~€5-10/month
- **1000GB:** ~€10-20/month
- **1500GB:** ~€15-30/month

**Check current pricing:**
https://www.hetzner.com/cloud/volumes

### Optimization:

1. **Temporary expansion:**
   - Expand to 1000GB
   - Do conversions
   - Shrink back (requires recreation)

2. **Keep expanded:**
   - Use for other backups
   - Store multiple system images
   - Cache for large transfers

---

## 📋 After Expansion - Conversion Steps

### With 1000GB Total Space:

Now you can use the **CONVERT-PLENTY-DISK-SPACE.md** approach!

```bash
# You'll have:
# - 190GB .img.gz (already there)
# - 500GB .img (decompressed)
# - 190GB .qcow2
# - 190GB .vhdx
# Total: ~1,070GB

# With 1000GB, you'll have room for everything + extra
```

### Quick Conversion (Parallel):

```bash
ssh fedora-vps "
cd /mnt/storage/windows-backups

# Decompress
gunzip -c win11-direct-stream.img.gz > win11-backup.img &

# Wait for decompress, then convert both in parallel
wait

qemu-img convert -f raw -O qcow2 -c -p win11-backup.img win11-backup.qcow2 &
qemu-img convert -f raw -O vhdx -o subformat=dynamic -p win11-backup.img win11-backup.vhdx &

wait

# Upload both in parallel
rclone copy win11-backup.qcow2 hetzner-storage:windows-backups/ --progress &
rclone copy win11-backup.vhdx hetzner-storage:windows-backups/ --progress &

wait

echo 'All done! All formats available locally + on Hetzner'
"
```

---

## 🔄 Alternative: Temporary Larger VPS

If you don't want to expand permanently:

### Option A: Create Temporary VPS

1. **Spin up new VPS with 1TB disk**
   - Hetzner Cloud: CX11 + 1TB volume
   - Cost: ~€20 for one month

2. **Transfer .gz file**
   ```bash
   # From current VPS to new VPS
   scp /mnt/storage/windows-backups/win11-direct-stream.img.gz root@new-vps:/data/
   ```

3. **Do conversions on new VPS**

4. **Upload to Hetzner Storage Box**

5. **Delete temporary VPS**

### Option B: Download and Convert Locally

If you have space on your Windows machine:

1. **Download .gz from Hetzner**
   ```bash
   rclone copy hetzner-storage:windows-backups/win11-direct-stream.img.gz D:/temp/
   ```

2. **Decompress and convert on Windows**
   ```bash
   # Install qemu-img for Windows
   # Or use Hyper-V tools
   ```

3. **Upload formats back to Hetzner**

---

## 🎯 Recommended Sizes

### For Your Use Case (Windows 11 backups):

| Size | What You Can Do |
|------|-----------------|
| **500GB** | ❌ Can't fit decompressed image |
| **800GB** | ✅ One format at a time (tight) |
| **1000GB** | ✅ All formats + some headroom |
| **1500GB** | ✅ Multiple backups + archives |

**Recommendation:** **1000GB** (double current, comfortable for all operations)

---

## 📝 Expansion Checklist

Before expanding:

- [ ] Current .gz uploaded to Hetzner ✅ (in progress)
- [ ] VPS backed up (optional but recommended)
- [ ] Know expansion cost
- [ ] Understand can't shrink without recreation

During expansion:

- [ ] Expand volume in Hetzner console
- [ ] Run `growpart` on VPS
- [ ] Run `resize2fs` on VPS
- [ ] Verify with `df -h`

After expansion:

- [ ] Download .gz back to VPS (if deleted)
- [ ] Run parallel conversion script
- [ ] Verify all formats created
- [ ] Upload to Hetzner Storage Box
- [ ] Test one format boots

---

## 🔍 Troubleshooting Expansion

### Partition doesn't grow

**Check partition table:**
```bash
sudo fdisk -l /dev/sda
```

**If no partition table (direct filesystem):**
```bash
sudo resize2fs /dev/sda
```

### Filesystem doesn't resize

**Check filesystem:**
```bash
sudo e2fsck -f /dev/sda
sudo resize2fs /dev/sda
```

### Changes not showing

**Remount:**
```bash
sudo umount /mnt/storage
sudo mount /dev/sda /mnt/storage
df -h /mnt/storage
```

---

## 💡 Pro Tips

1. **Expand before conversions** - Saves time and complexity

2. **Round numbers** - Expand to 1TB instead of 850GB

3. **Monitor usage** - Set up alerts before hitting 90%

4. **Regular cleanup** - Delete old backups after verification

5. **Documentation** - Update your notes with new size

---

## 🆘 If Expansion Not Available

Some VPS providers don't support online expansion. Alternatives:

### Option 1: Add Second Volume

```bash
# Attach new 500GB volume as /dev/sdb
sudo mkfs.ext4 /dev/sdb
sudo mount /dev/sdb /mnt/storage2

# Use for conversions
cd /mnt/storage2
# Run conversions here
```

### Option 2: Use Hetzner Storage Box Directly

```bash
# Mount Hetzner Storage Box via SSHFS
# (if we get SSHFS working)
# Then work directly on Hetzner storage
```

### Option 3: Cloud Storage + Rclone Mount

```bash
# Mount Hetzner with rclone
rclone mount hetzner-storage: /mnt/hetzner --daemon

# Work directly on mounted storage
# (slower but unlimited space)
```

---

## 📊 Space Planning

### After Expansion to 1TB:

```
Total: 1000GB
Used by .gz: 190GB
Available: 810GB

Space needed for conversions:
- Raw .img: 500GB
- QCOW2: 190GB
- VHDX: 190GB
Total: 880GB

Headroom: 810GB available - 880GB needed = -70GB
```

**Oops! Still 70GB short for keeping everything!**

**Solution: Expand to 1.5TB or delete .img after conversions**

### Better: 1.5TB Expansion

```
Total: 1500GB
Used: 190GB
Available: 1310GB

After all conversions: ~880GB used
Headroom: 430GB free (comfortable!)
```

---

## ✅ Final Recommendation

**Expand to 1.5TB** (~€25-30/month) for:
- ✅ All formats kept locally
- ✅ Comfortable headroom
- ✅ Future backups
- ✅ No manual cleanup needed
- ✅ Fast local access

**Or keep 500GB** and use space-efficient approach:
- Upload .gz to Hetzner (done!)
- Convert on-demand when needed
- Lower cost (~€5-10/month)

---

## 📚 Commands Reference

```bash
# Check current size
df -h /mnt/storage
lsblk

# After Hetzner console expansion
sudo growpart /dev/sda 1
sudo resize2fs /dev/sda

# Verify
df -h /mnt/storage

# Check what's using space
du -sh /mnt/storage/*
```

---

**Your current upload is running - when done, you'll have a safe backup on Hetzner!**

**Tomorrow you can decide:**
- Expand disk → Convert locally (faster)
- Keep as-is → Convert elsewhere (cheaper)
