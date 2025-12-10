# Connect to TigerVNC NOW - Quick Guide

## ✅ Status: VNC Server is RUNNING

- Server: 138.199.218.115
- VNC Port: 5901
- Password: `vncpass`
- Display: :1
- Session: XFCE Desktop

## 🔒 Important: VNC is on localhost only (secure)

You **CANNOT** connect directly to `138.199.218.115:5901`
You **MUST** use an SSH tunnel (see below)

## 📡 How to Connect (2 Steps)

### Step 1: Create SSH Tunnel

Open a terminal/command prompt and run:

```bash
ssh -L 5901:localhost:5901 fedora-vps
```

**Keep this terminal window open!**

### Step 2: Connect VNC Viewer

In your VNC viewer, connect to:
```
localhost:5901
```
OR
```
127.0.0.1:5901
```

Password: `vncpass`

## 🖥️ Windows Users

### Option A: Using Windows Terminal / PowerShell

1. Open PowerShell or Windows Terminal
2. Run:
   ```powershell
   ssh -L 5901:localhost:5901 fedora-vps
   ```
3. Keep this window open
4. Open TigerVNC Viewer
5. Connect to: `localhost:5901`

### Option B: Using PuTTY

1. Open PuTTY
2. Session → Host Name: `138.199.218.115`
3. Connection → SSH → Tunnels:
   - Source port: `5901`
   - Destination: `localhost:5901`
   - Click "Add"
4. Click "Open" to connect
5. Keep PuTTY window open
6. Open TigerVNC Viewer
7. Connect to: `localhost:5901`

## 🍎 macOS / Linux Users

1. Open Terminal
2. Run:
   ```bash
   ssh -L 5901:localhost:5901 fedora-vps
   ```
3. Keep terminal open
4. Open VNC Viewer
5. Connect to: `localhost:5901`

## 📥 Download VNC Viewers

- **TigerVNC**: https://tigervnc.org/ (recommended)
- **RealVNC Viewer**: https://www.realvnc.com/en/connect/download/viewer/
- **TightVNC**: https://www.tightvnc.com/download.php

## ❌ Common Errors & Fixes

### "Connection refused"
**Cause**: No SSH tunnel OR trying to connect directly to server IP
**Fix**: Create SSH tunnel first (see Step 1 above)

### "Cannot connect to localhost:5901"
**Cause**: SSH tunnel not established
**Fix**: Make sure Step 1 is done and the terminal is still open

### "Authentication failed"
**Cause**: Wrong password
**Fix**: Password is `vncpass` (all lowercase, no spaces)

### "No route to host"
**Cause**: Trying to connect to 138.199.218.115:5901 directly
**Fix**: Connect to `localhost:5901` instead (after SSH tunnel)

## 🔍 Verify Connection

### Check if tunnel is working:

**Windows PowerShell:**
```powershell
netstat -an | findstr 5901
```

**macOS/Linux:**
```bash
netstat -an | grep 5901
```

You should see: `127.0.0.1:5901` or `localhost:5901`

## 🎬 Video Tutorial Steps

1. **Open Terminal** → Run: `ssh -L 5901:localhost:5901 fedora-vps`
2. **Leave it open** → Don't close this window!
3. **Open VNC Viewer** → New Connection
4. **VNC Server**: `localhost:5901`
5. **Connect** → Enter password: `vncpass`
6. **Done!** → You should see XFCE desktop

## 🚀 One-Line Connection Script

### Windows (PowerShell)
```powershell
Start-Process ssh -ArgumentList "-L", "5901:localhost:5901", "fedora-vps"
Start-Sleep -Seconds 3
& "C:\Program Files\TigerVNC\vncviewer.exe" localhost:5901
```

### macOS/Linux (Bash)
```bash
#!/bin/bash
ssh -fN -L 5901:localhost:5901 fedora-vps
sleep 2
vncviewer localhost:5901
```

Save as `connect-vnc.sh`, make executable: `chmod +x connect-vnc.sh`

## 📞 Still Having Issues?

Run these diagnostic commands:

```bash
# Check VNC is running on server
ssh fedora-vps "sudo systemctl status vncserver@:1.service"

# Check VNC port
ssh fedora-vps "ss -tlnp | grep 5901"

# Test SSH connection
ssh fedora-vps "echo 'SSH works!'"
```

## 💡 Pro Tip

Create an alias for quick connection:

**Windows (PowerShell Profile):**
```powershell
function Connect-VPS-VNC {
    ssh -L 5901:localhost:5901 fedora-vps
}
```

**macOS/Linux (.bashrc or .zshrc):**
```bash
alias vnc-vps='ssh -L 5901:localhost:5901 fedora-vps'
```

Then just type: `vnc-vps` to connect!
