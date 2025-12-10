# Pre-commit Hook Setup Guide

This guide provides multiple options to prevent TypeScript `any` types from being committed.

---

## Option 1: Manual Git Hook (Simplest)

### Setup Steps

1. **Create the hook file:**
```bash
# Navigate to your git repository root
cd C:/github-claude/calculator-website-test

# Create pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/sh

echo "Running lint check before commit..."

# Check if this is a worktree
if [ -f .git ]; then
  # This is a worktree, read the actual git dir
  GIT_DIR=$(cat .git | sed 's/gitdir: //')
else
  GIT_DIR=".git"
fi

# Get list of staged TypeScript/TSX files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(ts|tsx)$')

if [ -z "$STAGED_FILES" ]; then
  echo "No TypeScript files to check."
  exit 0
fi

echo "Checking staged files for 'any' types..."

# Check for 'any' type usage in staged files
ERRORS=0
for FILE in $STAGED_FILES; do
  if [ -f "$FILE" ]; then
    # Check for common 'any' patterns
    if grep -n ': any\|<any>\|any\[\]\|as any' "$FILE" > /dev/null 2>&1; then
      echo "❌ ERROR: File contains 'any' types: $FILE"
      grep -n ': any\|<any>\|any\[\]\|as any' "$FILE" | head -5
      ERRORS=$((ERRORS + 1))
    fi
  fi
done

if [ $ERRORS -gt 0 ]; then
  echo ""
  echo "❌ Commit rejected: $ERRORS file(s) contain TypeScript 'any' types"
  echo "Please replace 'any' with proper types (unknown, specific types, etc.)"
  echo ""
  echo "To bypass this check (not recommended): git commit --no-verify"
  exit 1
fi

echo "✅ All checks passed!"
exit 0
EOF

# Make it executable
chmod +x .git/hooks/pre-commit
```

2. **For each worktree, create a symlink:**
```bash
# Example for one worktree
cd claude/coolcation-calculator-feature-011CV5qSqYUYdvwJ5bpua7ph
ln -s ../../.git/hooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

---

## Option 2: Husky + lint-staged (Recommended for Teams)

### Installation

```bash
cd C:/github-claude/calculator-website-test

# Install husky and lint-staged
npm install --save-dev husky lint-staged

# Initialize husky
npx husky install

# Create pre-commit hook
npx husky add .husky/pre-commit "npx lint-staged"
```

### Configuration

Add to `package.json`:

```json
{
  "lint-staged": {
    "*.{ts,tsx}": [
      "eslint --max-warnings 0",
      "bash -c 'if grep -n \": any\\|<any>\\|any\\[\\]\\|as any\" \"$0\"; then echo \"Error: any types found\"; exit 1; fi'"
    ]
  },
  "scripts": {
    "prepare": "husky install"
  }
}
```

---

## Option 3: ESLint Rule Update (Strictest)

Update `.eslintrc.json` or `.eslintrc.js`:

```json
{
  "rules": {
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/no-unsafe-assignment": "warn",
    "@typescript-eslint/no-unsafe-member-access": "warn",
    "@typescript-eslint/no-unsafe-call": "warn",
    "@typescript-eslint/no-unsafe-return": "warn"
  }
}
```

---

## Option 4: CI/CD Integration

### GitHub Actions Example

Create `.github/workflows/lint.yml`:

```yaml
name: Lint Check

on:
  pull_request:
    branches: [ main, master ]
  push:
    branches: [ main, master ]

jobs:
  lint:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'

    - name: Install dependencies
      run: npm ci

    - name: Run ESLint
      run: npm run lint

    - name: Check for any types
      run: |
        if grep -r ": any\|<any>\|any\[\]\|as any" src/ --include="*.ts" --include="*.tsx"; then
          echo "Error: TypeScript 'any' types found"
          exit 1
        fi
        echo "✅ No 'any' types found"
```

---

## Testing the Hook

1. **Create a test file with 'any':**
```bash
echo "const test: any = 'fail';" > test-hook.ts
git add test-hook.ts
git commit -m "Test hook"
```

Expected: Commit should be rejected ❌

2. **Fix and retry:**
```bash
echo "const test: unknown = 'pass';" > test-hook.ts
git add test-hook.ts
git commit -m "Test hook"
```

Expected: Commit should succeed ✅

3. **Cleanup:**
```bash
git reset HEAD~1
rm test-hook.ts
```

---

## Bypassing the Hook (Emergency Only)

If you absolutely must commit with `any` types:

```bash
git commit --no-verify -m "Emergency fix (will address types later)"
```

**⚠️ Warning:** Use sparingly and create a follow-up issue to fix the types!

---

## Worktree-Specific Setup Script

Create `setup-hooks-all-worktrees.sh`:

```bash
#!/bin/bash

# Setup pre-commit hooks for all worktrees

MAIN_REPO="C:/github-claude/calculator-website-test"
HOOK_FILE="$MAIN_REPO/.git/hooks/pre-commit"

# Ensure main hook exists
if [ ! -f "$HOOK_FILE" ]; then
  echo "Error: Main pre-commit hook not found at $HOOK_FILE"
  echo "Please create it first (see Option 1 above)"
  exit 1
fi

# Get all worktree paths
git worktree list | tail -n +2 | while read -r line; do
  WORKTREE_PATH=$(echo "$line" | awk '{print $1}')

  if [ -d "$WORKTREE_PATH/.git" ]; then
    # Regular worktree with .git directory
    WORKTREE_HOOK="$WORKTREE_PATH/.git/hooks/pre-commit"
  elif [ -f "$WORKTREE_PATH/.git" ]; then
    # Worktree with .git file (linked worktree)
    GIT_DIR=$(cat "$WORKTREE_PATH/.git" | sed 's/gitdir: //')
    WORKTREE_HOOK="$GIT_DIR/hooks/pre-commit"
  else
    echo "Skipping $WORKTREE_PATH (no .git found)"
    continue
  fi

  # Create hooks directory if it doesn't exist
  mkdir -p "$(dirname "$WORKTREE_HOOK")"

  # Copy the hook
  cp "$HOOK_FILE" "$WORKTREE_HOOK"
  chmod +x "$WORKTREE_HOOK"

  echo "✅ Installed hook for: $WORKTREE_PATH"
done

echo ""
echo "✅ All worktrees configured!"
```

Make it executable and run:
```bash
chmod +x setup-hooks-all-worktrees.sh
./setup-hooks-all-worktrees.sh
```

---

## Recommended Approach

**For individual developers:**
- Use **Option 1** (Manual Git Hook) - Simple and effective

**For teams:**
- Use **Option 2** (Husky + lint-staged) - Consistent across team
- Plus **Option 4** (CI/CD) - Catch anything that slips through

**For maximum safety:**
- Combine **all options** - Defense in depth!

---

## Troubleshooting

### Hook not running?
```bash
# Check if hook is executable
ls -la .git/hooks/pre-commit

# Make it executable if needed
chmod +x .git/hooks/pre-commit
```

### Hook running but not catching errors?
```bash
# Test the grep pattern manually
grep -n ': any\|<any>\|any\[\]\|as any' your-file.ts
```

### Want to see what the hook checks?
```bash
# Run the hook manually
.git/hooks/pre-commit
```

---

## Summary

✅ **Prevents new `any` types** from being committed
✅ **Maintains code quality** automatically
✅ **Works with worktrees** when set up correctly
✅ **Team-friendly** with proper tooling
✅ **CI/CD ready** for additional safety

Choose the option that best fits your workflow!
