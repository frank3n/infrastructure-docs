# Troubleshooting: Setup Script Failed

## Issue Summary

The `setup-worktrees.ps1` script failed because the target directory exists but is not a git repository.

## Error Analysis

### Log File: log-1-setup-worktrees.txt

**Key Error Messages:**
```
Line 29: fatal: not a git repository (or any of the parent directories): .git
Lines 37-67: ✗ Failed to create worktree: fatal: not a git repository
```

**What Happened:**
1. Script found existing directory: `C:\github-claude\calculator-website-test`
2. User confirmed to continue with existing directory
3. Script attempted to run git commands (fetch, worktree add)
4. All git commands failed - no `.git` directory found
5. No worktrees were created
6. Script completed but nothing was set up

### Directory Contents (Before Fix)

```
C:\github-claude\calculator-website-test\
├── all-branches.txt                 (branch list file)
├── logging-script-output.md         (documentation)
└── setup-script-changes.md          (documentation)
```

**Missing:** `.git/` directory and all repository files

## Root Cause

The directory `C:\github-claude\calculator-website-test` was created manually to store documentation files, but it was never initialized as a git repository. The setup script expects either:

1. **Non-existent directory** → Will clone the repository
2. **Existing git repository** → Will add worktrees to it

Since the directory existed but wasn't a git repo, the script couldn't proceed.

## Solutions

### Option 1: Delete and Let Script Clone (Recommended)

**Best for:** Clean setup, don't need to preserve current files

```powershell
# Navigate to parent directory
cd C:\github-claude

# Remove the directory and all contents
Remove-Item -Path "C:\github-claude\calculator-website-test" -Recurse -Force

# Run the script - it will clone the repo automatically
.\setup-worktrees.ps1 *>&1 | Tee-Object "setup-log-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').txt"
```

**What this does:**
- Completely removes the existing directory
- Script detects directory doesn't exist
- Script clones the repository from GitHub
- Script creates all worktrees
- Clean, automated setup

**Pros:**
- Simplest solution
- Guaranteed to work
- No manual git commands needed

**Cons:**
- Loses current documentation files (can be regenerated)

---

### Option 2: Clone Repository Manually First

**Best for:** Understanding the process, manual control

```powershell
# Navigate to parent directory
cd C:\github-claude

# Remove the existing directory
Remove-Item -Path "calculator-website-test" -Recurse -Force

# Clone the repository
git clone https://github.com/frank3n/calculator-website calculator-website-test

# Verify it's a git repo
cd calculator-website-test
git status

# Go back to parent and run script
cd ..
.\setup-worktrees.ps1 *>&1 | Tee-Object "setup-log-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').txt"
```

**What this does:**
- Manually removes existing directory
- Manually clones repository
- Verifies git repository is valid
- Runs script to create worktrees

**Pros:**
- More control over the process
- Can verify each step
- Good for learning

**Cons:**
- More steps
- Manual intervention required

---

### Option 3: Preserve Documentation Files

**Best for:** Keeping the markdown documentation you created

```powershell
# Create temporary backup directory
New-Item -Path "C:\github-claude\temp-backup" -ItemType Directory -Force

# Move documentation files to backup
Move-Item "C:\github-claude\calculator-website-test\*.md" "C:\github-claude\temp-backup\"
Move-Item "C:\github-claude\calculator-website-test\all-branches.txt" "C:\github-claude\temp-backup\"

# Remove the now-empty directory
Remove-Item "C:\github-claude\calculator-website-test" -Recurse -Force

# Clone the repository
cd C:\github-claude
git clone https://github.com/frank3n/calculator-website calculator-website-test

# Move documentation files back
Move-Item "C:\github-claude\temp-backup\*" "C:\github-claude\calculator-website-test\"

# Remove temporary backup directory
Remove-Item "C:\github-claude\temp-backup" -Force

# Run the script
.\setup-worktrees.ps1 *>&1 | Tee-Object "setup-log-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').txt"
```

**What this does:**
- Backs up documentation files temporarily
- Removes directory
- Clones repository
- Restores documentation files
- Runs script

**Pros:**
- Preserves your documentation
- Clean git repository
- Best of both worlds

**Cons:**
- Most steps
- More complex

---

## Recommended Approach

**Use Option 1** unless you have important files in the directory.

The documentation files (`*.md` and `all-branches.txt`) can be easily regenerated:
- `all-branches.txt` - Run `git branch -r` after cloning
- Documentation files - Can be recreated with the information in this file

---

## Prevention for Future

To avoid this issue in the future:

### 1. Let the Script Handle Directory Creation

Don't create the target directory manually. Let the script clone it:

```powershell
# Good - directory doesn't exist, script clones
.\setup-worktrees.ps1
```

### 2. If Directory Exists, Verify It's a Git Repo

Before running the script:

```powershell
cd C:\github-claude\calculator-website-test
git status
```

If you see `fatal: not a git repository`, delete the directory or clone into it.

### 3. Use Different Directory for Documentation

Keep documentation separate from the repository:

```
C:\github-claude\
├── calculator-website-test\        # Git repository
│   ├── .git/
│   ├── src/
│   └── ...
└── calculator-website-documentation\   # Documentation files
    ├── setup-script-changes.md
    ├── logging-script-output.md
    └── troubleshooting-setup-script.md
```

---

## Verification Steps After Fix

After running one of the solutions above, verify success:

### 1. Check Git Repository

```powershell
cd C:\github-claude\calculator-website-test
git status
```

**Expected output:**
```
On branch main
Your branch is up to date with 'origin/main'.
nothing to commit, working tree clean
```

### 2. List Worktrees

```powershell
cd C:\github-claude\calculator-website-test
git worktree list
```

**Expected output:**
```
C:/github-claude/calculator-website-test                              [main]
C:/github-claude/calculator-website-test/claude/add-loan-calculator-... [claude/add-loan-calculator-...]
C:/github-claude/calculator-website-test/claude/advanced-c-programming-... [claude/advanced-c-programming-...]
...
```

### 3. Verify Directory Structure

```powershell
ls C:\github-claude\calculator-website-test
```

**Expected output:**
```
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d-----        12/7/2025   1:00 PM                .git
d-----        12/7/2025   1:00 PM                claude
d-----        12/7/2025   1:00 PM                node_modules
d-----        12/7/2025   1:00 PM                src
-a----        12/7/2025   1:00 PM           xxxx package.json
-a----        12/7/2025   1:00 PM           xxxx README.md
...
```

### 4. Test a Worktree

```powershell
cd C:\github-claude\calculator-website-test\claude\add-loan-calculator-011CUzKvKUVZU5j9YrN2aQRb
git status
npm run dev
```

Should start the development server on port 5173 (or configured port).

---

## Quick Reference Commands

```powershell
# Check if directory is git repo
cd <directory>
git status

# List all worktrees
git worktree list

# Remove a worktree
git worktree remove <path>

# Fetch all remote branches
git fetch origin

# List remote branches
git branch -r

# Re-run setup script with logging
.\setup-worktrees.ps1 *>&1 | Tee-Object "setup-log-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').txt"
```

---

## Related Documentation

- [setup-script-changes.md](../calculator-website-test/setup-script-changes.md) - Script adaptation details
- [logging-script-output.md](../calculator-website-test/logging-script-output.md) - How to log script output

---

## Summary

**Problem:** Directory exists but isn't a git repository
**Solution:** Delete directory and let script clone fresh
**Prevention:** Let script manage directory creation, or keep docs separate
**Verification:** Check `git status`, `git worktree list`, and directory structure
