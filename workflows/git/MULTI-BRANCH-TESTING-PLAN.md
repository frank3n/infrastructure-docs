# Multi-Branch GitHub Repository Testing Plan
## Using Git Worktrees on Windows 11

---

## Table of Contents
1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Directory Structure](#directory-structure)
4. [Implementation Steps](#implementation-steps)
5. [Usage Workflow](#usage-workflow)
6. [Automation Scripts](#automation-scripts)
7. [Troubleshooting](#troubleshooting)
8. [Best Practices](#best-practices)

---

## Overview

This plan enables simultaneous testing of multiple branches from a single GitHub repository using **Git Worktrees**. Each branch runs in its own directory with isolated npm dependencies and can run dev servers on different ports simultaneously.

### Why Git Worktrees?

- ✅ **Multiple branches active simultaneously** - No switching overhead
- ✅ **Shared git history** - Saves disk space (only one .git directory)
- ✅ **Isolated dependencies** - Each branch has its own node_modules
- ✅ **Parallel development servers** - Test features side-by-side
- ✅ **No conflicts** - Complete isolation between branches
- ✅ **Easy cleanup** - Remove worktrees without affecting main repo

---

## Prerequisites

### Required Software
- ✅ Git (for Git Bash operations)
- ✅ PowerShell 7 (for npm and file operations)
- ✅ Node.js and npm (for running the project)

### Project Requirements
- GitHub repository URL
- Knowledge of branch names to test
- Default npm commands (e.g., `npm run dev`, `npm start`)
- Default port number the project uses

---

## Directory Structure

```
C:\github-claude\
├── your-project-name/
│   ├── main/                  # Main branch worktree
│   │   ├── node_modules/
│   │   ├── .env.local         # Port: 3000
│   │   └── ... (project files)
│   ├── feature-branch-1/      # Feature branch worktree
│   │   ├── node_modules/
│   │   ├── .env.local         # Port: 3001
│   │   └── ... (project files)
│   ├── feature-branch-2/      # Another feature branch
│   │   ├── node_modules/
│   │   ├── .env.local         # Port: 3002
│   │   └── ... (project files)
│   └── .git/                  # Shared git directory (hidden)
├── setup-worktrees.ps1        # Automation script
├── start-all-servers.ps1      # Launch all dev servers
├── cleanup-worktrees.ps1      # Remove worktrees
└── MULTI-BRANCH-TESTING-PLAN.md  # This file
```

---

## Implementation Steps

### Step 1: Initial Repository Clone (Git Bash)

**Terminal:** Git Bash  
**Location:** `C:\github-claude`

```bash
# Clone the repository with the main branch
git clone <REPOSITORY_URL> your-project-name

# Navigate into the repository
cd your-project-name

# Verify remote branches
git branch -r
```

**Expected Output:**
```
origin/HEAD -> origin/main
origin/main
origin/feature-branch-1
origin/feature-branch-2
origin/develop
```

---

### Step 2: Create Worktrees for Each Branch (Git Bash)

**Terminal:** Git Bash  
**Location:** `C:\github-claude\your-project-name`

```bash
# Create worktree for main branch (if not already default)
# This is usually already created during clone

# Create worktree for feature-branch-1
git worktree add ../your-project-name/feature-branch-1 origin/feature-branch-1

# Create worktree for feature-branch-2
git worktree add ../your-project-name/feature-branch-2 origin/feature-branch-2

# List all worktrees to verify
git worktree list
```

**Expected Output:**
```
C:/github-claude/your-project-name              abc1234 [main]
C:/github-claude/your-project-name/feature-branch-1  def5678 [feature-branch-1]
C:/github-claude/your-project-name/feature-branch-2  ghi9012 [feature-branch-2]
```

**Notes:**
- The path structure will be: `C:\github-claude\your-project-name\branch-name`
- Each worktree is a complete working directory
- All worktrees share the same `.git` directory

---

### Step 3: Install Dependencies for Each Branch (PowerShell 7)

**Terminal:** PowerShell 7  
**Reason:** npm operations use PowerShell 7 per .clinerules

```powershell
# Install dependencies for main branch
cd C:\github-claude\your-project-name\main
npm install

# Install dependencies for feature-branch-1
cd C:\github-claude\your-project-name\feature-branch-1
npm install

# Install dependencies for feature-branch-2
cd C:\github-claude\your-project-name\feature-branch-2
npm install
```

**Notes:**
- Each branch needs its own `node_modules` directory
- Dependencies may differ between branches
- This is a one-time setup per branch

---

### Step 4: Configure Different Ports (PowerShell 7)

**Terminal:** PowerShell 7

Create `.env.local` files (or modify `package.json` scripts) to assign different ports:

```powershell
# For main branch (Port 3000)
cd C:\github-claude\your-project-name\main
echo "PORT=3000" > .env.local

# For feature-branch-1 (Port 3001)
cd C:\github-claude\your-project-name\feature-branch-1
echo "PORT=3001" > .env.local

# For feature-branch-2 (Port 3002)
cd C:\github-claude\your-project-name\feature-branch-2
echo "PORT=3002" > .env.local
```

**Alternative:** Modify npm scripts in each `package.json`:
```json
{
  "scripts": {
    "dev": "next dev -p 3001"  // or whatever port
  }
}
```

**Port Assignment Reference:**
| Branch | Port | URL |
|--------|------|-----|
| main | 3000 | http://localhost:3000 |
| feature-branch-1 | 3001 | http://localhost:3001 |
| feature-branch-2 | 3002 | http://localhost:3002 |

---

### Step 5: Start Development Servers (PowerShell 7)

**Terminal:** PowerShell 7 (separate window for each)

```powershell
# Window 1 - Main branch
cd C:\github-claude\your-project-name\main
npm run dev

# Window 2 - Feature branch 1
cd C:\github-claude\your-project-name\feature-branch-1
npm run dev

# Window 3 - Feature branch 2
cd C:\github-claude\your-project-name\feature-branch-2
npm run dev
```

**Notes:**
- Open separate PowerShell 7 windows for each dev server
- Each server runs independently
- Access via browser at different ports

---

## Usage Workflow

### Daily Testing Routine

1. **Pull Latest Changes** (Git Bash)
   ```bash
   cd C:\github-claude\your-project-name
   git fetch origin
   
   # Update each worktree
   cd C:\github-claude\your-project-name\main
   git pull
   
   cd C:\github-claude\your-project-name\feature-branch-1
   git pull
   ```

2. **Start Servers** (PowerShell 7)
   - Use automation script (see below) OR
   - Manually start each server in separate windows

3. **Test in Browser**
   - http://localhost:3000 - Main branch
   - http://localhost:3001 - Feature branch 1
   - http://localhost:3002 - Feature branch 2

4. **Stop Servers**
   - Press `Ctrl+C` in each PowerShell window

### Adding New Branches

**Git Bash:**
```bash
cd C:\github-claude\your-project-name

# Create new worktree
git worktree add feature-branch-3 origin/feature-branch-3
```

**PowerShell 7:**
```powershell
# Install dependencies
cd C:\github-claude\your-project-name\feature-branch-3
npm install

# Configure port
echo "PORT=3003" > .env.local
```

### Removing Branches

**Git Bash:**
```bash
cd C:\github-claude\your-project-name

# Remove worktree
git worktree remove feature-branch-1

# Or if it has uncommitted changes
git worktree remove feature-branch-1 --force
```

---

## Automation Scripts

### 1. Setup Worktrees Script

**File:** `C:\github-claude\setup-worktrees.ps1`

```powershell
# setup-worktrees.ps1
param(
    [Parameter(Mandatory=$true)]
    [string]$RepoUrl,
    
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,
    
    [Parameter(Mandatory=$false)]
    [string[]]$Branches = @("main")
)

Write-Host "Setting up Git Worktrees for $ProjectName..." -ForegroundColor Green

# Clone repository using Git Bash
Write-Host "Cloning repository..." -ForegroundColor Yellow
$cloneCmd = "cd C:\github-claude && git clone $RepoUrl $ProjectName"
bash -c $cloneCmd

# Get current location
$baseDir = "C:\github-claude\$ProjectName"

# Create worktrees for each branch (except main which is already created)
foreach ($branch in $Branches) {
    if ($branch -ne "main") {
        Write-Host "Creating worktree for branch: $branch" -ForegroundColor Yellow
        
        # Create worktree using Git Bash
        $worktreeCmd = "cd $baseDir && git worktree add $branch origin/$branch"
        bash -c $worktreeCmd
        
        # Install npm dependencies
        Write-Host "Installing dependencies for $branch..." -ForegroundColor Cyan
        Set-Location "$baseDir\$branch"
        npm install
        
        # Calculate port number (3000 for main, 3001+)
        $portNumber = 3000 + [array]::IndexOf($Branches, $branch)
        
        # Create .env.local with port
        Write-Host "Configuring port $portNumber for $branch" -ForegroundColor Cyan
        "PORT=$portNumber" | Out-File -FilePath ".env.local" -Encoding utf8
    }
}

# Handle main branch
Write-Host "Installing dependencies for main branch..." -ForegroundColor Cyan
Set-Location "$baseDir"
npm install
"PORT=3000" | Out-File -FilePath ".env.local" -Encoding utf8

Write-Host "`nSetup complete! Worktrees created for:" -ForegroundColor Green
bash -c "cd $baseDir && git worktree list"

Write-Host "`nTo start all servers, run: .\start-all-servers.ps1 -ProjectName $ProjectName" -ForegroundColor Yellow
```

**Usage:**
```powershell
# PowerShell 7
cd C:\github-claude
.\setup-worktrees.ps1 -RepoUrl "https://github.com/user/repo.git" -ProjectName "my-project" -Branches @("main", "feature-1", "feature-2")
```

---

### 2. Start All Servers Script

**File:** `C:\github-claude\start-all-servers.ps1`

```powershell
# start-all-servers.ps1
param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,
    
    [Parameter(Mandatory=$false)]
    [string]$NpmCommand = "dev"
)

$baseDir = "C:\github-claude\$ProjectName"

Write-Host "Starting all development servers for $ProjectName..." -ForegroundColor Green

# Get list of worktrees
$worktreesCmd = "cd $baseDir && git worktree list"
$worktrees = bash -c $worktreesCmd

# Parse worktrees and start servers
foreach ($line in $worktrees -split "`n") {
    if ($line -match "C:[/\\].*?([^\s]+)\s+\w+\s+\[([^\]]+)\]") {
        $path = $matches[0] -replace '\s+\w+\s+\[.*', ''
        $branch = $matches[2]
        
        Write-Host "`nStarting server for branch: $branch" -ForegroundColor Yellow
        Write-Host "Path: $path" -ForegroundColor Cyan
        
        # Start new PowerShell window for each server
        $startCmd = "Set-Location '$path'; npm run $NpmCommand"
        Start-Process pwsh -ArgumentList "-NoExit", "-Command", $startCmd
        
        Start-Sleep -Seconds 2
    }
}

Write-Host "`nAll servers started in separate windows!" -ForegroundColor Green
Write-Host "Check each PowerShell window for the server URLs" -ForegroundColor Yellow
```

**Usage:**
```powershell
# PowerShell 7
cd C:\github-claude
.\start-all-servers.ps1 -ProjectName "my-project"

# Or with custom npm command
.\start-all-servers.ps1 -ProjectName "my-project" -NpmCommand "start"
```

---

### 3. Cleanup Worktrees Script

**File:** `C:\github-claude\cleanup-worktrees.ps1`

```powershell
# cleanup-worktrees.ps1
param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,
    
    [Parameter(Mandatory=$false)]
    [switch]$Force
)

$baseDir = "C:\github-claude\$ProjectName"

Write-Host "Cleaning up worktrees for $ProjectName..." -ForegroundColor Yellow

# Get list of worktrees
$worktreesCmd = "cd $baseDir && git worktree list"
$worktrees = bash -c $worktreesCmd

Write-Host "`nCurrent worktrees:" -ForegroundColor Cyan
Write-Host $worktrees

# Ask for confirmation unless -Force is used
if (-not $Force) {
    $confirmation = Read-Host "`nAre you sure you want to remove ALL worktrees (except main)? (yes/no)"
    if ($confirmation -ne "yes") {
        Write-Host "Cleanup cancelled." -ForegroundColor Red
        exit
    }
}

# Remove each worktree except main
foreach ($line in $worktrees -split "`n") {
    if ($line -match "\[([^\]]+)\]") {
        $branch = $matches[1]
        
        if ($branch -ne "main") {
            Write-Host "Removing worktree: $branch" -ForegroundColor Yellow
            
            $forceFlag = if ($Force) { "--force" } else { "" }
            $removeCmd = "cd $baseDir && git worktree remove $branch $forceFlag"
            bash -c $removeCmd
        }
    }
}

Write-Host "`nCleanup complete!" -ForegroundColor Green
bash -c "cd $baseDir && git worktree list"
```

**Usage:**
```powershell
# PowerShell 7
cd C:\github-claude

# With confirmation prompt
.\cleanup-worktrees.ps1 -ProjectName "my-project"

# Force removal without confirmation
.\cleanup-worktrees.ps1 -ProjectName "my-project" -Force
```

---

## Troubleshooting

### Issue: Port Already in Use

**Error:** `Error: listen EADDRINUSE: address already in use :::3000`

**Solution:**
```powershell
# Find process using the port
Get-Process -Id (Get-NetTCPConnection -LocalPort 3000).OwningProcess

# Kill the process
Stop-Process -Id <PROCESS_ID> -Force
```

---

### Issue: Git Worktree Won't Remove

**Error:** `fatal: 'branch-name' contains modified or untracked files, use --force to delete it`

**Solution:**
```bash
# Git Bash
cd C:\github-claude\your-project-name
git worktree remove branch-name --force
```

---

### Issue: npm Dependencies Conflict

**Problem:** Different branches require different Node.js versions

**Solution:**
Use Node Version Manager (nvm):
```powershell
# PowerShell 7
# Install nvm for Windows first

# In each branch directory, create .nvmrc file
echo "16.14.0" > .nvmrc

# Then use the version
nvm use
npm install
```

---

### Issue: Can't Find Git Bash Commands

**Problem:** `bash: command not found`

**Solution:**
Ensure Git Bash is in PATH:
```powershell
# PowerShell 7
# Add Git to PATH (if not already)
$env:Path += ";C:\Program Files\Git\bin"

# Or use full path
& "C:\Program Files\Git\bin\bash.exe" -c "git worktree list"
```

---

### Issue: Changes Not Appearing

**Problem:** Made changes in one worktree, not showing in another

**Solution:**
This is normal! Each worktree is independent. To share changes:
```bash
# Git Bash - In the worktree with changes
git add .
git commit -m "Your changes"
git push

# In other worktrees
git fetch origin
git pull
```

---

## Best Practices

### 1. Naming Conventions
- Use descriptive branch names: `feature/user-auth`, `bugfix/login-error`
- Keep worktree directory names matching branch names
- Use consistent port numbering scheme

### 2. Dependency Management
- Run `npm install` after creating each worktree
- Update dependencies in all worktrees when package.json changes
- Consider using `pnpm` or `yarn` for better disk space efficiency

### 3. Environment Variables
- Keep separate `.env.local` files for each branch
- Use `.env.example` as template
- Document required environment variables

### 4. Git Operations
- **Always use Git Bash** for git commands
- Commit changes before switching focus
- Keep worktrees synchronized with `git fetch` regularly

### 5. npm Operations
- **Always use PowerShell 7** for npm commands
- Run dev servers in separate windows
- Use Windows Terminal for better multi-window management

### 6. Resource Management
- Close dev servers when not testing
- Remove worktrees for merged/deleted branches
- Monitor disk space usage

### 7. Testing Workflow
- Test one feature at a time across branches
- Use browser profiles/incognito to avoid cache conflicts
- Document findings in branch-specific notes

### 8. Cleanup
- Remove worktrees after branches are merged
- Run `npm prune` periodically
- Keep only active development branches as worktrees

---

## Quick Reference

### Git Bash Commands
```bash
# List worktrees
git worktree list

# Add worktree
git worktree add <path> <branch>

# Remove worktree
git worktree remove <branch>

# List remote branches
git branch -r

# Fetch latest
git fetch origin
```

### PowerShell 7 Commands
```powershell
# Install dependencies
npm install

# Start dev server
npm run dev

# Check port usage
Get-NetTCPConnection -LocalPort 3000

# Kill process on port
Stop-Process -Id (Get-NetTCPConnection -LocalPort 3000).OwningProcess -Force
```

### Port Reference
| Branch | Port | URL |
|--------|------|-----|
| main | 3000 | http://localhost:3000 |
| Branch 1 | 3001 | http://localhost:3001 |
| Branch 2 | 3002 | http://localhost:3002 |
| Branch 3 | 3003 | http://localhost:3003 |
| Branch 4 | 3004 | http://localhost:3004 |

---

## Next Steps

1. **Customize this plan** for your specific repository
2. **Test with a sample repository** to verify workflow
3. **Create the automation scripts** in C:\github-claude
4. **Document your project-specific settings** (ports, npm commands, env vars)
5. **Train your team** on the worktree workflow

---

## Additional Resources

- [Git Worktree Documentation](https://git-scm.com/docs/git-worktree)
- [npm Configuration](https://docs.npmjs.com/cli/v8/commands/npm-config)
- [PowerShell Documentation](https://docs.microsoft.com/en-us/powershell/)

---

**Created:** December 2025  
**Last Updated:** December 2025  
**Author:** Claude (Anthropic)  
**Location:** C:\github-claude\MULTI-BRANCH-TESTING-PLAN.md
