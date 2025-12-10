# 📦 Package Contents Overview

```
C:\github-claude\
│
├─── 📘 DOCUMENTATION (5 files)
│    │
│    ├─── README.md ⭐ START HERE
│    │    │
│    │    ├─── Overview of entire setup
│    │    ├─── Quick command reference
│    │    ├─── Script usage examples
│    │    ├─── Troubleshooting quick tips
│    │    └─── Links to detailed docs
│    │
│    ├─── QUICK-START.md 🚀 DAILY REFERENCE
│    │    │
│    │    ├─── Quick setup (5 min)
│    │    ├─── Common tasks
│    │    ├─── Workflow examples
│    │    ├─── Command reference table
│    │    └─── Tips & best practices
│    │
│    ├─── MULTI-BRANCH-TESTING-PLAN.md 📖 COMPLETE GUIDE
│    │    │
│    │    ├─── Detailed implementation steps
│    │    ├─── Git Worktree explanation
│    │    ├─── Directory structure
│    │    ├─── Configuration details
│    │    ├─── Comprehensive troubleshooting
│    │    └─── Best practices
│    │
│    ├─── TESTING-TRACKER.md 📝 TESTING TEMPLATE
│    │    │
│    │    ├─── Branch status tracking
│    │    ├─── Comparison matrix
│    │    ├─── Issue logging
│    │    ├─── Decision log
│    │    └─── Session notes
│    │
│    └─── INSTALLATION-SUMMARY.md ℹ️ THIS OVERVIEW
│         │
│         ├─── What was created
│         ├─── Quick start steps
│         ├─── Common use cases
│         └─── Next actions
│
│
├─── ⚙️ AUTOMATION SCRIPTS (3 files)
│    │
│    ├─── setup-worktrees.ps1 🔧 INITIAL SETUP
│    │    │
│    │    ├─── Clones repository
│    │    ├─── Creates worktrees
│    │    ├─── Installs dependencies
│    │    ├─── Configures ports
│    │    └─── Creates .env files
│    │    │
│    │    └─── Usage:
│    │         .\setup-worktrees.ps1 -Branches @("main", "dev")
│    │
│    ├─── start-all-servers.ps1 ▶️ SERVER MANAGEMENT
│    │    │
│    │    ├─── Starts dev servers
│    │    ├─── Opens new windows
│    │    ├─── Auto port detection
│    │    ├─── Selective starting
│    │    └─── Browser auto-open
│    │    │
│    │    └─── Usage:
│    │         .\start-all-servers.ps1
│    │         .\start-all-servers.ps1 -OnlyBranches @("main")
│    │         .\start-all-servers.ps1 -Preview
│    │
│    └─── cleanup-worktrees.ps1 🧹 CLEANUP
│         │
│         ├─── Removes worktrees
│         ├─── Protects main branch
│         ├─── Dry-run mode
│         ├─── Force mode
│         └─── Reports disk space freed
│         │
│         └─── Usage:
│              .\cleanup-worktrees.ps1 -Branches @("feature-1")
│              .\cleanup-worktrees.ps1 -All
│              .\cleanup-worktrees.ps1 -All -DryRun
│
│
└─── 📊 PROJECT STRUCTURE (after setup)
     │
     └─── C:\github-code\calculator-website-test\
          │
          ├─── main\ ──────────────── Port 5173
          │    ├─── node_modules\
          │    ├─── .env.local
          │    ├─── vite.config.ts
          │    └─── ... (all project files)
          │
          ├─── develop\ ───────────── Port 5174
          │    ├─── node_modules\
          │    ├─── .env.local
          │    └─── ...
          │
          ├─── feature-1\ ─────────── Port 5175
          │    ├─── node_modules\
          │    └─── ...
          │
          ├─── feature-2\ ─────────── Port 5176
          │    └─── ...
          │
          └─── .git\ ──────────────── (shared by all)
```

---

## 🎯 Quick Decision Tree

```
┌─────────────────────────────────────────────┐
│  What do you want to do?                    │
└─────────────────────────────────────────────┘
                     │
        ┌────────────┴────────────┬──────────────┐
        │                         │              │
        ▼                         ▼              ▼
   First Time               Daily Use      Need Help?
    Setup?                  Testing?
        │                         │              │
        ▼                         ▼              ▼
Read README.md           Read QUICK-START    Read MULTI-BRANCH
        │                         │         TESTING-PLAN.md
        ▼                         │              │
Run setup-worktrees.ps1          ▼              │
        │               Run start-all-servers    │
        ▼                         │              │
Run start-all-servers.ps1        ▼              ▼
        │                  Test in Browser  Get detailed help
        ▼                         │
   Test in Browser                ▼
        │               Run cleanup-worktrees
        └───────────────────┬─────┘
                            │
                            ▼
                    Use TESTING-TRACKER
                    to document findings
```

---

## 📋 Workflow Cheat Sheet

### First Time (One Time Setup)
```powershell
# 1. Navigate to scripts
cd C:\github-claude

# 2. Setup your branches
.\setup-worktrees.ps1 -Branches @("main", "develop", "feature-1")
# ⏱️ Takes 5-10 minutes

# 3. Start servers
.\start-all-servers.ps1
# 🌐 Opens new windows for each server

# 4. Test in browser
# http://localhost:5173, 5174, 5175...
```

### Daily Testing (Regular Use)
```powershell
# Morning: Start servers
cd C:\github-claude
.\start-all-servers.ps1 -OnlyBranches @("main", "feature-xyz")

# ... Test all day ...

# Evening: Stop & cleanup
# Close PowerShell windows or:
.\cleanup-worktrees.ps1 -Branches @("feature-xyz")
```

### Adding New Branch
```powershell
cd C:\github-claude
.\setup-worktrees.ps1 -Branches @("new-branch-name")
```

### Removing Old Branches
```powershell
cd C:\github-claude

# Preview first (safe)
.\cleanup-worktrees.ps1 -Branches @("old-branch") -DryRun

# Then actually remove
.\cleanup-worktrees.ps1 -Branches @("old-branch")
```

---

## 🎨 Visual Port Map

```
Port     Branch          URL                          Window
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
5173  →  main        →  http://localhost:5173     →  PowerShell 1
5174  →  develop     →  http://localhost:5174     →  PowerShell 2
5175  →  feature-1   →  http://localhost:5175     →  PowerShell 3
5176  →  feature-2   →  http://localhost:5176     →  PowerShell 4
5177  →  bugfix-123  →  http://localhost:5177     →  PowerShell 5
...   →  ...         →  ...                       →  ...

Preview Mode (after npm run build):
4173  →  main        →  http://localhost:4173     →  PowerShell 1
4174  →  develop     →  http://localhost:4174     →  PowerShell 2
...   →  ...         →  ...                       →  ...
```

---

## 📈 Comparison: Traditional vs. Worktrees

```
┌───────────────────────────────────────────────────────────┐
│             TRADITIONAL APPROACH                          │
├───────────────────────────────────────────────────────────┤
│                                                           │
│  Clone repo → test → delete                              │
│  Clone repo → test → delete                              │
│  Clone repo → test → delete                              │
│                                                           │
│  Problems:                                                │
│  ❌ 10x disk space (10 full clones)                      │
│  ❌ 10x network bandwidth                                │
│  ❌ Can't compare side-by-side                           │
│  ❌ Reinstall dependencies each time                     │
│  ❌ Slow setup (~30-60 min for 10 branches)             │
│                                                           │
└───────────────────────────────────────────────────────────┘

                          VS.

┌───────────────────────────────────────────────────────────┐
│             GIT WORKTREES APPROACH                        │
├───────────────────────────────────────────────────────────┤
│                                                           │
│  Clone once → create 10 worktrees → test all             │
│                                                           │
│  Benefits:                                                │
│  ✅ 3x disk space (shared .git)                          │
│  ✅ 1x network bandwidth (one clone)                     │
│  ✅ Side-by-side comparison                              │
│  ✅ Dependencies installed per branch once               │
│  ✅ Fast setup (~5-10 min for 10 branches)              │
│  ✅ All branches always ready                            │
│  ✅ Automated with scripts                               │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

---

## 🔄 Typical Day Workflow

```
08:00 AM  ┌──────────────────────────────────┐
          │ cd C:\github-claude              │
          │ .\start-all-servers.ps1          │
          └──────────────────────────────────┘
                       │
                       ▼
08:05 AM  ┌──────────────────────────────────┐
          │ Open browser tabs:               │
          │ • localhost:5173 (main)          │
          │ • localhost:5174 (feature-1)     │
          │ • localhost:5175 (feature-2)     │
          └──────────────────────────────────┘
                       │
                       ▼
08:10 AM  ┌──────────────────────────────────┐
          │ Test features side-by-side       │
          │ Document in TESTING-TRACKER.md   │
          └──────────────────────────────────┘
                       │
                       ▼
12:00 PM  ┌──────────────────────────────────┐
          │ Lunch break                      │
          │ Servers keep running (optional)  │
          └──────────────────────────────────┘
                       │
                       ▼
01:00 PM  ┌──────────────────────────────────┐
          │ Continue testing                 │
          │ Make notes                       │
          │ Create GitHub issues             │
          └──────────────────────────────────┘
                       │
                       ▼
05:00 PM  ┌──────────────────────────────────┐
          │ Close PowerShell windows         │
          │ (Ctrl+C in each)                 │
          │                                  │
          │ Optional cleanup:                │
          │ .\cleanup-worktrees.ps1 -All     │
          └──────────────────────────────────┘
```

---

## 💾 Disk Space Breakdown

```
C:\github-code\calculator-website-test\

Main Repository (.git):           ~50 MB  (shared by all)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Branch: main
  ├─ node_modules/              ~250 MB
  ├─ Project files               ~50 MB
  └─ Total:                     ~300 MB

Branch: develop
  ├─ node_modules/              ~250 MB
  ├─ Project files               ~50 MB
  └─ Total:                     ~300 MB

Branch: feature-1
  ├─ node_modules/              ~250 MB
  ├─ Project files               ~50 MB
  └─ Total:                     ~300 MB

... (repeat for each branch)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TOTAL for 10 branches:          ~3.0 GB

Compare to 10 full clones:      ~5.5 GB
Savings:                        ~2.5 GB (45% reduction)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 🎓 Learning Path

### Beginner Level
1. Read `README.md`
2. Follow `QUICK-START.md` first-time setup
3. Test with just 2 branches (main + one feature)
4. Learn the basic commands

### Intermediate Level
1. Read `MULTI-BRANCH-TESTING-PLAN.md`
2. Test with 5+ branches simultaneously
3. Customize .env.local files
4. Use TESTING-TRACKER.md
5. Understand Git worktree concepts

### Advanced Level
1. Modify scripts for your needs
2. Create custom workflows
3. Add automation for testing
4. Integrate with CI/CD
5. Share knowledge with team

---

## ✅ Success Checklist

After setup, you should be able to:

- [ ] Run `.\setup-worktrees.ps1` successfully
- [ ] See multiple worktrees in `C:\github-code\calculator-website-test\`
- [ ] Start servers with `.\start-all-servers.ps1`
- [ ] Access different branches at different ports
- [ ] See dev servers running in separate PowerShell windows
- [ ] Make changes and see hot reload work
- [ ] Test features side-by-side in browser
- [ ] Clean up with `.\cleanup-worktrees.ps1`
- [ ] Understand the port assignment scheme
- [ ] Know where to find help (documentation files)

---

## 🎉 You Have Everything You Need!

```
┌─────────────────────────────────────────────────┐
│  ✅ All documentation created                   │
│  ✅ All scripts ready to use                    │
│  ✅ Project configured for your repo            │
│  ✅ Quick reference guides included             │
│  ✅ Testing tracker template provided           │
│  ✅ Troubleshooting guides available            │
│                                                 │
│  👉 Next: Run setup-worktrees.ps1              │
└─────────────────────────────────────────────────┘
```

**Ready to start? Open PowerShell 7 and run:**
```powershell
cd C:\github-claude
.\setup-worktrees.ps1 -Branches @("main", "develop")
```

---

**Package Created:** December 2025  
**For Project:** Calculator Website (frank3n/calculator-website)  
**Target Location:** C:\github-code\calculator-website-test  
**Scripts Location:** C:\github-claude\
