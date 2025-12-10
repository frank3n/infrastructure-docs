# Lint Error Fix Plan

**Created:** 2025-12-07
**Status:** In Progress
**Goal:** Reduce lint errors from 146 to acceptable levels with comprehensive logging

---

## Current State (Baseline)

### Error Statistics
- **Total Errors:** 146
- **Branches Analyzed:** 11
- **Success Rate:** 8.3% (1 of 12 passed)

### Error Breakdown
| Rule | Count | Percentage | Priority | Auto-fixable |
|------|-------|------------|----------|--------------|
| `@typescript-eslint/no-explicit-any` | 137 | 93.8% | HIGH | ❌ Manual |
| `prefer-const` | 7 | 4.8% | LOW | ✅ Auto-fix |
| `@typescript-eslint/ban-ts-comment` | 1 | 0.7% | MEDIUM | ❌ Manual |
| `react-hooks/rules-of-hooks` | 1 | 0.7% | HIGH | ❌ Manual |

### Most Affected Files
From previous analysis:
- `api/src/routes/monitoring.ts` - 20+ `any` instances
- `api/src/routes/proxies.ts` - 13+ `any` instances
- `api/src/routes/scheduler.ts` - 6 `any` instances
- `api/src/routes/sessions.ts` - 2 `any` instances
- `api/src/routes/test.ts` - 4 `any` instances
- `api/src/routes/webhooks.ts` - Multiple `any` instances

---

## Goals

### Primary Goals
1. ✅ **Auto-fix all 7 `prefer-const` errors**
2. ✅ **Fix 1 React hooks error**
3. ✅ **Fix 1 ban-ts-comment error**
4. 🎯 **Reduce `any` type usage by at least 50%** (137 → 68 or fewer)

### Secondary Goals
- Document all fixes with timestamps
- Create reusable TypeScript interfaces
- Generate before/after comparison reports
- Create fix guidelines for team

### Success Metrics
- **Target Error Count:** < 75 errors (50% reduction)
- **Target Success Rate:** > 50% branches passing lint
- **Documentation:** Complete logs for all fixes

---

## Logging Strategy

### Log Files to Generate
1. **baseline-lint-summary.txt** - Current state snapshot
2. **auto-fix-log-[timestamp].txt** - Auto-fix results
3. **manual-fix-log-[timestamp].txt** - Manual fix progress
4. **final-comparison-report.md** - Before/after comparison
5. **fix-guidelines.md** - Reusable patterns for team

### Logging Commands
```powershell
# Baseline
.\run-npm-sequential.ps1 -NpmCommand lint -SkipOnError *>&1 | Tee-Object "logs\baseline-lint-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"

# After auto-fix
.\run-npm-sequential.ps1 -NpmCommand lint -SkipOnError *>&1 | Tee-Object "logs\after-autofix-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"

# After manual fixes
.\run-npm-sequential.ps1 -NpmCommand lint -SkipOnError *>&1 | Tee-Object "logs\after-manual-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
```

---

## Execution Plan

### Phase 1: Preparation & Baseline (10 min)
- [x] Create plan document
- [ ] Document current state
- [ ] Create logs directory
- [ ] Generate baseline lint report
- [ ] Run initial analysis

**Expected Output:**
- `baseline-lint-summary.txt`
- `lint-error-analysis-baseline.md`

---

### Phase 2: Auto-Fixes (15 min)

#### Step 2.1: Fix `prefer-const` Errors
**Target:** 7 errors across multiple branches

**Commands:**
```powershell
# For each branch with prefer-const errors
cd C:\github-claude\calculator-website-test\claude\<branch-name>
npm run lint -- --fix 2>&1 | Tee-Object "..\..\logs\autofix-<branch-name>.txt"
```

**Expected Result:** 7 errors → 0 errors

---

#### Step 2.2: Verify Auto-Fixes
```powershell
.\run-npm-sequential.ps1 -NpmCommand lint -SkipOnError *>&1 | Tee-Object "logs\after-autofix-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
.\analyze-lint-errors.ps1
```

**Expected Output:**
- New error count: ~139 (146 - 7)
- Updated analysis report

---

### Phase 3: High-Priority Manual Fixes (30 min)

#### Step 3.1: Fix React Hooks Error
**Target:** 1 error in `src/pages/CalculatorPage.tsx`

**Issue:** `useSEO` called conditionally

**Fix Strategy:**
```typescript
// Before
if (!calculator) return null;
useSEO(calculator);

// After
const seoData = calculator || defaultCalculator;
useSEO(seoData);
```

**Log:** Document in `logs\fix-react-hooks.md`

---

#### Step 3.2: Fix ban-ts-comment Error
**Target:** 1 error

**Issue:** Using `// @ts-ignore` or similar

**Fix Strategy:**
- Find the comment
- Fix underlying type issue
- Remove comment

**Log:** Document in `logs\fix-ban-ts-comment.md`

---

#### Step 3.3: Create Common TypeScript Interfaces
**Target:** Prepare for `any` type fixes

**Create:** `common-interfaces.ts` with reusable types

```typescript
// api/src/types/common-interfaces.ts
export interface RequestQuery {
  [key: string]: string | string[] | undefined;
}

export interface ResponseData<T = unknown> {
  success: boolean;
  data?: T;
  error?: string;
}

export interface MonitoringMetric {
  name: string;
  value: number;
  timestamp: number;
}

export interface ProxyConfig {
  target: string;
  port: number;
  enabled: boolean;
}
```

**Log:** Document in `logs\interfaces-created.md`

---

### Phase 4: TypeScript `any` Type Fixes (60 min)

**Target:** Fix 68+ instances (50% of 137)

#### Priority Files (Most Impact)
1. `api/src/routes/monitoring.ts` (20+ instances)
2. `api/src/routes/proxies.ts` (13+ instances)
3. `api/src/routes/scheduler.ts` (6 instances)

#### Fix Strategy Per File

**For monitoring.ts:**
```typescript
// Before
app.get('/metric/:name', async (req: any, res: any) => {
  const data: any = await getMetric(req.params.name);
  res.json(data);
});

// After
import { Request, Response } from 'express';
import { MonitoringMetric } from '../types/common-interfaces';

app.get('/metric/:name', async (req: Request, res: Response) => {
  const data: MonitoringMetric = await getMetric(req.params.name);
  res.json(data);
});
```

**Logging:**
- Track each file fixed in `logs\typescript-fixes-log.md`
- Note patterns for reuse

---

### Phase 5: Verification & Analysis (15 min)

#### Step 5.1: Run Final Lint Check
```powershell
.\run-npm-sequential.ps1 -NpmCommand lint -SkipOnError *>&1 | Tee-Object "logs\final-lint-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
```

#### Step 5.2: Generate Final Analysis
```powershell
.\analyze-lint-errors.ps1
```

#### Step 5.3: Create Comparison Report
```powershell
# Compare before/after
$before = 146
$after = <new count>
$reduction = (($before - $after) / $before) * 100
Write-Host "Error reduction: $reduction%"
```

---

### Phase 6: Documentation (20 min)

#### Step 6.1: Create Before/After Report
**File:** `final-comparison-report.md`

**Contents:**
- Baseline statistics
- Final statistics
- Error reduction percentage
- Files fixed
- Patterns identified
- Recommendations for remaining errors

#### Step 6.2: Create Fix Guidelines
**File:** `typescript-fix-guidelines.md`

**Contents:**
- Common `any` type patterns
- Replacement interfaces
- Express.js specific fixes
- React specific fixes
- Code examples

---

## Timeline

| Phase | Duration | Cumulative |
|-------|----------|------------|
| 1. Preparation | 10 min | 10 min |
| 2. Auto-fixes | 15 min | 25 min |
| 3. High-priority fixes | 30 min | 55 min |
| 4. TypeScript fixes | 60 min | 115 min |
| 5. Verification | 15 min | 130 min |
| 6. Documentation | 20 min | 150 min |

**Total Estimated Time:** 2.5 hours

---

## Risk Mitigation

### Backup Strategy
```powershell
# Before starting fixes, create backup
cd C:\github-claude\calculator-website-test
git worktree list > backup-worktree-list.txt
git status > backup-git-status.txt
```

### Rollback Plan
If fixes break functionality:
```powershell
# Discard changes in specific branch
cd C:\github-claude\calculator-website-test\claude\<branch-name>
git restore .

# Or use git stash
git stash
```

---

## Success Criteria

### Minimum Success
- ✅ All 7 `prefer-const` errors fixed
- ✅ React hooks error fixed
- ✅ ban-ts-comment error fixed
- ✅ At least 20 `any` type fixes
- ✅ Complete documentation

**Result:** ~118 errors (19% reduction)

### Target Success
- ✅ All auto-fixable errors resolved
- ✅ 68+ `any` type fixes (50% reduction)
- ✅ Complete logging
- ✅ Reusable interfaces created

**Result:** <75 errors (>48% reduction)

### Stretch Success
- ✅ 100+ `any` type fixes (73% reduction)
- ✅ >75% branches passing lint
- ✅ Team guidelines document

**Result:** <40 errors (>72% reduction)

---

## Post-Completion Tasks

1. **Share Results**
   - Email team with before/after comparison
   - Share fix guidelines

2. **Set Up Prevention**
   - Add pre-commit hooks
   - Update ESLint rules
   - CI/CD integration

3. **Schedule Follow-up**
   - Weekly lint checks
   - Progress tracking
   - Continuous improvement

---

## Notes & Observations

### During Execution
- Track time spent per phase
- Note unexpected issues
- Document useful patterns

### Lessons Learned
- What worked well
- What was challenging
- How to improve next time

---

## Appendix: Quick Commands

```powershell
# Start
cd C:\github-claude

# Baseline
.\run-npm-sequential.ps1 -NpmCommand lint -SkipOnError

# Auto-fix a branch
cd calculator-website-test\claude\<branch>
npm run lint -- --fix

# Analyze
.\analyze-lint-errors.ps1

# Compare
Get-Content calculator-website-documentation\npm-logs\summary-*.txt | Select-String "Total:"
```

---

**Status:** Ready to execute
**Next Step:** Phase 1 - Preparation & Baseline
