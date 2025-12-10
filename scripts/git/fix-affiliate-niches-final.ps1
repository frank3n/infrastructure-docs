# Fix remaining TypeScript errors in calculator-affiliate-niches
$branchPath = "C:\github-claude\calculator-website-test\claude\calculator-affiliate-niches-01LXPQjEUAmFJPm6NjT3Jz6E"

Write-Host "Fixing remaining TypeScript errors in calculator-affiliate-niches..." -ForegroundColor Cyan

$filesToFix = @(
    "api\src\routes\reports.ts",
    "api\src\routes\test.ts",
    "api\src\services\linkTester.ts",
    "api\src\services\requestQueue.ts",
    "src\components\ProxyHealthDashboard.tsx"
)

$totalFixed = 0

foreach ($file in $filesToFix) {
    $filePath = Join-Path $branchPath $file

    if (Test-Path $filePath) {
        Write-Host "`nProcessing: $file" -ForegroundColor Yellow

        $content = Get-Content $filePath -Raw
        $originalContent = $content

        # Replace catch blocks with err: any
        $content = $content -replace '\(err: any\)', '(err: unknown)'
        $content = $content -replace '\(error: any\)', '(error: unknown)'
        $content = $content -replace '\(e: any\)', '(e: unknown)'

        # Replace type annotations
        $content = $content -replace ':\s*any\b(?!\))', ': unknown'

        # For specific patterns found in the code
        # Handle .map((item: any) => ...) patterns
        $content = $content -replace '\((\w+):\s*any\)\s*=>', '($1: unknown) =>'

        # Count changes
        $changes = 0
        if ($content -ne $originalContent) {
            $changes = ([regex]::Matches($originalContent, ':\s*any\b')).Count - ([regex]::Matches($content, ':\s*any\b')).Count

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
