# React Hooks Fix Guide

**Target:** Fix 1 `react-hooks/rules-of-hooks` error
**Time Required:** 10-15 minutes
**Difficulty:** Easy - clear solution

---

## The Problem

### Error: `react-hooks/rules-of-hooks`

**Location:** `src/pages/CalculatorPage.tsx` (line 40)

**Error Message:**
```
React Hook "useSEO" is called conditionally. React Hooks must be called in the exact same order in every component render. Did you accidentally call a React Hook after an early return?
```

---

## What This Means

React Hooks (like `useState`, `useEffect`, `useSEO`, etc.) MUST be called:
- In the same order every render
- NOT inside conditions
- NOT inside loops
- NOT after early returns

### Why This Rule Exists

React tracks hooks by call order. If you call hooks conditionally, the order changes between renders, causing bugs.

```typescript
// BAD - Hook order changes based on condition
function MyComponent({ user }) {
    if (!user) return null;  // Early return
    useEffect(() => { ... });  // Sometimes called, sometimes not!
}

// GOOD - Hooks always called in same order
function MyComponent({ user }) {
    useEffect(() => {
        if (!user) return;  // Condition inside hook
        // ...
    }, [user]);

    if (!user) return null;
}
```

---

## Finding the Error

### Step 1: Locate the File

```powershell
cd C:\github-claude\calculator-website-test\claude\<branch-with-error>
```

### Step 2: Open the File

```powershell
code src/pages/CalculatorPage.tsx
# Or use any text editor
```

### Step 3: Find Line 40

Look for code like:

```typescript
function CalculatorPage() {
    const calculator = useCalculator();

    if (!calculator) {
        return <div>Loading...</div>;  // Early return
    }

    useSEO(calculator);  // ❌ Hook called after early return!

    return <div>...</div>;
}
```

---

## The Fix

### Option 1: Move Hook Before Early Return

```typescript
// Before
function CalculatorPage() {
    const calculator = useCalculator();

    if (!calculator) {
        return <div>Loading...</div>;
    }

    useSEO(calculator);  // ❌ Called conditionally

    return <div>...</div>;
}

// After
function CalculatorPage() {
    const calculator = useCalculator();

    useSEO(calculator || defaultCalculator);  // ✅ Always called

    if (!calculator) {
        return <div>Loading...</div>;
    }

    return <div>...</div>;
}
```

### Option 2: Provide Default Value

```typescript
// Create a default/empty calculator for SEO
const defaultCalculator = {
    name: 'Loading...',
    description: 'Calculator loading',
    // ... other required fields
};

function CalculatorPage() {
    const calculator = useCalculator();

    // Always call hook with default fallback
    useSEO(calculator ?? defaultCalculator);  // ✅ Always called

    if (!calculator) {
        return <div>Loading...</div>;
    }

    return <div>...</div>;
}
```

### Option 3: Handle Inside the Hook

If you control the `useSEO` hook, make it handle null values:

```typescript
// Inside useSEO hook
function useSEO(calculator) {
    useEffect(() => {
        if (!calculator) return;  // Handle null case inside

        // Set SEO meta tags
        document.title = calculator.name;
        // ...
    }, [calculator]);
}

// In component
function CalculatorPage() {
    const calculator = useCalculator();

    useSEO(calculator);  // ✅ Always called, handles null internally

    if (!calculator) {
        return <div>Loading...</div>;
    }

    return <div>...</div>;
}
```

---

## Complete Example Fix

### Before (Error)

```typescript
import { useSEO } from '../hooks/useSEO';
import { useCalculator } from '../hooks/useCalculator';

function CalculatorPage() {
    const calculator = useCalculator();

    // Early return
    if (!calculator) {
        return <div>Loading calculator...</div>;
    }

    // ❌ Hook called after early return
    useSEO({
        title: calculator.name,
        description: calculator.description,
    });

    return (
        <div>
            <h1>{calculator.name}</h1>
            {/* ... rest of component */}
        </div>
    );
}

export default CalculatorPage;
```

### After (Fixed)

```typescript
import { useSEO } from '../hooks/useSEO';
import { useCalculator } from '../hooks/useCalculator';

// Default values for SEO when calculator is loading
const DEFAULT_SEO = {
    title: 'Calculator - Loading...',
    description: 'Loading calculator information',
};

function CalculatorPage() {
    const calculator = useCalculator();

    // ✅ Hook always called before any return
    useSEO({
        title: calculator?.name || DEFAULT_SEO.title,
        description: calculator?.description || DEFAULT_SEO.description,
    });

    // Now safe to return early
    if (!calculator) {
        return <div>Loading calculator...</div>;
    }

    return (
        <div>
            <h1>{calculator.name}</h1>
            {/* ... rest of component */}
        </div>
    );
}

export default CalculatorPage;
```

---

## Step-by-Step Fix Process

### 1. Create a Fix Log

```powershell
$timestamp = Get-Date -Format 'yyyy-MM-dd-HHmm'
New-Item "C:\github-claude\calculator-website-documentation\fix-logs\manual-fixes\react-hooks-fix-$timestamp.md"
```

### 2. Locate and Edit File

```powershell
cd C:\github-claude\calculator-website-test\claude\<branch>
code src/pages/CalculatorPage.tsx
```

### 3. Apply Fix

Add default SEO values and move `useSEO` before early return.

### 4. Verify

```powershell
npm run lint
```

Expected result:
```
Before: 1 error (react-hooks/rules-of-hooks)
After: 0 errors from this rule
```

### 5. Test

```powershell
npm run dev
```

Visit the page and verify:
- Page loads correctly
- SEO meta tags are set
- No console errors

### 6. Document

```markdown
# React Hooks Fix - [timestamp]

## File Changed
`src/pages/CalculatorPage.tsx`

## Error Before
Line 40: React Hook "useSEO" is called conditionally

## Fix Applied
Moved `useSEO` call before early return with default fallback values

## Verification
- ✅ Lint passes
- ✅ Page loads correctly
- ✅ SEO meta tags working

## Time Spent
10 minutes
```

### 7. Commit (Optional)

```powershell
git add src/pages/CalculatorPage.tsx
git commit -m "fix(hooks): Move useSEO call before early return

Fixes react-hooks/rules-of-hooks violation by ensuring
useSEO is always called in the same order.

Added DEFAULT_SEO fallback for loading state."
```

---

## Verification Checklist

After fixing:
- [ ] Run `npm run lint` - should pass
- [ ] Run `npm run build` - should compile
- [ ] Run `npm run dev` - should start
- [ ] Visit page in browser - should load
- [ ] Check console - no React warnings
- [ ] Check page source - SEO tags present
- [ ] Document fix in log file

---

## Common Mistakes to Avoid

### ❌ Don't Wrap Hook in Condition

```typescript
// WRONG
if (calculator) {
    useSEO(calculator);  // Still conditional!
}
```

### ❌ Don't Move Hook Inside useEffect

```typescript
// WRONG
useEffect(() => {
    useSEO(calculator);  // Hooks can't be called inside hooks!
}, [calculator]);
```

### ✅ Do Provide Defaults

```typescript
// CORRECT
useSEO(calculator || defaultValue);
```

### ✅ Do Handle Null Inside Hook

```typescript
// CORRECT - if you control the hook
function useSEO(data) {
    useEffect(() => {
        if (!data) return;
        // ... set SEO
    }, [data]);
}
```

---

## Related Resources

- [React Hooks Rules](https://react.dev/reference/rules/rules-of-hooks)
- [ESLint Plugin React Hooks](https://www.npmjs.com/package/eslint-plugin-react-hooks)

---

## Expected Impact

- **Errors Fixed:** 1
- **Time Required:** 10-15 minutes
- **Difficulty:** Easy
- **Risk:** Low - clear fix pattern

---

**Status:** Ready to implement
**Next:** After fixing, verify and document
