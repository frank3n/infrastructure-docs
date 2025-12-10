# Lint Error Analysis Report

**Generated:** 2025-12-08 15:34:43
**Log Files Analyzed:** 11
**Total Errors:** 614

---

## Top Error Rules

| Rank | Rule | Count | % of Total |
|------|------|-------|------------|
| 1 | `@typescript-eslint/no-explicit-any` | 594 | 96.7% |
| 2 | `prefer-const` | 14 | 2.3% |
| 3 | `@typescript-eslint/ban-ts-comment` | 3 | 0.5% |
| 4 | `react-hooks/rules-of-hooks` | 3 | 0.5% |

---

## Files with Most Errors

| Rank | File | Error Count |
|------|------|-------------|
| 1 | `src\services\deepl.ts` | 468 |

---

## Detailed Error Breakdown by Rule

### `@typescript-eslint/no-explicit-any` (594 errors)

**Top affected files:**

- `src\services\deepl.ts` - 457 occurrence(s)

### `prefer-const` (14 errors)

**Top affected files:**

- `src\services\deepl.ts` - 7 occurrence(s)

### `@typescript-eslint/ban-ts-comment` (3 errors)

**Top affected files:**

- `src\services\deepl.ts` - 2 occurrence(s)

### `react-hooks/rules-of-hooks` (3 errors)

**Top affected files:**

- `src\services\deepl.ts` - 2 occurrence(s)

---

## Recommendations

### High Priority Fixes

#### Fix `@typescript-eslint/no-explicit-any` (594 errors)

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

#### Fix `prefer-const` (14 errors)

**Issue:** Variables declared with `let` that are never reassigned.

**Solution:** Run `npm run lint -- --fix` to auto-fix most instances.
```bash
npm run lint -- --fix
```

#### Fix `@typescript-eslint/ban-ts-comment` (3 errors)

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

