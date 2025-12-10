# run-npm-sequential.ps1
# Run npm commands sequentially for each branch worktree with individual logging

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectPath = "C:\github-claude\calculator-website-test",

    [Parameter(Mandatory=$false)]
    [ValidateSet("dev", "build", "test", "lint", "preview")]
    [string]$NpmCommand = "build",

    [Parameter(Mandatory=$false)]
    [string]$LogDirectory = "C:\github-claude\calculator-website-documentation\npm-logs",

    [Parameter(Mandatory=$false)]
    [int]$DevServerTimeout = 30,  # Seconds to run dev server before stopping

    [Parameter(Mandatory=$false)]
    [switch]$SkipOnError  # Continue to next branch if one fails
)

# Color output functions
function Write-Success { param($msg) Write-Host $msg -ForegroundColor Green }
function Write-Info { param($msg) Write-Host $msg -ForegroundColor Cyan }
function Write-Warning { param($msg) Write-Host $msg -ForegroundColor Yellow }
function Write-Error { param($msg) Write-Host $msg -ForegroundColor Red }

Write-Success "`n========================================="
Write-Success "Sequential NPM Runner for Branch Worktrees"
Write-Success "=========================================`n"

# Create log directory if it doesn't exist
if (-not (Test-Path $LogDirectory)) {
    New-Item -Path $LogDirectory -ItemType Directory -Force | Out-Null
    Write-Info "Created log directory: $LogDirectory"
}

# Get timestamp for log file naming
$timestamp = Get-Date -Format "yyyy-MM-dd-HHmmss"
$summaryLogPath = Join-Path $LogDirectory "summary-$timestamp.txt"

# Verify project path exists and is a git repo
if (-not (Test-Path $ProjectPath)) {
    Write-Error "Project path does not exist: $ProjectPath"
    exit 1
}

Set-Location $ProjectPath

# Check if it's a git repository
try {
    $gitCheck = git rev-parse --is-inside-work-tree 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Not a git repository: $ProjectPath"
        exit 1
    }
} catch {
    Write-Error "Not a git repository: $ProjectPath"
    exit 1
}

# Get list of all worktrees
Write-Info "Fetching worktree list..."
$worktreeList = git worktree list --porcelain

# Parse worktree information
$worktrees = @()
$currentWorktree = @{}

foreach ($line in $worktreeList) {
    if ($line -match "^worktree (.+)$") {
        if ($currentWorktree.Count -gt 0) {
            $worktrees += $currentWorktree.Clone()
            $currentWorktree.Clear()
        }
        $currentWorktree["path"] = $matches[1]
    }
    elseif ($line -match "^branch (.+)$") {
        $branchFullPath = $matches[1]
        # Extract just the branch name (remove refs/heads/)
        $branchName = $branchFullPath -replace "^refs/heads/", ""
        $currentWorktree["branch"] = $branchName
    }
}

# Add the last worktree
if ($currentWorktree.Count -gt 0) {
    $worktrees += $currentWorktree
}

Write-Success "Found $($worktrees.Count) worktrees`n"

# Display worktrees
Write-Info "Worktrees to process:"
foreach ($wt in $worktrees) {
    Write-Host "  - $($wt.branch)" -ForegroundColor Gray
    Write-Host "    $($wt.path)" -ForegroundColor DarkGray
}
Write-Host ""

# Initialize summary
$summary = @()
$successCount = 0
$failCount = 0
$skipCount = 0

# Process each worktree
for ($i = 0; $i -lt $worktrees.Count; $i++) {
    $worktree = $worktrees[$i]
    $branchName = $worktree.branch
    $worktreePath = $worktree.path

    Write-Host "`n=========================================" -ForegroundColor Cyan
    Write-Host "[$($i + 1)/$($worktrees.Count)] Processing: $branchName" -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "Path: $worktreePath" -ForegroundColor Gray
    Write-Host "Command: npm run $NpmCommand" -ForegroundColor Gray

    # Create safe filename for log (replace / and \ with -)
    $safeBranchName = $branchName -replace "[/\\]", "-"
    $logFileName = "$safeBranchName-$NpmCommand-$timestamp.log"
    $logFilePath = Join-Path $LogDirectory $logFileName

    Write-Host "Log file: $logFilePath" -ForegroundColor Gray
    Write-Host ""

    # Check if worktree path exists
    if (-not (Test-Path $worktreePath)) {
        Write-Error "Worktree path does not exist: $worktreePath"
        $summary += @{
            Branch = $branchName
            Status = "SKIPPED"
            Reason = "Path not found"
            LogFile = "N/A"
        }
        $skipCount++
        continue
    }

    # Check if package.json exists
    $packageJsonPath = Join-Path $worktreePath "package.json"
    if (-not (Test-Path $packageJsonPath)) {
        Write-Warning "No package.json found in $worktreePath"
        $summary += @{
            Branch = $branchName
            Status = "SKIPPED"
            Reason = "No package.json"
            LogFile = "N/A"
        }
        $skipCount++
        continue
    }

    # Navigate to worktree
    Set-Location $worktreePath

    # Check if node_modules exists
    if (-not (Test-Path "node_modules")) {
        Write-Warning "node_modules not found. Running npm install first..."
        Write-Host "Running: npm install" -ForegroundColor Yellow

        $installLogPath = Join-Path $LogDirectory "$safeBranchName-install-$timestamp.log"

        try {
            npm install *>&1 | Tee-Object -FilePath $installLogPath

            if ($LASTEXITCODE -ne 0) {
                Write-Error "npm install failed for $branchName"
                $summary += @{
                    Branch = $branchName
                    Status = "FAILED"
                    Reason = "npm install failed"
                    LogFile = $installLogPath
                }
                $failCount++

                if (-not $SkipOnError) {
                    Write-Error "Stopping execution. Use -SkipOnError to continue on failures."
                    break
                }
                continue
            }
            Write-Success "npm install completed"
        } catch {
            Write-Error "Error during npm install: $_"
            $summary += @{
                Branch = $branchName
                Status = "FAILED"
                Reason = "npm install error: $_"
                LogFile = $installLogPath
            }
            $failCount++

            if (-not $SkipOnError) {
                break
            }
            continue
        }
    }

    # Run npm command
    Write-Info "`nRunning: npm run $NpmCommand"
    Write-Host "Press Ctrl+C to skip to next branch (if running dev server)`n" -ForegroundColor DarkGray

    $startTime = Get-Date

    try {
        if ($NpmCommand -eq "dev") {
            # For dev server, run with timeout
            Write-Warning "Dev server will run for $DevServerTimeout seconds, then auto-stop"

            # Start dev server in background job
            $job = Start-Job -ScriptBlock {
                param($path, $logFile)
                Set-Location $path
                npm run dev *>&1 | Tee-Object -FilePath $logFile
            } -ArgumentList $worktreePath, $logFilePath

            # Wait for specified timeout
            $waited = 0
            while ($waited -lt $DevServerTimeout -and $job.State -eq "Running") {
                Start-Sleep -Seconds 1
                $waited++
                Write-Progress -Activity "Running dev server for $branchName" `
                               -Status "$waited / $DevServerTimeout seconds" `
                               -PercentComplete (($waited / $DevServerTimeout) * 100)
            }

            # Stop the job
            Stop-Job -Job $job
            Receive-Job -Job $job | Out-File -FilePath $logFilePath -Append
            Remove-Job -Job $job

            Write-Success "Dev server ran for $waited seconds"

            $summary += @{
                Branch = $branchName
                Status = "SUCCESS"
                Reason = "Ran for $waited seconds"
                LogFile = $logFilePath
                Duration = "$waited seconds"
            }
            $successCount++

        } else {
            # For build/test/lint, run to completion
            npm run $NpmCommand *>&1 | Tee-Object -FilePath $logFilePath

            $endTime = Get-Date
            $duration = ($endTime - $startTime).TotalSeconds

            if ($LASTEXITCODE -eq 0) {
                Write-Success "`n✓ npm run $NpmCommand completed successfully"
                $summary += @{
                    Branch = $branchName
                    Status = "SUCCESS"
                    Reason = "Completed"
                    LogFile = $logFilePath
                    Duration = "$([math]::Round($duration, 2)) seconds"
                }
                $successCount++
            } else {
                Write-Error "`n✗ npm run $NpmCommand failed"
                $summary += @{
                    Branch = $branchName
                    Status = "FAILED"
                    Reason = "npm run $NpmCommand exited with code $LASTEXITCODE"
                    LogFile = $logFilePath
                    Duration = "$([math]::Round($duration, 2)) seconds"
                }
                $failCount++

                if (-not $SkipOnError) {
                    Write-Error "Stopping execution. Use -SkipOnError to continue on failures."
                    break
                }
            }
        }
    } catch {
        Write-Error "Error running npm command: $_"
        $summary += @{
            Branch = $branchName
            Status = "FAILED"
            Reason = "Error: $_"
            LogFile = $logFilePath
        }
        $failCount++

        if (-not $SkipOnError) {
            break
        }
    }
}

# Return to project root
Set-Location $ProjectPath

# Print summary
Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "=========================================`n" -ForegroundColor Cyan

Write-Host "Total worktrees: $($worktrees.Count)" -ForegroundColor White
Write-Success "Successful: $successCount"
Write-Error "Failed: $failCount"
Write-Warning "Skipped: $skipCount"

Write-Host "`nDetailed Results:" -ForegroundColor Cyan

# Create summary output
$summaryOutput = @()
$summaryOutput += "========================================="
$summaryOutput += "NPM Sequential Run Summary"
$summaryOutput += "========================================="
$summaryOutput += "Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$summaryOutput += "Command: npm run $NpmCommand"
$summaryOutput += "Total: $($worktrees.Count) | Success: $successCount | Failed: $failCount | Skipped: $skipCount"
$summaryOutput += ""
$summaryOutput += "Detailed Results:"
$summaryOutput += ""

foreach ($result in $summary) {
    $statusColor = switch ($result.Status) {
        "SUCCESS" { "Green" }
        "FAILED" { "Red" }
        "SKIPPED" { "Yellow" }
        default { "Gray" }
    }

    $statusSymbol = switch ($result.Status) {
        "SUCCESS" { "✓" }
        "FAILED" { "✗" }
        "SKIPPED" { "○" }
        default { "-" }
    }

    Write-Host "  $statusSymbol " -ForegroundColor $statusColor -NoNewline
    Write-Host "$($result.Branch)" -ForegroundColor White
    Write-Host "    Status: $($result.Status)" -ForegroundColor $statusColor
    Write-Host "    Reason: $($result.Reason)" -ForegroundColor Gray
    if ($result.Duration) {
        Write-Host "    Duration: $($result.Duration)" -ForegroundColor Gray
    }
    Write-Host "    Log: $($result.LogFile)" -ForegroundColor DarkGray
    Write-Host ""

    # Add to summary output
    $summaryOutput += "[$($result.Status)] $($result.Branch)"
    $summaryOutput += "  Reason: $($result.Reason)"
    if ($result.Duration) {
        $summaryOutput += "  Duration: $($result.Duration)"
    }
    $summaryOutput += "  Log: $($result.LogFile)"
    $summaryOutput += ""
}

# Save summary to file
$summaryOutput | Out-File -FilePath $summaryLogPath -Encoding UTF8
Write-Info "Summary saved to: $summaryLogPath"

Write-Host "`nLog files location: $LogDirectory" -ForegroundColor Cyan
Write-Success "`n✓ Sequential npm run complete!`n"
