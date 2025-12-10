# setup-worktrees.ps1
# Automated Git Worktree Setup for calculator-website
# Creates worktrees for multiple branches with npm dependencies and port configuration

param(
    [Parameter(Mandatory=$false)]
    [string]$RepoUrl = "https://github.com/frank3n/calculator-website",

    [Parameter(Mandatory=$false)]
    [string]$ProjectName = "calculator-website-test",

    [Parameter(Mandatory=$false)]
    [string]$BaseDirectory = "C:\github-claude",

    [Parameter(Mandatory=$false)]
    [string]$BranchListFile = "C:\github-claude\calculator-website-documentation\all-branches.txt",

    [Parameter(Mandatory=$false)]
    [string[]]$Branches = $null,

    [Parameter(Mandatory=$false)]
    [switch]$SkipNpmInstall
)

# Color output functions
function Write-Success { param($msg) Write-Host $msg -ForegroundColor Green }
function Write-Info { param($msg) Write-Host $msg -ForegroundColor Cyan }
function Write-Warning { param($msg) Write-Host $msg -ForegroundColor Yellow }
function Write-Error { param($msg) Write-Host $msg -ForegroundColor Red }

# Load branches from file if not specified
if ($null -eq $Branches -or $Branches.Count -eq 0) {
    if (Test-Path $BranchListFile) {
        Write-Info "Loading branches from: $BranchListFile"

        # Read and parse the branch list file
        $fileContent = Get-Content $BranchListFile
        $parsedBranches = @()

        foreach ($line in $fileContent) {
            $trimmedLine = $line.Trim()

            # Skip empty lines, the command line, and HEAD reference
            if ([string]::IsNullOrWhiteSpace($trimmedLine) -or
                $trimmedLine -eq "git branch -r" -or
                $trimmedLine -like "*HEAD*") {
                continue
            }

            # Remove "origin/" prefix if present
            if ($trimmedLine -match "^\s*origin/(.+)$") {
                $branchName = $matches[1]
                $parsedBranches += $branchName
            }
        }

        # Remove duplicates and sort
        $Branches = $parsedBranches | Select-Object -Unique | Sort-Object

        Write-Success "Loaded $($Branches.Count) unique branches from file"
    } else {
        Write-Warning "Branch list file not found: $BranchListFile"
        Write-Warning "Using default branch: main"
        $Branches = @("main")
    }
}

Write-Success "`n========================================="
Write-Success "Git Worktree Setup for Calculator Website"
Write-Success "=========================================`n"

Write-Info "Branches to process ($($Branches.Count)):"
foreach ($branch in $Branches) {
    Write-Host "  - $branch" -ForegroundColor Gray
}
Write-Host ""

$projectPath = Join-Path $BaseDirectory $ProjectName

# Check if project already exists
if (Test-Path $projectPath) {
    Write-Warning "Project directory already exists: $projectPath"
    $continue = Read-Host "Do you want to continue and add worktrees to existing repo? (yes/no)"
    if ($continue -ne "yes") {
        Write-Error "Setup cancelled."
        exit
    }
    $skipClone = $true
} else {
    $skipClone = $false
}

# Step 1: Clone repository (if needed)
if (-not $skipClone) {
    Write-Info "`n[Step 1/5] Cloning repository..."
    Write-Host "  Repository: $RepoUrl" -ForegroundColor Gray
    Write-Host "  Destination: $projectPath" -ForegroundColor Gray
    
    try {
        # Use Git Bash for cloning
        $cloneCmd = "cd '$BaseDirectory' && git clone $RepoUrl $ProjectName"
        $result = bash -c $cloneCmd 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "  ✓ Repository cloned successfully"
        } else {
            throw "Git clone failed: $result"
        }
    } catch {
        Write-Error "  ✗ Failed to clone repository: $_"
        exit 1
    }
} else {
    Write-Info "`n[Step 1/5] Using existing repository..."
    Write-Success "  ✓ Repository found at $projectPath"
}

# Step 2: Fetch all remote branches
Write-Info "`n[Step 2/5] Fetching remote branches..."
try {
    $fetchCmd = "cd '$projectPath' && git fetch origin"
    bash -c $fetchCmd 2>&1 | Out-Null
    
    # List all remote branches
    $branchListCmd = "cd '$projectPath' && git branch -r"
    $remoteBranches = bash -c $branchListCmd
    
    Write-Success "  ✓ Remote branches fetched"
    Write-Host "`n  Available branches:" -ForegroundColor Gray
    $remoteBranches | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
} catch {
    Write-Error "  ✗ Failed to fetch branches: $_"
    exit 1
}

# Step 3: Create worktrees for each branch
Write-Info "`n[Step 3/5] Creating worktrees..."

$createdWorktrees = @()
$portNumber = 5173  # Vite's default dev port

foreach ($branch in $Branches) {
    Write-Host "`n  Processing branch: $branch" -ForegroundColor Yellow
    
    # Check if branch is main (already exists as primary worktree)
    if ($branch -eq "main" -or $branch -eq "master") {
        Write-Info "    ℹ Main branch already exists as primary worktree"
        $createdWorktrees += @{
            Branch = $branch
            Path = $projectPath
            Port = $portNumber
        }
        $portNumber++
        continue
    }
    
    $worktreePath = Join-Path $projectPath $branch
    
    # Check if worktree already exists
    if (Test-Path $worktreePath) {
        Write-Warning "    ⚠ Worktree already exists: $worktreePath"
        $createdWorktrees += @{
            Branch = $branch
            Path = $worktreePath
            Port = $portNumber
        }
        $portNumber++
        continue
    }
    
    try {
        # Create worktree using Git Bash
        # Handle both local and remote branch references
        $worktreeCmd = "cd '$projectPath' && git worktree add $branch origin/$branch 2>&1"
        $result = bash -c $worktreeCmd
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "    ✓ Worktree created at: $worktreePath"
            $createdWorktrees += @{
                Branch = $branch
                Path = $worktreePath
                Port = $portNumber
            }
        } else {
            # Try without origin/ prefix for local branches
            $worktreeCmd = "cd '$projectPath' && git worktree add $branch $branch 2>&1"
            $result = bash -c $worktreeCmd
            
            if ($LASTEXITCODE -eq 0) {
                Write-Success "    ✓ Worktree created at: $worktreePath"
                $createdWorktrees += @{
                    Branch = $branch
                    Path = $worktreePath
                    Port = $portNumber
                }
            } else {
                Write-Error "    ✗ Failed to create worktree: $result"
            }
        }
    } catch {
        Write-Error "    ✗ Error creating worktree: $_"
    }
    
    $portNumber++
}

# Step 4: Install npm dependencies for each worktree
if (-not $SkipNpmInstall) {
    Write-Info "`n[Step 4/5] Installing npm dependencies..."
    
    foreach ($worktree in $createdWorktrees) {
        Write-Host "`n  Installing for branch: $($worktree.Branch)" -ForegroundColor Yellow
        Write-Host "    Path: $($worktree.Path)" -ForegroundColor Gray
        
        try {
            Set-Location $worktree.Path
            
            # Check if node_modules exists
            if (Test-Path "node_modules") {
                Write-Info "    ℹ node_modules already exists, skipping..."
                continue
            }
            
            Write-Host "    Running npm install..." -ForegroundColor Gray
            $npmResult = npm install 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                Write-Success "    ✓ Dependencies installed successfully"
            } else {
                Write-Error "    ✗ npm install failed: $npmResult"
            }
        } catch {
            Write-Error "    ✗ Error installing dependencies: $_"
        }
    }
} else {
    Write-Warning "`n[Step 4/5] Skipping npm install (--SkipNpmInstall flag set)"
}

# Step 5: Configure ports for each worktree
Write-Info "`n[Step 5/5] Configuring ports..."

foreach ($worktree in $createdWorktrees) {
    Write-Host "`n  Configuring branch: $($worktree.Branch)" -ForegroundColor Yellow
    Write-Host "    Port: $($worktree.Port)" -ForegroundColor Gray
    
    try {
        Set-Location $worktree.Path
        
        # Create vite.config.ts with custom port (if not exists)
        # We'll modify the existing vite.config.ts to add server port
        $viteConfigPath = Join-Path $worktree.Path "vite.config.ts"
        
        if (Test-Path $viteConfigPath) {
            # Read existing config
            $viteConfig = Get-Content $viteConfigPath -Raw
            
            # Check if server config already exists
            if ($viteConfig -notmatch "server:\s*{") {
                # Add server config after plugins
                $viteConfig = $viteConfig -replace "(plugins:\s*\[.*?\],)", "`$1`n  server: { port: $($worktree.Port) },"
                
                # Write back
                $viteConfig | Out-File -FilePath $viteConfigPath -Encoding utf8 -NoNewline
                Write-Success "    ✓ Port configured in vite.config.ts"
            } else {
                Write-Info "    ℹ Server config already exists in vite.config.ts"
            }
        }
        
        # Also create .env.local for additional configuration
        $envContent = @"
# Port configuration for branch: $($worktree.Branch)
VITE_PORT=$($worktree.Port)

# DeepL API Token (add when available)
# VITE_DEEPL_API_TOKEN=your_token_here
"@
        
        $envContent | Out-File -FilePath ".env.local" -Encoding utf8
        Write-Success "    ✓ .env.local created"
        
    } catch {
        Write-Error "    ✗ Error configuring port: $_"
    }
}

# Summary
Write-Success "`n========================================="
Write-Success "Setup Complete!"
Write-Success "=========================================`n"

Write-Host "Worktrees created:" -ForegroundColor Cyan
bash -c "cd '$projectPath' && git worktree list" | ForEach-Object {
    Write-Host "  $_" -ForegroundColor Gray
}

Write-Host "`nPort assignments:" -ForegroundColor Cyan
foreach ($worktree in $createdWorktrees) {
    Write-Host "  $($worktree.Branch.PadRight(30)) → http://localhost:$($worktree.Port)" -ForegroundColor Gray
}

Write-Host "`nAvailable npm commands:" -ForegroundColor Cyan
Write-Host "  npm run dev      - Start development server (Vite)" -ForegroundColor Gray
Write-Host "  npm run build    - Build for production" -ForegroundColor Gray
Write-Host "  npm run preview  - Preview production build" -ForegroundColor Gray
Write-Host "  npm test         - Run tests (Vitest)" -ForegroundColor Gray
Write-Host "  npm run lint     - Lint code (ESLint)" -ForegroundColor Gray

Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "  1. Review the .env.local files and add DeepL API token when available" -ForegroundColor Gray
Write-Host "  2. Start all servers: .\start-all-servers.ps1" -ForegroundColor Gray
Write-Host "  3. Or start individual servers: cd $projectPath\<branch> && npm run dev" -ForegroundColor Gray

Write-Success "`n✓ All done!`n"
