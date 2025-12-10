# Logging Strategy for Lint Error Fixes

**Created:** 2025-12-07
**Purpose:** Track all lint error fixes with complete audit trail

---

## Directory Structure

```
calculator-website-documentation/
└── fix-logs/
    ├── baseline-state.md                    # Current state snapshot
    ├── logging-strategy.md                  # This file
    ├── auto-fix-demonstrations/             # Auto-fix examples
    │   ├── branch-1-autofix.log
    │   ├── branch-2-autofix.log
    │   └── summary.md
    ├── manual-fixes/                        # Manual fix documentation
    │   ├── react-hooks-fix.md
    │   ├── ban-ts-comment-fix.md
    │   ├── typescript-any-fixes.md
    │   └── interfaces-created.md
    ├── progress-snapshots/                  # Periodic snapshots
    │   ├── snapshot-2025-12-07-1400.md
    │   ├── snapshot-2025-12-07-1500.md
    │   └── snapshot-2025-12-07-1600.md
    └── final-report/                        # Final comparison
        ├── before-after-comparison.md
        ├── success-metrics.md
        └── lessons-learned.md
```

---

## Log File Naming Conventions

### Timestamp Format
All files use: `YYYY-MM-DD-HHmm`

**Example:** `2025-12-07-1430`

### File Naming Patterns

| Type | Pattern | Example |
|------|---------|---------|
| Baseline | `baseline-state.md` | `baseline-state.md` |
| Auto-fix log | `autofix-[branch]-[timestamp].log` | `autofix-main-2025-12-07-1430.log` |
| Manual fix | `[error-type]-fix-[timestamp].md` | `react-hooks-fix-2025-12-07-1445.md` |
| Snapshot | `snapshot-[timestamp].md` | `snapshot-2025-12-07-1500.md` |
| Lint run | `lint-run-[phase]-[timestamp].txt` | `lint-run-after-autofix-2025-12-07-1430.txt` |
| Analysis | `analysis-[phase]-[timestamp].md` | `analysis-after-manual-2025-12-07-1500.md` |

---

## Logging Commands

### 1. Initial Baseline
```powershell
# Run lint and save output
.\run-npm-sequential.ps1 -NpmCommand lint -SkipOnError *>&1 |
  Tee-Object "calculator-website-documentation\fix-logs\lint-run-baseline-$(Get-Date -Format 'yyyy-MM-dd-HHmm').txt"

# Generate analysis
.\analyze-lint-errors.ps1
Copy-Item "calculator-website-documentation\lint-error-analysis-*.md" `
  "calculator-website-documentation\fix-logs\analysis-baseline-$(Get-Date -Format 'yyyy-MM-dd-HHmm').md"
```

### 2. Auto-fix Phase
```powershell
# For each branch
$branch = "claude/add-loan-calculator-011CUzKvKUVZU5j9YrN2aQRb"
$safeBranch = $branch -replace "[/\\]", "-"
$timestamp = Get-Date -Format 'yyyy-MM-dd-HHmm'

cd "C:\github-claude\calculator-website-test\$branch"
npm run lint -- --fix *>&1 |
  Tee-Object "..\..\calculator-website-documentation\fix-logs\auto-fix-demonstrations\autofix-$safeBranch-$timestamp.log"

# Verify
npm run lint *>&1 |
  Tee-Object "..\..\calculator-website-documentation\fix-logs\auto-fix-demonstrations\verify-$safeBranch-$timestamp.log"
```

### 3. After Auto-fix Verification
```powershell
.\run-npm-sequential.ps1 -NpmCommand lint -SkipOnError *>&1 |
  Tee-Object "calculator-website-documentation\fix-logs\lint-run-after-autofix-$(Get-Date -Format 'yyyy-MM-dd-HHmm').txt"

.\analyze-lint-errors.ps1
Copy-Item "calculator-website-documentation\lint-error-analysis-*.md" `
  "calculator-website-documentation\fix-logs\analysis-after-autofix-$(Get-Date -Format 'yyyy-MM-dd-HHmm').md"
```

### 4. Manual Fix Documentation
```powershell
# Document each manual fix
$timestamp = Get-Date -Format 'yyyy-MM-dd-HHmm'
$fixType = "react-hooks"  # or "typescript-any", "ban-ts-comment"

# Create fix documentation
@"
# $fixType Fix - $timestamp

## File Changed
[path to file]

## Error Before
[error message]

## Code Before
\`\`\`typescript
[old code]
\`\`\`

## Code After
\`\`\`typescript
[new code]
\`\`\`

## Explanation
[why this fix works]

## Verification
\`\`\`powershell
npm run lint
\`\`\`

## Result
[pass/fail, remaining errors]
"@ | Out-File "calculator-website-documentation\fix-logs\manual-fixes\$fixType-fix-$timestamp.md"
```

### 5. Progress Snapshots (Hourly)
```powershell
$timestamp = Get-Date -Format 'yyyy-MM-dd-HHmm'

# Quick snapshot
@"
# Progress Snapshot - $timestamp

## Current Stats
- Errors remaining: [count]
- Errors fixed this hour: [count]
- Branches completed: [count]

## Recent Fixes
- [list of recent fixes]

## Next Steps
- [what's next]
"@ | Out-File "calculator-website-documentation\fix-logs\progress-snapshots\snapshot-$timestamp.md"
```

### 6. Final Comparison
```powershell
# After all fixes
.\run-npm-sequential.ps1 -NpmCommand lint -SkipOnError *>&1 |
  Tee-Object "calculator-website-documentation\fix-logs\lint-run-final-$(Get-Date -Format 'yyyy-MM-dd-HHmm').txt"

.\analyze-lint-errors.ps1
Copy-Item "calculator-website-documentation\lint-error-analysis-*.md" `
  "calculator-website-documentation\fix-logs\analysis-final-$(Get-Date -Format 'yyyy-MM-dd-HHmm').md"
```

---

## Automated Logging Script

### Create: log-fix-session.ps1

```powershell
# log-fix-session.ps1
param(
    [string]$Phase,  # "baseline", "autofix", "manual", "final"
    [string]$Notes = ""
)

$timestamp = Get-Date -Format 'yyyy-MM-dd-HHmm'
$logDir = "C:\github-claude\calculator-website-documentation\fix-logs"

Write-Host "Logging $Phase phase at $timestamp..." -ForegroundColor Cyan

# Run lint
$lintOutput = ".\run-npm-sequential.ps1 -NpmCommand lint -SkipOnError"
Invoke-Expression $lintOutput |
    Tee-Object "$logDir\lint-run-$Phase-$timestamp.txt"

# Run analysis
.\analyze-lint-errors.ps1
$latestAnalysis = Get-ChildItem "calculator-website-documentation\lint-error-analysis-*.md" |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

if ($latestAnalysis) {
    Copy-Item $latestAnalysis.FullName "$logDir\analysis-$Phase-$timestamp.md"
}

# Create snapshot
$errorCount = (Select-String -Path "$logDir\analysis-$Phase-$timestamp.md" -Pattern "Total Errors: (\d+)").Matches.Groups[1].Value

@"
# $Phase Phase Snapshot - $timestamp

## Statistics
- Total Errors: $errorCount
- Phase: $Phase
- Notes: $Notes

## Files Generated
- Lint output: lint-run-$Phase-$timestamp.txt
- Analysis: analysis-$Phase-$timestamp.md

## Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
"@ | Out-File "$logDir\progress-snapshots\snapshot-$Phase-$timestamp.md"

Write-Host "✓ Logged to: $logDir" -ForegroundColor Green
Write-Host "  - lint-run-$Phase-$timestamp.txt" -ForegroundColor Gray
Write-Host "  - analysis-$Phase-$timestamp.md" -ForegroundColor Gray
Write-Host "  - snapshot-$Phase-$timestamp.md" -ForegroundColor Gray
```

---

## Usage Examples

### Example 1: Log Baseline
```powershell
.\log-fix-session.ps1 -Phase "baseline" -Notes "Initial state before any fixes"
```

### Example 2: Log After Auto-fix
```powershell
.\log-fix-session.ps1 -Phase "autofix" -Notes "Completed prefer-const auto-fixes on 3 branches"
```

### Example 3: Log After Manual Fixes
```powershell
.\log-fix-session.ps1 -Phase "manual" -Notes "Fixed React hooks and ban-ts-comment errors"
```

### Example 4: Log Final State
```powershell
.\log-fix-session.ps1 -Phase "final" -Notes "All planned fixes completed"
```

---

## Comparison Report Template

### Generate Comparison
```powershell
# Extract error counts from snapshots
$baseline = (Select-String -Path "fix-logs\analysis-baseline-*.md" -Pattern "Total Errors: (\d+)").Matches.Groups[1].Value
$final = (Select-String -Path "fix-logs\analysis-final-*.md" -Pattern "Total Errors: (\d+)").Matches.Groups[1].Value

$reduction = $baseline - $final
$percentage = [math]::Round(($reduction / $baseline) * 100, 1)

@"
# Before/After Comparison

## Summary
- **Baseline Errors:** $baseline
- **Final Errors:** $final
- **Errors Fixed:** $reduction
- **Reduction:** $percentage%

## Success Criteria
- Minimum (18% reduction): $(if ($percentage -ge 18) { '✅ PASSED' } else { '❌ NOT MET' })
- Target (48% reduction): $(if ($percentage -ge 48) { '✅ PASSED' } else { '❌ NOT MET' })
- Stretch (73% reduction): $(if ($percentage -ge 73) { '✅ PASSED' } else { '❌ NOT MET' })

## Phase Breakdown
[To be filled with details from each phase]
"@ | Out-File "fix-logs\final-report\before-after-comparison.md"
```

---

## Git Integration (Optional)

### Commit After Each Phase
```powershell
# After completing a phase
git add .
git commit -m "lint: Fixed [error-type] errors in [branch]

- Errors before: [count]
- Errors after: [count]
- Files changed: [list]

Ref: fix-logs/[relevant-log-file]"
```

---

## Metrics to Track

### Per-Phase Metrics
- Starting error count
- Ending error count
- Errors fixed
- Time spent
- Branches affected
- Files modified

### Overall Metrics
- Total errors fixed
- Total time spent
- Success rate (% branches passing)
- Most impactful fixes
- Remaining errors by type

---

## Review Checklist

After each phase:
- [ ] Lint output logged
- [ ] Analysis generated
- [ ] Snapshot created
- [ ] Error count documented
- [ ] Time recorded
- [ ] Notes added
- [ ] Files committed (optional)

---

## Archive Strategy

### After Completion
```powershell
# Create archive
$archiveDate = Get-Date -Format 'yyyy-MM-dd'
Compress-Archive -Path "calculator-website-documentation\fix-logs\*" `
    -DestinationPath "calculator-website-documentation\archives\lint-fixes-$archiveDate.zip"
```

---

**Status:** Ready to use
**Next:** Create subdirectories and begin baseline logging
