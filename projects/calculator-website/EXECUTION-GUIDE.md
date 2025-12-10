# Lint Error Fix - Complete Execution Guide

**Created:** 2025-12-07
**Status:** Ready to Execute
**Goal:** Reduce lint errors from 146 to <75 (50% reduction)

---

## Quick Reference

```powershell
# Current directory
cd C:\github-claude

# 1. Log baseline
.\log-fix-session.ps1 -Phase baseline

# 2. Auto-fix prefer-const
# [See Auto-Fix Section]

# 3. Log after auto-fix
.\log-fix-session.ps1 -Phase autofix

# 4. Manual fixes
# [See Manual Fix Sections]

# 5. Log final state
.\log-fix-session.ps1 -Phase final
```

---

## Prerequisites

### Verify Setup
```powershell
# Check we're in the right directory
cd C:\github-claude
Test-Path setup-worktrees.ps1  # Should be True

# Verify project exists
Test-Path calculator-website-test  # Should be True

# Verify worktrees exist
cd calculator-website-test
git worktree list
```

---

## Phase 1: Baseline & Setup (10 min)

### 1.1 Log Current State

```powershell
cd C:\github-claude

# Run baseline lint check with logging
.\log-fix-session.ps1 -Phase "baseline" -Notes "Initial state before any fixes"
```

**This will:**
- Run lint on all branches
- Generate error analysis
- Create snapshot
- Save logs to `fix-logs/`

### 1.2 Review Baseline

```powershell
# View summary
Get-Content calculator-website-documentation\fix-logs\analysis-baseline-*.md | Select-Object -First 20

# Check error count
Select-String -Path "calculator-website-documentation\fix-logs\analysis-baseline-*.md" -Pattern "Total Errors"
```

**Expected:** 146 errors

---

## Phase 2: Auto-Fix (15 min)

### 2.1 Understand What Will Be Fixed

**Target:** 7 `prefer-const` errors
**Method:** Automated via ESLint
**Risk:** Very low - safe transformation

### 2.2 Create Auto-Fix Script

Already created at: `calculator-website-documentation\fix-logs\manual-fixes\auto-fix-demo-guide.md`

### 2.3 Run Auto-Fix

#### Option A: Fix One Branch Manually

```powershell
# Example: Fix one specific branch
cd C:\github-claude\calculator-website-test\claude\multilang-calculator-plan-011CUz48qy2HekjPBWXe9Req

# Check current errors
npm run lint

# Run auto-fix
npm run lint -- --fix

# Verify
npm run lint
```

#### Option B: Use Automated Script

```powershell
cd C:\github-claude

# Run auto-fix on all branches
# (Script needs to be created - see auto-fix-demo-guide.md for template)
```

### 2.4 Log After Auto-Fix

```powershell
cd C:\github-claude

.\log-fix-session.ps1 -Phase "autofix" -Notes "Completed prefer-const auto-fixes"
```

### 2.5 Verify Reduction

```powershell
# Compare error counts
$baseline = (Select-String -Path "fix-logs\analysis-baseline-*.md" -Pattern "Total Errors: (\d+)").Matches.Groups[1].Value
$afterAuto = (Select-String -Path "fix-logs\analysis-autofix-*.md" -Pattern "Total Errors: (\d+)").Matches.Groups[1].Value

Write-Host "Baseline: $baseline errors"
Write-Host "After auto-fix: $afterAuto errors"
Write-Host "Fixed: $($baseline - $afterAuto) errors"
```

**Expected:** 139 errors (7 fixed)

---

## Phase 3: High-Priority Manual Fixes (45 min)

### 3.1 Fix React Hooks Error (15 min)

**Guide:** `fix-logs/manual-fixes/react-hooks-fix-guide.md`

**Quick Steps:**
1. Find the file with the error
2. Identify the conditional hook call
3. Move hook before early return
4. Provide default values
5. Verify

```powershell
# Navigate to branch with error
cd C:\github-claude\calculator-website-test\claude\<branch-with-react-error>

# Edit file
code src/pages/CalculatorPage.tsx

# After fixing, verify
npm run lint
npm run build
npm run dev  # Test it works

# Document
$timestamp = Get-Date -Format 'yyyy-MM-dd-HHmm'
@"
# React Hooks Fix - $timestamp

## Fixed
react-hooks/rules-of-hooks in src/pages/CalculatorPage.tsx

## Solution
Moved useSEO call before early return with default fallback

## Verified
- ✅ Lint passes
- ✅ Build successful
- ✅ Runtime test passed
"@ | Out-File "C:\github-claude\calculator-website-documentation\fix-logs\manual-fixes\react-hooks-fix-$timestamp.md"
```

### 3.2 Fix Ban TS Comment Error (15 min)

**Guide:** `fix-logs/manual-fixes/ban-ts-comment-fix-guide.md`

**Quick Steps:**
1. Find the @ts-ignore or @ts-nocheck comment
2. Remove it and see what TypeScript error appears
3. Fix the underlying type issue
4. Verify

```powershell
# Search for banned comments
cd C:\github-claude\calculator-website-test
grep -rn "@ts-ignore" . --include="*.ts" --include="*.tsx"
grep -rn "@ts-nocheck" . --include="*.ts" --include="*.tsx"

# Open the file and fix
# (See guide for specific fix strategies)

# After fixing, verify
npm run lint
npm run build

# Document
$timestamp = Get-Date -Format 'yyyy-MM-dd-HHmm'
@"
# Ban TS Comment Fix - $timestamp

## Fixed
@typescript-eslint/ban-ts-comment in [file]:line

## Issue
[What the comment was hiding]

## Solution
[How you fixed it]

## Verified
- ✅ Lint passes
- ✅ Build successful
"@ | Out-File "C:\github-claude\calculator-website-documentation\fix-logs\manual-fixes\ban-ts-comment-fix-$timestamp.md"
```

### 3.3 Log Progress

```powershell
cd C:\github-claude

.\log-fix-session.ps1 -Phase "manual" -Notes "Fixed React hooks and ban-ts-comment errors"
```

**Expected:** 137 errors remaining (only TypeScript `any` types left)

---

## Phase 4: TypeScript `any` Type Fixes (60-120 min)

### 4.1 Create Common Interfaces

**Guide:** `fix-logs/manual-fixes/typescript-interfaces-guide.md`

```powershell
cd C:\github-claude\calculator-website-test\claude\<branch>

# Create directory if not exists
mkdir -p api/src/types

# Create common interfaces file
code api/src/types/common.ts
```

**Copy interfaces from guide:**
- `ApiResponse<T>`
- `RequestQuery`
- `PaginationParams`
- `PaginatedResponse<T>`

### 4.2 Fix High-Impact Files

**Priority Order:**
1. `api/src/routes/monitoring.ts` (20+ errors) - 30 min
2. `api/src/routes/proxies.ts` (13+ errors) - 20 min
3. `api/src/routes/scheduler.ts` (6 errors) - 15 min

**For each file:**

```powershell
# 1. Create domain interfaces
code api/src/types/monitoring.ts  # Copy from guide

# 2. Edit the route file
code api/src/routes/monitoring.ts

# 3. Import types
# import { Request, Response } from 'express';
# import { MonitoringMetric } from '../types/monitoring';

# 4. Replace any types
# Before: (req: any, res: any)
# After: (req: Request, res: Response<ApiResponse<MonitoringMetric>>)

# 5. Verify after each file
npm run lint
npm run build

# 6. Document progress
$timestamp = Get-Date -Format 'yyyy-MM-dd-HHmm'
$file = "api/src/routes/monitoring.ts"
$fixed = 20  # Number of any instances fixed

@"
# TypeScript Any Fix - $file - $timestamp

## File: $file
## Errors Fixed: $fixed

## Interfaces Created:
- MonitoringMetric
- SystemStatus
- HealthCheckResponse

## Time Spent: 30 minutes

## Verification:
- ✅ Lint passes
- ✅ Build successful
"@ | Out-File "C:\github-claude\calculator-website-documentation\fix-logs\manual-fixes\typescript-any-$file-$timestamp.md" -Force
```

### 4.3 Track Progress

After each file, log progress:

```powershell
# Quick check
npm run lint | Select-String "error"

# Or full analysis
cd C:\github-claude
.\analyze-lint-errors.ps1
```

### 4.4 Goal: 50% Reduction

**Target:** Fix 68+ of 137 `any` type errors

**Progress tracking:**
- Start: 137 errors
- After monitoring.ts: ~117 errors (20 fixed)
- After proxies.ts: ~104 errors (33 fixed)
- After scheduler.ts: ~98 errors (39 fixed)

**Continue until < 69 errors remaining**

---

## Phase 5: Final Verification (15 min)

### 5.1 Run Final Lint Check

```powershell
cd C:\github-claude

.\log-fix-session.ps1 -Phase "final" -Notes "Completed all planned fixes"
```

### 5.2 Generate Comparison Report

```powershell
# Extract error counts
$baseline = (Select-String -Path "fix-logs\analysis-baseline-*.md" -Pattern "Total Errors: (\d+)").Matches.Groups[1].Value
$final = (Select-String -Path "fix-logs\analysis-final-*.md" -Pattern "Total Errors: (\d+)").Matches.Groups[1].Value

$reduction = $baseline - $final
$percentage = [math]::Round(($reduction / $baseline) * 100, 1)

Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "FINAL RESULTS" -ForegroundColor Cyan
Write-Host "=========================================`n" -ForegroundColor Cyan

Write-Host "Baseline Errors: " -NoNewline
Write-Host $baseline -ForegroundColor Red

Write-Host "Final Errors: " -NoNewline
Write-Host $final -ForegroundColor $(if ($final -lt 75) { 'Green' } else { 'Yellow' })

Write-Host "Errors Fixed: " -NoNewline
Write-Host $reduction -ForegroundColor Green

Write-Host "Reduction: " -NoNewline
Write-Host "$percentage%" -ForegroundColor $(if ($percentage -ge 48) { 'Green' } else { 'Yellow' })

Write-Host "`nSuccess Criteria:" -ForegroundColor Cyan
Write-Host "  Minimum (18%): " -NoNewline
Write-Host $(if ($percentage -ge 18) { '✅ PASSED' } else { '❌ NOT MET' }) -ForegroundColor $(if ($percentage -ge 18) { 'Green' } else { 'Red' })

Write-Host "  Target (48%): " -NoNewline
Write-Host $(if ($percentage -ge 48) { '✅ PASSED' } else { '❌ NOT MET' }) -ForegroundColor $(if ($percentage -ge 48) { 'Green' } else { 'Yellow' })

Write-Host "  Stretch (73%): " -NoNewline
Write-Host $(if ($percentage -ge 73) { '✅ PASSED' } else { '❌ NOT MET' }) -ForegroundColor $(if ($percentage -ge 73) { 'Green' } else { 'Gray' })

# Save comparison report
$reportContent = @"
# Final Comparison Report

**Generated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

---

## Summary

| Metric | Value |
|--------|-------|
| Baseline Errors | $baseline |
| Final Errors | $final |
| Errors Fixed | $reduction |
| Reduction % | $percentage% |

---

## Success Criteria

| Criterion | Target | Result |
|-----------|--------|--------|
| Minimum | 18% reduction | $(if ($percentage -ge 18) { '✅ PASSED' } else { '❌ NOT MET' }) |
| Target | 48% reduction | $(if ($percentage -ge 48) { '✅ PASSED' } else { '❌ NOT MET' }) |
| Stretch | 73% reduction | $(if ($percentage -ge 73) { '✅ PASSED' } else { '❌ NOT MET' }) |

---

## Phase Breakdown

1. **Auto-Fix Phase**
   - prefer-const errors fixed: 7

2. **Manual High-Priority Phase**
   - React hooks fixed: 1
   - Ban TS comment fixed: 1

3. **TypeScript Any Phase**
   - any types fixed: [calculated]

---

## Files Changed

[List of modified files]

---

## Next Steps

$(if ($final -lt 75) {
    "✅ Target achieved! Consider:"
} else {
    "⚠️ Target not fully met. Continue with:"
})

- [ ] Review remaining errors
- [ ] Create follow-up plan
- [ ] Share results with team
- [ ] Set up prevention (pre-commit hooks)

"@

$reportContent | Out-File "calculator-website-documentation\fix-logs\final-report\comparison-$(Get-Date -Format 'yyyy-MM-dd-HHmm').md"

Write-Host "`nFull report saved to: fix-logs\final-report\comparison-*.md`n" -ForegroundColor Green
```

---

## Troubleshooting

### Issue: Script not found

```powershell
# Verify you're in the right directory
cd C:\github-claude
ls *.ps1
```

### Issue: Permission denied

```powershell
# Set execution policy
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

### Issue: npm command not found

```powershell
# Check Node.js is installed
node --version
npm --version

# Install if needed
```

### Issue: Worktree not found

```powershell
# List worktrees
cd calculator-website-test
git worktree list

# May need to run setup-worktrees.ps1 first
```

---

## Time Estimates

| Phase | Task | Time |
|-------|------|------|
| 1 | Baseline & Setup | 10 min |
| 2 | Auto-Fix | 15 min |
| 3 | Manual High-Priority | 45 min |
| 4 | TypeScript Any (50%) | 90 min |
| 5 | Final Verification | 15 min |
| **Total** | | **2h 55min** |

---

## Success Metrics

### Minimum Success (18% reduction)
- Starting: 146 errors
- Target: < 120 errors
- Fixed: 26+ errors

### Target Success (48% reduction)
- Starting: 146 errors
- Target: < 76 errors
- Fixed: 70+ errors

### Stretch Success (73% reduction)
- Starting: 146 errors
- Target: < 40 errors
- Fixed: 106+ errors

---

## All Commands Summary

```powershell
# Setup
cd C:\github-claude

# Phase 1: Baseline
.\log-fix-session.ps1 -Phase baseline

# Phase 2: Auto-fix
# [Run auto-fix on branches]
.\log-fix-session.ps1 -Phase autofix

# Phase 3: Manual fixes
# [Fix React hooks]
# [Fix ban-ts-comment]
.\log-fix-session.ps1 -Phase manual

# Phase 4: TypeScript any fixes
# [Fix monitoring.ts, proxies.ts, scheduler.ts, etc.]

# Phase 5: Final
.\log-fix-session.ps1 -Phase final

# Generate comparison
# [Run comparison script above]
```

---

**Status:** Ready to execute
**Start:** When ready
**Estimated Duration:** 3 hours
**Next Step:** Phase 1 - Log baseline state
