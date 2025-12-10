# Automation Scripts

Production-ready scripts for infrastructure management.

## 📁 Directory Structure

- **vps/** - VPS and server management scripts
- **git/** - Git workflow automation
- **utilities/** - Common utility functions

## 🔧 VPS Scripts

### Backup & Conversion
- process-win11-backup-safe.sh - Full backup workflow with screen sessions
- esume-decompression.sh - Resume interrupted decompression
- create-qcow2-version.sh - Create QCOW2 from VHDX/IMG

### Storage Management
- mount-vps-x.ps1 - Mount VPS storage as X: drive
- check-conversion-status.sh - Monitor conversion progress

## 📝 Usage

All scripts include:
- Usage instructions in header comments
- Error handling
- Logging
- Progress monitoring

Example:
\\\ash
# Run in screen session (recommended)
ssh vps "bash -s" < script-name.sh

# Or directly
./script-name.sh
\\\

## ✅ Best Practices

1. Always use screen for long-running operations
2. Check disk space before operations
3. Verify outputs before cleanup
4. Keep logs for troubleshooting

## 🔗 See Also

- [VPS Management Docs](../vps-management/)
- [Quick Start Guide](../vps-management/QUICK-START-SAFE.md)
