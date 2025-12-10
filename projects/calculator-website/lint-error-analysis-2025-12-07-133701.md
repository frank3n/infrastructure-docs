# Lint Error Analysis Report

**Generated:** 2025-12-07 13:37:01
**Log Files Analyzed:** 2
**Total Errors:** 146

---

## Top Error Rules

| Rank | Rule | Count | % of Total |
|------|------|-------|------------|
| 1 | `@typescript-eslint/no-explicit-any` | 137 | 93.8% |
| 2 | `prefer-const` | 7 | 4.8% |
| 3 | `@typescript-eslint/ban-ts-comment` | 1 | 0.7% |
| 4 | `react-hooks/rules-of-hooks` | 1 | 0.7% |

---

## Files with Most Errors

| Rank | File | Error Count |
|------|------|-------------|

---

## Detailed Error Breakdown by Rule

### `@typescript-eslint/no-explicit-any` (137 errors)

**Top affected files:**


### `prefer-const` (7 errors)

**Top affected files:**


### `@typescript-eslint/ban-ts-comment` (1 errors)

**Top affected files:**


### `react-hooks/rules-of-hooks` (1 errors)

**Top affected files:**


---

## Recommendations

### High Priority Fixes

#### Fix `@typescript-eslint/no-explicit-any` (137 errors)

**Issue:** Using `any` type defeats TypeScript's type safety.

**Solution:**
```typescript
// Bad
function process(data: any) { ... }

// Good
interface ProcessData {
  id: string;
  value: number;
}
function process(data: ProcessData) { ... }
```

#### Fix `prefer-const` (7 errors)

**Issue:** Variables declared with `let` that are never reassigned.

**Solution:** Run `npm run lint -- --fix` to auto-fix most instances.
```bash
npm run lint -- --fix
```

#### Fix `@typescript-eslint/ban-ts-comment` (1 errors)

**Issue:** ESLint rule violation.

**Solution:** Review ESLint documentation for `@typescript-eslint/ban-ts-comment`.

### Suggested Workflow

1. **Auto-fix what you can:**
   ```powershell
   cd C:\github-claude\calculator-website-test\claude\<branch-name>
   npm run lint -- --fix
   ```

2. **Manually fix remaining errors:**
   - Focus on high-priority rules first
   - Fix one file at a time
   - Run lint after each fix to verify

3. **Re-run lint check:**
   ```powershell
   cd C:\github-claude
   .\run-npm-sequential.ps1 -NpmCommand lint -SkipOnError
   ```

---

## Related Documentation

- [sequential-npm-runner-guide.md](sequential-npm-runner-guide.md)
- [lint-analysis.md](lint-analysis.md)

