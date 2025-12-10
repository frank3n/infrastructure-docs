# Mount VPS Storage to Windows X: Drive

## Summary

Mount the VPS /mnt/storage directory to Windows X: drive using SSHFS-Win.

**VPS Details:**
- Host: 138.199.218.115
- User: root
- Remote Path: /mnt/storage (500GB storage drive)
- Local Mount: X: drive

## 📋 Prerequisites

✅ SSHFS-Win installed at: `C:\Program Files\SSHFS-Win\`
✅ WinFsp service running (required by SSHFS-Win)
✅ SSH key: `C:\2025-claude-code-laptop\projects\vps-management\ssh-keys\fedora-vps-key`
✅ SFTP access verified and working

## 🔍 Troubleshooting Findings

### Issue Discovered
SSHFS-Win was failing to mount with error: **"Connection reset by peer"**

### Root Cause Identified
The SSH private key path was being corrupted when passed to SSHFS:
- ❌ **Wrong**: `C:\2025-claude-code-laptop\...` (backslashes stripped)
- ✅ **Correct**: `C:/2025-claude-code-laptop\...` (forward slashes)

### Tests Performed
1. ✅ SSH connection works fine
2. ✅ SFTP subsystem works correctly
3. ✅ WinFsp service is running
4. ❌ SSHFS-Win fails with backslash paths
5. ⚠️ SSHFS-Win with forward-slash paths: Connection established but drops immediately

## 🚀 Mount Scripts

### Option 1: PowerShell Script (Recommended)

**File**: `mount-vps-x.ps1`

Run from PowerShell:
```powershell
cd C:\2025-claude-code-laptop\projects\vps-management
.\mount-vps-x.ps1
```

Or right-click → "Run with PowerShell"

### Option 2: Batch File

**File**: `mount-vps-x.bat`

Double-click to run or execute from Command Prompt:
```cmd
C:\2025-claude-code-laptop\projects\vps-management\mount-vps-x.bat
```

### Option 3: Debug Version

**File**: `mount-debug-verbose.ps1`

For detailed troubleshooting with full debug output:
```powershell
cd C:\2025-claude-code-laptop\projects\vps-management
.\mount-debug-verbose.ps1
```

This will show all SSHFS debug messages in real-time.

## 📝 Manual Mount Command

If you want to run the mount command manually:

```cmd
"C:\Program Files\SSHFS-Win\bin\sshfs.exe" root@138.199.218.115:/mnt/storage X: -o IdentityFile="C:/2025-claude-code-laptop/projects/vps-management/ssh-keys/fedora-vps-key" -o StrictHostKeyChecking=no -o ServerAliveInterval=15 -o ServerAliveCountMax=3 -o reconnect -o volname=VPS-Storage
```

**Key Points:**
- Use **forward slashes** (`/`) in the IdentityFile path
- The `reconnect` option will automatically reconnect if connection drops
- `ServerAliveInterval` keeps the connection alive
- `volname` sets the drive label to "VPS-Storage"

## 🗑️ Unmount X: Drive

### Using Batch File
**File**: `unmount-vps-x.bat`

Double-click or run:
```cmd
C:\2025-claude-code-laptop\projects\vps-management\unmount-vps-x.bat
```

### Manual Unmount
```cmd
taskkill /F /IM sshfs.exe
net use X: /delete /y
```

Or from PowerShell:
```powershell
Stop-Process -Name sshfs -Force -ErrorAction SilentlyContinue
net use X: /delete /y
```

## ⚠️ Known Issues

### Issue: Connection Reset by Peer

**Symptoms:**
- SSHFS process starts but immediately exits
- "Connection reset by peer" in debug logs
- X: drive never appears

**Possible Causes:**
1. Network instability
2. SSH connection drops during SFTP handshake
3. Incompatibility between SSHFS-Win and server's SFTP implementation
4. Antivirus/Firewall blocking the connection

**Solutions to Try:**

1. **Run as Administrator**
   - Right-click the PowerShell/Batch file
   - Select "Run as Administrator"

2. **Disable Antivirus Temporarily**
   - Some antivirus software blocks SSHFS/WinFsp
   - Try temporarily disabling and testing

3. **Check Firewall**
   - Ensure SSH (port 22) is allowed outbound
   - Add exception for sshfs.exe

4. **Restart WinFsp Service**
   ```powershell
   Restart-Service WinFsp.Launcher
   ```

5. **Use Alternative: Map via SSH Tunnel + SMB**
   - If SSHFS continues to fail
   - Set up Samba on VPS
   - Forward port via SSH tunnel
   - Map as network drive

## 🔄 Alternative: Rclone Mount

If SSHFS-Win continues to have issues, you can use rclone mount instead:

### Configure Rclone on Windows

1. Install rclone on Windows: https://rclone.org/downloads/

2. Copy rclone config from VPS:
   ```bash
   scp fedora-vps:~/.config/rclone/rclone.conf "%USERPROFILE%\.config\rclone\"
   ```

3. Add VPS SFTP remote to local rclone config:
   ```cmd
   rclone config
   ```

   Configure:
   - Name: `vps-storage`
   - Type: `sftp`
   - Host: `138.199.218.115`
   - User: `root`
   - Port: `22`
   - Key file: `C:/2025-claude-code-laptop/projects/vps-management/ssh-keys/fedora-vps-key`

4. Mount with rclone:
   ```cmd
   rclone mount vps-storage:/mnt/storage X: --vfs-cache-mode writes
   ```

## 🎯 Next Steps

1. **Try running the PowerShell script directly from Windows**:
   - Open File Explorer
   - Navigate to: `C:\2025-claude-code-laptop\projects\vps-management`
   - Right-click `mount-vps-x.ps1`
   - Select "Run with PowerShell"

2. **If that fails, run the debug version**:
   - Right-click `mount-debug-verbose.ps1`
   - Select "Run with PowerShell"
   - Observe the full debug output
   - Look for specific error messages

3. **If SSHFS-Win doesn't work**:
   - Consider using rclone mount instead (more reliable)
   - Or set up SMB/Samba share on VPS with SSH tunnel

## 📊 Verification

Once mounted successfully, verify with:

```powershell
# Check if X: drive exists
Test-Path X:

# List contents
dir X:\

# Check drive info
Get-PSDrive X

# Test write access
echo "test" > X:\test.txt
cat X:\test.txt
del X:\test.txt
```

## 📚 Documentation

- SSHFS-Win: https://github.com/winfsp/sshfs-win
- WinFsp: https://github.com/winfsp/winfsp
- Rclone SFTP: https://rclone.org/sftp/

## 🆘 Getting Help

If issues persist:
1. Check WinFsp/SSHFS-Win GitHub issues
2. Try rclone mount as alternative
3. Consider SMB/Samba share via SSH tunnel

---

**Status**: Scripts created and ready to test
**Next Action**: Run `mount-vps-x.ps1` directly from Windows PowerShell
