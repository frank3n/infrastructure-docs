#!/bin/bash
# Script to install XFCE Desktop Environment on Fedora VPS
# Server: 138.199.218.115

set -e  # Exit on error

echo "=========================================="
echo "XFCE Desktop Installation for Fedora VPS"
echo "=========================================="
echo ""

# Update system first
echo "[1/6] Updating system packages..."
sudo dnf upgrade --refresh -y

# Install XFCE Desktop
echo ""
echo "[2/6] Installing XFCE Desktop Environment..."
sudo dnf group install "xfce-desktop" -y

# Install additional XFCE applications (optional but recommended)
echo ""
echo "[3/6] Installing XFCE applications..."
sudo dnf group install "xfce-apps" -y

# Install X11 and display manager
echo ""
echo "[4/6] Installing LightDM display manager..."
sudo dnf install lightdm lightdm-gtk -y

# Set graphical target as default
echo ""
echo "[5/6] Setting graphical target as default..."
sudo systemctl set-default graphical.target

# Enable LightDM
echo ""
echo "[6/6] Enabling LightDM display manager..."
sudo systemctl enable lightdm

echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Reboot the system: sudo reboot"
echo "2. After reboot, the system will boot to graphical mode"
echo "3. For remote access, you'll need to set up VNC or RDP"
echo ""
echo "To switch between targets:"
echo "  - Graphical: sudo systemctl set-default graphical.target"
echo "  - CLI only:  sudo systemctl set-default multi-user.target"
echo ""
