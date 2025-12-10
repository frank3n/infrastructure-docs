# cleanup-worktrees.ps1
# Remove Git worktrees for calculator-website project
# Safely removes worktrees while preserving the main repository

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectName = "calculator-website-test",
    
    [Parameter(Mandatory=$false)]
    [string]$BaseDirectory = "C:\github-code",
    
    [Parameter(Mandatory=$false)]
    [string[]]$Branches,
    
    [Parameter(Mandatory=$false)]
    [switch]$Force,
    
    [Parameter(Mandatory=$false)]
    [switch]$All,
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun
)

# Color output functions
function Write-Success { param($msg) Write-Host $msg -ForegroundColor Green }
function Write-Info { param($msg) Write-Host $msg -ForegroundColor Cyan }
function Write-Warning { param($msg) Write-Host $msg -ForegroundColor Yellow }
function Write-Error { param($msg) Write-Host $msg -ForegroundColor Red }

Write-Warning "`n========================================="
Write-Warning "Git Worktree Cleanup"
Write-Warning "=========================================`n"

$projectPath = Join-Path $BaseDirectory $ProjectName

# Check if project exists
if (-not (Test-Path $projectPath)) {
    Write-Error "Project not found: $projectPath"
    exit 1
}

# Get list of worktrees
Write-Info "Discovering worktrees..."
try {
    $worktreesCmd = "cd '$projectPath' && git worktree list --porcelain"
    $worktreeOutput = bash -c $worktreesCmd
    
    # Parse worktree output
    $worktrees = @()
    $currentWorktree = @{}
    
    foreach ($line in $worktreeOutput -split "`n") {
        if ($line -match "^worktree (.+)$") {
            if ($currentWorktree.Count -gt 0) {
                $worktrees += $currentWorktree
            }
            $currentWorktree = @{
                Path = $matches[1].Trim()
            }
        }
        elseif ($line -match "^branch refs/heads/(.+)$") {
            $currentWorktree.Branch = $matches[1].Trim()
        }
    }
    
    # Add last worktree
    if ($currentWorktree.Count -gt 0) {
        $worktrees += $currentWorktree
    }
    
    # If no branch detected, check each worktree
    foreach ($wt in $worktrees) {
        if (-not $wt.Branch) {
            $branchCmd = "cd '$($wt.Path)' && git branch --show-current"
            $branch = bash -c $branchCmd
            $wt.Branch = $branch.Trim()
            if ([string]::IsNullOrEmpty($wt.Branch)) {
                $wt.Branch = "main"
            }
        }
    }
    
    Write-Success "  ✓ Found $($worktrees.Count) worktree(s)"
    
} catch {
    Write-Error "  ✗ Failed to get worktree list: $_"
    exit 1
}

# Display current worktrees
Write-Host "`nCurrent worktrees:" -ForegroundColor Cyan
foreach ($wt in $worktrees) {
    $isMain = ($wt.Branch -eq "main" -or $wt.Branch -eq "master")
    $marker = if ($isMain) { " [MAIN - Protected]" } else { "" }
    Write-Host "  • $($wt.Branch)$marker" -ForegroundColor $(if ($isMain) { "Yellow" } else { "Gray" })
    Write-Host "    Path: $($wt.Path)" -ForegroundColor DarkGray
}

# Determine which worktrees to remove
$worktreesToRemove = @()

if ($All) {
    # Remove all except main
    $worktreesToRemove = $worktrees | Where-Object { 
        $_.Branch -ne "main" -and $_.Branch -ne "master" 
    }
    Write-Warning "`n⚠ ALL mode selected - will remove all worktrees except main"
}
elseif ($Branches -and $Branches.Count -gt 0) {
    # Remove specific branches
    $worktreesToRemove = $worktrees | Where-Object { 
        $Branches -contains $_.Branch -and $_.Branch -ne "main" -and $_.Branch -ne "master"
    }
    
    # Warn about protected branches
    $protectedBranches = $Branches | Where-Object { $_ -eq "main" -or $_ -eq "master" }
    if ($protectedBranches) {
        Write-Warning "`n⚠ Cannot remove protected branches: $($protectedBranches -join ', ')"
    }
}
else {
    Write-Error "`nNo branches specified for removal"
    Write-Host "Usage examples:" -ForegroundColor Yellow
    Write-Host "  .\cleanup-worktrees.ps1 -Branches feature-1,feature-2" -ForegroundColor Gray
    Write-Host "  .\cleanup-worktrees.ps1 -All" -ForegroundColor Gray
    Write-Host "  .\cleanup-worktrees.ps1 -All -DryRun" -ForegroundColor Gray
    exit 1
}

if ($worktreesToRemove.Count -eq 0) {
    Write-Info "`nNo worktrees to remove"
    exit 0
}

# Display what will be removed
Write-Host "`nWorktrees to be removed:" -ForegroundColor Red
foreach ($wt in $worktreesToRemove) {
    Write-Host "  • $($wt.Branch)" -ForegroundColor Red
    Write-Host "    Path: $($wt.Path)" -ForegroundColor DarkGray
    
    # Check for uncommitted changes
    $statusCmd = "cd '$($wt.Path)' && git status --porcelain"
    $status = bash -c $statusCmd
    
    if (-not [string]::IsNullOrEmpty($status)) {
        Write-Warning "    ⚠ Has uncommitted changes!"
    }
    
    # Check if node_modules exists (disk space info)
    $nodeModulesPath = Join-Path $wt.Path "node_modules"
    if (Test-Path $nodeModulesPath) {
        try {
            $size = (Get-ChildItem $nodeModulesPath -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1MB
            Write-Host "    node_modules size: $([math]::Round($size, 2)) MB" -ForegroundColor DarkGray
        } catch {
            Write-Host "    node_modules exists" -ForegroundColor DarkGray
        }
    }
}

# Dry run mode
if ($DryRun) {
    Write-Info "`n[DRY RUN] No changes will be made"
    Write-Success "`n✓ Dry run complete - these worktrees would be removed`n"
    exit 0
}

# Confirmation (unless Force flag is set)
if (-not $Force) {
    Write-Host ""
    Write-Warning "⚠ This will permanently remove the above worktrees and their node_modules"
    Write-Warning "⚠ Any uncommitted changes will be lost"
    Write-Host ""
    $confirmation = Read-Host "Are you sure you want to continue? Type 'yes' to confirm"
    
    if ($confirmation -ne "yes") {
        Write-Info "Cleanup cancelled by user"
        exit 0
    }
}

# Remove worktrees
Write-Info "`nRemoving worktrees..."
$successCount = 0
$failCount = 0

foreach ($wt in $worktreesToRemove) {
    Write-Host "`n  Removing: $($wt.Branch)" -ForegroundColor Yellow
    
    try {
        # Determine force flag
        $forceFlag = if ($Force) { "--force" } else { "" }
        
        # Get the branch name for the worktree path
        # Extract just the branch name from the path
        $branchPath = Split-Path -Leaf $wt.Path
        
        # Remove worktree using Git Bash
        $removeCmd = "cd '$projectPath' && git worktree remove '$branchPath' $forceFlag 2>&1"
        $result = bash -c $removeCmd
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "    ✓ Worktree removed successfully"
            $successCount++
        } else {
            Write-Error "    ✗ Failed to remove worktree: $result"
            $failCount++
            
            # Suggest using --force
            if (-not $Force) {
                Write-Warning "    Try running with -Force flag to remove worktrees with uncommitted changes"
            }
        }
    } catch {
        Write-Error "    ✗ Error removing worktree: $_"
        $failCount++
    }
}

# Summary
Write-Success "`n========================================="
Write-Success "Cleanup Summary"
Write-Success "=========================================`n"

Write-Host "Results:" -ForegroundColor Cyan
Write-Host "  Successfully removed: $successCount" -ForegroundColor Green
if ($failCount -gt 0) {
    Write-Host "  Failed to remove: $failCount" -ForegroundColor Red
}

# Display remaining worktrees
Write-Host "`nRemaining worktrees:" -ForegroundColor Cyan
try {
    $remainingCmd = "cd '$projectPath' && git worktree list"
    $remaining = bash -c $remainingCmd
    $remaining | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
} catch {
    Write-Warning "  Could not list remaining worktrees"
}

# Cleanup tips
if ($successCount -gt 0) {
    Write-Host "`nNext steps:" -ForegroundColor Yellow
    Write-Host "  • Disk space has been freed from removed node_modules" -ForegroundColor Gray
    Write-Host "  • Git references have been cleaned up" -ForegroundColor Gray
    Write-Host "  • You can recreate worktrees anytime with setup-worktrees.ps1" -ForegroundColor Gray
}

if ($failCount -gt 0) {
    Write-Host "`nTroubleshooting failed removals:" -ForegroundColor Yellow
    Write-Host "  • Use -Force flag to remove worktrees with uncommitted changes" -ForegroundColor Gray
    Write-Host "  • Manually delete directory and run: git worktree prune" -ForegroundColor Gray
    Write-Host "  • Check if dev servers are still running for those branches" -ForegroundColor Gray
}

Write-Success "`n✓ Cleanup complete!`n"
