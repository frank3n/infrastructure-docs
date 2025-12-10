# Stream Windows 11 Disk Image Directly to VPS (No Local Storage)
# Run as Administrator

param(
    [string]$VPSHost = "138.199.218.115",
    [string]$VPSUser = "root",
    [string]$VPSKeyPath = "C:/2025-claude-code-laptop/projects/vps-management/ssh-keys/fedora-vps-key",
    [string]$VPSDestPath = "/mnt/storage/windows-backups/win11-stream.img.gz",
    [string]$SourceDrive = "C:",
    [switch]$UseCompression = $true
)

$ErrorActionPreference = "Stop"

# Check Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: Must run as Administrator!" -ForegroundColor Red
    exit 1
}

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "Stream Windows 11 to VPS (Zero Local Storage)" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Method: Direct disk streaming via SSH pipe" -ForegroundColor Yellow
Write-Host "Source: Physical disk containing $SourceDrive" -ForegroundColor Yellow
Write-Host "Destination: ${VPSUser}@${VPSHost}:${VPSDestPath}" -ForegroundColor Yellow
Write-Host "Compression: $UseCompression" -ForegroundColor Yellow
Write-Host ""

# Get disk number for the source drive
$partition = Get-Partition -DriveLetter $SourceDrive.TrimEnd(':')
$diskNumber = $partition.DiskNumber
$disk = Get-Disk -Number $diskNumber

Write-Host "Disk Information:" -ForegroundColor Cyan
Write-Host "  Disk Number: $diskNumber" -ForegroundColor Gray
Write-Host "  Size: $([math]::Round($disk.Size / 1GB, 2)) GB" -ForegroundColor Gray
Write-Host "  Partitions: $($disk.NumberOfPartitions)" -ForegroundColor Gray
Write-Host ""

# Warn user
Write-Host "WARNING: This will create a RAW disk image of the entire physical disk." -ForegroundColor Red
Write-Host "This includes all partitions (EFI, Recovery, System, etc.)" -ForegroundColor Red
Write-Host ""
Write-Host "Estimated time: 4-12 hours for 256GB disk" -ForegroundColor Yellow
Write-Host "This process cannot be easily paused/resumed." -ForegroundColor Yellow
Write-Host ""

$confirm = Read-Host "Continue? (yes/no)"
if ($confirm -ne "yes") {
    Write-Host "Cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Starting disk stream..." -ForegroundColor Cyan
Write-Host ""

# Create SSH command
if ($UseCompression) {
    $sshCommand = "ssh -i `"$VPSKeyPath`" ${VPSUser}@${VPSHost} `"cat | gzip > '$VPSDestPath'`""
} else {
    $sshCommand = "ssh -i `"$VPSKeyPath`" ${VPSUser}@${VPSHost} `"cat > '$VPSDestPath'`""
}

Write-Host "SSH Command: $sshCommand" -ForegroundColor Gray
Write-Host ""

# Use dd from Git Bash to stream the disk
$ddCommand = "dd if=/dev/sd$([char](97 + $diskNumber)) bs=4M status=progress | $sshCommand"

Write-Host "This will take several hours..." -ForegroundColor Yellow
Write-Host "Do NOT close this window or put computer to sleep." -ForegroundColor Red
Write-Host ""

# Execute via bash
bash -c $ddCommand

Write-Host ""
Write-Host "Stream completed!" -ForegroundColor Green
Write-Host ""

Read-Host "Press Enter to exit"
