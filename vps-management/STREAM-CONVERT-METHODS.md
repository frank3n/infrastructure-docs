# Stream Convert & Upload (Zero Disk Space)

## 🎯 Goal
Convert disk image formats **without** using local disk space by streaming through pipes.

---

## 💡 Concept

Instead of:
```
.gz → decompress → .img (500GB disk) → convert → .qcow2 (190GB disk) → upload
```

Do this:
```
.gz → decompress → [pipe] → convert → [pipe] → upload
          ↓            ↓           ↓         ↓
       in memory   no disk    in memory  to Hetzner
```

**Disk usage:** ZERO additional space needed!

---

## 🔧 Method 1: Named Pipes (Linux FIFO)

### How It Works:

```bash
# Create named pipes (virtual files in memory)
mkfifo /tmp/raw.fifo
mkfifo /tmp/qcow2.fifo

# Start 3 processes that feed into each other:
gunzip -c source.img.gz > /tmp/raw.fifo &
qemu-img convert -f raw -O qcow2 /tmp/raw.fifo /tmp/qcow2.fifo &
rclone rcat hetzner:dest.qcow2 < /tmp/qcow2.fifo &

wait  # Wait for all to complete
```

### Complete Script:

**File:** `stream-convert-upload.sh`

```bash
#!/bin/bash
SOURCE="/mnt/storage/windows-backups/win11-direct-stream.img.gz"

# Create pipes
mkfifo /tmp/raw.fifo /tmp/qcow2.fifo

# Pipeline: decompress → convert → upload
(gunzip -c "$SOURCE" > /tmp/raw.fifo) &
(qemu-img convert -f raw -O qcow2 -c /tmp/raw.fifo /tmp/qcow2.fifo) &
(rclone rcat hetzner-storage:windows-backups/win11.qcow2 < /tmp/qcow2.fifo --progress) &

wait
rm /tmp/raw.fifo /tmp/qcow2.fifo

echo "Done - zero disk space used!"
```

**Run:**
```bash
ssh fedora-vps "bash /tmp/stream-convert-upload.sh"
```

---

## 🔧 Method 2: Direct Streaming (Simpler)

### QCOW2:

```bash
# Decompress and convert in one command
gunzip -c win11-direct-stream.img.gz | \
    qemu-img convert -f raw -O qcow2 -c - - | \
    rclone rcat hetzner-storage:windows-backups/win11.qcow2 --progress
```

**Explanation:**
- `gunzip -c` - Decompress to stdout
- `|` - Pipe to next command
- `qemu-img convert ... - -` - Read from stdin, write to stdout
- `rclone rcat` - Read from stdin, upload to Hetzner

### VHDX:

```bash
gunzip -c win11-direct-stream.img.gz | \
    qemu-img convert -f raw -O vhdx -o subformat=dynamic - - | \
    rclone rcat hetzner-storage:windows-backups/win11.vhdx --progress
```

---

## 🔧 Method 3: Process Substitution (Bash Feature)

```bash
# One-liner using bash process substitution
qemu-img convert -f raw -O qcow2 -c \
    <(gunzip -c win11-direct-stream.img.gz) \
    >(rclone rcat hetzner-storage:windows-backups/win11.qcow2)
```

---

## ⚡ Method 4: Parallel Both Formats

Convert QCOW2 and VHDX **simultaneously** by decompressing twice:

```bash
#!/bin/bash
SOURCE="/mnt/storage/windows-backups/win11-direct-stream.img.gz"

# QCOW2 in background
(
    gunzip -c "$SOURCE" | \
    qemu-img convert -f raw -O qcow2 -c - - | \
    rclone rcat hetzner-storage:windows-backups/win11.qcow2 --progress
) &

# VHDX in background
(
    gunzip -c "$SOURCE" | \
    qemu-img convert -f raw -O vhdx -o subformat=dynamic - - | \
    rclone rcat hetzner-storage:windows-backups/win11.vhdx --progress
) &

wait
echo "Both formats uploaded!"
```

**Time:** Same as sequential (limited by decompression speed)
**Disk:** Still zero!

---

## 📊 Comparison

| Method | Disk Usage | Speed | Complexity | Resumable |
|--------|------------|-------|------------|-----------|
| **Temp files** | 880GB | Fast | Simple | Yes |
| **Named pipes** | 0GB | Medium | Medium | No |
| **Direct stream** | 0GB | Medium | Simple | No |
| **Parallel stream** | 0GB | Medium | Medium | No |

---

## ⏱️ Timeline

### Single Format (QCOW2 or VHDX):

1. Decompress (streaming): Continuous
2. Convert (streaming): Continuous
3. Upload (streaming): Continuous

**Total:** 2-4 hours (all happening simultaneously)

### Both Formats (Sequential):

**Total:** 4-8 hours

### Both Formats (Parallel):

**Total:** 2-4 hours (but CPU intensive)

---

## 🎯 Recommended Approach

### If Upload Already Complete:

You already have `.img.gz` on Hetzner!

**Option A: Convert on Hetzner Storage Box**
```bash
# SSH to Hetzner Storage Box (if they allow it)
# Then convert there
```

**Option B: Download when needed**
```bash
# When you need a format, download .gz and convert locally
rclone copy hetzner-storage:windows-backups/win11-direct-stream.img.gz /local/
gunzip -c win11-direct-stream.img.gz | qemu-img convert -f raw -O qcow2 -c - win11.qcow2
```

**Option C: Stream from Hetzner → VPS → Convert → Upload back**
```bash
# Download and convert in one stream
rclone cat hetzner-storage:windows-backups/win11-direct-stream.img.gz | \
    gunzip -c | \
    qemu-img convert -f raw -O qcow2 -c - - | \
    rclone rcat hetzner-storage:windows-backups/win11.qcow2 --progress
```

---

## 💾 Memory Requirements

### Streaming:
- **Buffers:** ~256MB per process
- **qemu-img:** ~512MB for conversion
- **rclone:** ~256MB for upload
- **Total:** ~1-2GB RAM (very manageable)

### vs Traditional:
- **Temp files:** 500GB disk space
- **Memory:** Similar RAM usage

**Winner:** Streaming (no disk space needed!)

---

## 🔍 Monitoring Streams

### Watch Progress:

```bash
# rclone shows progress
rclone rcat ... --progress --stats 5s

# Watch network usage
ssh fedora-vps "iftop -i eth0"

# Watch processes
ssh fedora-vps "ps aux | grep -E 'gunzip|qemu-img|rclone'"
```

### Check Hetzner:

```bash
# See file growing
ssh fedora-vps "watch -n 10 'rclone size hetzner-storage:windows-backups/'"
```

---

## ⚠️ Limitations

### Can't Resume:
- If interrupted, must start over
- No partial file on destination
- Use stable connection

### Slower Than Files:
- Pipes have overhead
- Can't parallelize compression
- ~10-20% slower than temp files

### Limited Error Recovery:
- Hard to debug which step failed
- Can't verify intermediate stages
- Test small file first

---

## 🆘 Troubleshooting

### Pipe Broken:

```bash
# One process exited early
# Check which one failed:
ps aux | grep -E 'gunzip|qemu|rclone'

# Check error logs
dmesg | tail -20
```

### Out of Memory:

```bash
# Reduce buffer sizes
rclone rcat ... --buffer-size 16M

# Limit qemu-img memory
qemu-img convert -m 2 ...  # 2GB max
```

### Slow Upload:

```bash
# Check bottleneck
iftop  # Network?
top    # CPU?
iostat # Disk (should be near zero)?

# The .gz decompression is usually the bottleneck
```

---

## 💡 Pro Tips

### 1. Test First:

```bash
# Test with small file
head -c 1G win11-direct-stream.img.gz > test.img.gz
# Try streaming with test file
```

### 2. Use pv for Progress:

```bash
gunzip -c file.gz | pv -s 500G | qemu-img convert ... | rclone rcat ...
```

### 3. Add Verification:

```bash
# Calculate checksum during stream
gunzip -c file.gz | tee >(md5sum > /tmp/checksum.txt) | qemu-img convert ...
```

### 4. Log Everything:

```bash
(gunzip -c ... | qemu-img ... | rclone ...) 2>&1 | tee /tmp/stream.log
```

---

## 🎯 One-Liner Summary

### Convert .gz to QCOW2 on Hetzner (Zero Disk):

```bash
ssh fedora-vps "
gunzip -c /mnt/storage/windows-backups/win11-direct-stream.img.gz | \
qemu-img convert -f raw -O qcow2 -c - - | \
rclone rcat hetzner-storage:windows-backups/win11-backup.qcow2 --progress --stats 30s
"
```

### Convert .gz to VHDX on Hetzner (Zero Disk):

```bash
ssh fedora-vps "
gunzip -c /mnt/storage/windows-backups/win11-direct-stream.img.gz | \
qemu-img convert -f raw -O vhdx -o subformat=dynamic - - | \
rclone rcat hetzner-storage:windows-backups/win11-backup.vhdx --progress --stats 30s
"
```

### Both at Once:

```bash
ssh fedora-vps "
# QCOW2
(gunzip -c /mnt/storage/windows-backups/win11-direct-stream.img.gz | \
 qemu-img convert -f raw -O qcow2 -c - - | \
 rclone rcat hetzner-storage:windows-backups/win11-backup.qcow2 --progress) &

# VHDX
(gunzip -c /mnt/storage/windows-backups/win11-direct-stream.img.gz | \
 qemu-img convert -f raw -O vhdx -o subformat=dynamic - - | \
 rclone rcat hetzner-storage:windows-backups/win11-backup.vhdx --progress) &

wait
echo 'Both complete!'
"
```

---

## ✅ Best Approach For You

**Since .gz is already uploaded to Hetzner:**

### Option 1: Download and stream convert locally
```bash
# On VPS with zero disk space
rclone cat hetzner-storage:windows-backups/win11-direct-stream.img.gz | \
gunzip -c | \
qemu-img convert -f raw -O qcow2 -c - - | \
rclone rcat hetzner-storage:windows-backups/win11-backup.qcow2 --progress
```

### Option 2: Expand disk tomorrow
- Expand to 1.5TB
- Download .gz
- Convert traditionally (faster, resumable)

### Option 3: Keep .gz, convert when needed
- .gz IS a complete backup
- Decompress + convert on-demand
- Saves Hetzner storage cost

---

**You can run the stream conversion tomorrow after the upload finishes!** 🚀
