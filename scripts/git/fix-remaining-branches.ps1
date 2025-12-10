# Fix TypeScript 'any' errors in remaining branches
$basePath = "C:\github-claude\calculator-website-test\claude"

$filesToFix = @(
    @{
        Branch = "futures-paper-trading-tool-011CV2w7JCjGJLFx4otwjzFY"
        Files = @("src\calculators\financial\FuturesPaperTrading\store\tradingStore.ts")
    },
    @{
        Branch = "futures-trading-calculators-011CV12pWyQ2LdP27bvnsUDa"
        Files = @(
            "src\calculators\trading\utils\HistoryPanel.tsx",
            "src\calculators\trading\utils\export.ts",
            "src\calculators\trading\utils\history.ts"
        )
    }
)

Write-Host "Fixing TypeScript errors in remaining branches..." -ForegroundColor Cyan

$totalFixed = 0

foreach ($branchInfo in $filesToFix) {
    $branchPath = Join-Path $basePath $branchInfo.Branch
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "Branch: $($branchInfo.Branch)" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan

    foreach ($file in $branchInfo.Files) {
        $filePath = Join-Path $branchPath $file

        if (Test-Path $filePath) {
            Write-Host "`nProcessing: $file" -ForegroundColor Yellow

            $content = Get-Content $filePath -Raw
            $originalContent = $content

            # Replace err: any with err: unknown in catch blocks
            $content = $content -replace '(\bcatch\s*\(\s*\w+)\s*:\s*any\s*\)', '$1: unknown)'

            # Replace error: any with error: unknown
            $content = $content -replace '(\berror)\s*:\s*any\b', '$1: unknown'

            # Replace e: any with e: unknown in catch blocks
            $content = $content -replace '(\bcatch\s*\(\s*e)\s*:\s*any\s*\)', '$1: unknown)'

            # Replace data: any with data: unknown
            $content = $content -replace '(\bdata)\s*:\s*any\b', '$1: unknown'

            # Replace function parameters ending with: any)
            $content = $content -replace '(\w+)\s*:\s*any\s*\)', '$1: unknown)'

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

    # Run lint for this branch
    Write-Host "`nRunning lint for $($branchInfo.Branch)..." -ForegroundColor Cyan
    Set-Location $branchPath
    $lintOutput = npm run lint 2>&1
    $errorCount = ($lintOutput | Select-String "@typescript-eslint/no-explicit-any" | Measure-Object).Count
    Write-Host "Remaining 'any' type errors: $errorCount" -ForegroundColor $(if ($errorCount -eq 0) { 'Green' } else { 'Yellow' })
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Total 'any' types fixed across branches: $totalFixed" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan
