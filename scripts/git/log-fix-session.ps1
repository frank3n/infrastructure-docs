# log-fix-session.ps1
# Automated logging script for lint fix sessions

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("baseline", "autofix", "manual", "final")]
    [string]$Phase,

    [Parameter(Mandatory=$false)]
    [string]$Notes = ""
)

$timestamp = Get-Date -Format 'yyyy-MM-dd-HHmm'
$logDir = "C:\github-claude\calculator-website-documentation\fix-logs"

Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "Logging $Phase Phase" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Timestamp: $timestamp" -ForegroundColor Gray
if ($Notes) {
    Write-Host "Notes: $Notes" -ForegroundColor Gray
}
Write-Host ""

# Run lint
Write-Host "Running lint check..." -ForegroundColor Yellow
$lintLogPath = "$logDir\lint-run-$Phase-$timestamp.txt"

try {
    & ".\run-npm-sequential.ps1" -NpmCommand lint -SkipOnError *>&1 |
        Tee-Object -FilePath $lintLogPath

    Write-Host "✓ Lint output saved" -ForegroundColor Green
} catch {
    Write-Host "✗ Error running lint: $_" -ForegroundColor Red
    exit 1
}

# Run analysis
Write-Host "`nRunning error analysis..." -ForegroundColor Yellow

try {
    & ".\analyze-lint-errors.ps1"

    # Find latest analysis file
    $latestAnalysis = Get-ChildItem "$logDir\..\lint-error-analysis-*.md" -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if ($latestAnalysis) {
        $analysisPath = "$logDir\analysis-$Phase-$timestamp.md"
        Copy-Item $latestAnalysis.FullName $analysisPath
        Write-Host "✓ Analysis saved" -ForegroundColor Green

        # Extract error count
        $errorCountMatch = Select-String -Path $analysisPath -Pattern "\*\*Total Errors:\*\* (\d+)"
        if ($errorCountMatch) {
            $errorCount = $errorCountMatch.Matches.Groups[1].Value
        } else {
            $errorCount = "Unknown"
        }
    } else {
        $errorCount = "Unknown"
        Write-Host "⚠ No analysis file found" -ForegroundColor Yellow
    }
} catch {
    Write-Host "✗ Error running analysis: $_" -ForegroundColor Red
    $errorCount = "Error"
}

# Create snapshot
Write-Host "`nCreating progress snapshot..." -ForegroundColor Yellow

$snapshotPath = "$logDir\progress-snapshots\snapshot-$Phase-$timestamp.md"

$snapshotContent = @"
# $Phase Phase Snapshot

**Timestamp:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
**Phase:** $Phase
**Notes:** $Notes

---

## Statistics

- **Total Errors:** $errorCount
- **Phase:** $Phase

---

## Files Generated

- **Lint Output:** ``lint-run-$Phase-$timestamp.txt``
- **Analysis:** ``analysis-$Phase-$timestamp.md``
- **Snapshot:** ``progress-snapshots/snapshot-$Phase-$timestamp.md``

---

## Execution Details

**Command:**
``````powershell
.\log-fix-session.ps1 -Phase "$Phase" -Notes "$Notes"
``````

**Directory:** ``$logDir``

---

## Next Steps

[To be filled manually if needed]

"@

$snapshotContent | Out-File -FilePath $snapshotPath -Encoding UTF8
Write-Host "✓ Snapshot created" -ForegroundColor Green

# Summary
Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "Logging Complete!" -ForegroundColor Cyan
Write-Host "=========================================`n" -ForegroundColor Cyan

Write-Host "Phase: " -NoNewline
Write-Host "$Phase" -ForegroundColor Yellow
Write-Host "Errors: " -NoNewline
Write-Host "$errorCount" -ForegroundColor $(if ($errorCount -match '^\d+$' -and [int]$errorCount -gt 100) { 'Red' } elseif ($errorCount -match '^\d+$') { 'Yellow' } else { 'Gray' })

Write-Host "`nFiles saved to: $logDir" -ForegroundColor Cyan
Write-Host "  - lint-run-$Phase-$timestamp.txt" -ForegroundColor Gray
Write-Host "  - analysis-$Phase-$timestamp.md" -ForegroundColor Gray
Write-Host "  - progress-snapshots/snapshot-$Phase-$timestamp.md" -ForegroundColor Gray

Write-Host "`n✓ Session logged successfully!`n" -ForegroundColor Green
