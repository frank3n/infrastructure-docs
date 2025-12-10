# Calculator Website - Multi-Branch Development Documentation

## Overview

This documentation covers the setup and management of a multi-branch development environment using git worktrees for the calculator website project.

## Quick Start

```powershell
# 1. Setup all branch worktrees
cd C:\github-claude
.\setup-worktrees.ps1 *>&1 | Tee-Object setup-log.txt

# 2. Build all branches
.\run-npm-sequential.ps1 -NpmCommand build -SkipOnError

# 3. Test all branches
.\run-npm-sequential.ps1 -NpmCommand test -SkipOnError

# 4. View results
Get-Content calculator-website-documentation\npm-logs\summary-*.txt | Select-Object -Last 50
```

## Documentation Files

### Setup & Configuration

1. **[setup-script-changes.md](setup-script-changes.md)**
   - Details on the setup-worktrees.ps1 script
   - Branch list and port assignments
   - Usage instructions

2. **[logging-script-output.md](logging-script-output.md)**
   - How to log PowerShell script output
   - Different logging methods
   - Best practices

3. **[troubleshooting-setup-script.md](troubleshooting-setup-script.md)**
   - Common setup issues and solutions
   - Error analysis and fixes
   - Verification steps

### NPM Operations

4. **[sequential-npm-runner-guide.md](sequential-npm-runner-guide.md)**
   - Complete guide to run-npm-sequential.ps1
   - Run npm commands across all branches
   - Individual logging per branch
   - Usage examples and best practices

## Available Scripts

### C:\github-claude\setup-worktrees.ps1

Creates git worktrees for all branches with npm dependencies and port configuration.

**Usage:**
```powershell
.\setup-worktrees.ps1
```

**Features:**
- Reads branches from `calculator-website-test\all-branches.txt`
- Creates worktrees for each branch
- Installs npm dependencies
- Configures unique ports for each branch
- Creates .env.local files

### C:\github-claude\run-npm-sequential.ps1

Runs npm commands sequentially for each branch with individual logging.

**Usage:**
```powershell
# Build all branches
.\run-npm-sequential.ps1

# Test all branches (continue on errors)
.\run-npm-sequential.ps1 -NpmCommand test -SkipOnError

# Lint all branches
.\run-npm-sequential.ps1 -NpmCommand lint -SkipOnError

# Verify dev servers (30 seconds each)
.\run-npm-sequential.ps1 -NpmCommand dev
```

**Features:**
- Sequential execution (one branch at a time)
- Individual log file per branch
- Automatic npm install if needed
- Summary report generation
- Continue on errors option

## Branches

The project manages 11 branches:

1. claude/add-loan-calculator-011CUzKvKUVZU5j9YrN2aQRb
2. claude/advanced-c-programming-016Z8rGiwZaYgPcis17YorRy
3. claude/calculator-affiliate-niches-01LXPQjEUAmFJPm6NjT3Jz6E
4. claude/coolcation-calculator-feature-011CV5qSqYUYdvwJ5bpua7ph
5. claude/futures-paper-trading-tool-011CV2w7JCjGJLFx4otwjzFY
6. claude/futures-trading-calculators-011CV12pWyQ2LdP27bvnsUDa
7. claude/multilang-calculator-plan-011CUz48qy2HekjPBWXe9Req
8. claude/plan-calculator-feature-01G24dsP61dwRf4jonCD4mTe
9. claude/research-vps-credits-014ADcc6USifgWdsXuVG39tw
10. claude/restart-dev-server-01TjCDbF2u7qoke6SzZw65xi
11. claude/vpn-comparison-tool-013xNsusZ8MbzaotBc9mVbEV

## Directory Structure

```
C:\github-claude\
├── setup-worktrees.ps1                      # Setup script
├── run-npm-sequential.ps1                   # NPM runner script
├── log-1-setup-worktrees.txt               # Setup log
│
├── calculator-website-test\                 # Main repository
│   ├── .git\                               # Git repository data
│   ├── all-branches.txt                    # Branch list file
│   ├── [main branch files]
│   │
│   └── claude\                             # Branch worktrees
│       ├── add-loan-calculator-011CUzKvKUVZU5j9YrN2aQRb\
│       ├── advanced-c-programming-016Z8rGiwZaYgPcis17YorRy\
│       ├── calculator-affiliate-niches-01LXPQjEUAmFJPm6NjT3Jz6E\
│       ├── coolcation-calculator-feature-011CV5qSqYUYdvwJ5bpua7ph\
│       ├── futures-paper-trading-tool-011CV2w7JCjGJLFx4otwjzFY\
│       ├── futures-trading-calculators-011CV12pWyQ2LdP27bvnsUDa\
│       ├── multilang-calculator-plan-011CUz48qy2HekjPBWXe9Req\
│       ├── plan-calculator-feature-01G24dsP61dwRf4jonCD4mTe\
│       ├── research-vps-credits-014ADcc6USifgWdsXuVG39tw\
│       ├── restart-dev-server-01TjCDbF2u7qoke6SzZw65xi\
│       └── vpn-comparison-tool-013xNsusZ8MbzaotBc9mVbEV\
│
└── calculator-website-documentation\        # Documentation
    ├── README.md                           # This file
    ├── setup-script-changes.md             # Setup documentation
    ├── logging-script-output.md            # Logging guide
    ├── troubleshooting-setup-script.md     # Troubleshooting
    ├── sequential-npm-runner-guide.md      # NPM runner guide
    │
    └── npm-logs\                           # NPM logs directory
        ├── [branch]-[command]-[timestamp].log
        └── summary-[timestamp].txt
```

## Common Workflows

### Initial Setup

```powershell
# Clone repository and setup worktrees
cd C:\github-claude
.\setup-worktrees.ps1 *>&1 | Tee-Object setup-log.txt
```

### Build All Branches

```powershell
# Build all branches, continue on errors
.\run-npm-sequential.ps1 -NpmCommand build -SkipOnError
```

### Test All Branches

```powershell
# Run tests for all branches
.\run-npm-sequential.ps1 -NpmCommand test -SkipOnError
```

### Code Quality Check

```powershell
# Lint all branches
.\run-npm-sequential.ps1 -NpmCommand lint -SkipOnError
```

### Verify Dev Servers

```powershell
# Start each dev server for 30 seconds to verify
.\run-npm-sequential.ps1 -NpmCommand dev -DevServerTimeout 30
```

### Work on Specific Branch

```powershell
# Navigate to branch worktree
cd C:\github-claude\calculator-website-test\claude\add-loan-calculator-011CUzKvKUVZU5j9YrN2aQRb

# Start dev server
npm run dev

# Run tests
npm test

# Build
npm run build
```

### View Logs

```powershell
# List all log files
Get-ChildItem calculator-website-documentation\npm-logs

# View latest summary
Get-Content calculator-website-documentation\npm-logs\summary-*.txt | Select-Object -Last 50

# View specific branch log
Get-Content calculator-website-documentation\npm-logs\claude-add-loan-calculator-*-build-*.log
```

## Port Assignments

Each branch is assigned a unique port starting from 5173:

| Branch | Port |
|--------|------|
| Main | 5173 |
| claude/add-loan-calculator-... | 5174 |
| claude/advanced-c-programming-... | 5175 |
| claude/calculator-affiliate-niches-... | 5176 |
| claude/coolcation-calculator-feature-... | 5177 |
| claude/futures-paper-trading-tool-... | 5178 |
| claude/futures-trading-calculators-... | 5179 |
| claude/multilang-calculator-plan-... | 5180 |
| claude/plan-calculator-feature-... | 5181 |
| claude/research-vps-credits-... | 5182 |
| claude/restart-dev-server-... | 5183 |
| claude/vpn-comparison-tool-... | 5184 |

## Troubleshooting

### Setup Issues

See [troubleshooting-setup-script.md](troubleshooting-setup-script.md) for:
- "Not a git repository" errors
- Directory already exists issues
- Worktree creation failures

### NPM Issues

```powershell
# Manually install dependencies for a branch
cd C:\github-claude\calculator-website-test\claude\<branch-name>
npm install

# Clear node_modules and reinstall
Remove-Item node_modules -Recurse -Force
npm install

# Check package.json exists
Test-Path package.json
```

### Viewing Errors

```powershell
# Search for errors in logs
Get-ChildItem calculator-website-documentation\npm-logs\*.log | Select-String "error" -Context 2

# View failed builds from summary
Get-ChildItem calculator-website-documentation\npm-logs\summary-*.txt | Select-String "FAILED"
```

## Maintenance

### Clean Old Logs

```powershell
# Remove logs older than 7 days
Get-ChildItem calculator-website-documentation\npm-logs\*.log |
    Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-7)} |
    Remove-Item
```

### Update Branches

```powershell
cd C:\github-claude\calculator-website-test
git fetch origin

# Update specific worktree
cd claude\<branch-name>
git pull
```

### Remove Worktree

```powershell
cd C:\github-claude\calculator-website-test
git worktree remove claude\<branch-name>
```

### List All Worktrees

```powershell
cd C:\github-claude\calculator-website-test
git worktree list
```

## Best Practices

1. **Run builds regularly** to catch issues early
   ```powershell
   .\run-npm-sequential.ps1 -NpmCommand build -SkipOnError
   ```

2. **Use -SkipOnError** for complete analysis across all branches

3. **Review summary files** for historical tracking

4. **Keep logs** for a reasonable time period (7-30 days)

5. **Update branches** before running builds/tests
   ```powershell
   cd calculator-website-test
   git fetch origin
   ```

6. **Check logs** after failures to identify root causes

## Resources

- GitHub Repository: https://github.com/frank3n/calculator-website
- Vite Documentation: https://vitejs.dev/
- Git Worktree Documentation: https://git-scm.com/docs/git-worktree

## Support

For issues or questions:
1. Check the troubleshooting documentation
2. Review log files for error details
3. Verify git repository status
4. Check npm and Node.js versions

## Version History

- **2025-12-07**: Initial documentation created
  - Setup script adapted for branch list file
  - Sequential NPM runner created
  - Comprehensive documentation written
