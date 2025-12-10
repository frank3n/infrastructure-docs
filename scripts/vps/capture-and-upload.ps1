# Automated Windows 11 VHDX Capture and Upload to VPS
# Run as Administrator

param(
    [string]$OutputPath = "D:\temp",
    [string]$VHDXName = "win11-backup-$(Get-Date -Format 'yyyy-MM-dd').vhdx",
    [string[]]$Volumes = @("C:"),
    [switch]$UploadToVPS = $true,
    [switch]$BackupToHetzner = $false,
    [switch]$SkipCapture = $false
)

$ErrorActionPreference = "Stop"

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Windows 11 VHDX Capture & Upload to VPS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$disk2vhdUrl = "https://download.sysinternals.com/files/Disk2vhd.zip"
$disk2vhdDir = "$env:TEMP\Disk2vhd"
$vpsHost = "138.199.218.115"
$vpsUser = "root"
$vpsKeyPath = "C:/2025-claude-code-laptop/projects/vps-management/ssh-keys/fedora-vps-key"
$vpsDestPath = "/mnt/storage/windows-backups"
$fullOutputPath = Join-Path $OutputPath $VHDXName

Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  Volumes to capture: $($Volumes -join ', ')" -ForegroundColor Gray
Write-Host "  Output path: $fullOutputPath" -ForegroundColor Gray
Write-Host "  VPS destination: ${vpsUser}@${vpsHost}:${vpsDestPath}" -ForegroundColor Gray
Write-Host ""

# Step 1: Check disk space
Write-Host "[1/6] Checking disk space..." -ForegroundColor Cyan

foreach ($vol in $Volumes) {
    $drive = Get-Volume -DriveLetter $vol.TrimEnd(':')
    $usedGB = [math]::Round(($drive.Size - $drive.SizeRemaining) / 1GB, 2)
    $freeGB = [math]::Round($drive.SizeRemaining / 1GB, 2)
    Write-Host "  $vol Used: ${usedGB}GB, Free: ${freeGB}GB" -ForegroundColor Gray
}

$outputDrive = Split-Path $OutputPath -Qualifier
$outputVol = Get-Volume -DriveLetter $outputDrive.TrimEnd(':')
$outputFreeGB = [math]::Round($outputVol.SizeRemaining / 1GB, 2)
Write-Host "  Output location ($outputDrive) Free: ${outputFreeGB}GB" -ForegroundColor Gray
Write-Host ""

# Step 2: Download Disk2vhd if not already present
if (-not $SkipCapture) {
    Write-Host "[2/6] Downloading Disk2vhd..." -ForegroundColor Cyan

    if (-not (Test-Path $disk2vhdDir)) {
        New-Item -ItemType Directory -Path $disk2vhdDir -Force | Out-Null
    }

    $disk2vhdExe = Join-Path $disk2vhdDir "disk2vhd.exe"

    if (-not (Test-Path $disk2vhdExe)) {
        Write-Host "  Downloading from Microsoft Sysinternals..." -ForegroundColor Yellow
        $zipPath = "$env:TEMP\Disk2vhd.zip"

        try {
            Invoke-WebRequest -Uri $disk2vhdUrl -OutFile $zipPath -UseBasicParsing
            Expand-Archive -Path $zipPath -DestinationPath $disk2vhdDir -Force
            Remove-Item $zipPath
            Write-Host "  Downloaded successfully" -ForegroundColor Green
        } catch {
            Write-Host "  ERROR: Failed to download Disk2vhd" -ForegroundColor Red
            Write-Host "  Please download manually from: $disk2vhdUrl" -ForegroundColor Yellow
            exit 1
        }
    } else {
        Write-Host "  Disk2vhd already present" -ForegroundColor Green
    }
    Write-Host ""

    # Step 3: Create output directory
    Write-Host "[3/6] Preparing output directory..." -ForegroundColor Cyan
    if (-not (Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
        Write-Host "  Created: $OutputPath" -ForegroundColor Green
    } else {
        Write-Host "  Directory exists: $OutputPath" -ForegroundColor Green
    }
    Write-Host ""

    # Step 4: Run Disk2vhd
    Write-Host "[4/6] Creating VHDX image..." -ForegroundColor Cyan
    Write-Host "  This will take 1-3 hours depending on disk size..." -ForegroundColor Yellow
    Write-Host "  Command: disk2vhd.exe $($Volumes -join ' ') $fullOutputPath" -ForegroundColor Gray
    Write-Host ""

    $volumeArgs = $Volumes -join " "
    $disk2vhdArgs = "$volumeArgs `"$fullOutputPath`""

    Write-Host "  Starting Disk2vhd (GUI will open)..." -ForegroundColor Yellow
    Write-Host "  Please configure in the GUI:" -ForegroundColor Yellow
    Write-Host "    1. Verify volumes are selected" -ForegroundColor Gray
    Write-Host "    2. Check 'Use VHDX'" -ForegroundColor Gray
    Write-Host "    3. Check 'Use Volume Shadow Copy'" -ForegroundColor Gray
    Write-Host "    4. Click 'Create'" -ForegroundColor Gray
    Write-Host ""

    # Launch Disk2vhd GUI
    Start-Process -FilePath $disk2vhdExe -WorkingDirectory $disk2vhdDir -Wait

    Write-Host ""
    Write-Host "  Disk2vhd completed!" -ForegroundColor Green

    # Verify file was created
    if (-not (Test-Path $fullOutputPath)) {
        Write-Host "  ERROR: VHDX file not found at: $fullOutputPath" -ForegroundColor Red
        Write-Host "  Please check if Disk2vhd completed successfully" -ForegroundColor Yellow
        exit 1
    }

    $vhdxSize = (Get-Item $fullOutputPath).Length / 1GB
    Write-Host "  VHDX created: $fullOutputPath" -ForegroundColor Green
    Write-Host "  Size: $([math]::Round($vhdxSize, 2)) GB" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "[2-4/6] Skipping VHDX capture (using existing file)..." -ForegroundColor Yellow
    if (-not (Test-Path $fullOutputPath)) {
        Write-Host "  ERROR: VHDX file not found at: $fullOutputPath" -ForegroundColor Red
        exit 1
    }
    Write-Host ""
}

# Step 5: Upload to VPS
if ($UploadToVPS) {
    Write-Host "[5/6] Uploading to VPS..." -ForegroundColor Cyan

    # Create remote directory
    Write-Host "  Creating remote directory..." -ForegroundColor Yellow
    ssh -i $vpsKeyPath ${vpsUser}@${vpsHost} "mkdir -p $vpsDestPath"

    Write-Host "  Uploading via SCP..." -ForegroundColor Yellow
    Write-Host "  This may take several hours for large files..." -ForegroundColor Yellow

    $remoteFile = "$vpsDestPath/$(Split-Path $fullOutputPath -Leaf)"

    # Use SCP for transfer
    scp -i $vpsKeyPath -o StrictHostKeyChecking=no $fullOutputPath ${vpsUser}@${vpsHost}:${remoteFile}

    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Upload completed successfully!" -ForegroundColor Green

        # Verify on VPS
        Write-Host "  Verifying file on VPS..." -ForegroundColor Yellow
        $remoteSize = ssh -i $vpsKeyPath ${vpsUser}@${vpsHost} "stat -c%s '$remoteFile' 2>/dev/null"
        $localSize = (Get-Item $fullOutputPath).Length

        if ($remoteSize -eq $localSize) {
            Write-Host "  Verification: File sizes match! ✓" -ForegroundColor Green
        } else {
            Write-Host "  WARNING: File sizes don't match!" -ForegroundColor Red
            Write-Host "    Local:  $localSize bytes" -ForegroundColor Gray
            Write-Host "    Remote: $remoteSize bytes" -ForegroundColor Gray
        }
    } else {
        Write-Host "  ERROR: Upload failed!" -ForegroundColor Red
        exit 1
    }
    Write-Host ""
}

# Step 6: Backup to Hetzner (optional)
if ($BackupToHetzner) {
    Write-Host "[6/6] Backing up to Hetzner Storage Box..." -ForegroundColor Cyan
    Write-Host "  Running rclone on VPS..." -ForegroundColor Yellow

    $remoteFile = "$vpsDestPath/$(Split-Path $fullOutputPath -Leaf)"
    ssh -i $vpsKeyPath ${vpsUser}@${vpsHost} "rclone copy '$remoteFile' hetzner-storage:windows-backups/ --progress --stats 5s"

    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Backup to Hetzner completed!" -ForegroundColor Green
    } else {
        Write-Host "  WARNING: Hetzner backup failed" -ForegroundColor Red
    }
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✓ Process Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "  Local VHDX: $fullOutputPath" -ForegroundColor Gray
if ($UploadToVPS) {
    Write-Host "  VPS Location: ${vpsUser}@${vpsHost}:${vpsDestPath}/$(Split-Path $fullOutputPath -Leaf)" -ForegroundColor Gray
}
if ($BackupToHetzner) {
    Write-Host "  Hetzner Backup: hetzner-storage:windows-backups/$(Split-Path $fullOutputPath -Leaf)" -ForegroundColor Gray
}
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Verify the VHDX can be mounted/used" -ForegroundColor Gray
Write-Host "  2. Test restoring from the backup" -ForegroundColor Gray
Write-Host "  3. Consider deleting local copy to free space" -ForegroundColor Gray
Write-Host ""

Read-Host "Press Enter to exit"
