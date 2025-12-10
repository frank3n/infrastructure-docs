# Sequential NPM Runner Guide

## Recommended Order: Lint → Test → Build

  # 1. Lint first (fastest, catches syntax/style issues)
  .\run-npm-sequential.ps1 -NpmCommand lint -SkipOnError

  # 2. Test second (verify functionality)
  .\run-npm-sequential.ps1 -NpmCommand test -SkipOnError

  # 3. Build last (slowest, final verification)
  .\run-npm-sequential.ps1 -NpmCommand build -SkipOnError

Why This Order?

  1. Lint (⚡ Fastest)
    - Catches syntax errors
    - Code style violations
    - Unused imports
    - Simple issues
    - No point testing/building if code has lint errors
  2. Test (⚙️ Medium)
    - Verifies functionality
    - Unit/integration tests
    - No point building if tests fail
  3. Build (🐌 Slowest)
    - Compilation
    - Bundling
    - Final verification
    - Most resource-intensive

## Overview

The `run-npm-sequential.ps1` script runs npm commands for each branch worktree one at a time, creating individual log files for each branch.

## Features

- ✓ Sequential execution (one branch at a time)
- ✓ Individual log file per branch
- ✓ Automatic npm install if node_modules missing
- ✓ Progress tracking and summary report
- ✓ Error handling with skip option
- ✓ Support for multiple npm commands (build, test, lint, dev)
- ✓ Timestamped logs
- ✓ Summary report saved to file

## Usage

### Basic Usage

```powershell
# Run build for all branches
.\run-npm-sequential.ps1

# Run tests for all branches
.\run-npm-sequential.ps1 -NpmCommand test

# Run linter for all branches
.\run-npm-sequential.ps1 -NpmCommand lint

# Run dev server (30 seconds per branch)
.\run-npm-sequential.ps1 -NpmCommand dev
```

### Advanced Usage

```powershell
# Run with custom project path
.\run-npm-sequential.ps1 -ProjectPath "C:\custom\path\to\project"

# Run with custom log directory
.\run-npm-sequential.ps1 -LogDirectory "C:\my-logs"

# Continue on errors (don't stop if a branch fails)
.\run-npm-sequential.ps1 -SkipOnError

# Run dev server for 60 seconds per branch
.\run-npm-sequential.ps1 -NpmCommand dev -DevServerTimeout 60

# Combine multiple options
.\run-npm-sequential.ps1 -NpmCommand test -SkipOnError -LogDirectory "C:\test-logs"
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `ProjectPath` | string | `C:\github-claude\calculator-website-test` | Path to the git repository with worktrees |
| `NpmCommand` | string | `build` | NPM command to run: `dev`, `build`, `test`, `lint`, `preview` |
| `LogDirectory` | string | `C:\github-claude\calculator-website-documentation\npm-logs` | Directory to save log files |
| `DevServerTimeout` | int | `30` | Seconds to run dev server before auto-stopping |
| `SkipOnError` | switch | `false` | Continue to next branch even if current one fails |

## NPM Commands

### build
Builds the project for production.

```powershell
.\run-npm-sequential.ps1 -NpmCommand build
```

**Use case:** Verify all branches can build successfully
**Logs:** Build output, errors, warnings

### test
Runs the test suite.

```powershell
.\run-npm-sequential.ps1 -NpmCommand test
```

**Use case:** Run tests across all branches
**Logs:** Test results, coverage, failures

### lint
Runs ESLint to check code quality.

```powershell
.\run-npm-sequential.ps1 -NpmCommand lint
```

**Use case:** Check code quality across branches
**Logs:** Lint errors, warnings

### dev
Starts the development server (with auto-timeout).

```powershell
.\run-npm-sequential.ps1 -NpmCommand dev -DevServerTimeout 45
```

**Use case:** Verify each branch can start dev server
**Logs:** Server startup output, console logs
**Note:** Auto-stops after timeout (default 30 seconds)

### preview
Preview production build.

```powershell
.\run-npm-sequential.ps1 -NpmCommand preview
```

**Use case:** Test production builds
**Logs:** Preview server output

## Output Files

### Log Files

Individual log files are created for each branch:

**Naming format:**
```
<branch-name>-<command>-<timestamp>.log
```

**Examples:**
```
claude-add-loan-calculator-011CUzKvKUVZU5j9YrN2aQRb-build-2025-12-07-140530.log
claude-advanced-c-programming-016Z8rGiwZaYgPcis17YorRy-build-2025-12-07-140532.log
main-test-2025-12-07-140535.log
```

### Summary File

A summary report is created after each run:

**Naming format:**
```
summary-<timestamp>.txt
```

**Contents:**
- Total worktrees processed
- Success/failure/skip counts
- Detailed results for each branch
- Log file locations
- Duration for each branch

**Example:**
```
=========================================
NPM Sequential Run Summary
=========================================
Date: 2025-12-07 14:05:30
Command: npm run build
Total: 11 | Success: 9 | Failed: 2 | Skipped: 0

Detailed Results:

[SUCCESS] main
  Reason: Completed
  Duration: 45.32 seconds
  Log: C:\...\main-build-2025-12-07-140530.log

[FAILED] claude/add-loan-calculator-011CUzKvKUVZU5j9YrN2aQRb
  Reason: npm run build exited with code 1
  Duration: 12.45 seconds
  Log: C:\...\claude-add-loan-calculator-...-build-2025-12-07-140531.log
```

## Workflow Examples

### Example 1: Build All Branches

```powershell
# Build all branches and continue on errors
.\run-npm-sequential.ps1 -NpmCommand build -SkipOnError
```

**What happens:**
1. Script finds all worktrees
2. For each worktree:
   - Checks if node_modules exists (installs if missing)
   - Runs `npm run build`
   - Logs output to individual file
   - Shows progress on screen
3. Creates summary report
4. Continues even if some builds fail

### Example 2: Test All Branches and Stop on First Failure

```powershell
# Test all branches, stop on first failure
.\run-npm-sequential.ps1 -NpmCommand test
```

**What happens:**
1. Runs tests for each branch sequentially
2. Stops immediately if any test fails
3. Logs are saved for branches that ran
4. Summary shows which branch failed

### Example 3: Verify All Branches Can Start

```powershell
# Start dev server for 60 seconds per branch
.\run-npm-sequential.ps1 -NpmCommand dev -DevServerTimeout 60 -SkipOnError
```

**What happens:**
1. Starts dev server for first branch
2. Waits 60 seconds (captures startup logs)
3. Auto-stops server
4. Moves to next branch
5. Repeats for all branches

### Example 4: Complete Quality Check

```powershell
# Run multiple checks sequentially
.\run-npm-sequential.ps1 -NpmCommand lint -SkipOnError
.\run-npm-sequential.ps1 -NpmCommand test -SkipOnError
.\run-npm-sequential.ps1 -NpmCommand build -SkipOnError
```

**Creates:**
- 3 sets of log files (lint, test, build)
- 3 summary reports
- Complete quality check across all branches

## Understanding the Output

### Console Output

```
=========================================
Sequential NPM Runner for Branch Worktrees
=========================================

Created log directory: C:\...\npm-logs
Fetching worktree list...
Found 11 worktrees

Worktrees to process:
  - main
    C:\github-claude\calculator-website-test
  - claude/add-loan-calculator-011CUzKvKUVZU5j9YrN2aQRb
    C:\github-claude\calculator-website-test\claude\add-loan-calculator-...

=========================================
[1/11] Processing: main
=========================================
Path: C:\github-claude\calculator-website-test
Command: npm run build
Log file: C:\...\main-build-2025-12-07-140530.log

Running: npm run build

[Build output...]

✓ npm run build completed successfully

=========================================
[2/11] Processing: claude/add-loan-calculator-011CUzKvKUVZU5j9YrN2aQRb
=========================================
...
```

### Summary Output

```
=========================================
SUMMARY
=========================================

Total worktrees: 11
Successful: 9
Failed: 2
Skipped: 0

Detailed Results:

  ✓ main
    Status: SUCCESS
    Reason: Completed
    Duration: 45.32 seconds
    Log: C:\...\main-build-2025-12-07-140530.log

  ✗ claude/add-loan-calculator-011CUzKvKUVZU5j9YrN2aQRb
    Status: FAILED
    Reason: npm run build exited with code 1
    Duration: 12.45 seconds
    Log: C:\...\claude-add-loan-calculator-...-build-2025-12-07-140531.log

Log files location: C:\github-claude\calculator-website-documentation\npm-logs

✓ Sequential npm run complete!
```

## Troubleshooting

### Issue: "Project path does not exist"

**Solution:**
```powershell
# Verify path
Test-Path "C:\github-claude\calculator-website-test"

# Or specify custom path
.\run-npm-sequential.ps1 -ProjectPath "C:\your\actual\path"
```

### Issue: "Not a git repository"

**Solution:**
```powershell
cd C:\github-claude\calculator-website-test
git status

# If not a repo, run setup script first
cd C:\github-claude
.\setup-worktrees.ps1
```

### Issue: "No package.json found"

**Reason:** Worktree doesn't have a package.json file

**Status:** Branch will be SKIPPED automatically

### Issue: npm install fails

**Solution:**
```powershell
# Manually install for that branch
cd C:\github-claude\calculator-website-test\claude\<branch-name>
npm install

# Or check the install log file
Get-Content C:\...\npm-logs\<branch-name>-install-<timestamp>.log
```

### Issue: Build/test fails for a branch

**Solution:**
```powershell
# Check the log file for that branch
Get-Content C:\...\npm-logs\<branch-name>-<command>-<timestamp>.log

# Or manually run for that branch
cd C:\github-claude\calculator-website-test\claude\<branch-name>
npm run <command>
```

## Analyzing Results

### View All Logs

```powershell
# List all log files
Get-ChildItem C:\github-claude\calculator-website-documentation\npm-logs

# View specific log
Get-Content C:\...\npm-logs\<branch-name>-build-<timestamp>.log

# Search for errors across all logs
Get-ChildItem C:\...\npm-logs\*.log | Select-String "error" -Context 2
```

### Find Failed Builds

```powershell
# Search summary files for failures
Get-ChildItem C:\...\npm-logs\summary-*.txt | Select-String "FAILED"
```

### Compare Branch Results

```powershell
# Get file sizes (larger = more output/errors)
Get-ChildItem C:\...\npm-logs\*-build-*.log | Select-Object Name, Length | Sort-Object Length -Descending
```

## Best Practices

### 1. Run Builds Regularly

```powershell
# Weekly build check
.\run-npm-sequential.ps1 -NpmCommand build -SkipOnError
```

### 2. Clean Logs Periodically

```powershell
# Remove logs older than 7 days
Get-ChildItem C:\...\npm-logs\*.log | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-7)} | Remove-Item
```

### 3. Use SkipOnError for Full Analysis

```powershell
# Check all branches even if some fail
.\run-npm-sequential.ps1 -SkipOnError
```

### 4. Save Summary Files

Keep summary files for historical tracking of branch health.

### 5. Combine with Git Workflows

```powershell
# Before merging branches
.\run-npm-sequential.ps1 -NpmCommand test -SkipOnError
.\run-npm-sequential.ps1 -NpmCommand build -SkipOnError
```

## Related Scripts

- [setup-worktrees.ps1](../setup-worktrees.ps1) - Setup worktrees first
- [start-all-servers.ps1](../start-all-servers.ps1) - Run all dev servers simultaneously (if available)

## Related Documentation

- [setup-script-changes.md](../calculator-website-test/setup-script-changes.md) - Worktree setup details
- [troubleshooting-setup-script.md](troubleshooting-setup-script.md) - Setup troubleshooting

## Quick Reference

```powershell
# Build all branches
.\run-npm-sequential.ps1

# Test all branches (continue on errors)
.\run-npm-sequential.ps1 -NpmCommand test -SkipOnError

# Lint all branches
.\run-npm-sequential.ps1 -NpmCommand lint -SkipOnError

# Verify dev servers start (45 sec each)
.\run-npm-sequential.ps1 -NpmCommand dev -DevServerTimeout 45

# View summary
Get-Content C:\github-claude\calculator-website-documentation\npm-logs\summary-*.txt | Select-Object -Last 50

# Clean old logs
Get-ChildItem C:\github-claude\calculator-website-documentation\npm-logs\*.log | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-7)} | Remove-Item
```
