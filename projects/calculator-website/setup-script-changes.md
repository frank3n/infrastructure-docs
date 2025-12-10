# Setup Script Adaptation

## Overview
The `setup-worktrees.ps1` script has been adapted to automatically load branch names from `all-branches.txt`.

## Key Changes

### 1. Added `$BranchListFile` parameter
Points to the all-branches.txt file with default path: `C:\github-claude\calculator-website-test\all-branches.txt`

### 2. Changed `$BaseDirectory` default
- **Before:** `C:\github-code`
- **After:** `C:\github-claude`

### 3. Changed `$Branches` default
- **Before:** `@("main")`
- **After:** `$null` (will be loaded from file)

### 4. Added branch loading logic
The script now:
- Reads and parses branches from the all-branches.txt file
- Skips the "git branch -r" command line
- Skips the "HEAD" reference line
- Removes "origin/" prefix from each branch
- Removes duplicates (found 1 duplicate in the list)
- Sorts branches alphabetically

### 5. Added branch display
Shows which branches will be processed before starting the setup

## Branches to be Processed (11 unique)

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

## Port Assignments

Each branch will be assigned a sequential port number starting from 5173:

- Branch 1 → http://localhost:5173
- Branch 2 → http://localhost:5174
- Branch 3 → http://localhost:5175
- ... and so on

## Usage

### Basic usage (loads branches from file):
```powershell
.\setup-worktrees.ps1
```

### Override branch list file:
```powershell
.\setup-worktrees.ps1 -BranchListFile "C:\path\to\custom-branches.txt"
```

### Manual branch specification (skip file loading):
```powershell
.\setup-worktrees.ps1 -Branches @("main", "feature/my-branch")
```

### Skip npm install:
```powershell
.\setup-worktrees.ps1 -SkipNpmInstall
```

## What the Script Does

1. **Clones repository** (if not already present)
2. **Fetches remote branches** from origin
3. **Creates worktrees** for each branch
   - Main branch uses the primary worktree
   - Other branches get subdirectories (e.g., `calculator-website-test/claude/add-loan-calculator-011CUzKvKUVZU5j9YrN2aQRb/`)
4. **Installs npm dependencies** in each worktree (unless -SkipNpmInstall is used)
5. **Configures ports** for each worktree
   - Modifies `vite.config.ts` to set custom port
   - Creates `.env.local` with port configuration

## Directory Structure

After running, you'll have:

```
C:\github-claude\calculator-website-test\
├── .git/
├── [main branch files]
└── claude/
    ├── add-loan-calculator-011CUzKvKUVZU5j9YrN2aQRb/
    ├── advanced-c-programming-016Z8rGiwZaYgPcis17YorRy/
    ├── calculator-affiliate-niches-01LXPQjEUAmFJPm6NjT3Jz6E/
    ├── coolcation-calculator-feature-011CV5qSqYUYdvwJ5bpua7ph/
    ├── futures-paper-trading-tool-011CV2w7JCjGJLFx4otwjzFY/
    ├── futures-trading-calculators-011CV12pWyQ2LdP27bvnsUDa/
    ├── multilang-calculator-plan-011CUz48qy2HekjPBWXe9Req/
    ├── plan-calculator-feature-01G24dsP61dwRf4jonCD4mTe/
    ├── research-vps-credits-014ADcc6USifgWdsXuVG39tw/
    ├── restart-dev-server-01TjCDbF2u7qoke6SzZw65xi/
    └── vpn-comparison-tool-013xNsusZ8MbzaotBc9mVbEV/
```

## Next Steps

1. Run the setup script: `.\setup-worktrees.ps1`
2. Review the `.env.local` files in each worktree
3. Add DeepL API token to `.env.local` files if needed
4. Start development servers for each branch as needed:
   ```powershell
   cd C:\github-claude\calculator-website-test\claude\[branch-name]
   npm run dev
   ```

## Notes

- The script automatically handles branches with "/" in the name by creating nested directories
- Duplicate branches in the source file are automatically removed
- Each worktree gets its own `node_modules` directory
- Port numbers are assigned sequentially to avoid conflicts
