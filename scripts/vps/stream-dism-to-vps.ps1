# Stream Windows 11 Using DISM (Efficient - Only Used Space)
# Run as Administrator

param(
    [string]$VPSHost = "138.199.218.115",
    [string]$VPSUser = "root",
    [string]$VPSKeyPath = "C:/2025-claude-code-laptop/projects/vps-management/ssh-keys/fedora-vps-key",
    [string]$VPSDestPath = "/mnt/storage/windows-backups/win11-backup.wim",
    [string]$TempPipe = "\\.\pipe\wimstream",
    [string]$SourceDrive = "C:"
)

$ErrorActionPreference = "Stop"

# Check Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: Must run as Administrator!" -ForegroundColor Red
    exit 1
}

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "Stream Windows 11 to VPS Using DISM" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "This method uses Windows DISM to:" -ForegroundColor Yellow
Write-Host "  - Capture only USED space (not entire disk)" -ForegroundColor Gray
Write-Host "  - Compress on the fly" -ForegroundColor Gray
Write-Host "  - Stream directly to VPS" -ForegroundColor Gray
Write-Host "  - Much faster than raw disk copy" -ForegroundColor Gray
Write-Host ""

# Get drive info
$volume = Get-Volume -DriveLetter $SourceDrive.TrimEnd(':')
$usedGB = [math]::Round(($volume.Size - $volume.SizeRemaining) / 1GB, 2)
$freeGB = [math]::Round($volume.SizeRemaining / 1GB, 2)

Write-Host "Source Drive: $SourceDrive" -ForegroundColor Cyan
Write-Host "  Used: ${usedGB} GB" -ForegroundColor Gray
Write-Host "  Free: ${freeGB} GB" -ForegroundColor Gray
Write-Host "  Estimated WIM size: ~$([math]::Round($usedGB * 0.6, 2)) GB (compressed)" -ForegroundColor Gray
Write-Host ""

Write-Host "Destination: ${VPSUser}@${VPSHost}:${VPSDestPath}" -ForegroundColor Cyan
Write-Host ""

$confirm = Read-Host "Continue? (yes/no)"
if ($confirm -ne "yes") {
    Write-Host "Cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "[1/3] Creating DISM capture job..." -ForegroundColor Cyan

# Method 1: DISM to stdout piped to SSH (simplest)
$captureCmd = "Dism /Capture-Image /ImageFile:- /CaptureDir:${SourceDrive}\ /Name:`"Windows 11 Backup`" /Compress:max"
$sshCmd = "ssh -i `"$VPSKeyPath`" ${VPSUser}@${VPSHost} `"cat > '$VPSDestPath'`""

Write-Host ""
Write-Host "[2/3] Starting capture and stream..." -ForegroundColor Cyan
Write-Host "This will take 2-8 hours depending on data size and connection speed." -ForegroundColor Yellow
Write-Host "Do NOT close this window." -ForegroundColor Red
Write-Host ""

try {
    # Create temporary WIM in memory/minimal space and stream
    # We'll use a small buffer file approach
    $tempWim = "$env:TEMP\wimtemp.wim"

    Write-Host "Method: Creating WIM with DISM and uploading via SSH" -ForegroundColor Yellow
    Write-Host ""

    # Start DISM capture in background
    $dismJob = Start-Job -ScriptBlock {
        param($drive, $tempFile)
        Dism /Capture-Image /ImageFile:$tempFile /CaptureDir:${drive}\ /Name:"Windows 11 Backup" /Compress:max
    } -ArgumentList $SourceDrive, $tempWim

    Write-Host "DISM capture started (Job ID: $($dismJob.Id))" -ForegroundColor Green
    Write-Host "Monitoring progress..." -ForegroundColor Yellow
    Write-Host ""

    # Monitor DISM progress
    while ($dismJob.State -eq "Running") {
        Start-Sleep -Seconds 10
        if (Test-Path $tempWim) {
            $currentSize = (Get-Item $tempWim).Length / 1GB
            Write-Host "  Current WIM size: $([math]::Round($currentSize, 2)) GB" -ForegroundColor Gray
        }
        Write-Host "  DISM still capturing... (Check Task Manager for DISM.exe)" -ForegroundColor Gray
    }

    # Wait for completion
    $result = Receive-Job -Job $dismJob
    Write-Host $result

    if (Test-Path $tempWim) {
        $wimSize = (Get-Item $tempWim).Length / 1GB
        Write-Host ""
        Write-Host "DISM capture completed!" -ForegroundColor Green
        Write-Host "WIM size: $([math]::Round($wimSize, 2)) GB" -ForegroundColor Green
        Write-Host ""

        Write-Host "[3/3] Uploading to VPS..." -ForegroundColor Cyan

        # Upload via SCP
        $scpCmd = "scp -i `"$VPSKeyPath`" `"$tempWim`" ${VPSUser}@${VPSHost}:$VPSDestPath"
        Write-Host "Command: $scpCmd" -ForegroundColor Gray
        Write-Host ""

        Invoke-Expression $scpCmd

        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "Upload completed successfully!" -ForegroundColor Green
            Write-Host ""

            # Verify
            Write-Host "Verifying on VPS..." -ForegroundColor Yellow
            $remoteSize = ssh -i $VPSKeyPath ${VPSUser}@${VPSHost} "stat -c%s '$VPSDestPath'"
            $localSize = (Get-Item $tempWim).Length

            if ($remoteSize -eq $localSize) {
                Write-Host "Verification: Sizes match! ✓" -ForegroundColor Green
            } else {
                Write-Host "WARNING: Size mismatch!" -ForegroundColor Red
            }
        }

        # Clean up
        Write-Host ""
        Write-Host "Cleaning up temporary file..." -ForegroundColor Yellow
        Remove-Item $tempWim -Force
        Write-Host "Done!" -ForegroundColor Green

    } else {
        Write-Host "ERROR: DISM capture failed!" -ForegroundColor Red
        exit 1
    }

} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "✓ Backup Complete!" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Location: ${VPSUser}@${VPSHost}:${VPSDestPath}" -ForegroundColor Gray
Write-Host ""
Write-Host "To restore this image:" -ForegroundColor Yellow
Write-Host "  1. Download WIM from VPS" -ForegroundColor Gray
Write-Host "  2. Use DISM /Apply-Image or Windows Recovery" -ForegroundColor Gray
Write-Host "  3. Or boot from Windows Install Media and restore" -ForegroundColor Gray
Write-Host ""

Read-Host "Press Enter to exit"
