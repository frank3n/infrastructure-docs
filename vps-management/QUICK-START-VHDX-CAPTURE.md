# 🚀 Quick Start: Capture Windows 11 VHDX to VPS

## Option 1: Automated Script (Easiest)

**Run this PowerShell script as Administrator:**

```powershell
cd C:\2025-claude-code-laptop\projects\vps-management
.\capture-and-upload.ps1
```

**What it does:**
1. Downloads Disk2vhd automatically
2. Opens Disk2vhd GUI for you to configure
3. Waits for VHDX creation to complete
4. Uploads to VPS automatically
5. Verifies file integrity

**Optional parameters:**
```powershell
# Custom output location
.\capture-and-upload.ps1 -OutputPath "E:\Backups"

# Also backup to Hetzner after VPS upload
.\capture-and-upload.ps1 -BackupToHetzner

# Just upload existing VHDX (skip capture)
.\capture-and-upload.ps1 -SkipCapture -OutputPath "D:\temp" -VHDXName "existing.vhdx"

# Capture specific volumes
.\capture-and-upload.ps1 -Volumes @("C:","D:")
```

---

## Option 2: Manual Steps

### Step 1: Download Disk2vhd

https://download.sysinternals.com/files/Disk2vhd.zip

Extract to a folder.

### Step 2: Run Disk2vhd as Administrator

Right-click `disk2vhd.exe` → **Run as Administrator**

**Configure:**
- ✅ Select **C:** drive
- ✅ Check **"Use VHDX"**
- ✅ Check **"Use Volume Shadow Copy"**
- Set output path: `D:\temp\win11.vhdx` (or location with space)
- Click **"Create"**

**Wait 1-3 hours** for completion.

### Step 3: Upload to VPS

**Option A: Using SCP (Recommended)**
```bash
scp -i C:/2025-claude-code-laptop/projects/vps-management/ssh-keys/fedora-vps-key \
    D:/temp/win11.vhdx \
    root@138.199.218.115:/mnt/storage/windows-backups/
```

**Option B: Using rsync (with resume support)**
```bash
rsync -avzP --partial \
    -e "ssh -i C:/2025-claude-code-laptop/projects/vps-management/ssh-keys/fedora-vps-key" \
    /d/temp/win11.vhdx \
    root@138.199.218.115:/mnt/storage/windows-backups/
```

### Step 4: Verify Upload

```bash
# Check file on VPS
ssh fedora-vps "ls -lh /mnt/storage/windows-backups/"

# Compare sizes
ssh fedora-vps "stat -c%s /mnt/storage/windows-backups/win11.vhdx"
```

### Step 5: Backup to Hetzner (Optional)

```bash
ssh fedora-vps "rclone copy /mnt/storage/windows-backups/win11.vhdx hetzner-storage:windows-backups/ --progress"
```

---

## 📊 Space Requirements

**Your system:**
- Check C: drive usage: Right-click C: → Properties
- Need temporary space equal to used space on C:

**VPS:**
- ✅ 467GB available at `/mnt/storage`
- ✅ Directory ready: `/mnt/storage/windows-backups/`

**Hetzner Storage Box:**
- Check current usage:
  ```bash
  ssh fedora-vps "rclone size hetzner-storage:"
  ```

---

## ⏱️ Estimated Timeline

| Step | Time | Notes |
|------|------|-------|
| Download Disk2vhd | 1 min | 882KB download |
| Create VHDX | 1-3 hours | Depends on disk size |
| Upload to VPS | 2-6 hours | ~100GB = ~3 hours on good connection |
| Backup to Hetzner | 2-4 hours | From VPS to Hetzner |

**Total: 5-13 hours** (can run overnight)

---

## 💡 Tips

1. **Run overnight**: Start the process before bed
2. **Use Task Scheduler**: Schedule for off-peak hours
3. **Compress first** (optional): Can reduce transfer time
   ```powershell
   Compress-Archive -Path D:\temp\win11.vhdx -DestinationPath D:\temp\win11.vhdx.zip
   ```
4. **Check network**: Ensure stable internet connection
5. **Disable sleep**: Keep computer awake during process

---

## 🔧 Troubleshooting

### "Not enough space"
- Choose a different output drive
- Free up space on target drive
- Use external USB drive

### "Access denied"
- Run as Administrator
- Check if file is in use
- Disable antivirus temporarily

### Upload fails/interrupts
- Use `rsync --partial` for resume support
- Check network stability
- Try rclone (better resume capability)

### VHDX won't mount later
- Ensure VSS was enabled during capture
- Check file wasn't corrupted during transfer
- Verify checksums match

---

## ✅ Verification Checklist

After completion:

- [ ] VHDX file exists locally
- [ ] File size is reasonable (check in properties)
- [ ] File uploaded to VPS successfully
- [ ] File sizes match (local vs VPS)
- [ ] Optional: Backed up to Hetzner
- [ ] Optional: Test mounting VHDX

---

## 🎯 Ready to Start?

**Choose your method:**

### Quick & Easy:
```powershell
cd C:\2025-claude-code-laptop\projects\vps-management
.\capture-and-upload.ps1
```

### Full Control:
Follow **Option 2: Manual Steps** above

---

**Questions or issues?** Check `CAPTURE-WIN11-TO-VPS.md` for detailed documentation.
