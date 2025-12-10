# Fix TypeScript 'any' errors in coolcation-calculator branch
$branchPath = "C:\github-claude\calculator-website-test\claude\coolcation-calculator-feature-011CV5qSqYUYdvwJ5bpua7ph"

Write-Host "Fixing TypeScript errors in coolcation-calculator branch..." -ForegroundColor Cyan

# Files to fix
$filesToFix = @(
    "src\hooks\useCollections.ts",
    "src\hooks\useDestinationReviews.ts",
    "src\hooks\useSavedSearches.ts",
    "src\components\auth\AuthModal.tsx",
    "src\components\coolcation\AddToCollectionButton.tsx",
    "src\components\coolcation\CollectionsManager.tsx",
    "src\components\coolcation\SavedSearches.tsx",
    "src\components\reviews\ReviewForm.tsx",
    "src\calculators\travel\CoolcationCalculator\api.ts",
    "src\calculators\travel\CoolcationCalculator\index.tsx"
)

$totalFixed = 0

foreach ($file in $filesToFix) {
    $filePath = Join-Path $branchPath $file

    if (Test-Path $filePath) {
        Write-Host "`nProcessing: $file" -ForegroundColor Yellow

        $content = Get-Content $filePath -Raw
        $originalContent = $content

        # Replace err: any with err: unknown in catch blocks
        $content = $content -replace '(\bcatch\s*\(\s*\w+)\s*:\s*any\s*\)', '$1: unknown)'

        # Replace error: any with error: unknown
        $content = $content -replace '(\berror)\s*:\s*any\b', '$1: unknown'

        # Replace data: any with data: unknown
        $content = $content -replace '(\bdata)\s*:\s*any\b', '$1: unknown'

        # Replace const/let variable: any with proper unknown type
        $content = $content -replace '(const|let)\s+(\w+)\s*:\s*any\s*=', '$1 $2: Record<string, unknown> ='

        # Count changes
        $changes = 0
        if ($content -ne $originalContent) {
            $changes = ([regex]::Matches($originalContent, ': any\b')).Count - ([regex]::Matches($content, ': any\b')).Count

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

# Save log
$logPath = "C:\github-claude\calculator-website-documentation\fix-logs\coolcation-fix-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
"Fixed $totalFixed errors at $(Get-Date)" | Out-File $logPath
Write-Host "Log saved to: $logPath" -ForegroundColor Gray
