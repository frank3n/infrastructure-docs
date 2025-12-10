# Multi-Branch Testing Setup for Calculator Website

This directory contains automation scripts and documentation for testing multiple branches of the [calculator-website](https://github.com/frank3n/calculator-website) repository simultaneously on Windows 11.

## 📁 What's in This Directory

| File | Purpose |
|------|---------|
| `MULTI-BRANCH-TESTING-PLAN.md` | Complete implementation guide and reference |
| `QUICK-START.md` | Quick reference for daily usage |
| `setup-worktrees.ps1` | Automated worktree creation and configuration |
| `start-all-servers.ps1` | Launch development servers for all branches |
| `cleanup-worktrees.ps1` | Remove worktrees when done testing |
| `README.md` | This file |

## 🎯 What This Setup Does

Using **Git Worktrees**, this setup allows you to:

- ✅ Test **10+ branches simultaneously** without switching
- ✅ Run **multiple dev servers** on different ports (5173, 5174, 5175...)
- ✅ Compare features **side-by-side** in browser tabs
- ✅ Save **disk space** with shared git history
- ✅ Keep **isolated dependencies** (separate node_modules per branch)
- ✅ Automate the **entire workflow** with PowerShell scripts

## 🚀 Getting Started

### Prerequisites
- ✅ Git (with Git Bash)
- ✅ PowerShell 7
- ✅ Node.js and npm
- ✅ ~2-3GB free disk space (for 10 branches)

### First-Time Setup (5 minutes)

1. **Open PowerShell 7**
   ```powershell
   cd C:\github-claude
   ```

2. **Run the setup script**
   ```powershell
   .\setup-worktrees.ps1 -Branches @("main", "develop", "feature-1")
   ```

3. **Start the servers**
   ```powershell
   .\start-all-servers.ps1
   ```

4. **Open in browser**
   - http://localhost:5173 (main)
   - http://localhost:5174 (develop)
   - http://localhost:5175 (feature-1)

That's it! 🎉

## 📚 Documentation

- **New to this?** Start with [`QUICK-START.md`](QUICK-START.md)
- **Want details?** Read [`MULTI-BRANCH-TESTING-PLAN.md`](MULTI-BRANCH-TESTING-PLAN.md)

## 💻 Script Usage

### Setup Worktrees
```powershell
# Setup specific branches
.\setup-worktrees.ps1 -Branches @("main", "feature-1", "feature-2")

# Use custom directory
.\setup-worktrees.ps1 -Branches @("main") -BaseDirectory "D:\Projects"

# Skip npm install (if you want to do it manually)
.\setup-worktrees.ps1 -Branches @("main") -SkipNpmInstall
```

### Start Servers
```powershell
# Start all branches
.\start-all-servers.ps1

# Start specific branches only
.\start-all-servers.ps1 -OnlyBranches @("main", "feature-1")

# Start in preview mode (production build)
.\start-all-servers.ps1 -Preview
```

### Cleanup
```powershell
# Remove specific branches
.\cleanup-worktrees.ps1 -Branches @("feature-1", "feature-2")

# Remove all except main
.\cleanup-worktrees.ps1 -All

# Preview what will be removed (safe)
.\cleanup-worktrees.ps1 -All -DryRun

# Force removal (even with uncommitted changes)
.\cleanup-worktrees.ps1 -Branches @("feature-1") -Force
```

## 🗂️ Project Structure

After setup, your project will look like this:

```
C:\github-code\calculator-website-test\
├── main\              # Port 5173
│   ├── node_modules\
│   ├── .env.local
│   └── ... (all project files)
├── develop\           # Port 5174
│   ├── node_modules\
│   └── ...
├── feature-1\         # Port 5175
│   └── ...
└── .git\              # Shared (saves disk space!)
```

## 🎨 Calculator Website Specifics

### npm Commands Available
```bash
npm run dev         # Development server (Vite)
npm run build       # Production build
npm run build:embed # Embeddable widget build
npm run preview     # Preview production build
npm test           # Run tests (Vitest)
npm run lint       # ESLint
npm run translate  # Translation script
```

### Default Ports
- **Development:** 5173, 5174, 5175... (Vite default: 5173)
- **Preview:** 4173, 4174, 4175... (Vite default: 4173)

### Environment Variables
Each branch has `.env.local` for configuration:
```env
VITE_PORT=5173
# VITE_DEEPL_API_TOKEN=your_token_here  # Add when available
```

## 🔄 Typical Workflow

```powershell
# Morning: Setup branches you're testing today
.\setup-worktrees.ps1 -Branches @("main", "feature-new-ui", "bugfix-123")

# Start the servers
.\start-all-servers.ps1

# ... Test throughout the day ...

# Evening: Clean up (or keep for tomorrow)
.\cleanup-worktrees.ps1 -Branches @("feature-new-ui", "bugfix-123")
```

## 🛠️ Troubleshooting

### Port Already in Use
```powershell
# Find and kill the process
Get-NetTCPConnection -LocalPort 5173 | Select-Object OwningProcess
Stop-Process -Id <PID> -Force
```

### Can't Remove Worktree
```powershell
# Use force flag
.\cleanup-worktrees.ps1 -Branches @("feature-1") -Force
```

### Git Bash Not Found
```powershell
# Add Git to PATH
$env:Path += ";C:\Program Files\Git\bin"
```

See [`MULTI-BRANCH-TESTING-PLAN.md`](MULTI-BRANCH-TESTING-PLAN.md) for more troubleshooting.

## 💡 Pro Tips

1. **Use Windows Terminal** - Open tabs for each dev server
2. **Browser Profiles** - Use different profiles to avoid cache issues
3. **Regular Cleanup** - Remove merged/unused branches to save disk space
4. **Test Systematically** - Use main as baseline, test features one at a time
5. **Document Findings** - Keep notes on what works/doesn't in each branch

## 📊 Example Scenarios

### Scenario 1: Bug Fix Testing
```powershell
# Setup main (baseline) and bugfix branch
.\setup-worktrees.ps1 -Branches @("main", "bugfix-calculator-error")

# Start both
.\start-all-servers.ps1

# Compare: 
# - http://localhost:5173 (main - bug present)
# - http://localhost:5174 (bugfix - bug fixed)
```

### Scenario 2: Feature Comparison
```powershell
# Setup two competing approaches
.\setup-worktrees.ps1 -Branches @("feature-approach-a", "feature-approach-b")

# Test both side-by-side
.\start-all-servers.ps1 -OnlyBranches @("feature-approach-a", "feature-approach-b")
```

### Scenario 3: Testing All 10 Active Branches
```powershell
# Setup all branches at once
.\setup-worktrees.ps1 -Branches @(
    "main", "develop", "feature-1", "feature-2", "feature-3",
    "feature-4", "feature-5", "bugfix-1", "bugfix-2", "hotfix-1"
)

# Start only what you need right now
.\start-all-servers.ps1 -OnlyBranches @("main", "feature-1", "feature-2")

# Later, switch to different branches without re-setup
.\start-all-servers.ps1 -OnlyBranches @("develop", "hotfix-1")
```

## 🎯 Quick Command Reference

| I want to... | Command |
|--------------|---------|
| Setup new branches | `.\setup-worktrees.ps1 -Branches @("branch1", "branch2")` |
| Start all servers | `.\start-all-servers.ps1` |
| Start specific servers | `.\start-all-servers.ps1 -OnlyBranches @("main")` |
| Test production build | `.\start-all-servers.ps1 -Preview` |
| Remove branches | `.\cleanup-worktrees.ps1 -Branches @("branch1")` |
| Remove all but main | `.\cleanup-worktrees.ps1 -All` |
| Preview cleanup | `.\cleanup-worktrees.ps1 -All -DryRun` |
| List all worktrees | `bash -c "cd C:\github-code\calculator-website-test && git worktree list"` |

## 🔐 Security Note

The scripts follow your `.clinerules` preferences:
- **Git operations** → Git Bash
- **npm operations** → PowerShell 7
- **File operations** → PowerShell 7

Scripts include safety checks:
- Confirmation prompts before destructive operations
- Protected main/master branch from removal
- Dry-run mode for testing
- Clear warning messages

## 📈 Benefits Over Traditional Methods

| Traditional | With Git Worktrees |
|-------------|-------------------|
| Clone repo 10 times | Clone once, worktrees share .git |
| 10× disk space | ~3× disk space (shared history) |
| Switch branches constantly | All branches active simultaneously |
| Reinstall dependencies | Dependencies installed once per branch |
| Can't compare side-by-side | Direct visual comparison |
| Manual port management | Automated port assignment |

## 🆘 Need Help?

1. Check [`QUICK-START.md`](QUICK-START.md) for common tasks
2. Read [`MULTI-BRANCH-TESTING-PLAN.md`](MULTI-BRANCH-TESTING-PLAN.md) for detailed explanations
3. Run `Get-Help .\script-name.ps1 -Detailed` for script help
4. Check [Git Worktree Docs](https://git-scm.com/docs/git-worktree)

## 📝 Notes

- **Project:** [frank3n/calculator-website](https://github.com/frank3n/calculator-website)
- **Target Directory:** `C:\github-code\calculator-website-test`
- **Created:** December 2025
- **Tested on:** Windows 11, PowerShell 7, Git Bash

---

**Happy Testing! 🚀**

If you find issues or want to improve these scripts, feel free to modify them for your workflow.
