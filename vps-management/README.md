# VPS Management Documentation

Comprehensive guides for VPS server management, backup strategies, and remote access.

## 📋 Table of Contents

### Quick Starts
- [Quick Start Guide](QUICK-START-SAFE.md) - SSH timeout-safe workflows
- [Screen Tutorial](SCREEN-GUIDE.md) - Prevent SSH timeouts

### Backup & Recovery
- [Decompress-Convert-Upload Workflow](DECOMPRESS-CONVERT-WORKFLOW.md)
- [Windows 11 Capture to VPS](CAPTURE-WIN11-TO-VPS.md)
- [Disk Image Conversion Methods](CONVERT-LOW-DISK-SPACE.md)

### Storage
- [Hetzner Storage with Rclone](RCLONE-HETZNER-STORAGE.md)
- [Vultr S3 with Rclone](RCLONE-VULTR-S3.md)
- [SSHFS Drive Mounting](SSHFS-MOUNT-X-DRIVE.md)
- [Expand VPS Disk](EXPAND-VPS-DISK.md)

### Remote Access
- [VNC Connection Setup](VNC-CONNECTION.md)
- [RealVNC Cloud Setup](REALVNC-CLOUD-SETUP.md)
- [XFCE Desktop Quick Start](XFCE-QUICK-START.md)

## 🎯 Key Concepts

### Screen Sessions
All guides use screen sessions to prevent SSH timeout failures. See [SCREEN-GUIDE.md](SCREEN-GUIDE.md).

### Space-Efficient Workflows
Workflows designed for tight disk space with sequential operations.

### Automation
Production-ready scripts in [../scripts/vps/](../scripts/vps/).

## 🚀 Common Tasks

### Backup Windows to VPS
1. Capture local disk → IMG file
2. Upload to VPS
3. Convert to VHDX/QCOW2
4. Upload to cloud storage

### Mount VPS Storage
- SSH
FS to Windows: Drive letter mapping
- Persistent mounting with scripts

### Remote Desktop
- VNC server setup
- SSH tunneling
- Cloud connectivity

## 📖 See Also

- [Scripts](../scripts/vps/) - Automation scripts
- [Templates](../templates/) - Configuration templates
