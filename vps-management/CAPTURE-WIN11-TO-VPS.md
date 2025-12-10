# Capture Windows 11 VHDX and Stream to VPS

## 🎯 Goal
Create a VHDX image of your live Windows 11 system and transfer it to the VPS `/mnt/storage` directory.

## 📋 Prerequisites

- ✅ VPS with 500GB storage at `/mnt/storage` (467GB available)
- ✅ Rclone configured on VPS with access to Hetzner Storage Box
- ✅ SSH access to VPS configured
- ⚠️ Administrator privileges on Windows 11
- ⚠️ Sufficient disk space (depends on method)

## 🔧 Method 1: Disk2vhd + Direct SSH Stream (Recommended)

**Best for**: Minimal local disk usage, direct to VPS

### Step 1: Download Disk2vhd

```powershell
# Download from Microsoft Sysinternals
$url = "https://download.sysinternals.com/files/Disk2vhd.zip"
$output = "$env:TEMP\Disk2vhd.zip"
Invoke-WebRequest -Uri $url -OutFile $output
Expand-Archive -Path $output -DestinationPath "$env:TEMP\Disk2vhd" -Force
```

Or download manually: https://docs.microsoft.com/en-us/sysinternals/downloads/disk2vhd

### Step 2: Create VHDX to Temporary Location

Run Disk2vhd (must run as Administrator):
```powershell
# Create VHDX of C: drive
cd $env:TEMP\Disk2vhd
.\disk2vhd.exe C: D:\temp\win11.vhdx
```

**Options in GUI:**
- ✅ Check "Use VHDX" (not VHD)
- ✅ Check "Use Volume Shadow Copy" (allows live capture)
- ✅ Select the volume(s) you want to capture
- Set output path to a location with enough space

**Estimated Time**: 1-3 hours depending on disk size

### Step 3: Stream to VPS via SSH

While or after creation, upload to VPS:

```powershell
# Method A: Using pv (with progress) via SSH
ssh fedora-vps "cat > /mnt/storage/win11-backup.vhdx" < D:\temp\win11.vhdx

# Method B: Using SSH with compression
type D:\temp\win11.vhdx | ssh fedora-vps "gzip -c > /mnt/storage/win11-backup.vhdx.gz"

# Method C: Using rclone from Windows (if installed locally)
rclone copy D:\temp\win11.vhdx vps-storage:/mnt/storage/ --progress --stats 5s
```

## 🚀 Method 2: Disk2vhd + Rclone Upload from VPS

**Best for**: Reliable transfer with resume capability

### Step 1: Create VHDX Locally

Same as Method 1, Step 2.

### Step 2: Copy to VPS via SCP

```powershell
# Copy directly to VPS
scp -i C:/2025-claude-code-laptop/projects/vps-management/ssh-keys/fedora-vps-key D:\temp\win11.vhdx root@138.199.218.115:/mnt/storage/

# Or with progress using rsync (if available in Git Bash)
rsync -avz --progress -e "ssh -i C:/2025-claude-code-laptop/projects/vps-management/ssh-keys/fedora-vps-key" D:/temp/win11.vhdx root@138.199.218.115:/mnt/storage/
```

### Step 3: Backup to Hetzner Storage Box

From VPS:
```bash
# Upload to Hetzner for long-term storage
ssh fedora-vps "rclone copy /mnt/storage/win11.vhdx hetzner-storage:windows-backups/ --progress --transfers 4"
```

## 💾 Method 3: Direct Pipe Creation (Advanced)

**Best for**: Zero local disk usage, stream directly during creation

This requires creating a named pipe and streaming during VHDX creation:

```powershell
# Create PowerShell script for streaming
$script = @'
$process = Start-Process -FilePath "disk2vhd.exe" -ArgumentList "C: \\.\pipe\vhdx" -PassThru -NoNewWindow
$pipe = New-Object System.IO.Pipes.NamedPipeServerStream("vhdx", [System.IO.Pipes.PipeDirection]::Out)
$pipe.WaitForConnection()

$ssh = New-Object System.Diagnostics.Process
$ssh.StartInfo.FileName = "ssh"
$ssh.StartInfo.Arguments = "-i C:/2025-claude-code-laptop/projects/vps-management/ssh-keys/fedora-vps-key root@138.199.218.115 'cat > /mnt/storage/win11-live.vhdx'"
$ssh.StartInfo.UseShellExecute = $false
$ssh.StartInfo.RedirectStandardInput = $true
$ssh.Start()

$pipe.CopyTo($ssh.StandardInput.BaseStream)
$pipe.Close()
$ssh.WaitForExit()
'@
```

**Note**: This method is complex and may have compatibility issues.

## 🛡️ Method 4: Hyper-V Checkpoint (If Hyper-V Enabled)

If your Windows 11 is running in Hyper-V:

```powershell
# Export VM
Export-VM -Name "Win11VM" -Path "D:\temp\vm-export"

# Copy VHDX to VPS
scp -i C:/2025-claude-code-laptop/projects/vps-management/ssh-keys/fedora-vps-key "D:\temp\vm-export\Virtual Hard Disks\*.vhdx" root@138.199.218.115:/mnt/storage/
```

## 📊 Check Available Space

Before starting, verify space:

**On Windows:**
```powershell
# Check source drive size
Get-Volume C | Select-Object DriveLetter, Size, SizeRemaining

# Check temp location space
Get-Volume D | Select-Object DriveLetter, Size, SizeRemaining
```

**On VPS:**
```bash
ssh fedora-vps "df -h /mnt/storage"
```

## 🎛️ Recommended Workflow

### For Most Users (Method 1 + 2 Combined):

1. **Prepare VPS Storage**
   ```bash
   ssh fedora-vps "mkdir -p /mnt/storage/windows-backups"
   ```

2. **Download and Run Disk2vhd** (as Administrator)
   - Download from: https://download.sysinternals.com/files/Disk2vhd.zip
   - Extract to a folder
   - Right-click `disk2vhd.exe` → Run as Administrator
   - Select C: drive
   - Enable "Use VHDX"
   - Enable "Use Volume Shadow Copy"
   - Set output path (make sure enough space)
   - Click "Create"

3. **Monitor Progress**
   - Disk2vhd will show progress
   - Can take 1-3 hours for 100-250GB system

4. **Upload to VPS Using SCP**
   ```bash
   # From Git Bash
   cd /c/path/to/vhdx/location
   scp -i C:/2025-claude-code-laptop/projects/vps-management/ssh-keys/fedora-vps-key ./win11.vhdx root@138.199.218.115:/mnt/storage/windows-backups/
   ```

5. **Backup to Hetzner (Optional but Recommended)**
   ```bash
   ssh fedora-vps "rclone copy /mnt/storage/windows-backups/win11.vhdx hetzner-storage:windows-backups/ --progress --stats 5s"
   ```

## 📈 Transfer Speed Optimization

### Using Rclone for Upload

If you have rclone installed on Windows:

```powershell
# Configure VPS SFTP remote in local rclone
rclone config

# Transfer with optimized settings
rclone copy C:\path\to\win11.vhdx vps-sftp:/mnt/storage/windows-backups/ `
    --progress `
    --stats 5s `
    --transfers 4 `
    --checkers 4 `
    --buffer-size 64M
```

### Using rsync (in Git Bash)

```bash
rsync -avzP --partial \
    -e "ssh -i C:/2025-claude-code-laptop/projects/vps-management/ssh-keys/fedora-vps-key" \
    /c/path/to/win11.vhdx \
    root@138.199.218.115:/mnt/storage/windows-backups/

# --partial allows resume if interrupted
```

## 🔐 Verification After Transfer

```bash
# Check file exists and size on VPS
ssh fedora-vps "ls -lh /mnt/storage/windows-backups/"

# Verify file integrity (MD5)
# On Windows
certutil -hashfile C:\path\to\win11.vhdx MD5

# On VPS
ssh fedora-vps "md5sum /mnt/storage/windows-backups/win11.vhdx"
```

## 💡 Tips

1. **Disk Space Requirements**
   - Local: At least equal to used space on C: drive
   - VPS: 467GB available should be enough for most systems

2. **Shadow Copy Service**
   - Disk2vhd uses VSS (Volume Shadow Copy)
   - Allows live capture without rebooting
   - May increase disk usage temporarily

3. **Compression**
   - VHDX files compress well (50-70% reduction)
   - Consider compressing before transfer:
     ```powershell
     Compress-Archive -Path win11.vhdx -DestinationPath win11.vhdx.zip
     ```

4. **Resume Capability**
   - Use `rsync --partial` or `rclone copy` for resume support
   - SCP does not support resume

5. **Background Transfer**
   - Transfers can take many hours for 100GB+
   - Consider running in a screen/tmux session
   - Or use Task Scheduler to run overnight

## 🚨 Important Notes

- ⚠️ **Disk2vhd requires Administrator privileges**
- ⚠️ **System will be slower during capture** (due to VSS)
- ⚠️ **Verify space** on both source and destination
- ⚠️ **Test the VHDX** after transfer before deleting local copy
- ⚠️ **Legal compliance**: Ensure you have rights to create system images

## 🆘 Troubleshooting

### Disk2vhd Fails
- Run as Administrator
- Check if VSS service is running: `net start vss`
- Ensure destination has enough space
- Try creating VHDX of smaller volume first

### Transfer Interrupted
- Use rsync with --partial flag for resume
- Or use rclone (supports resume automatically)
- Check network stability

### Out of Space on VPS
- Delete large VHDX from Vultr (already on Hetzner):
  ```bash
  ssh fedora-vps "rclone delete vultr-s3:london-vhdx/DESKTOP-c.VHDX"
  ```
  This would free up ~239GB

## 📚 Resources

- Disk2vhd: https://docs.microsoft.com/en-us/sysinternals/downloads/disk2vhd
- VHDX Format: https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-vhdx/
- Hyper-V Manager: Built into Windows 11 Pro/Enterprise

---

**Ready to proceed?** Let me know which method you'd like to use, and I can provide detailed step-by-step commands.
