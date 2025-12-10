# Quick Start Guide - Adventurer Dating Website Quality Rollout

**Goal:** Apply TypeScript quality improvements from calculator-website template
**Time:** 2-3 hours estimated
**Method:** Automated rollout script (recommended) or manual

---

## Option 1: Automated Rollout (Recommended) ⚡

### Step 1: Clone Repository
```bash
cd C:/github
gh repo clone frank3n/adventurer-dating-website
```

### Step 2: Add to Scan List
```bash
cd C:/github-claude
echo "C:\github\adventurer-dating-website" >> repos-to-scan.txt
```

### Step 3: Run Baseline Scan
```bash
powershell -ExecutionPolicy Bypass -File scan-all-repos.ps1
```

**Review output:**
- `scan-results_[timestamp].csv` - Error counts and details
- `priority-order.txt` - Priority ordering

### Step 4: Dry Run Rollout
```bash
powershell -ExecutionPolicy Bypass -File rollout-to-all-repos.ps1 `
  -Repositories @("C:\github\adventurer-dating-website") `
  -DryRun
```

**Review what would happen** (no changes made)

### Step 5: Execute Rollout
```bash
powershell -ExecutionPolicy Bypass -File rollout-to-all-repos.ps1 `
  -Repositories @("C:\github\adventurer-dating-website") `
  -AutoCommit
```

**Result:** 
- Improvements applied
- Errors fixed
- Branch created and committed
- Ready for PR

### Step 6: Create Pull Request
```bash
cd C:/github/adventurer-dating-website
gh pr create --base main --head typescript-quality-improvements
```

---

## Option 2: Manual Rollout (Full Control) 🔧

### Step 1: Clone and Setup
```bash
cd C:/github
gh repo clone frank3n/adventurer-dating-website
cd adventurer-dating-website
npm ci
```

### Step 2: Create Feature Branch
```bash
git checkout -b typescript-quality-improvements
```

### Step 3: Copy Configuration Files
```bash
# Copy from calculator-website template
cp C:/github-claude/calculator-website-test/tsconfig.json ./
cp C:/github-claude/calculator-website-test/.eslintrc.cjs ./
cp C:/github-claude/calculator-website-test/typedoc.json ./

# Copy GitHub Actions
mkdir -p .github/workflows
cp C:/github-claude/calculator-website-test/.github/workflows/*.yml .github/workflows/

# Copy pre-commit hook
cp C:/github-claude/pre-commit-hook.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

### Step 4: Install Dependencies
```bash
npm install --save-dev eslint-plugin-import type-coverage typedoc
```

### Step 5: Update package.json
Add these scripts:
```json
{
  "scripts": {
    "docs:generate": "typedoc",
    "docs:watch": "typedoc --watch",
    "docs:open": "typedoc && start docs/api/index.html",
    "docs:clean": "rimraf docs/api",
    "docs:validate": "typedoc --emit none --treatWarningsAsErrors",
    "type-coverage": "type-coverage",
    "type-coverage:detail": "type-coverage --detail",
    "type-coverage:report": "type-coverage --detail --ignore-files 'src/**/*.test.ts'",
    "type-coverage:check": "type-coverage --at-least 95 --strict"
  }
}
```

### Step 6: Check Baseline Errors
```bash
npx tsc --noEmit 2>&1 | tee baseline-errors.log
```

### Step 7: Auto-fix What's Possible
```bash
npm run lint -- --fix
```

### Step 8: Fix Remaining Errors
Use calculator-website fixes as reference:
- See: `C:/github-claude/calculator-website-documentation/PHASE-2-COMPLETION-SUMMARY.md`

Common fixes:
- Add `[key: string]: unknown` to interfaces
- Add null checks: `array[0]?.value ?? default`
- Fix array access: `items[index] !== undefined`
- Remove unused imports

### Step 9: Verify All Checks
```bash
npx tsc --noEmit           # 0 errors expected
npm run lint               # Should pass
npm run type-coverage      # Check coverage
npm run build              # Should succeed
```

### Step 10: Commit and Push
```bash
git add .
git commit -m "feat: TypeScript quality improvements (Phase 2)

- Enhanced tsconfig with strict options
- Updated ESLint configuration
- Added type coverage reporting
- Fixed all TypeScript errors
- Set up CI/CD workflows

🤖 Generated with Claude Code"

git push origin typescript-quality-improvements
```

### Step 11: Create PR
```bash
gh pr create --base main --head typescript-quality-improvements \
  --title "feat: TypeScript Quality Improvements (Phase 2)" \
  --body-file C:/github-claude/calculator-website-documentation/PR-DESCRIPTION-TEMPLATE.md
```

---

## What Gets Applied

### Configuration Files
- ✅ `tsconfig.json` - 10 strict compiler options
- ✅ `.eslintrc.cjs` - Enhanced linting rules
- ✅ `typedoc.json` - Documentation generation
- ✅ `package.json` - New npm scripts

### GitHub Actions Workflows
- ✅ `type-check.yml` - TypeScript validation
- ✅ `pr-quality-check.yml` - PR validation  
- ✅ `documentation.yml` - TypeDoc generation

### Dependencies Added
- ✅ `eslint-plugin-import` - Import organization
- ✅ `type-coverage` - Type coverage measurement
- ✅ `typedoc` - API documentation generation

### Pre-commit Hook
- ✅ Blocks commits with TypeScript errors
- ✅ Runs linting automatically
- ✅ Enforces quality standards

---

## Troubleshooting

### Error: "Module not found"
```bash
npm ci  # Clean install dependencies
```

### Error: "Too many TypeScript errors"
```bash
# Fix in phases:
# 1. Run auto-fix
npm run lint -- --fix

# 2. Fix one category at a time
# - Unused imports first
# - Then null checks
# - Then interface updates
```

### Error: "Build fails"
```bash
# Check what's failing
npm run build 2>&1 | tee build-errors.log

# Fix errors in order shown
# Verify after each fix
npx tsc --noEmit
```

---

## Expected Timeline

**Automated Rollout:** 30-60 minutes
- Clone: 5 min
- Scan: 5 min
- Rollout: 15-30 min
- Verify: 10 min
- PR: 5 min

**Manual Rollout:** 2-3 hours
- Setup: 15 min
- Copy configs: 15 min
- Fix errors: 1-2 hours
- Verify: 30 min
- Document: 30 min

---

## Success Checklist

- [ ] Repository cloned
- [ ] Baseline scan completed
- [ ] Configuration files copied/updated
- [ ] Dependencies installed
- [ ] TypeScript errors: 0
- [ ] ESLint: passing
- [ ] Type coverage: ≥95%
- [ ] Build: successful
- [ ] CI/CD workflows: added
- [ ] Pre-commit hook: installed
- [ ] Branch: pushed
- [ ] PR: created

---

## Help & References

**Template Location:** `C:/github-claude/calculator-website-test`
**Documentation:** `C:/github-claude/calculator-website-documentation/`
**Automation Scripts:** `C:/github-claude/*.ps1`
**Command Reference:** `C:/github-claude/COMMAND-REFERENCE.md`

**For Detailed Error Fixes:**
See: `C:/github-claude/calculator-website-documentation/PHASE-2-COMPLETION-SUMMARY.md`

---

*Ready to Start!* 🚀
