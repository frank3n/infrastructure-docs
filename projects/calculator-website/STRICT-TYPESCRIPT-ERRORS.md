# Strict TypeScript Errors - Fix Plan

**Date:** December 8, 2025
**Total Errors:** 32
**Status:** Analysis Complete, Ready to Fix

---

## Error Summary

### Category Breakdown
- ❌ Unused imports: 3 errors (FIXED)
- ⚠️  Possibly undefined: 12 errors
- ⚠️  Type mismatches: 4 errors
- ⚠️  Missing index signatures: 6 errors
- ⚠️  Missing override modifier: 1 error
- ⚠️  Private property conflict: 3 errors
- ⚠️  Undefined as index: 4 errors

---

## ✅ FIXED: Unused Imports (3 errors)

### src/App.tsx
```typescript
// FIXED: Removed unused React import
-import React from 'react'
+// Removed (not needed with new JSX transform)
```

### src/services/deepl.ts
```typescript
// FIXED: Removed unused TranslationRequest import
-import { Translation, TranslationRequest } from './types'
+import { Translation } from './types'
```

### src/components/shared/Input.tsx
```typescript
// FIXED: Removed unused 't' variable
-const { t } = useTranslation()
+// Removed
```

---

## ⚠️  TO FIX: UnitConverter Issues (14 errors)

**File:** `src/calculators/conversion/UnitConverter/index.tsx`

### Problem 1: Temperature type mismatch (Lines 36-38)
```typescript
// CURRENT (incorrect - strings in number Record)
temperature: {
  c: 'celsius',    // ❌ Type 'string' not assignable to 'number'
  f: 'fahrenheit', // ❌ Type 'string' not assignable to 'number'
  k: 'kelvin',     // ❌ Type 'string' not assignable to 'number'
},
```

**Fix:**
```typescript
// Option A: Separate temperature from numeric conversions
const numericConversionRates: Record<string, Record<string, number>> = {
  length: { /*...*/ },
  weight: { /*...*/ },
  volume: { /*...*/ },
}

const temperatureUnits = ['c', 'f', 'k'] as const
```

### Problem 2: Possibly undefined rates (Lines 60-62)
```typescript
// CURRENT
const rates = conversionRates[category]  // ❌ Could be undefined
const baseValue = value / rates[from]     // ❌ rates possibly undefined
return baseValue * rates[to]              // ❌ rates possibly undefined
```

**Fix:**
```typescript
const rates = conversionRates[category]
if (!rates) {
  throw new Error(`Unknown category: ${category}`)
}
const baseValue = value / rates[from]
return baseValue * rates[to]
```

### Problem 3: Unsafe array access (Lines 117-118, 153, 160)
```typescript
// CURRENT
const units = Object.keys(conversionRates[category])  // ❌ Could be undefined
return units.map(/*...*/)                              // ❌ Could be undefined
```

**Fix:**
```typescript
const rates = conversionRates[category]
if (!rates) return []
const units = Object.keys(rates)
return units.map(/*...*/)
```

---

## ⚠️  TO FIX: Calculator Input Type Issues (6 errors)

**Files:**
- `src/calculators/date/AgeCalculator/index.tsx`
- `src/calculators/financial/LoanCalculator/index.tsx`
- `src/calculators/financial/MortgageCalculator/index.tsx`
- `src/calculators/financial/TipCalculator/index.tsx`
- `src/calculators/health/BMICalculator/index.tsx`
- `src/calculators/health/CalorieCalculator/index.tsx`

### Problem: Interfaces don't satisfy Record<string, unknown>
```typescript
// CURRENT
interface LoanInputs {
  principal: number
  rate: number
  years: number
}

const calculator = useCalculator<LoanInputs>({  // ❌ Missing index signature
  principal: 10000,
  rate: 5,
  years: 10,
})
```

**Fix Option A: Add index signature**
```typescript
interface LoanInputs {
  principal: number
  rate: number
  years: number
  [key: string]: unknown  // ✅ Allow additional properties
}
```

**Fix Option B: Update useCalculator to not require index signature**
```typescript
// In hooks/useCalculator.ts
export function useCalculator<T extends Record<string, unknown>>(
  // Change to:
export function useCalculator<T>(
```

---

## ⚠️  TO FIX: DeepL Service Issues (4 errors)

**File:** `src/services/deepl.ts`

### Problem: Using undefined as index (Lines 101, 102, 104, 107)
```typescript
// CURRENT
const cacheKey = `${sourceLang}-${targetLang}`  // ❌ targetLang could be undefined
if (cache[cacheKey]) {                           // ❌ Using undefined as index
  return cache[cacheKey][text]                   // ❌ Multiple undefined usages
}
```

**Fix:**
```typescript
if (!targetLang) {
  targetLang = 'en'  // Default target language
}

const cacheKey = `${sourceLang}-${targetLang}`
if (cache[cacheKey]) {
  return cache[cacheKey]?.[text]
}
```

---

## ⚠️  TO FIX: Embed Loader Issues (4 errors)

**File:** `src/embed/embed-loader.ts`

### Problem 1: shadowRoot private property conflict
```typescript
// CURRENT
class CalcWidget extends HTMLElement {
  private shadowRoot: ShadowRoot  // ❌ Conflicts with HTMLElement.shadowRoot
```

**Fix:**
```typescript
class CalcWidget extends HTMLElement {
  private _shadowRoot: ShadowRoot  // ✅ Use different name

  connectedCallback() {
    this._shadowRoot = this.attachShadow({ mode: 'open' })
  }
}
```

### Problem 2: Missing override modifier
```typescript
// CURRENT
connectedCallback() {  // ❌ Missing 'override' keyword
```

**Fix:**
```typescript
override connectedCallback(): void {  // ✅ Add override
```

---

## ⚠️  TO FIX: AgeCalculator Issue (1 error)

**File:** `src/calculators/date/AgeCalculator/index.tsx`

### Problem: birthDate could be undefined (Line 68)
```typescript
// CURRENT
const calculator = useCalculator<AgeInputs>({
  birthDate: birthDateStr,  // ❌ string | undefined not assignable to string
})
```

**Fix:**
```typescript
const calculator = useCalculator<AgeInputs>({
  birthDate: birthDateStr || new Date().toISOString().split('T')[0],
})
```

---

## ⚠️  TO FIX: CalorieCalculator Issue (1 error)

**File:** `src/calculators/health/CalorieCalculator/index.tsx`

### Problem: activityFactors possibly undefined (Line 44)
```typescript
// CURRENT
const label = activityFactors[value].label  // ❌ Could be undefined
```

**Fix:**
```typescript
const label = activityFactors[value]?.label || value
```

---

## 🔧 Automated Fix Script

```bash
#!/bin/bash
# fix-all-strict-errors.sh

echo "Fixing strict TypeScript errors..."

# 1. Fix UnitConverter - separate temperature
cat > src/calculators/conversion/UnitConverter/types.ts << 'EOF'
export const numericConversionRates: Record<string, Record<string, number>> = {
  length: {
    m: 1,
    km: 0.001,
    cm: 100,
    mm: 1000,
    mi: 0.000621371,
    yd: 1.09361,
    ft: 3.28084,
    in: 39.3701,
  },
  weight: {
    kg: 1,
    g: 1000,
    mg: 1000000,
    lb: 2.20462,
    oz: 35.274,
    ton: 0.001,
  },
  volume: {
    l: 1,
    ml: 1000,
    gal: 0.264172,
    qt: 1.05669,
    pt: 2.11338,
    cup: 4.22675,
    floz: 33.814,
  },
}
EOF

# 2. Fix calculator interfaces - add index signatures
find src/calculators -name "index.tsx" -exec sed -i '/^interface.*Inputs {/a\  [key: string]: unknown' {} \;

# 3. Fix embed loader - rename shadowRoot
sed -i 's/private shadowRoot/private _shadowRoot/g' src/embed/embed-loader.ts
sed -i 's/this\.shadowRoot/this._shadowRoot/g' src/embed/embed-loader.ts
sed -i 's/connectedCallback()/override connectedCallback(): void/' src/embed/embed-loader.ts

echo "✅ Automated fixes complete"
echo "⚠️  Manual fixes required for:"
echo "   - UnitConverter logic"
echo "   - DeepL service"
echo "   - Null checks"
```

---

## 📊 Fix Priority

### High Priority (Breaking Changes)
1. **UnitConverter** - Type system broken, needs refactor
2. **Embed Loader** - Won't compile, blocks build
3. **DeepL Service** - Runtime errors likely

### Medium Priority (Safety Issues)
4. **Calculator interfaces** - Type safety compromised
5. **Null checks** - Potential runtime errors

### Low Priority (Code Quality)
6. **Unused imports** - Already fixed

---

## 🎯 Recommended Approach

### Option A: Automated + Manual (Recommended)
1. Run automated script for simple fixes
2. Manually fix complex issues (UnitConverter, DeepL)
3. Test thoroughly
4. **Time:** 1-2 hours

### Option B: All Manual
1. Fix each error individually with careful review
2. More control, better understanding
3. **Time:** 2-3 hours

### Option C: Disable Some Strict Options (Not Recommended)
1. Keep most strict options
2. Disable `noUncheckedIndexedAccess` temporarily
3. Fix gradually
4. **Time:** 30 minutes initial, ongoing fixes

---

## ✅ Testing Checklist

After fixes:
- [ ] `npx tsc --noEmit` - 0 errors
- [ ] `npm run lint` - 0 errors
- [ ] `npm run build` - succeeds
- [ ] `npm test` - all pass
- [ ] Manual testing of:
  - [ ] Unit Converter (all categories)
  - [ ] Age Calculator
  - [ ] Calorie Calculator
  - [ ] Embed widgets
  - [ ] DeepL translations

---

**Status:** Ready to implement fixes
**Next Step:** Run automated fixes, then manual fixes
**Estimated Time:** 1-2 hours total
