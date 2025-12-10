# VPS Backup Workflow Session

**Date:** 2025-12-10
**Session Type:** Continued from 2025-12-09
**Previous Session ID:** d1ab8d83-2dbb-4e79-9200-13f2196adf02
**VPS:** Fedora 8GB (138.199.218.115)
**Storage:** 500GB VPS + Hetzner Storage Box (5TB)

## Session Overview

Completed Windows 11 backup processing workflow with screen session protection against SSH timeouts. Created both VHDX and QCOW2 disk image formats and uploaded to Hetzner cloud storage.

## Tasks Completed

### 1. Decompression (Completed ✅)
- **File:** win11-direct-stream.img.gz (190GB)
- **Method:** Screen session with `pv` for progress monitoring
- **Result:** win11-backup.img (239GB)
- **Time:** ~2 hours
- **Issue Fixed:** Previous attempt failed due to SSH timeout
- **Solution:** Implemented screen session in `resume-decompression.sh`

### 2. VHDX Conversion (Completed ✅)
- **Source:** win11-backup.img (239GB)
- **Method:** qemu-img in screen session
- **Result:** win11-backup-2025-12-10-182246.vhdx (206GB)
- **Format:** Dynamic VHDX for Hyper-V compatibility
- **Time:** ~45 minutes

### 3. Hetzner Upload - VHDX (Completed ✅)
- **File:** win11-backup-2025-12-10-182246.vhdx (205.195 GiB)
- **Method:** rclone copy via SFTP (port 23)
- **Destination:** hetzner-storage: (root directory)
- **Time:** 26 minutes 48 seconds
- **Screen Session:** 233872.hetzner-upload
- **Status:** ✅ Verified on Hetzner (220326789120 bytes)

### 4. QCOW2 Conversion & Upload (In Progress 🔄)
- **Source:** win11-backup-2025-12-10-182246.vhdx (206GB)
- **Method:** qemu-img convert with zstd compression in screen
- **Progress:** 1% (just started)
- **Expected Time:** 30-60 minutes
- **Screen Session:** 234872.qcow2-creation
- **Script:** `/tmp/create-qcow2-version.sh`
- **Status:** Converting VHDX → QCOW2 with compression

## Documentation Work Completed

### Created Infrastructure Documentation Repository
- **Repository:** https://github.com/frank3n/infrastructure-docs
- **Created:** 2025-12-10
- **Initial Content:** 150 files, 34,468 lines
- **Structure:**
  - vps-management/ (VPS guides and workflows)
  - scripts/ (Automation scripts)
  - workflows/ (General workflows)
  - guides/ (How-to guides)
  - templates/ (Configuration templates)
  - references/ (Quick references)
  - sessions/ (Session logs - this file)

### Documentation Added
- VPS management guides (19 files)
- Calculator website documentation (40+ files)
- Adventurer dating website documentation
- Claude Code credits documentation
- Git workflow guides
- PowerShell automation scripts

### Root Folder Organization
- **Created:** `organize-root-files.ps1`
- **Plan:** `ORGANIZATION-PLAN.md`
- **Purpose:** Organize 45 loose files in C:\github-claude
- **Categories:** docs/, scripts/, logs/, notes/, config/, status/, completed/
- **Status:** Ready to execute (dry-run tested)

## Scripts Created/Updated

### 1. resume-decompression.sh
- Deletes incomplete IMG file
- Restarts decompression in screen session
- Uses `pv` for progress monitoring
- SSH timeout-safe

### 2. process-win11-backup-safe.sh
- Complete workflow with screen sessions
- Handles: decompress → convert → upload
- Space management with cleanup between steps
- All operations SSH timeout-protected

### 3. create-qcow2-version.sh (Updated)
- Creates QCOW2 version from VHDX
- Uses zstd compression for smaller size
- Uploads to Hetzner Storage
- Updated to use root directory (not /windows-backups/)
- Handles local or remote VHDX sources

### 4. SCREEN-GUIDE.md
- Complete tutorial on screen sessions
- Essential commands and best practices
- Real-world examples for VPS work

### 5. organize-root-files.ps1
- Automates file organization
- Dry-run mode by default
- Categorizes by file purpose
- Preserves existing directory structure

## Key Commands Used

### Screen Session Management
```bash
# Create detached screen session
screen -dmS session-name bash -c 'command'

# List sessions
screen -ls

# Attach to session
screen -r session-name

# View session output without attaching
screen -S session-name -X hardcopy /tmp/output.txt && cat /tmp/output.txt

# Kill session
screen -S session-name -X quit
```

### VPS Backup Workflow
```bash
# Decompression with progress
pv -pterb file.img.gz | gunzip > output.img

# VHDX conversion
qemu-img convert -f raw -O vhdx -o subformat=dynamic input.img output.vhdx -p

# QCOW2 conversion with compression
qemu-img convert -f vhdx -O qcow2 -o compression_type=zstd -o cluster_size=64k input.vhdx output.qcow2 -p

# Hetzner upload
rclone copy file.vhdx hetzner-storage: --progress --stats 10s

# Verify upload
rclone ls hetzner-storage: | grep filename
```

### SSH Commands
```bash
# Run script on VPS in screen
scp script.sh vps:/tmp/ && ssh vps "screen -dmS name bash -c '/tmp/script.sh'"

# Monitor VPS process
ssh vps "ps aux | grep process-name"

# Check disk space
ssh vps "df -h /mnt/storage"
```

## Technical Details

### VPS Configuration
- **Provider:** Hetzner
- **OS:** Fedora
- **IP:** 138.199.218.115
- **RAM:** 8GB
- **Storage:** 500GB SSD
- **Mount:** /mnt/storage (492GB usable)

### Hetzner Storage Box
- **Capacity:** 5TB
- **Protocol:** SFTP
- **Port:** 23
- **Host:** u516587.your-storagebox.de
- **Rclone Remote:** hetzner-storage

### Disk Image Formats
- **IMG/RAW:** Uncompressed disk image (239GB)
- **VHDX:** Hyper-V format, dynamic allocation (206GB)
- **QCOW2:** KVM/QEMU format, compressed with zstd (TBD)

### Space Management Timeline
```
Initial:          500GB total, ~300GB free
After decompress: 239GB IMG + 190GB GZ = 429GB used
Delete GZ:        239GB IMG only = 239GB used
After VHDX:       239GB IMG + 206GB VHDX = 445GB used
Delete IMG:       206GB VHDX only = 206GB used
Upload VHDX:      206GB used (upload to cloud)
After QCOW2:      206GB VHDX + ~180GB QCOW2 = ~386GB used
Upload QCOW2:     Final cleanup, minimal local storage
```

## Issues Resolved

### 1. SSH Timeout During Decompression
- **Problem:** 2-hour decompression stopped when SSH disconnected
- **Solution:** Implemented screen sessions for all long operations
- **Result:** Operations continue regardless of SSH connection

### 2. Hetzner Directory Creation Failed
- **Problem:** mkdir "/windows-backups" failed with SSH_FX_FAILURE
- **Solution:** Upload to root directory instead of subdirectory
- **Result:** Uploads successful

### 3. Incomplete IMG File
- **Problem:** 239GB partial IMG from failed decompression
- **Decision:** User chose option 2 - restart fresh
- **Solution:** Delete incomplete file and restart in screen session

## Research Completed

### Windows 11 Licensing on Hetzner
- **Question:** Can Hetzner allow BYOL for Windows 11?
- **Answer:** ❌ NO - Microsoft EULA prohibits Windows 10/11 desktop editions on server hardware
- **Allowed:** Only Windows Server editions with BYOL
- **Alternatives:**
  - Use Windows Server with BYOL
  - Local virtualization with Windows 11
  - Compliant cloud providers (Azure, AWS with proper licensing)

## Current Status

### ✅ Completed
- Decompression: win11-backup.img (239GB)
- VHDX conversion and upload (205 GiB to Hetzner)
- Documentation repository created and populated
- Root folder organization plan created
- All guides updated with screen session methods

### 🔄 In Progress
- QCOW2 conversion (1% complete)
- Screen session: 234872.qcow2-creation
- Estimated completion: 30-60 minutes

### 📋 Next Steps
1. Monitor QCOW2 conversion completion
2. Verify QCOW2 upload to Hetzner
3. Cleanup local files on VPS
4. Optional: Execute root folder organization (`organize-root-files.ps1 -Execute`)
5. Commit and push session log to infrastructure-docs repo

## Monitor Commands

### Check QCOW2 Progress
```bash
ssh fedora-vps "screen -r qcow2-creation"  # Attach (Ctrl+A, D to detach)
ssh fedora-vps "screen -S qcow2-creation -X hardcopy /tmp/out.txt && tail -20 /tmp/out.txt"
```

### Verify Final Results
```bash
# List files on Hetzner
rclone ls hetzner-storage: | grep -E "\.vhdx|\.qcow2"

# Check VPS disk space
ssh fedora-vps "df -h /mnt/storage"

# List screen sessions
ssh fedora-vps "screen -ls"
```

## Files on Hetzner (Final)
```
win11-backup-2025-12-10-182246.vhdx (205 GiB) ✅
win11-backup-TIMESTAMP.qcow2 (TBD GB with compression) 🔄
```

## Repository Structure Created
```
infrastructure-docs/
├── vps-management/          # VPS guides and workflows
├── scripts/                 # Automation scripts
│   ├── vps/                # VPS-specific scripts
│   ├── git/                # Git workflow scripts
│   └── utilities/          # Common utilities
├── workflows/              # General workflows
├── guides/                 # How-to guides
├── templates/              # Configuration templates
├── references/             # Quick references
├── projects/               # Project documentation
│   ├── calculator-website-documentation/
│   ├── adventurer-dating-website-documentation/
│   └── claude-code-credits-documentation/
└── sessions/               # Session logs (this file)
```

## Lessons Learned

1. **Always use screen sessions for long VPS operations** (>30 min)
2. **Sequential space management is critical** on VPS with limited storage
3. **Hetzner Storage Box has permission limitations** on subdirectory creation
4. **QCOW2 with zstd compression** provides better storage efficiency than VHDX
5. **Documentation centralization** improves discoverability and maintenance
6. **File organization** should be planned before execution with dry-run testing

## References

- [SCREEN-GUIDE.md](../vps-management/SCREEN-GUIDE.md)
- [DECOMPRESS-CONVERT-WORKFLOW.md](../vps-management/DECOMPRESS-CONVERT-WORKFLOW.md)
- [QUICK-START-SAFE.md](../vps-management/QUICK-START-SAFE.md)
- [RCLONE-HETZNER-STORAGE.md](../vps-management/RCLONE-HETZNER-STORAGE.md)
- [ORGANIZATION-PLAN.md](../../github-claude/ORGANIZATION-PLAN.md)

---

**Session End Time:** TBD (QCOW2 conversion in progress)
**Total Session Duration:** ~3 hours (across multiple Claude Code sessions)
**Data Processed:** 190GB compressed → 239GB raw → 206GB VHDX + QCOW2 (in progress)
**Cloud Storage Used:** ~400GB (both formats)
