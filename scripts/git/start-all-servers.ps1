# start-all-servers.ps1
# Start development servers for all calculator-website worktrees
# Each server runs in a separate PowerShell window with unique port

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectName = "calculator-website-test",
    
    [Parameter(Mandatory=$false)]
    [string]$BaseDirectory = "C:\github-code",
    
    [Parameter(Mandatory=$false)]
    [string]$NpmCommand = "dev",
    
    [Parameter(Mandatory=$false)]
    [switch]$Preview,
    
    [Parameter(Mandatory=$false)]
    [string[]]$OnlyBranches
)

# Color output functions
function Write-Success { param($msg) Write-Host $msg -ForegroundColor Green }
function Write-Info { param($msg) Write-Host $msg -ForegroundColor Cyan }
function Write-Warning { param($msg) Write-Host $msg -ForegroundColor Yellow }
function Write-Error { param($msg) Write-Host $msg -ForegroundColor Red }

Write-Success "`n========================================="
Write-Success "Starting Calculator Website Dev Servers"
Write-Success "=========================================`n"

$projectPath = Join-Path $BaseDirectory $ProjectName

# Check if project exists
if (-not (Test-Path $projectPath)) {
    Write-Error "Project not found: $projectPath"
    Write-Warning "Run setup-worktrees.ps1 first to create the project structure"
    exit 1
}

# Determine npm command to use
if ($Preview) {
    $NpmCommand = "preview"
    $defaultPort = 4173
    Write-Info "Mode: Preview (production build preview)"
} else {
    $defaultPort = 5173
    Write-Info "Mode: Development"
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
    
    # If no branch detected for main worktree, assume it's main
    foreach ($wt in $worktrees) {
        if (-not $wt.Branch) {
            # Check current branch for this worktree
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

# Filter by OnlyBranches if specified
if ($OnlyBranches -and $OnlyBranches.Count -gt 0) {
    $worktrees = $worktrees | Where-Object { $OnlyBranches -contains $_.Branch }
    Write-Info "Filtered to $($worktrees.Count) worktree(s) based on -OnlyBranches parameter"
}

if ($worktrees.Count -eq 0) {
    Write-Error "No worktrees found to start"
    exit 1
}

# Display worktrees that will be started
Write-Host "`nWorktrees to start:" -ForegroundColor Cyan
foreach ($wt in $worktrees) {
    Write-Host "  • $($wt.Branch)" -ForegroundColor Gray
    Write-Host "    Path: $($wt.Path)" -ForegroundColor DarkGray
}

Write-Host ""
$confirmation = Read-Host "Start servers for these worktrees? (yes/no)"
if ($confirmation -ne "yes") {
    Write-Warning "Cancelled by user"
    exit 0
}

# Start each server
Write-Info "`nStarting servers..."
$startedServers = @()

foreach ($wt in $worktrees) {
    Write-Host "`n  Starting server for: $($wt.Branch)" -ForegroundColor Yellow
    
    # Convert Windows path to proper format
    $wtPath = $wt.Path -replace '/', '\'
    
    # Check if .env.local exists to get port
    $envPath = Join-Path $wtPath ".env.local"
    $port = $defaultPort
    
    if (Test-Path $envPath) {
        $envContent = Get-Content $envPath -Raw
        if ($envContent -match "VITE_PORT=(\d+)") {
            $port = $matches[1]
        }
    }
    
    # Check if package.json exists
    $packageJsonPath = Join-Path $wtPath "package.json"
    if (-not (Test-Path $packageJsonPath)) {
        Write-Warning "    ⚠ package.json not found, skipping..."
        continue
    }
    
    # Build the command
    $serverCommand = @"
Write-Host '==========================================' -ForegroundColor Green
Write-Host 'Calculator Website - Branch: $($wt.Branch)' -ForegroundColor Green
Write-Host '==========================================' -ForegroundColor Green
Write-Host ''
Write-Host 'Path: $wtPath' -ForegroundColor Cyan
Write-Host 'Port: $port' -ForegroundColor Cyan
Write-Host 'URL:  http://localhost:$port' -ForegroundColor Yellow
Write-Host ''
Write-Host 'Press Ctrl+C to stop the server' -ForegroundColor Gray
Write-Host ''
Set-Location '$wtPath'
npm run $NpmCommand
"@
    
    try {
        # Start in new PowerShell window
        $process = Start-Process pwsh -ArgumentList "-NoExit", "-Command", $serverCommand -PassThru
        
        Write-Success "    ✓ Server started in new window (PID: $($process.Id))"
        Write-Host "      URL: http://localhost:$port" -ForegroundColor Gray
        
        $startedServers += @{
            Branch = $wt.Branch
            Port = $port
            ProcessId = $process.Id
            Path = $wtPath
        }
        
        # Small delay to prevent overwhelming the system
        Start-Sleep -Seconds 2
        
    } catch {
        Write-Error "    ✗ Failed to start server: $_"
    }
}

# Summary
Write-Success "`n========================================="
Write-Success "Server Start Summary"
Write-Success "=========================================`n"

if ($startedServers.Count -eq 0) {
    Write-Warning "No servers were started"
    exit 1
}

Write-Host "Started $($startedServers.Count) server(s):" -ForegroundColor Cyan
Write-Host ""

# Display in a nice table format
$maxBranchLen = ($startedServers | ForEach-Object { $_.Branch.Length } | Measure-Object -Maximum).Maximum
$header = "  {0,-$maxBranchLen} | {1,-8} | {2}" -f "Branch", "Port", "URL"
Write-Host $header -ForegroundColor White
Write-Host ("  " + ("-" * $header.Length)) -ForegroundColor DarkGray

foreach ($server in $startedServers) {
    $line = "  {0,-$maxBranchLen} | {1,-8} | {2}" -f $server.Branch, $server.Port, "http://localhost:$($server.Port)"
    Write-Host $line -ForegroundColor Gray
}

Write-Host "`nProcess IDs:" -ForegroundColor Cyan
foreach ($server in $startedServers) {
    Write-Host "  $($server.Branch): PID $($server.ProcessId)" -ForegroundColor Gray
}

Write-Host "`nUseful commands:" -ForegroundColor Yellow
Write-Host "  • Check all servers: Get-Process pwsh | Where-Object { `$_.MainWindowTitle -like '*Calculator*' }" -ForegroundColor Gray
Write-Host "  • Stop all servers: Press Ctrl+C in each window" -ForegroundColor Gray
Write-Host "  • Kill by PID: Stop-Process -Id <PID>" -ForegroundColor Gray

Write-Host "`nTips:" -ForegroundColor Yellow
Write-Host "  • Each server runs in its own PowerShell window" -ForegroundColor Gray
Write-Host "  • Use Windows Terminal tabs to organize your servers" -ForegroundColor Gray
Write-Host "  • Test all branches side-by-side in different browser tabs" -ForegroundColor Gray
Write-Host "  • Hot reload is active - changes will reflect automatically" -ForegroundColor Gray

Write-Success "`n✓ All servers started successfully!`n"

# Optional: Open browsers
$openBrowsers = Read-Host "Open all URLs in browser? (yes/no)"
if ($openBrowsers -eq "yes") {
    Write-Info "`nOpening browsers..."
    foreach ($server in $startedServers) {
        $url = "http://localhost:$($server.Port)"
        Start-Process $url
        Start-Sleep -Milliseconds 500
    }
    Write-Success "  ✓ Browsers opened"
}

Write-Host ""
