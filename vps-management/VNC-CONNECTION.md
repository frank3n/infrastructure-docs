# VNC Connection Guide

## Connection Details

- **Server**: 138.199.218.115
- **VNC Port**: 5901 (Display :1)
- **VNC Password**: `vncpass`
- **Session**: XFCE Desktop
- **Resolution**: 1920x1080

## Connect via SSH Tunnel (Recommended - Secure)

### Step 1: Create SSH Tunnel

```bash
ssh -L 5901:localhost:5901 fedora-vps
```

Leave this terminal open while using VNC.

### Step 2: Connect VNC Client

Point your VNC client to:
```
localhost:5901
```

Enter password: `vncpass`

## VNC Client Downloads

- **Windows**: [TigerVNC Viewer](https://tigervnc.org/) or [RealVNC](https://www.realvnc.com/en/connect/download/viewer/)
- **macOS**: [RealVNC Viewer](https://www.realvnc.com/en/connect/download/viewer/) or built-in Screen Sharing
- **Linux**: `tigervnc-viewer` or `vncviewer`

### Install VNC Viewer on Linux
```bash
# Fedora/RHEL
sudo dnf install tigervnc

# Ubuntu/Debian
sudo apt install tigervnc-viewer

# Then connect
vncviewer localhost:5901
```

## VNC Server Management

### Check Status
```bash
ssh fedora-vps "sudo systemctl status vncserver@:1.service"
```

### Stop VNC Server
```bash
ssh fedora-vps "sudo systemctl stop vncserver@:1.service"
```

### Start VNC Server
```bash
ssh fedora-vps "sudo systemctl start vncserver@:1.service"
```

### Restart VNC Server
```bash
ssh fedora-vps "sudo systemctl restart vncserver@:1.service"
```

### View VNC Logs
```bash
ssh fedora-vps "sudo journalctl -u vncserver@:1.service -n 50"
```

## VNC Configuration Files

- **Config**: `~/.config/tigervnc/config`
- **Password**: `~/.config/tigervnc/passwd`
- **User Mapping**: `/etc/tigervnc/vncserver.users`

## Change VNC Password

```bash
ssh fedora-vps
echo 'newpass' | vncpasswd -f > ~/.config/tigervnc/passwd
chmod 600 ~/.config/tigervnc/passwd
sudo systemctl restart vncserver@:1.service
```

## Change Resolution

Edit the config file:
```bash
ssh fedora-vps "nano ~/.config/tigervnc/config"
```

Change the geometry line:
```
geometry=2560x1440
# or
geometry=1680x1050
# etc.
```

Then restart VNC:
```bash
ssh fedora-vps "sudo systemctl restart vncserver@:1.service"
```

## Security Notes

- VNC is configured to listen only on localhost (127.0.0.1)
- Always use SSH tunneling for connections - never expose VNC directly
- The port 5901 is NOT open to the internet by default
- Strong encryption is provided by the SSH tunnel

## Troubleshooting

### Can't Connect
1. Verify VNC is running: `sudo systemctl status vncserver@:1.service`
2. Check SSH tunnel is active
3. Verify port forwarding: `ss -tlnp | grep 5901` (on your local machine)

### Black Screen or Session Won't Start
```bash
# Check XFCE is installed
ssh fedora-vps "rpm -qa | grep xfce4-session"

# Check logs
ssh fedora-vps "cat ~/.vnc/*.log"

# Restart VNC
ssh fedora-vps "sudo systemctl restart vncserver@:1.service"
```

### Performance Issues
- Lower the color depth (edit config, add `depth=16`)
- Reduce resolution
- Disable composition in XFCE settings

## Quick Connect Script

Create a script on your local machine to connect quickly:

```bash
#!/bin/bash
# save as connect-vps-vnc.sh

# Start SSH tunnel in background
ssh -fN -L 5901:localhost:5901 fedora-vps

# Wait a moment
sleep 2

# Start VNC viewer (adjust command for your OS)
vncviewer localhost:5901

# When done, kill the tunnel
pkill -f "ssh -fN -L 5901"
```

Make it executable:
```bash
chmod +x connect-vps-vnc.sh
./connect-vps-vnc.sh
```
