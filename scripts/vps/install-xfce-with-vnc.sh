#!/bin/bash
# Script to install XFCE Desktop + VNC Server on Fedora VPS
# Server: 138.199.218.115
# This version includes TigerVNC for remote desktop access

set -e  # Exit on error

echo "=================================================="
echo "XFCE Desktop + VNC Installation for Fedora VPS"
echo "=================================================="
echo ""

# Update system first
echo "[1/8] Updating system packages..."
sudo dnf upgrade --refresh -y

# Install XFCE Desktop
echo ""
echo "[2/8] Installing XFCE Desktop Environment..."
sudo dnf group install "xfce-desktop" -y

# Install additional XFCE applications
echo ""
echo "[3/8] Installing XFCE applications..."
sudo dnf group install "xfce-apps" -y

# Install VNC server
echo ""
echo "[4/8] Installing TigerVNC server..."
sudo dnf install tigervnc-server -y

# Install additional useful packages
echo ""
echo "[5/8] Installing additional packages..."
sudo dnf install firefox xfce4-terminal thunar -y

# Set up VNC password
echo ""
echo "[6/8] Setting up VNC..."
echo "Please set a VNC password when prompted:"
vncpasswd

# Create VNC systemd service
echo ""
echo "[7/8] Creating VNC service..."
sudo mkdir -p ~/.vnc

cat > ~/.vnc/xstartup << 'EOF'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec startxfce4
EOF

chmod +x ~/.vnc/xstartup

# Configure VNC to start on boot (optional)
echo ""
echo "[8/8] VNC configuration complete!"

echo ""
echo "=================================================="
echo "Installation Complete!"
echo "=================================================="
echo ""
echo "To start VNC server:"
echo "  vncserver :1 -geometry 1920x1080 -depth 24"
echo ""
echo "To stop VNC server:"
echo "  vncserver -kill :1"
echo ""
echo "To connect from your local machine:"
echo "  - Use VNC client (like RealVNC, TigerVNC Viewer, or TightVNC)"
echo "  - Connect to: 138.199.218.115:5901"
echo "  - Or via SSH tunnel (more secure):"
echo "    ssh -L 5901:localhost:5901 fedora-vps"
echo "    Then connect VNC to: localhost:5901"
echo ""
echo "VNC ports used:"
echo "  :1 = port 5901"
echo "  :2 = port 5902"
echo "  etc."
echo ""
