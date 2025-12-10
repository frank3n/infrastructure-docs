# backup-to-zip.ps1
# Create a backup zip file of the multi-branch testing setup
# Backs up all documentation and scripts to a dated zip file

param(
    [Parameter(Mandatory=$false)]
    [string]$BackupLocation = "C:\github-claude\backups",
    
    [Parameter(Mandatory=$false)]
    [string]$IncludeProject = $null,
    
    [Parameter(Mandatory=$false)]
    [switch]$OpenBackupFolder
)

# Color output functions
function Write-Success { param($msg) Write-Host $msg -ForegroundColor Green }
function Write-Info { param($msg) Write-Host $msg -ForegroundColor Cyan }
function Write-Warning { param($msg) Write-Host $msg -ForegroundColor Yellow }
function Write-Error { param($msg) Write-Host $msg -ForegroundColor Red }

Write-Success "`n========================================="
Write-Success "Multi-Branch Testing Setup - Backup Tool"
Write-Success "=========================================`n"

# Get current date for filename
$timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$backupFileName = "calculator-website-testing-setup_$timestamp.zip"

# Ensure backup directory exists
if (-not (Test-Path $BackupLocation)) {
    Write-Info "Creating backup directory: $BackupLocation"
    New-Item -ItemType Directory -Path $BackupLocation -Force | Out-Null
}

$backupFilePath = Join-Path $BackupLocation $backupFileName

Write-Info "Backup Configuration:"
Write-Host "  Source: C:\github-claude\" -ForegroundColor Gray
Write-Host "  Destination: $backupFilePath" -ForegroundColor Gray
Write-Host ""

# Define what to include in backup
$itemsToBackup = @(
    # Documentation
    "README.md",
    "START-HERE.md",
    "QUICK-START.md",
    "MULTI-BRANCH-TESTING-PLAN.md",
    "INSTALLATION-SUMMARY.md",
    "PACKAGE-OVERVIEW.md",
    "TESTING-TRACKER.md",
    
    # Scripts
    "setup-worktrees.ps1",
    "start-all-servers.ps1",
    "cleanup-worktrees.ps1",
    "backup-to-zip.ps1",
    
    # Reference files
    "calculator-website npm commands.txt"
)

Write-Info "Files to backup:"
foreach ($item in $itemsToBackup) {
    $itemPath = Join-Path "C:\github-claude" $item
    if (Test-Path $itemPath) {
        $size = (Get-Item $itemPath).Length / 1KB
        Write-Host "  ✓ $item" -ForegroundColor Green -NoNewline
        Write-Host " ($([math]::Round($size, 2)) KB)" -ForegroundColor DarkGray
    } else {
        Write-Host "  ⚠ $item (not found)" -ForegroundColor Yellow
    }
}

# Check if we should include the project worktrees
if ($IncludeProject) {
    Write-Warning "`n⚠ Including project files can create VERY large backup (2-3 GB+)"
    Write-Warning "⚠ This will include all node_modules directories"
    Write-Host ""
    $confirm = Read-Host "Are you sure you want to include project files? (yes/no)"
    if ($confirm -ne "yes") {
        Write-Info "Skipping project files backup"
        $IncludeProject = $null
    }
}

# Create temporary directory for organizing files
$tempDir = Join-Path $env:TEMP "multi-branch-backup-$timestamp"
Write-Info "`nCreating temporary staging directory..."
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

try {
    # Copy files to temp directory
    Write-Info "Copying files to staging area..."
    
    # Create subdirectories
    $docsDir = Join-Path $tempDir "documentation"
    $scriptsDir = Join-Path $tempDir "scripts"
    $refDir = Join-Path $tempDir "reference"
    
    New-Item -ItemType Directory -Path $docsDir -Force | Out-Null
    New-Item -ItemType Directory -Path $scriptsDir -Force | Out-Null
    New-Item -ItemType Directory -Path $refDir -Force | Out-Null
    
    # Copy documentation files
    $docFiles = @(
        "README.md", "START-HERE.md", "QUICK-START.md",
        "MULTI-BRANCH-TESTING-PLAN.md", "INSTALLATION-SUMMARY.md",
        "PACKAGE-OVERVIEW.md", "TESTING-TRACKER.md"
    )
    
    foreach ($file in $docFiles) {
        $sourcePath = Join-Path "C:\github-claude" $file
        if (Test-Path $sourcePath) {
            Copy-Item $sourcePath -Destination $docsDir
        }
    }
    
    # Copy script files
    $scriptFiles = @(
        "setup-worktrees.ps1", "start-all-servers.ps1",
        "cleanup-worktrees.ps1", "backup-to-zip.ps1"
    )
    
    foreach ($file in $scriptFiles) {
        $sourcePath = Join-Path "C:\github-claude" $file
        if (Test-Path $sourcePath) {
            Copy-Item $sourcePath -Destination $scriptsDir
        }
    }
    
    # Copy reference files
    $refFiles = @("calculator-website npm commands.txt")
    foreach ($file in $refFiles) {
        $sourcePath = Join-Path "C:\github-claude" $file
        if (Test-Path $sourcePath) {
            Copy-Item $sourcePath -Destination $refDir
        }
    }
    
    # Create a README in the backup
    $backupReadme = @"
# Multi-Branch Testing Setup - Backup
Created: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Contents

### Documentation/
- README.md - Main entry point
- START-HERE.md - Quick start guide
- QUICK-START.md - Daily reference
- MULTI-BRANCH-TESTING-PLAN.md - Complete guide
- INSTALLATION-SUMMARY.md - Setup summary
- PACKAGE-OVERVIEW.md - Visual overview
- TESTING-TRACKER.md - Testing template

### Scripts/
- setup-worktrees.ps1 - Setup automation
- start-all-servers.ps1 - Server management
- cleanup-worktrees.ps1 - Cleanup tool
- backup-to-zip.ps1 - This backup script

### Reference/
- calculator-website npm commands.txt

## Restore Instructions

1. Extract this zip file to C:\github-claude\
2. Open PowerShell 7
3. Run: cd C:\github-claude
4. Run: .\setup-worktrees.ps1 -Branches @("main", "develop")

## Project Information
- Repository: https://github.com/frank3n/calculator-website
- Target Location: C:\github-code\calculator-website-test\
- Ports: 5173, 5174, 5175...

For detailed instructions, see START-HERE.md or README.md
"@
    
    $backupReadme | Out-File -FilePath (Join-Path $tempDir "BACKUP-README.md") -Encoding utf8
    
    # Include project files if requested
    if ($IncludeProject) {
        Write-Info "Copying project files (this may take several minutes)..."
        $projectDir = Join-Path $tempDir "project"
        New-Item -ItemType Directory -Path $projectDir -Force | Out-Null
        
        if (Test-Path $IncludeProject) {
            Copy-Item -Path $IncludeProject -Destination $projectDir -Recurse -Force
            Write-Success "  ✓ Project files copied"
        } else {
            Write-Warning "  ⚠ Project path not found: $IncludeProject"
        }
    }
    
    # Create the zip file
    Write-Info "`nCreating zip file..."
    
    # Use .NET compression (faster and more reliable)
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $backupFilePath, 'Optimal', $false)
    
    # Verify backup was created
    if (Test-Path $backupFilePath) {
        $backupSize = (Get-Item $backupFilePath).Length
        $backupSizeMB = [math]::Round($backupSize / 1MB, 2)
        
        Write-Success "`n========================================="
        Write-Success "Backup Created Successfully!"
        Write-Success "=========================================`n"
        
        Write-Host "Backup Details:" -ForegroundColor Cyan
        Write-Host "  File: $backupFileName" -ForegroundColor Gray
        Write-Host "  Location: $BackupLocation" -ForegroundColor Gray
        Write-Host "  Size: $backupSizeMB MB" -ForegroundColor Gray
        Write-Host "  Created: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
        
        # Calculate what was included
        $fileCount = (Get-ChildItem $tempDir -Recurse -File).Count
        Write-Host "  Files: $fileCount" -ForegroundColor Gray
        
        Write-Host "`nRestore Instructions:" -ForegroundColor Yellow
        Write-Host "  1. Extract zip to C:\github-claude\" -ForegroundColor Gray
        Write-Host "  2. Open PowerShell 7" -ForegroundColor Gray
        Write-Host "  3. Run: cd C:\github-claude" -ForegroundColor Gray
        Write-Host "  4. Run: .\setup-worktrees.ps1 -Branches @('main')" -ForegroundColor Gray
        
        # Open backup folder if requested
        if ($OpenBackupFolder) {
            Write-Info "`nOpening backup folder..."
            Start-Process explorer.exe -ArgumentList $BackupLocation
        }
        
        Write-Success "`n✓ Backup complete!`n"
        
    } else {
        Write-Error "`n✗ Failed to create backup file"
        exit 1
    }
    
} catch {
    Write-Error "`n✗ Error creating backup: $_"
    exit 1
} finally {
    # Cleanup temporary directory
    if (Test-Path $tempDir) {
        Write-Info "Cleaning up temporary files..."
        Remove-Item $tempDir -Recurse -Force
    }
}

# List existing backups
Write-Host "`nExisting Backups:" -ForegroundColor Cyan
$existingBackups = Get-ChildItem $BackupLocation -Filter "calculator-website-testing-setup_*.zip" | Sort-Object LastWriteTime -Descending

if ($existingBackups.Count -gt 0) {
    foreach ($backup in $existingBackups) {
        $age = (Get-Date) - $backup.LastWriteTime
        $sizeMB = [math]::Round($backup.Length / 1MB, 2)
        
        $ageText = if ($age.Days -gt 0) { "$($age.Days) days ago" }
                   elseif ($age.Hours -gt 0) { "$($age.Hours) hours ago" }
                   else { "$($age.Minutes) minutes ago" }
        
        $marker = if ($backup.Name -eq $backupFileName) { " ← NEW" } else { "" }
        
        Write-Host "  • $($backup.Name)" -ForegroundColor Gray
        Write-Host "    Size: $sizeMB MB | Created: $ageText$marker" -ForegroundColor DarkGray
    }
    
    # Suggest cleanup if many backups
    if ($existingBackups.Count -gt 5) {
        Write-Host "`nTip: You have $($existingBackups.Count) backups. Consider cleaning up old ones." -ForegroundColor Yellow
    }
} else {
    Write-Host "  No previous backups found" -ForegroundColor Gray
}

Write-Host ""
