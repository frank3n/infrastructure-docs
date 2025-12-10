# Fix all remaining TypeScript errors in coolcation-calculator
$branchPath = "C:\github-claude\calculator-website-test\claude\coolcation-calculator-feature-011CV5qSqYUYdvwJ5bpua7ph"

Write-Host "Fixing all remaining TypeScript errors in coolcation-calculator..." -ForegroundColor Cyan

$filesToFix = @(
    "src\calculators\travel\CoolcationCalculator\api.ts",
    "src\calculators\travel\CoolcationCalculator\index.tsx",
    "src\components\coolcation\CollectionsManager.tsx",
    "src\hooks\useDestinationReviews.ts",
    "src\hooks\useSavedSearches.ts"
)

$totalFixed = 0

foreach ($file in $filesToFix) {
    $filePath = Join-Path $branchPath $file

    if (Test-Path $filePath) {
        Write-Host "`nProcessing: $file" -ForegroundColor Yellow

        $content = Get-Content $filePath -Raw
        $originalContent = $content

        # Replace various any patterns
        # Function parameters
        $content = $content -replace '\(([a-zA-Z_]\w*):\s*any\)', '($1: unknown)'

        # Array types
        $content = $content -replace ':\s*any\[\]', ': unknown[]'

        # Generic types
        $content = $content -replace '<any>', '<unknown>'

        # Record types
        $content = $content -replace 'Record<([^,>]+),\s*any>', 'Record<$1, unknown>'

        # Map functions and callbacks
        $content = $content -replace '\.map\(\(([a-zA-Z_]\w*):\s*any\)', '.map(($1: unknown)'
        $content = $content -replace '\.filter\(\(([a-zA-Z_]\w*):\s*any\)', '.filter(($1: unknown)'
        $content = $content -replace '\.forEach\(\(([a-zA-Z_]\w*):\s*any\)', '.forEach(($1: unknown)'

        # Function type annotations
        $content = $content -replace '\(\)\s*=>\s*any', '() => unknown'

        # Variable declarations
        $content = $content -replace '(const|let|var)\s+([a-zA-Z_]\w*):\s*any(\s*=)', '$1 $2: unknown$3'

        # As any casts
        $content = $content -replace '\s+as\s+any\b', ' as unknown'

        # Type annotations in general
        $content = $content -replace ':\s*any\b(?!\[|\])', ': unknown'

        # Count changes
        $changes = 0
        if ($content -ne $originalContent) {
            $changes = ([regex]::Matches($originalContent, '\bany\b')).Count - ([regex]::Matches($content, '\bany\b')).Count

            # Write the fixed content
            $content | Set-Content $filePath -NoNewline
            Write-Host "  Fixed $changes 'any' type(s)" -ForegroundColor Green
            $totalFixed += $changes
        } else {
            Write-Host "  No changes needed" -ForegroundColor Gray
        }
    } else {
        Write-Host "  File not found: $filePath" -ForegroundColor Red
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Total 'any' types fixed: $totalFixed" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

# Run lint to check remaining errors
Write-Host "Running lint to check remaining errors..." -ForegroundColor Cyan
Set-Location $branchPath
$lintOutput = npm run lint 2>&1
$errorCount = ($lintOutput | Select-String "@typescript-eslint/no-explicit-any" | Measure-Object).Count

Write-Host "`nRemaining 'any' type errors: $errorCount" -ForegroundColor $(if ($errorCount -eq 0) { 'Green' } else { 'Yellow' })
