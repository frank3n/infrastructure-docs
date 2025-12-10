# XFCE Quick Start Guide

## Quick Installation (Recommended for VPS)

```bash
# Copy the installation script
scp vps-management/install-xfce-with-vnc.sh fedora-vps:~/

# Run the installation
ssh fedora-vps "bash ~/install-xfce-with-vnc.sh"
```

## Quick Commands

### Start VNC Server
```bash
ssh fedora-vps "vncserver :1 -geometry 1920x1080 -depth 24"
```

### Connect to VNC (via SSH Tunnel - Secure)
```bash
# In one terminal, create SSH tunnel:
ssh -L 5901:localhost:5901 fedora-vps

# Then connect your VNC viewer to:
localhost:5901
```

### Stop VNC Server
```bash
ssh fedora-vps "vncserver -kill :1"
```

### List Running VNC Sessions
```bash
ssh fedora-vps "vncserver -list"
```

## VNC Clients

Download a VNC client for your OS:
- **Windows**: [TigerVNC](https://tigervnc.org/) or [RealVNC](https://www.realvnc.com/)
- **macOS**: [RealVNC Viewer](https://www.realvnc.com/) or built-in Screen Sharing
- **Linux**: `vncviewer` (from tigervnc-viewer package)

## Manual DNF Commands

```bash
# Install XFCE Desktop
sudo dnf group install "xfce-desktop" -y

# Install XFCE Apps
sudo dnf group install "xfce-apps" -y

# Install VNC Server
sudo dnf install tigervnc-server -y

# Install additional apps
sudo dnf install firefox xfce4-terminal thunar -y
```

## Troubleshooting

### VNC Server Won't Start
```bash
# Check if port is already in use
ssh fedora-vps "ss -tlnp | grep 5901"

# Kill existing VNC sessions
ssh fedora-vps "vncserver -kill :1"

# Check VNC logs
ssh fedora-vps "cat ~/.vnc/*.log"
```

### Reset VNC Password
```bash
ssh fedora-vps "vncpasswd"
```

### Check XFCE Installation
```bash
ssh fedora-vps "dnf group list --installed | grep -i xfce"
```

## Security Best Practices

1. **Always use SSH tunneling** for VNC connections
2. **Don't expose VNC ports** directly to the internet
3. **Use strong VNC password** (8+ characters)
4. **Stop VNC when not in use** to save resources

## Resource Usage

- **XFCE**: ~200-300 MB RAM (very lightweight)
- **VNC Session**: ~50-100 MB RAM
- **Total**: ~400 MB RAM with XFCE + VNC running

Your VPS has 8GB RAM, plenty for multiple VNC sessions.
