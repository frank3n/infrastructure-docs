# Screen Sessions - SSH Timeout Protection

## Why Use Screen?

**Problem:** Long-running operations (decompression, conversion, uploads) fail when SSH connection times out after 2 hours.

**Solution:** `screen` creates persistent terminal sessions that survive SSH disconnects.

## 🚀 Quick Start

### Basic Usage

```bash
# Start a new screen session
ssh fedora-vps
screen -S backup-work

# Your commands run here...
# Even if SSH dies, they keep running!

# Detach (keep running): Ctrl+A then D
# Your SSH can disconnect now - screen keeps running!
```

### Reconnect After Disconnect

```bash
# Reconnect to your session
ssh fedora-vps
screen -r backup-work

# Or if only one session:
screen -r
```

### List Active Sessions

```bash
ssh fedora-vps "screen -ls"

# Output:
# There are screens on:
#     12345.backup-work    (Detached)
#     67890.upload-task    (Attached)
```

## 📚 Common Commands

| Action | Command |
|--------|---------|
| Start new session | `screen -S name` |
| Detach (keep running) | `Ctrl+A` then `D` |
| List sessions | `screen -ls` |
| Reattach | `screen -r name` |
| Kill session | `screen -X -S name quit` |
| Create new window | `Ctrl+A` then `C` |
| Next window | `Ctrl+A` then `N` |
| Previous window | `Ctrl+A` then `P` |
| Split horizontal | `Ctrl+A` then `S` |

## 💡 Real-World Examples

### Example 1: Decompress Large File

```bash
# Start session
ssh fedora-vps
screen -S decompress

# Run decompression
pv backup.img.gz | gunzip > backup.img

# Detach: Ctrl+A, D
# Close laptop, go home, whatever!

# Later... check progress
ssh fedora-vps
screen -r decompress
# Still running!
```

### Example 2: Multiple Operations

```bash
ssh fedora-vps
screen -S multiwork

# Create multiple windows
Ctrl+A, C  # New window - run decompression
Ctrl+A, C  # Another window - monitor disk space
Ctrl+A, C  # Another window - check logs

# Switch between windows
Ctrl+A, N  # Next
Ctrl+A, P  # Previous
Ctrl+A, 0  # Go to window 0
Ctrl+A, 1  # Go to window 1
```

### Example 3: Upload with Progress

```bash
ssh fedora-vps
screen -S upload

# Start upload
rclone copy /mnt/storage/large-file.vhdx hetzner-storage:/ --progress

# Detach and check later
Ctrl+A, D

# Check hours later
screen -r upload
```

## 🔄 Workflow Examples

### Safe Decompression Workflow

```bash
# Connect and start screen
ssh fedora-vps
screen -S decompress-safe

# Install pv for progress
sudo dnf install -y pv

# Decompress with progress bar
pv /mnt/storage/backup.img.gz | gunzip > /mnt/storage/backup.img

# Detach: Ctrl+A, D
# Now safe from SSH timeout!

# Monitor from local machine
watch -n 30 'ssh fedora-vps "du -h /mnt/storage/backup.img"'

# Reconnect when done
ssh fedora-vps
screen -r decompress-safe
```

### Safe Conversion Workflow

```bash
ssh fedora-vps
screen -S convert-safe

# Convert with progress
qemu-img convert -f raw -O vhdx \
    -o subformat=dynamic \
    input.img output.vhdx \
    -p

# Detach: Ctrl+A, D
```

### Complete Backup Pipeline

```bash
ssh fedora-vps
screen -S backup-pipeline

# Step 1: Decompress
echo "Step 1: Decompressing..."
pv backup.img.gz | gunzip > backup.img
echo "✅ Done"

# Step 2: Delete compressed
rm backup.img.gz
echo "✅ Freed space"

# Step 3: Convert
echo "Step 3: Converting..."
qemu-img convert -f raw -O vhdx -o subformat=dynamic backup.img backup.vhdx -p
echo "✅ Done"

# Step 4: Upload
echo "Step 4: Uploading..."
rclone copy backup.vhdx hetzner-storage:/backups/ --progress
echo "✅ Done"

# All steps run without SSH timeout risk!
# Detach anytime: Ctrl+A, D
```

## 🎯 Best Practices

### 1. Name Your Sessions Clearly

```bash
# Good names
screen -S decompress-win11
screen -S upload-to-hetzner
screen -S convert-vhdx

# Bad names
screen -S work
screen -S temp
screen
```

### 2. Check Before Starting

```bash
# See what's already running
screen -ls

# Reattach if exists
screen -r decompress-win11

# Or start new if doesn't exist
screen -S decompress-win11
```

### 3. Clean Up When Done

```bash
# Kill completed sessions
screen -X -S old-session quit

# Or kill all
screen -ls | grep Detached | cut -d. -f1 | xargs -I {} screen -X -S {} quit
```

### 4. Log Output

```bash
# Log to file for later review
screen -S mywork
command 2>&1 | tee /tmp/mywork.log

# Or use screen's built-in logging
Ctrl+A, H  # Toggle logging
```

## 🛠️ Troubleshooting

### Can't Reattach ("Already attached")

```bash
# Force detach first
screen -d backup-work

# Then reattach
screen -r backup-work

# Or do both
screen -dr backup-work
```

### Session Shows "Dead"

```bash
# Remove dead session
screen -wipe

# Start fresh
screen -S new-session
```

### Forgot Session Name

```bash
# List all sessions
screen -ls

# Reattach to first one
screen -r

# If multiple, specify
screen -r 12345  # Use session ID
```

### Screen Hangs

```bash
# Kill screen process
ps aux | grep screen
kill -9 <PID>

# Clean up
screen -wipe
```

## 🔐 Security Notes

### Screen Lock

```bash
# Lock screen (password protect)
Ctrl+A, X
# Enter password to unlock
```

### View Who's Attached

```bash
# Multiuser mode
screen -x session-name
# Both users see same screen
```

## 📝 Automation

### Auto-create Screen Sessions

```bash
# Create script: ~/run-in-screen.sh
#!/bin/bash
SESSION_NAME=$1
COMMAND=$2

screen -dmS "$SESSION_NAME" bash -c "$COMMAND; exec bash"
echo "Started: $SESSION_NAME"
echo "Monitor: screen -r $SESSION_NAME"

# Usage
./run-in-screen.sh decompress "pv backup.gz | gunzip > backup.img"
./run-in-screen.sh convert "qemu-img convert -f raw -O vhdx backup.img backup.vhdx -p"
```

### Status Check Script

```bash
# Create: ~/check-screens.sh
#!/bin/bash
echo "=== Active Screen Sessions ==="
screen -ls

echo ""
echo "=== Disk Usage ==="
df -h /mnt/storage

echo ""
echo "=== Current Files ==="
ls -lh /mnt/storage/*.{img,vhdx,qcow2} 2>/dev/null || echo "No image files"

# Run from local machine
ssh fedora-vps "bash -s" < check-screens.sh
```

## 🆚 Screen vs Tmux

| Feature | Screen | Tmux |
|---------|--------|------|
| Simpler | ✅ Yes | More features |
| Lightweight | ✅ Yes | Heavier |
| Easier keybindings | ✅ Yes | More powerful |
| Good for basic use | ✅ Perfect | Overkill |

**For our backup workflow:** Screen is perfect! Simple and reliable.

## 📖 Summary

**Essential Commands:**
```bash
screen -S name          # Start
Ctrl+A, D               # Detach
screen -r name          # Reattach
screen -ls              # List
screen -X -S name quit  # Kill
```

**Why It Matters:**
- ✅ SSH timeout protection
- ✅ Long operations run safely
- ✅ Monitor anytime
- ✅ Never lose progress
- ✅ Professional workflow

**Use Cases:**
- Decompressing large files (30+ min)
- Converting disk images (30+ min)
- Uploading to cloud storage (1+ hour)
- Running builds/compilations
- Database operations
- Any operation > 2 hours

## 🎓 Learn More

**Official Screen Manual:**
```bash
man screen
```

**Screen Shortcuts:**
```bash
Ctrl+A, ?  # Help screen
```

**Config File:**
```bash
# ~/.screenrc
# Customize your screen settings
startup_message off
defscrollback 10000
hardstatus alwayslastline "%{= kw}%-w%{= BW}%n %t%{-}%+w %= %c"
```

---

**Remember:** Screen sessions are persistent. They keep running even if you:
- Close SSH
- Close terminal
- Reboot local machine
- Lose internet connection

They only stop if:
- You kill the session
- The VPS reboots
- The process completes or errors
