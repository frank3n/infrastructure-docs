# Lint Error Analysis Guide

## Overview

The `analyze-lint-errors.ps1` script parses lint log files and generates comprehensive analysis reports showing error patterns, affected files, and recommendations.

## Features

- ✓ Parses all lint log files
- ✓ Counts errors by rule type
- ✓ Identifies files with most errors
- ✓ Shows which rules affect which files
- ✓ Generates markdown reports
- ✓ Provides fix recommendations
- ✓ Optional warning analysis
- ✓ Top error rules ranking

## Usage

### Basic Usage

```powershell
# Analyze all lint logs
.\analyze-lint-errors.ps1
```

### Include Warnings

```powershell
# Analyze errors and warnings
.\analyze-lint-errors.ps1 -IncludeWarnings
```

### Custom Directories

```powershell
# Custom log directory
.\analyze-lint-errors.ps1 -LogDirectory "C:\custom\logs"

# Custom output directory
.\analyze-lint-errors.ps1 -OutputDirectory "C:\custom\output"
```

### Custom Pattern

```powershell
# Analyze specific logs
.\analyze-lint-errors.ps1 -Pattern "main-lint-*.log"
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `LogDirectory` | string | `C:\github-claude\calculator-website-documentation\npm-logs` | Directory containing lint logs |
| `OutputDirectory` | string | `C:\github-claude\calculator-website-documentation` | Where to save analysis report |
| `Pattern` | string | `*-lint-*.log` | Pattern to match log files |
| `IncludeWarnings` | switch | `false` | Include warnings in analysis |

## Output

### Console Summary

```
=========================================
SUMMARY
=========================================

Total Errors: 150

Top 5 Error Rules:
  1. @typescript-eslint/no-explicit-any: 85 errors
  2. prefer-const: 25 errors
  3. @typescript-eslint/no-unused-vars: 20 errors
  4. react-hooks/rules-of-hooks: 12 errors
  5. react-hooks/exhaustive-deps: 8 errors

Files with Most Errors:
  1. api/src/routes/monitoring.ts - 20 errors
  2. api/src/routes/proxies.ts - 15 errors
  3. api/src/routes/scheduler.ts - 10 errors
  4. src/components/SEO.tsx - 8 errors
  5. src/pages/CalculatorPage.tsx - 7 errors

Report saved to:
  C:\...\lint-error-analysis-2025-12-07-140530.md

✓ Analysis complete!
```

### Report File

Creates a markdown report with:

1. **Statistics**
   - Total errors/warnings
   - Number of log files analyzed

2. **Top Error Rules**
   - Ranked list of most common errors
   - Percentage of total

3. **Files with Most Errors**
   - Top 20 files ranked by error count

4. **Detailed Breakdown by Rule**
   - Each rule with affected files
   - Occurrence count per file

5. **Recommendations**
   - Priority fixes
   - Code examples
   - Suggested workflow

## Report Example

```markdown
# Lint Error Analysis Report

**Generated:** 2025-12-07 14:05:30
**Log Files Analyzed:** 3
**Total Errors:** 150

---

## Top Error Rules

| Rank | Rule | Count | % of Total |
|------|------|-------|------------|
| 1 | `@typescript-eslint/no-explicit-any` | 85 | 56.7% |
| 2 | `prefer-const` | 25 | 16.7% |
| 3 | `@typescript-eslint/no-unused-vars` | 20 | 13.3% |

---

## Files with Most Errors

| Rank | File | Error Count |
|------|------|-------------|
| 1 | `api/src/routes/monitoring.ts` | 20 |
| 2 | `api/src/routes/proxies.ts` | 15 |

---

## Detailed Error Breakdown by Rule

### `@typescript-eslint/no-explicit-any` (85 errors)

**Top affected files:**

- `api/src/routes/monitoring.ts` - 20 occurrence(s)
- `api/src/routes/proxies.ts` - 13 occurrence(s)

---

## Recommendations

### High Priority Fixes

#### Fix `@typescript-eslint/no-explicit-any` (85 errors)

**Issue:** Using `any` type defeats TypeScript's type safety.

**Solution:**
\`\`\`typescript
// Bad
function process(data: any) { ... }

// Good
interface ProcessData {
  id: string;
  value: number;
}
function process(data: ProcessData) { ... }
\`\`\`
```

## Workflow

### 1. Run Lint Check

```powershell
# Run lint for all branches
.\run-npm-sequential.ps1 -NpmCommand lint -SkipOnError
```

### 2. Analyze Results

```powershell
# Generate analysis report
.\analyze-lint-errors.ps1
```

### 3. Review Report

```powershell
# Open the report
notepad C:\github-claude\calculator-website-documentation\lint-error-analysis-*.md
```

### 4. Fix Errors

#### Auto-fix First

```powershell
cd C:\github-claude\calculator-website-test\claude\<branch-name>
npm run lint -- --fix
```

#### Manual Fixes

Focus on:
1. React Hooks violations (high priority)
2. TypeScript `any` types (high priority)
3. Unused variables (medium priority)
4. `prefer-const` (low priority - auto-fixable)

### 5. Re-run Lint

```powershell
cd C:\github-claude
.\run-npm-sequential.ps1 -NpmCommand lint -SkipOnError
```

### 6. Re-analyze

```powershell
.\analyze-lint-errors.ps1
```

Compare error counts to track progress.

## Understanding Error Rules

### `@typescript-eslint/no-explicit-any`

**What it means:** Using `any` type instead of specific types

**Why it matters:** Defeats TypeScript's type safety

**How to fix:**
- Define interfaces for complex types
- Use union types for multiple possibilities
- Use generic types for flexible functions

**Example:**
```typescript
// Bad
function getData(params: any): any { }

// Good
interface RequestParams {
  id: string;
  filters?: string[];
}
interface ResponseData {
  items: Item[];
  total: number;
}
function getData(params: RequestParams): ResponseData { }
```

### `prefer-const`

**What it means:** Variable declared with `let` but never reassigned

**Why it matters:** Code clarity and immutability

**How to fix:** Auto-fixable with `npm run lint -- --fix`

**Example:**
```typescript
// Bad
let value = 10;
console.log(value);

// Good
const value = 10;
console.log(value);
```

### `@typescript-eslint/no-unused-vars`

**What it means:** Variable/import/parameter defined but not used

**Why it matters:** Clean code, smaller bundles

**How to fix:**
- Remove unused code
- Prefix with `_` if intentionally unused

**Example:**
```typescript
// Bad
import { unused } from './module';
const notUsed = 'hello';

// Good - Remove unused code
// Or if intentionally unused:
function handler(_req, res) { ... }
```

### `react-hooks/rules-of-hooks`

**What it means:** React Hooks called conditionally

**Why it matters:** Can cause React runtime errors

**How to fix:** Move conditional logic inside hooks

**Example:**
```typescript
// Bad
if (condition) {
  useEffect(() => { ... });
}

// Good
useEffect(() => {
  if (condition) {
    // ... do something
  }
}, [condition]);
```

### `react-hooks/exhaustive-deps`

**What it means:** Missing dependencies in useEffect

**Why it matters:** Can cause stale data bugs

**How to fix:** Add all dependencies or use useCallback/useMemo

**Example:**
```typescript
// Bad
useEffect(() => {
  fetchData(userId);
}, []);

// Good
useEffect(() => {
  fetchData(userId);
}, [userId, fetchData]);
```

## Advanced Usage

### Track Progress Over Time

```powershell
# Day 1
.\run-npm-sequential.ps1 -NpmCommand lint -SkipOnError
.\analyze-lint-errors.ps1
# Note: 150 errors

# Day 2 (after fixes)
.\run-npm-sequential.ps1 -NpmCommand lint -SkipOnError
.\analyze-lint-errors.ps1
# Note: 120 errors (progress!)

# Compare reports
Get-Content lint-error-analysis-*.md | Select-String "Total Errors"
```

### Focus on Specific Rule

```powershell
# After running analysis, search for specific rule
$report = Get-Content lint-error-analysis-*.md -Raw
$report | Select-String "@typescript-eslint/no-explicit-any" -Context 5
```

### Export for Sharing

```powershell
# Copy report to shared location
Copy-Item lint-error-analysis-*.md "\\shared\team\reports\"
```

## Troubleshooting

### No log files found

**Solution:**
```powershell
# Verify log directory
Test-Path C:\github-claude\calculator-website-documentation\npm-logs

# List log files
Get-ChildItem C:\github-claude\calculator-website-documentation\npm-logs\*-lint-*.log
```

### Encoding issues

**Issue:** Log files with wrong encoding

**Solution:** The script handles UTF-16 encoding automatically

### Empty report

**Issue:** No errors parsed from logs

**Possible causes:**
- Logs are empty
- Logs have different format
- All lints passed (unlikely)

**Solution:**
```powershell
# Check log content
Get-Content npm-logs\*-lint-*.log | Select-Object -First 20
```

## Integration with CI/CD

### Example: Daily Lint Check

```powershell
# Create scheduled task
$action = New-ScheduledTaskAction -Execute "powershell.exe" `
  -Argument "-File C:\github-claude\run-npm-sequential.ps1 -NpmCommand lint -SkipOnError; C:\github-claude\analyze-lint-errors.ps1"

$trigger = New-ScheduledTaskTrigger -Daily -At 9am

Register-ScheduledTask -TaskName "Daily Lint Check" `
  -Action $action -Trigger $trigger
```

## Best Practices

1. **Run analysis after every lint check**
   - Track error trends
   - Prioritize fixes

2. **Fix high-count rules first**
   - Biggest impact
   - Improve overall code quality

3. **Use auto-fix when possible**
   - Save time
   - Quick wins

4. **Share reports with team**
   - Visibility
   - Collaboration

5. **Set goals**
   - "Reduce errors by 20% this week"
   - Track progress

## Related Documentation

- [sequential-npm-runner-guide.md](sequential-npm-runner-guide.md) - NPM runner
- [lint-analysis.md](lint-analysis.md) - Lint results summary
- [README.md](README.md) - Main documentation

## Quick Reference

```powershell
# Complete workflow
.\run-npm-sequential.ps1 -NpmCommand lint -SkipOnError
.\analyze-lint-errors.ps1

# View report
notepad calculator-website-documentation\lint-error-analysis-*.md

# Fix a branch
cd calculator-website-test\claude\<branch-name>
npm run lint -- --fix
npm run lint

# Re-check all
cd C:\github-claude
.\run-npm-sequential.ps1 -NpmCommand lint -SkipOnError
.\analyze-lint-errors.ps1
```
