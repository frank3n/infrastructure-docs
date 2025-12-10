# Command Reference Guide - TypeScript Quality Project

**Last Updated:** December 8, 2025
**Project:** calculator-website + multi-repo rollout
**Status:** Production-ready

---

## 📋 Table of Contents

1. [Daily Development Commands](#daily-development-commands)
2. [Quality Check Commands](#quality-check-commands)
3. [Documentation Commands](#documentation-commands)
4. [Multi-Repo Rollout Commands](#multi-repo-rollout-commands)
5. [Git & CI/CD Commands](#git--cicd-commands)
6. [Pre-commit Hook Commands](#pre-commit-hook-commands)
7. [Troubleshooting Commands](#troubleshooting-commands)

---

## 🛠️ Daily Development Commands

### Start Development
```bash
# Start dev server
npm run dev

# Start dev server and open browser
npm run dev -- --open
```

### Build & Preview
```bash
# Build for production
npm run build

# Build embed version
npm run build:embed

# Preview production build
npm run preview
```

### Testing
```bash
# Run tests
npm test

# Run tests in watch mode
npm test -- --watch

# Run tests with coverage
npm test -- --coverage
```

---

## ✅ Quality Check Commands

### TypeScript Type Checking
```bash
# Check types (no output files)
npx tsc --noEmit

# Check types with strict mode
npx tsc --noEmit --strict

# Watch mode for type checking
npx tsc --noEmit --watch
```

### ESLint
```bash
# Run ESLint
npm run lint

# Run ESLint with auto-fix
npm run lint -- --fix

# Lint specific directory
npm run lint -- src/

# Lint specific file
npm run lint -- src/App.tsx
```

### Type Coverage
```bash
# Quick type coverage check
npm run type-coverage

# Detailed report (shows untyped locations)
npm run type-coverage:detail

# Full report (ignore test files)
npm run type-coverage:report

# Enforce 95% minimum coverage
npm run type-coverage:check
```

### All Quality Checks (Run Before Commit)
```bash
# Run all checks at once
npx tsc --noEmit && npm run lint && npm run type-coverage:check && npm run build
```

---

## 📚 Documentation Commands

### TypeDoc
```bash
# Generate documentation
npm run docs:generate

# Generate and open in browser
npm run docs:open

# Watch mode (regenerate on changes)
npm run docs:watch

# Clean documentation folder
npm run docs:clean

# Validate documentation (no output)
npm run docs:validate
```

### View Documentation
```bash
# Open documentation in default browser (Windows)
start docs/api/index.html

# Open documentation (macOS)
open docs/api/index.html

# Open documentation (Linux)
xdg-open docs/api/index.html
```

---

## 🔄 Multi-Repo Rollout Commands

### Scan Repositories
```bash
# Scan all repositories from config file
powershell -ExecutionPolicy Bypass -File scan-all-repos.ps1

# Scan specific repositories
powershell -ExecutionPolicy Bypass -File scan-all-repos.ps1 `
  -Repositories @("C:\repo1", "C:\repo2")

# Scan with custom config file
powershell -ExecutionPolicy Bypass -File scan-all-repos.ps1 `
  -ConfigFile "my-repos.txt"
```

**Output Files:**
- `scan-results_[timestamp].csv` - Full scan results
- `priority-order.txt` - Repositories sorted by error count

### Rollout to Repositories
```bash
# DRY RUN - See what would happen (RECOMMENDED FIRST)
powershell -ExecutionPolicy Bypass -File rollout-to-all-repos.ps1 -DryRun

# Rollout to specific repository
powershell -ExecutionPolicy Bypass -File rollout-to-all-repos.ps1 `
  -Repositories @("C:\github\api-gateway")

# Rollout with auto-commit
powershell -ExecutionPolicy Bypass -File rollout-to-all-repos.ps1 `
  -Repositories @("C:\github\api-gateway") `
  -AutoCommit

# Rollout to all repositories from scan
powershell -ExecutionPolicy Bypass -File rollout-to-all-repos.ps1 `
  -ConfigFile priority-order.txt `
  -AutoCommit

# Rollout with custom source
powershell -ExecutionPolicy Bypass -File rollout-to-all-repos.ps1 `
  -SourceRepo "C:\github-claude" `
  -AutoCommit
```

**Output Files:**
- `rollout-results_[timestamp].csv` - Rollout results per repository

---

## 🔧 Git & CI/CD Commands

### Pre-commit Hook Installation
```bash
# Install pre-commit hooks for all worktrees
powershell -ExecutionPolicy Bypass -File install-pre-commit-hooks.ps1

# Test the hook (should block commit)
echo "const test: any = 1;" > test.ts
git add test.ts
git commit -m "test"  # Should be blocked

# Bypass hook (emergency only)
git commit --no-verify -m "emergency fix"
```

### Create Commits
```bash
# Standard commit workflow
git add .
git status
git commit -m "feat: Add new calculator feature"

# Commit with detailed message
git commit -m "fix: Resolve TypeScript errors

- Fixed 32 strict mode errors
- Added type coverage reporting
- Enhanced ESLint configuration

🤖 Generated with Claude Code
Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

### Create Pull Request
```bash
# Push branch
git push origin feature-branch

# Create PR (using GitHub CLI)
gh pr create --title "feat: TypeScript quality improvements" \
  --body-file calculator-website-documentation/PR-DESCRIPTION-TEMPLATE.md

# Create PR with auto-fill
gh pr create --fill

# Create draft PR
gh pr create --draft --title "WIP: New feature"
```

### View CI/CD Status
```bash
# Check workflow runs
gh run list

# View specific workflow
gh run list --workflow=type-check.yml

# Watch latest run
gh run watch

# View run details
gh run view [run-id]

# Re-run failed jobs
gh run rerun [run-id]
```

---

## 🔐 Pre-commit Hook Commands

### Manual Hook Management
```bash
# Check if hook exists
ls -la .git/hooks/pre-commit

# View hook content
cat .git/hooks/pre-commit

# Make hook executable (Linux/Mac)
chmod +x .git/hooks/pre-commit

# Test hook manually
.git/hooks/pre-commit

# Disable hook temporarily
mv .git/hooks/pre-commit .git/hooks/pre-commit.disabled

# Re-enable hook
mv .git/hooks/pre-commit.disabled .git/hooks/pre-commit
```

### Bypass Hook (Emergency)
```bash
# Bypass for single commit
git commit --no-verify -m "emergency: fix production bug"

# Bypass for amend
git commit --amend --no-verify
```

---

## 🔍 Troubleshooting Commands

### Check Versions
```bash
# Node.js version
node --version

# npm version
npm --version

# TypeScript version
npx tsc --version

# ESLint version
npx eslint --version

# Check installed packages
npm list --depth=0
```

### Clean & Reinstall
```bash
# Remove node_modules
rm -rf node_modules

# Remove package-lock
rm package-lock.json

# Clean npm cache
npm cache clean --force

# Reinstall dependencies
npm install

# Or use clean install
npm ci
```

### Debug TypeScript
```bash
# Show TypeScript config
npx tsc --showConfig

# Explain file inclusion
npx tsc --listFiles | grep "src/"

# Check compiler options
npx tsc --help
```

### Debug ESLint
```bash
# Show ESLint config for a file
npx eslint --print-config src/App.tsx

# Debug ESLint rules
npx eslint src/App.tsx --debug

# Show which rules are enabled
npx eslint src/App.tsx --print-config | grep "rules" -A 50
```

### Find Errors
```bash
# Find all TypeScript errors
npx tsc --noEmit 2>&1 | grep "error TS"

# Count errors
npx tsc --noEmit 2>&1 | grep -c "error TS"

# Find 'any' types
git grep -n ": any\b\|<any>\|any\[\]\| as any\b" -- "*.ts" "*.tsx"

# Count 'any' types
git grep -c ": any\b\|<any>\|any\[\]\| as any\b" -- "*.ts" "*.tsx"
```

### Build Debugging
```bash
# Build with detailed output
npm run build -- --debug

# Build and keep intermediate files
npx vite build --mode development

# Analyze bundle size
npm run build -- --report
```

---

## 📊 Reporting Commands

### Generate Reports
```bash
# Type coverage report (console)
npm run type-coverage

# Type coverage report (JSON)
npx type-coverage --output-mode json > type-coverage.json

# ESLint report (HTML)
npx eslint src/ --format html --output-file eslint-report.html

# ESLint report (JSON)
npx eslint src/ --format json --output-file eslint-report.json
```

### View Statistics
```bash
# Count TypeScript files
find src -name "*.ts" -o -name "*.tsx" | wc -l

# Lines of code
find src -name "*.ts" -o -name "*.tsx" | xargs wc -l

# Total files
find src -type f | wc -l

# Git statistics
git log --stat
git shortlog -sn
```

---

## 🚀 Common Workflows

### Before Starting Work
```bash
# Update from remote
git pull origin main

# Install/update dependencies
npm ci

# Verify everything works
npm run lint && npx tsc --noEmit && npm run build
```

### Before Committing
```bash
# Run all quality checks
npx tsc --noEmit
npm run lint
npm run type-coverage:check
npm test

# Stage changes
git add .

# Commit (pre-commit hook runs automatically)
git commit -m "feat: your message"
```

### After Making Changes
```bash
# Check what changed
git status
git diff

# Type check
npx tsc --noEmit

# Lint with auto-fix
npm run lint -- --fix

# Test
npm test

# Build
npm run build
```

### Creating a Release
```bash
# Run full quality suite
npx tsc --noEmit && \
npm run lint && \
npm run type-coverage:check && \
npm test && \
npm run build

# Generate documentation
npm run docs:generate

# Commit release
git add .
git commit -m "chore: release v1.0.0"
git tag v1.0.0
git push origin main --tags
```

---

## 📝 Configuration File Locations

```
calculator-website/
├── .eslintrc.cjs           # ESLint configuration
├── tsconfig.json           # TypeScript configuration
├── typedoc.json            # TypeDoc configuration
├── package.json            # Scripts and dependencies
├── .git/hooks/pre-commit   # Pre-commit hook
└── .github/workflows/      # GitHub Actions
    ├── type-check.yml
    ├── pr-quality-check.yml
    └── documentation.yml
```

---

## 🔗 Quick Reference Links

### Documentation Files
- `PHASE-2-COMPLETION-SUMMARY.md` - Phase 2 results
- `QUICK-WINS-SUMMARY.md` - Phase 1 results
- `REMAINING-ENHANCEMENTS-AND-REPO-STRATEGY.md` - Multi-repo strategy
- `MULTI-REPO-QUICK-START.md` - Rollout guide
- `TYPEDOC-SETUP.md` - TypeDoc guide
- `PRE-COMMIT-HOOK-SETUP.md` - Hook setup guide

### Key Scripts
- `scan-all-repos.ps1` - Scan repositories
- `rollout-to-all-repos.ps1` - Automated rollout
- `install-pre-commit-hooks.ps1` - Hook installer

---

## 💡 Pro Tips

### Speed Up Development
```bash
# Run type check in background
npx tsc --noEmit --watch &

# Run tests in watch mode
npm test -- --watch &

# Run dev server
npm run dev
```

### Parallel Execution
```bash
# Run multiple commands in parallel (PowerShell)
Start-Process npm -ArgumentList "run", "lint"
Start-Process npm -ArgumentList "test"
Start-Process npx -ArgumentList "tsc", "--noEmit"

# Run multiple commands in parallel (Bash)
npm run lint & npm test & npx tsc --noEmit & wait
```

### Aliases (Add to ~/.bashrc or ~/.zshrc)
```bash
# Quality checks
alias tc='npx tsc --noEmit'
alias lint='npm run lint'
alias coverage='npm run type-coverage'
alias qa='npx tsc --noEmit && npm run lint && npm run type-coverage:check'

# Development
alias dev='npm run dev'
alias build='npm run build'
alias test='npm test'

# Documentation
alias docs='npm run docs:generate && npm run docs:open'
```

---

## 🎯 Most Important Commands (Daily Use)

```bash
# 1. Start development
npm run dev

# 2. Check quality before commit
npx tsc --noEmit && npm run lint

# 3. Full quality check
npm run type-coverage:check && npm run build

# 4. Commit with confidence
git add . && git commit -m "your message"

# 5. Generate documentation
npm run docs:generate
```

---

## 📞 Getting Help

```bash
# npm script help
npm run

# TypeScript help
npx tsc --help

# ESLint help
npx eslint --help

# TypeDoc help
npx typedoc --help

# Git help
git --help
gh --help
```

---

**Quick Start:** Run `npm run dev` to start developing!
**Before Commit:** Run `npx tsc --noEmit && npm run lint`
**Full Check:** Run `npm run type-coverage:check && npm run build`

**Status:** Ready to use! 🚀
