# Count total errors across all branches
$basePath = "C:\github-claude\calculator-website-test\claude"
$branches = @(
    "add-loan-calculator-011CUzKvKUVZU5j9YrN2aQRb",
    "advanced-c-programming-016Z8rGiwZaYgPcis17YorRy",
    "calculator-affiliate-niches-01LXPQjEUAmFJPm6NjT3Jz6E",
    "coolcation-calculator-feature-011CV5qSqYUYdvwJ5bpua7ph",
    "futures-paper-trading-tool-011CV2w7JCjGJLFx4otwjzFY",
    "futures-trading-calculators-011CV12pWyQ2LdP27bvnsUDa",
    "multilang-calculator-plan-011CUz48qy2HekjPBWXe9Req",
    "plan-calculator-feature-01G24dsP61dwRf4jonCD4mTe",
    "research-vps-credits-014ADcc6USifgWdsXuVG39tw",
    "restart-dev-server-01TjCDbF2u7qoke6SzZw65xi",
    "vpn-comparison-tool-013xNsusZ8MbzaotBc9mVbEV"
)

Write-Host "Counting 'any' type errors across all branches..." -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

$totalErrors = 0
$results = @()

foreach ($branch in $branches) {
    $branchPath = Join-Path $basePath $branch

    if (Test-Path $branchPath) {
        Write-Host "`nBranch: $branch" -ForegroundColor Yellow
        Set-Location $branchPath

        $lintOutput = npm run lint 2>&1 | Out-String
        $errorCount = ([regex]::Matches($lintOutput, "@typescript-eslint/no-explicit-any")).Count

        $totalErrors += $errorCount
        $results += [PSCustomObject]@{
            Branch = $branch
            Errors = $errorCount
        }

        Write-Host "  Errors: $errorCount" -ForegroundColor $(if ($errorCount -eq 0) { 'Green' } else { 'White' })
    }
}

Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
Write-Host "TOTAL 'any' TYPE ERRORS: $totalErrors" -ForegroundColor $(if ($totalErrors -lt 150) { 'Green' } elseif ($totalErrors -lt 200) { 'Yellow' } else { 'Red' })
Write-Host ("=" * 60) -ForegroundColor Cyan

Write-Host "`nBranches by error count:" -ForegroundColor Cyan
$results | Sort-Object -Property Errors -Descending | ForEach-Object {
    $color = if ($_.Errors -eq 0) { 'Green' } else { 'White' }
    Write-Host ("  {0,-50} {1,3} errors" -f $_.Branch, $_.Errors) -ForegroundColor $color
}

# Save summary
$summaryPath = "C:\github-claude\calculator-website-documentation\error-count-summary-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
"Total 'any' type errors: $totalErrors" | Out-File $summaryPath
"Generated: $(Get-Date)" | Out-File $summaryPath -Append
"" | Out-File $summaryPath -Append
$results | Sort-Object -Property Errors -Descending | ForEach-Object {
    "$($_.Branch): $($_.Errors) errors" | Out-File $summaryPath -Append
}

Write-Host "`nSummary saved to: $summaryPath" -ForegroundColor Gray
