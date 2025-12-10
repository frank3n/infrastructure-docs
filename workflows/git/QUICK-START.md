# Quick Start Guide - Calculator Website Multi-Branch Testing

## 🚀 Quick Setup (First Time)

### Step 1: Get All Branch Names
```bash
# Git Bash - Navigate to a temporary directory
cd C:\temp
git clone https://github.com/frank3n/calculator-website temp-check
cd temp-check
git branch -r
cd ..
rm -rf temp-check
```

**Expected Output:**
```
origin/HEAD -> origin/main
origin/main
origin/feature-translations
origin/bugfix-styling
origin/develop
... (and 7 more branches)
```

### Step 2: Run Setup Script
```powershell
# PowerShell 7 - Run the automated setup
cd C:\github-claude
.\setup-worktrees.ps1 -Branches @("main", "feature-1", "feature-2", "develop")
```

This will:
✅ Clone the repository to `C:\github-code\calculator-website-test`
✅ Create worktrees for each branch
✅ Install npm dependencies for each branch
✅ Configure unique ports (5173, 5174, 5175, 5176...)
✅ Create .env.local files for each branch

**Time:** ~5-10 minutes depending on internet speed

---

## 🏃 Daily Usage

### Start All Servers
```powershell
# PowerShell 7
cd C:\github-claude
.\start-all-servers.ps1
```

This opens a new PowerShell window for each branch with the dev server running.

### Start Specific Branches Only
```powershell
# PowerShell 7
.\start-all-servers.ps1 -OnlyBranches @("main", "feature-1")
```

### Access in Browser
- **main branch:** http://localhost:5173
- **feature-1:** http://localhost:5174
- **feature-2:** http://localhost:5175
- **develop:** http://localhost:5176

---

## 📝 Common Tasks

### Add a New Branch to Test
```powershell
# PowerShell 7
cd C:\github-claude

# Add the new branch (e.g., "hotfix-123")
.\setup-worktrees.ps1 -Branches @("hotfix-123")
```

### Pull Latest Changes for All Branches
```bash
# Git Bash
cd C:\github-code\calculator-website-test

# Update main
git pull

# Update other branches
cd feature-1
git pull

cd ../feature-2
git pull

# ... repeat for each branch
```

### Stop All Servers
Simply close the PowerShell windows or press `Ctrl+C` in each window.

### Remove Branches You're Done Testing
```powershell
# PowerShell 7
cd C:\github-claude

# Remove specific branches
.\cleanup-worktrees.ps1 -Branches @("feature-1", "feature-2")

# Or remove ALL except main
.\cleanup-worktrees.ps1 -All

# Preview what will be removed (dry run)
.\cleanup-worktrees.ps1 -All -DryRun
```

---

## 🔧 Project-Specific Commands

### Available npm Scripts
```powershell
npm run dev         # Start development server (Port 5173+)
npm run build       # Build for production
npm run build:embed # Build embeddable widget
npm run preview     # Preview production build (Port 4173+)
npm test           # Run Vitest tests
npm run lint       # Lint with ESLint
npm run translate  # Run translation script
```

### Test Production Build
```powershell
# PowerShell 7
# First build all branches
cd C:\github-code\calculator-website-test\main
npm run build

cd C:\github-code\calculator-website-test\feature-1
npm run build

# Then start preview servers
cd C:\github-claude
.\start-all-servers.ps1 -Preview
```

Preview mode uses ports 4173, 4174, 4175, etc.

---

## 📂 Directory Structure

```
C:\github-code\calculator-website-test\
├── main\                          # Main branch (Port 5173)
│   ├── node_modules\
│   ├── .env.local                 # Port config
│   ├── vite.config.ts             # Modified with port
│   └── ... (all project files)
│
├── feature-1\                     # Feature branch 1 (Port 5174)
│   ├── node_modules\
│   ├── .env.local
│   └── ...
│
├── feature-2\                     # Feature branch 2 (Port 5175)
│   ├── node_modules\
│   ├── .env.local
│   └── ...
│
└── .git\                          # Shared Git directory
```

---

## 🔐 Environment Variables

Each branch has its own `.env.local` file at the root:

```env
# Port configuration for branch: main
VITE_PORT=5173

# DeepL API Token (add when available)
# VITE_DEEPL_API_TOKEN=your_token_here
```

**To add DeepL token:**
1. Edit `.env.local` in each branch directory
2. Uncomment and replace `your_token_here` with actual token
3. Restart the dev server for that branch

---

## 🛠️ Troubleshooting

### Port Already in Use
```powershell
# PowerShell 7 - Find what's using the port
Get-NetTCPConnection -LocalPort 5173 | Select-Object OwningProcess
Get-Process -Id <PROCESS_ID>

# Kill the process
Stop-Process -Id <PROCESS_ID> -Force
```

### Can't Remove Worktree (Uncommitted Changes)
```powershell
# PowerShell 7 - Use force flag
.\cleanup-worktrees.ps1 -Branches @("feature-1") -Force
```

### npm Install Fails
```powershell
# PowerShell 7 - Clear cache and retry
cd C:\github-code\calculator-website-test\branch-name
Remove-Item node_modules -Recurse -Force
Remove-Item package-lock.json -Force
npm cache clean --force
npm install
```

### Git Bash Not Found
```powershell
# PowerShell 7 - Check if Git is in PATH
where.exe bash

# If not found, add Git to PATH
$env:Path += ";C:\Program Files\Git\bin"
```

---

## 📊 Workflow Examples

### Example 1: Testing New Feature Across Branches
```powershell
# 1. Setup worktrees for comparison
.\setup-worktrees.ps1 -Branches @("main", "feature-new-ui", "develop")

# 2. Start all servers
.\start-all-servers.ps1

# 3. Test in browser
# - http://localhost:5173 (main - baseline)
# - http://localhost:5174 (feature-new-ui)
# - http://localhost:5175 (develop)

# 4. When done, cleanup
.\cleanup-worktrees.ps1 -Branches @("feature-new-ui", "develop")
```

### Example 2: Testing 10 Active Branches
```powershell
# List all branches first
cd C:\github-code\calculator-website-test
git branch -r

# Setup all 10 branches
cd C:\github-claude
.\setup-worktrees.ps1 -Branches @(
    "main",
    "develop", 
    "feature-1",
    "feature-2",
    "feature-3",
    "feature-4",
    "feature-5",
    "bugfix-1",
    "bugfix-2",
    "hotfix-1"
)

# Start only the ones you're testing now
.\start-all-servers.ps1 -OnlyBranches @("main", "feature-1", "feature-2")

# Later, start different branches
.\start-all-servers.ps1 -OnlyBranches @("develop", "hotfix-1")
```

### Example 3: Side-by-Side Feature Comparison
```powershell
# Setup competing feature branches
.\setup-worktrees.ps1 -Branches @("feature-approach-a", "feature-approach-b")

# Start both servers
.\start-all-servers.ps1 -OnlyBranches @("feature-approach-a", "feature-approach-b")

# Open both in browser tabs
# - http://localhost:5173 (approach A)
# - http://localhost:5174 (approach B)

# Compare and decide which approach is better
```

---

## 💡 Tips & Best Practices

### 1. Use Windows Terminal
- Open multiple tabs for different branches
- Split panes to view logs side-by-side
- Save workspace layouts

### 2. Browser Organization
- Use different browser profiles for each branch
- Or use incognito/private windows to avoid cache conflicts
- Install browser extensions for localhost port switching

### 3. Disk Space Management
- Each branch needs ~200-300MB for node_modules
- 10 branches ≈ 2-3GB total
- Cleanup unused branches regularly

### 4. Git Workflow
- Always commit changes before switching focus
- Pull latest changes before starting daily testing
- Don't make changes in worktree directories directly
  (Create a proper feature branch and push instead)

### 5. Testing Strategy
- Start with main branch as baseline
- Test one feature branch at a time
- Use consistent test data across all branches

---

## 🎯 Quick Reference Commands

| Task | Command |
|------|---------|
| Setup all branches | `.\setup-worktrees.ps1 -Branches @("main", "dev")` |
| Start all servers | `.\start-all-servers.ps1` |
| Start specific servers | `.\start-all-servers.ps1 -OnlyBranches @("main")` |
| Preview mode | `.\start-all-servers.ps1 -Preview` |
| Remove branches | `.\cleanup-worktrees.ps1 -Branches @("feature-1")` |
| Remove all except main | `.\cleanup-worktrees.ps1 -All` |
| Dry run cleanup | `.\cleanup-worktrees.ps1 -All -DryRun` |
| List worktrees | `bash -c "cd C:\github-code\calculator-website-test && git worktree list"` |
| Check ports in use | `Get-NetTCPConnection -LocalPort 5173` |

---

## 📖 Script Parameters Reference

### setup-worktrees.ps1
```powershell
-RepoUrl "https://..."           # Default: frank3n/calculator-website
-ProjectName "name"              # Default: calculator-website-test
-BaseDirectory "C:\path"         # Default: C:\github-code
-Branches @("main", "dev")       # Required: branches to setup
-SkipNpmInstall                  # Skip npm install (faster, but manual install needed)
```

### start-all-servers.ps1
```powershell
-ProjectName "name"              # Default: calculator-website-test
-BaseDirectory "C:\path"         # Default: C:\github-code
-NpmCommand "dev"                # Default: dev (can be: build, preview, test)
-Preview                         # Use npm run preview instead of dev
-OnlyBranches @("main", "dev")  # Start only specific branches
```

### cleanup-worktrees.ps1
```powershell
-ProjectName "name"              # Default: calculator-website-test
-BaseDirectory "C:\path"         # Default: C:\github-code
-Branches @("feature-1")         # Specific branches to remove
-All                             # Remove all except main
-Force                           # Force removal (ignore uncommitted changes)
-DryRun                          # Preview what will be removed
```

---

## 🆘 Getting Help

### Check Script Help
```powershell
Get-Help .\setup-worktrees.ps1 -Detailed
Get-Help .\start-all-servers.ps1 -Detailed
Get-Help .\cleanup-worktrees.ps1 -Detailed
```

### Common Issues Documentation
See `MULTI-BRANCH-TESTING-PLAN.md` for detailed troubleshooting

### Git Worktree Documentation
- Official docs: https://git-scm.com/docs/git-worktree
- Tutorial: https://git-scm.com/docs/gitworkflows

---

**Last Updated:** December 2025  
**Project:** Calculator Website (frank3n/calculator-website)  
**Location:** C:\github-claude\QUICK-START.md
