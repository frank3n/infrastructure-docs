# TypeDoc Documentation Setup

Automated TypeScript API documentation generation using TypeDoc.

## Overview

TypeDoc automatically generates comprehensive documentation from your TypeScript code, JSDoc comments, and type annotations.

**Benefits:**
- 📚 Auto-generated API documentation
- 🔍 Search functionality
- 🔗 Cross-referenced types and functions
- 📱 Mobile-friendly output
- ⚡ Integrates with CI/CD

## Quick Start

### 1. Install TypeDoc

```bash
npm install --save-dev typedoc
```

### 2. Generate Documentation

```bash
# Generate docs locally
npm run docs:generate

# Generate and open in browser
npm run docs:open

# Watch mode (regenerate on file changes)
npm run docs:watch
```

### 3. View Documentation

Open `docs/api/index.html` in your browser.

## Configuration

### typedoc.json

The project includes a pre-configured `typedoc.json` file:

```json
{
  "entryPoints": ["src", "types", "api/src"],
  "out": "docs/api",
  "exclude": ["**/node_modules/**", "**/dist/**", "**/*.test.ts"],
  "excludePrivate": true,
  "name": "Calculator Website API Documentation"
}
```

### Customize

Edit `typedoc.json` to adjust:

- **Entry points**: Which directories to document
- **Output directory**: Where to generate docs
- **Exclusions**: Files to skip
- **Theme**: Visual appearance
- **Plugins**: Additional features

## Writing Documentation

### JSDoc Comments

TypeDoc reads JSDoc comments to generate rich documentation:

```typescript
/**
 * Calculate the compound interest for an investment
 *
 * @param principal - Initial investment amount
 * @param rate - Annual interest rate (as decimal, e.g., 0.05 for 5%)
 * @param time - Investment period in years
 * @param frequency - Compounding frequency per year
 *
 * @returns The future value of the investment
 *
 * @example
 * ```typescript
 * const futureValue = calculateCompoundInterest(1000, 0.05, 10, 12);
 * console.log(futureValue); // 1647.01
 * ```
 *
 * @see {@link https://en.wikipedia.org/wiki/Compound_interest}
 *
 * @category Financial
 * @public
 */
export function calculateCompoundInterest(
  principal: number,
  rate: number,
  time: number,
  frequency: number
): number {
  return principal * Math.pow(1 + rate / frequency, frequency * time);
}
```

### Key JSDoc Tags

| Tag | Purpose | Example |
|-----|---------|---------|
| `@param` | Document parameters | `@param principal - Initial amount` |
| `@returns` | Document return value | `@returns The calculated value` |
| `@example` | Show usage examples | `@example const x = foo(1, 2);` |
| `@see` | Reference related items | `@see {@link OtherFunction}` |
| `@category` | Group related items | `@category Calculators` |
| `@public` / `@private` | Visibility | `@public` |
| `@deprecated` | Mark as deprecated | `@deprecated Use newFunction instead` |
| `@throws` | Document exceptions | `@throws {Error} If value is negative` |
| `@since` | Version added | `@since 2.0.0` |

### Markdown in Comments

JSDoc comments support full markdown:

```typescript
/**
 * ## Overview
 *
 * This function performs **complex calculations** with the following features:
 *
 * - Fast performance
 * - Type-safe inputs
 * - Error handling
 *
 * ### Algorithm
 *
 * Uses the [Black-Scholes model](https://example.com) for option pricing:
 *
 * ```
 * C = S₀N(d₁) - Ke^(-rt)N(d₂)
 * ```
 *
 * @param options - Configuration object
 */
```

## Categories and Organization

### Using @category

Group related items with `@category`:

```typescript
/**
 * @category Calculators/Financial
 */
export function calculateLoan() { ... }

/**
 * @category Calculators/Financial
 */
export function calculateMortgage() { ... }

/**
 * @category Calculators/Health
 */
export function calculateBMI() { ... }
```

### Using @group

Organize within a module:

```typescript
/**
 * @group Input Validation
 */
export function validateNumber() { ... }

/**
 * @group Input Validation
 */
export function validateDate() { ... }

/**
 * @group Formatting
 */
export function formatCurrency() { ... }
```

## Package.json Scripts

Add these scripts to `package.json`:

```json
{
  "scripts": {
    "docs:generate": "typedoc",
    "docs:watch": "typedoc --watch",
    "docs:open": "typedoc && open docs/api/index.html",
    "docs:clean": "rm -rf docs/api",
    "docs:validate": "typedoc --emit none --treatWarningsAsErrors"
  }
}
```

## CI/CD Integration

### GitHub Actions Workflow

Create `.github/workflows/docs.yml`:

```yaml
name: Documentation

on:
  push:
    branches: [ main, master ]
  workflow_dispatch:

jobs:
  generate-docs:
    name: Generate TypeDoc Documentation
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
        cache: 'npm'

    - name: Install dependencies
      run: npm ci

    - name: Install TypeDoc
      run: npm install --save-dev typedoc

    - name: Generate documentation
      run: npm run docs:generate

    - name: Upload documentation
      uses: actions/upload-artifact@v3
      with:
        name: api-documentation
        path: docs/api/

    - name: Deploy to GitHub Pages (optional)
      uses: peaceiris/actions-gh-pages@v3
      if: github.ref == 'refs/heads/main'
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: ./docs/api
```

### Publish to GitHub Pages

1. **Enable GitHub Pages** in repository settings
2. **Set source** to `gh-pages` branch
3. **Push to main** - docs auto-deploy
4. **Access docs** at `https://your-org.github.io/calculator-website/`

## Advanced Features

### Custom Theme

```bash
npm install --save-dev typedoc-theme-hierarchy
```

Update `typedoc.json`:
```json
{
  "theme": "hierarchy"
}
```

### Plugins

Popular TypeDoc plugins:

```bash
# Markdown plugin for enhanced formatting
npm install --save-dev typedoc-plugin-markdown

# Mermaid diagrams
npm install --save-dev typedoc-plugin-mermaid

# Search enhancement
npm install --save-dev typedoc-plugin-pages
```

Update `typedoc.json`:
```json
{
  "plugin": [
    "typedoc-plugin-markdown",
    "typedoc-plugin-mermaid"
  ]
}
```

### Link to GitHub Source

Update `typedoc.json`:
```json
{
  "sourceLinkTemplate": "https://github.com/YOUR_ORG/calculator-website/blob/{gitRevision}/{path}#L{line}"
}
```

This adds "View Source" links to GitHub.

## Best Practices

### 1. Document Public APIs

```typescript
// ✅ Good - Public function is documented
/**
 * Calculate monthly payment for a loan
 * @param amount - Loan amount
 * @returns Monthly payment amount
 */
export function calculatePayment(amount: number): number { ... }

// ✅ Good - Private helper doesn't need extensive docs
function validateInput(x: number): boolean { ... }
```

### 2. Include Examples

```typescript
/**
 * @example
 * ```typescript
 * const result = calculateTax(1000, 0.08);
 * console.log(result); // 1080
 * ```
 */
```

### 3. Use Descriptive Names

```typescript
// ❌ Bad
/** Calculate it */
export function calc(x: number, y: number): number { ... }

// ✅ Good
/** Calculate compound interest on an investment */
export function calculateCompoundInterest(
  principal: number,
  rate: number
): number { ... }
```

### 4. Link Related Items

```typescript
/**
 * Calculate monthly loan payment
 *
 * @see {@link calculateTotalInterest} for total interest calculation
 * @see {@link LoanOptions} for available options
 */
```

### 5. Mark Deprecations

```typescript
/**
 * @deprecated Use {@link calculatePaymentV2} instead
 */
export function calculatePayment(amount: number): number { ... }
```

## Common Patterns

### Interface Documentation

```typescript
/**
 * Configuration options for the calculator
 *
 * @example
 * ```typescript
 * const options: CalculatorOptions = {
 *   precision: 2,
 *   currency: 'USD'
 * };
 * ```
 */
export interface CalculatorOptions {
  /**
   * Number of decimal places for results
   * @defaultValue 2
   */
  precision?: number;

  /**
   * Currency code for formatting
   * @defaultValue 'USD'
   */
  currency?: string;

  /**
   * Enable debug mode
   * @defaultValue false
   */
  debug?: boolean;
}
```

### Type Alias Documentation

```typescript
/**
 * Represents a calculation result with metadata
 *
 * @example
 * ```typescript
 * const result: CalculationResult = {
 *   value: 1234.56,
 *   timestamp: Date.now(),
 *   source: 'user-input'
 * };
 * ```
 */
export type CalculationResult = {
  /** The calculated numeric value */
  value: number;

  /** When the calculation was performed */
  timestamp: number;

  /** Source of the calculation inputs */
  source: 'user-input' | 'api' | 'default';
};
```

### React Component Documentation

```typescript
/**
 * Calculator input component with validation
 *
 * @example
 * ```tsx
 * <CalculatorInput
 *   label="Principal Amount"
 *   value={principal}
 *   onChange={setPrincipal}
 *   min={0}
 *   max={1000000}
 * />
 * ```
 *
 * @category Components
 */
export function CalculatorInput(props: CalculatorInputProps) { ... }

/**
 * Props for {@link CalculatorInput}
 */
export interface CalculatorInputProps {
  /** Input field label */
  label: string;

  /** Current input value */
  value: number;

  /** Callback when value changes */
  onChange: (value: number) => void;

  /** Minimum allowed value */
  min?: number;

  /** Maximum allowed value */
  max?: number;
}
```

### Hook Documentation

```typescript
/**
 * React hook for managing calculation history
 *
 * Provides functions to save, load, and clear calculation history
 * with automatic persistence to localStorage.
 *
 * @example
 * ```typescript
 * function Calculator() {
 *   const { history, saveCalculation, clearHistory } = useCalculationHistory();
 *
 *   const handleCalculate = (result: number) => {
 *     saveCalculation({ value: result, timestamp: Date.now() });
 *   };
 *
 *   return <div>History: {history.length} items</div>;
 * }
 * ```
 *
 * @category Hooks
 */
export function useCalculationHistory() { ... }
```

## Validation

### Check Documentation Coverage

```bash
# Generate docs and check for warnings
npm run docs:validate

# Treat warnings as errors
npx typedoc --treatWarningsAsErrors
```

### Required Documentation

In `typedoc.json`:
```json
{
  "validation": {
    "notExported": true,
    "invalidLink": true,
    "notDocumented": false
  },
  "requiredToBeDocumented": [
    "Function",
    "Class",
    "Interface",
    "TypeAlias"
  ]
}
```

## Troubleshooting

### Issue: Documentation not generating

**Solution:**
```bash
# Clean output directory
npm run docs:clean

# Reinstall TypeDoc
npm install --save-dev typedoc

# Generate with verbose logging
npx typedoc --logLevel Verbose
```

### Issue: Types not resolving

**Solution:** Ensure `tsconfig.json` is configured correctly:
```json
{
  "compilerOptions": {
    "declaration": true,
    "declarationMap": true
  }
}
```

### Issue: Private types appearing

**Solution:** Update `typedoc.json`:
```json
{
  "excludePrivate": true,
  "excludeInternal": true
}
```

## Examples in This Project

### Well-documented modules:

1. **`types/utils.ts`** - Comprehensive utility types with examples
2. **`src/calculators/trading/utils/history.ts`** - Calculation history management
3. **`src/hooks/useCollections.ts`** - React hook with full documentation

### Review these for documentation patterns to follow.

## Next Steps

1. **Generate initial docs**: `npm run docs:generate`
2. **Review output**: Open `docs/api/index.html`
3. **Add JSDoc comments**: Document public APIs
4. **Set up CI/CD**: Use GitHub Actions workflow
5. **Publish**: Deploy to GitHub Pages

## Resources

- [TypeDoc Official Documentation](https://typedoc.org/)
- [JSDoc Reference](https://jsdoc.app/)
- [TSDoc Standard](https://tsdoc.org/)
- [TypeDoc Themes](https://www.npmjs.com/search?q=keywords:typedoc-theme)
- [TypeDoc Plugins](https://www.npmjs.com/search?q=keywords:typedoc-plugin)

## Maintenance

- **Weekly**: Review newly added APIs for documentation
- **Before releases**: Regenerate and publish docs
- **Monthly**: Check for broken links and outdated examples
- **Quarterly**: Update examples and add new categories

---

**Status**: Ready to use
**Estimated setup time**: 15-30 minutes
**Maintenance**: Minimal (automatic with CI/CD)
