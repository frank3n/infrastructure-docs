# Auto-Fix Demonstration Guide

**Target:** Fix 7 `prefer-const` errors automatically
**Time Required:** 5-10 minutes
**Difficulty:** Easy (automated)

---

## What This Fixes

### `prefer-const` Rule
Variables declared with `let` that are never reassigned should use `const` instead.

**Example:**
```typescript
// Bad - triggers prefer-const error
let name = "Calculator";
console.log(name);

// Good - uses const
const name = "Calculator";
console.log(name);
```

**Why it matters:**
- Improves code clarity
- Prevents accidental reassignment
- Best practice in modern JavaScript/TypeScript

---

## Step-by-Step Process

### Step 1: Identify Branches with prefer-const Errors

From baseline analysis, we know there are 7 `prefer-const` errors across branches.

To find which branches have these errors, check the lint logs.

### Step 2: Run Auto-fix on Each Branch

```powershell
# Navigate to a branch with errors
cd C:\github-claude\calculator-website-test\claude\<branch-name>

# Run ESLint with auto-fix flag
npm run lint -- --fix

# Verify the fix
npm run lint
```

### Step 3: Log the Results

```powershell
# With logging
$branch = "claude/add-loan-calculator-011CUzKvKUVZU5j9YrN2aQRb"
$safeBranch = $branch -replace "[/\\]", "-"
$timestamp = Get-Date -Format 'yyyy-MM-dd-HHmm'

cd "C:\github-claude\calculator-website-test\$branch"

# Run auto-fix and log
npm run lint -- --fix *>&1 |
  Tee-Object "..\..\calculator-website-documentation\fix-logs\auto-fix-demonstrations\autofix-$safeBranch-$timestamp.log"

# Verify and log
npm run lint *>&1 |
  Tee-Object "..\..\calculator-website-documentation\fix-logs\auto-fix-demonstrations\verify-$safeBranch-$timestamp.log"
```

---

## Complete Example: Fix One Branch

```powershell
# 1. Navigate to branch
cd C:\github-claude\calculator-website-test\claude\multilang-calculator-plan-011CUz48qy2HekjPBWXe9Req

# 2. Check current errors
npm run lint
# Output might show: "5 errors, 2 warnings"

# 3. Run auto-fix
npm run lint -- --fix
# ESLint will automatically fix prefer-const errors

# 4. Verify
npm run lint
# Output should show fewer errors: "3 errors, 2 warnings"
# (prefer-const errors are gone)

# 5. Review what changed
git diff
# See the let → const changes
```

---

## Automated Script for All Branches

### Create: auto-fix-all-branches.ps1

```powershell
# auto-fix-all-branches.ps1
$projectPath = "C:\github-claude\calculator-website-test"
$logDir = "C:\github-claude\calculator-website-documentation\fix-logs\auto-fix-demonstrations"

# Get list of all worktrees
$worktrees = git -C $projectPath worktree list --porcelain |
    Where-Object { $_ -match '^branch' } |
    ForEach-Object { $_ -replace '^branch refs/heads/', '' }

Write-Host "Found $($worktrees.Count) worktrees`n" -ForegroundColor Cyan

$fixedCount = 0
$results = @()

foreach ($branch in $worktrees) {
    Write-Host "Processing: $branch" -ForegroundColor Yellow

    $branchPath = if ($branch -eq "main") {
        $projectPath
    } else {
        Join-Path $projectPath $branch
    }

    if (!(Test-Path $branchPath)) {
        Write-Host "  ⚠ Path not found, skipping" -ForegroundColor Yellow
        continue
    }

    Push-Location $branchPath

    # Run auto-fix
    $output = npm run lint -- --fix 2>&1

    # Check if any fixes were made
    if ($output -match "(\d+) error.*fixed") {
        $fixCount = $matches[1]
        Write-Host "  ✓ Fixed $fixCount errors" -ForegroundColor Green
        $fixedCount += $fixCount

        $results += @{
            Branch = $branch
            Fixed = $fixCount
            Status = "Success"
        }
    } else {
        Write-Host "  ℹ No auto-fixable errors" -ForegroundColor Gray
        $results += @{
            Branch = $branch
            Fixed = 0
            Status = "No fixes needed"
        }
    }

    Pop-Location
}

# Summary
Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "Auto-fix Summary" -ForegroundColor Cyan
Write-Host "=========================================`n" -ForegroundColor Cyan

Write-Host "Total errors fixed: $fixedCount" -ForegroundColor Green

foreach ($result in $results) {
    if ($result.Fixed -gt 0) {
        Write-Host "  $($result.Branch): $($result.Fixed) errors fixed" -ForegroundColor White
    }
}

# Save summary
$timestamp = Get-Date -Format 'yyyy-MM-dd-HHmm'
@"
# Auto-fix Summary - $timestamp

## Results

Total Errors Fixed: $fixedCount
Branches Processed: $($worktrees.Count)

## Details

$(foreach ($result in $results) {
    "- **$($result.Branch)**: $($result.Fixed) fixed ($($result.Status))"
})

## Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
"@ | Out-File "$logDir\summary-$timestamp.md"

Write-Host "`nSummary saved to: $logDir\summary-$timestamp.md" -ForegroundColor Cyan
```

---

## Expected Results

### Before Auto-fix
```
Total Errors: 146
├─ @typescript-eslint/no-explicit-any: 137
├─ prefer-const: 7
├─ @typescript-eslint/ban-ts-comment: 1
└─ react-hooks/rules-of-hooks: 1
```

### After Auto-fix
```
Total Errors: 139
├─ @typescript-eslint/no-explicit-any: 137
├─ prefer-const: 0  ← Fixed!
├─ @typescript-eslint/ban-ts-comment: 1
└─ react-hooks/rules-of-hooks: 1
```

**Reduction:** 7 errors (4.8%)

---

## What Auto-fix WON'T Fix

ESLint auto-fix is limited to safe, mechanical changes. It CANNOT fix:
- `@typescript-eslint/no-explicit-any` - Requires defining proper types
- `react-hooks/rules-of-hooks` - Requires code restructuring
- `@typescript-eslint/ban-ts-comment` - Requires fixing underlying type issue

These require manual intervention.

---

## Verification Commands

### After Running Auto-fix

```powershell
# 1. Re-run lint on all branches
cd C:\github-claude
.\run-npm-sequential.ps1 -NpmCommand lint -SkipOnError

# 2. Generate new analysis
.\analyze-lint-errors.ps1

# 3. Compare error counts
$before = 146
$after = (Select-String -Path "calculator-website-documentation\lint-error-analysis-*.md" -Pattern "\*\*Total Errors:\*\* (\d+)").Matches.Groups[1].Value
$reduction = $before - $after
Write-Host "Errors fixed: $reduction"
```

---

## Troubleshooting

### Issue: "npm run lint command not found"

**Solution:** Ensure you're in a directory with `package.json`
```powershell
Test-Path package.json
```

### Issue: "No files to fix"

**Possible reasons:**
- Branch doesn't have `prefer-const` errors
- Errors are in files excluded by `.eslintignore`
- Already fixed

**Verify:**
```powershell
npm run lint  # Check if any errors exist
```

### Issue: Auto-fix doesn't reduce error count

**Reason:** The 7 `prefer-const` errors might be in specific branches

**Solution:** Check individual branches manually

---

## Best Practices

1. **Always verify after auto-fix**
   ```powershell
   npm run lint
   ```

2. **Review changes before committing**
   ```powershell
   git diff
   ```

3. **Test that code still works**
   ```powershell
   npm run build
   npm test
   ```

4. **Log all changes**
   Use the logging commands provided

---

## Next Steps After Auto-fix

1. ✅ Run verification lint check
2. ✅ Generate new analysis
3. ✅ Compare before/after counts
4. ➡️ Move to manual fixes (React hooks, TypeScript types)

---

**Estimated Impact:** 4.8% error reduction (7 of 146 errors)
**Time Required:** 5-10 minutes
**Difficulty:** Easy - fully automated
