# analyze-lint-errors.ps1
# Analyze lint error logs and create comprehensive summary reports

param(
    [Parameter(Mandatory=$false)]
    [string]$LogDirectory = "C:\github-claude\calculator-website-documentation\npm-logs",

    [Parameter(Mandatory=$false)]
    [string]$OutputDirectory = "C:\github-claude\calculator-website-documentation",

    [Parameter(Mandatory=$false)]
    [string]$Pattern = "*-lint-*.log",

    [Parameter(Mandatory=$false)]
    [switch]$IncludeWarnings
)

# Color output functions
function Write-Success { param($msg) Write-Host $msg -ForegroundColor Green }
function Write-Info { param($msg) Write-Host $msg -ForegroundColor Cyan }
function Write-Warning { param($msg) Write-Host $msg -ForegroundColor Yellow }
function Write-Error { param($msg) Write-Host $msg -ForegroundColor Red }

Write-Success "`n========================================="
Write-Success "Lint Error Analysis Tool"
Write-Success "=========================================`n"

# Verify log directory exists
if (-not (Test-Path $LogDirectory)) {
    Write-Error "Log directory does not exist: $LogDirectory"
    exit 1
}

# Find all lint log files
Write-Info "Searching for lint logs in: $LogDirectory"
$logFiles = Get-ChildItem -Path $LogDirectory -Filter $Pattern

if ($logFiles.Count -eq 0) {
    Write-Warning "No lint log files found matching pattern: $Pattern"
    exit 0
}

Write-Success "Found $($logFiles.Count) lint log files`n"

# Initialize data structures
$errorsByRule = @{}
$errorsByFile = @{}
$warningsByRule = @{}
$warningsByFile = @{}
$totalErrors = 0
$totalWarnings = 0
$filesWithErrors = @{}

# Parse each log file
foreach ($logFile in $logFiles) {
    Write-Host "Analyzing: $($logFile.Name)" -ForegroundColor Gray

    try {
        # Read file content
        $content = Get-Content $logFile.FullName -Raw -Encoding Unicode

        # Split into lines
        $lines = $content -split "`n"

        foreach ($line in $lines) {
            # Match error/warning pattern
            # Format: C:\path\to\file.ts
            #   line:col  error/warning  message  rule-name

            # Check if line contains file path
            if ($line -match '^([A-Z]:\\[^`n]+\.(ts|tsx|js|jsx))') {
                $currentFile = $matches[1]
            }

            # Check if line contains error or warning
            if ($line -match '\s+(error|warning)\s+(.+?)\s+([@\w\-\/]+)\s*$') {
                $severity = $matches[1]
                $message = $matches[2].Trim()
                $rule = $matches[3].Trim()

                if ($severity -eq "error") {
                    $totalErrors++

                    # Count by rule
                    if ($errorsByRule.ContainsKey($rule)) {
                        $errorsByRule[$rule]++
                    } else {
                        $errorsByRule[$rule] = 1
                    }

                    # Count by file
                    if ($currentFile) {
                        if ($errorsByFile.ContainsKey($currentFile)) {
                            $errorsByFile[$currentFile]++
                        } else {
                            $errorsByFile[$currentFile] = 1
                        }

                        # Track which rules affect which files
                        if (-not $filesWithErrors.ContainsKey($currentFile)) {
                            $filesWithErrors[$currentFile] = @{}
                        }
                        if ($filesWithErrors[$currentFile].ContainsKey($rule)) {
                            $filesWithErrors[$currentFile][$rule]++
                        } else {
                            $filesWithErrors[$currentFile][$rule] = 1
                        }
                    }
                }
                elseif ($severity -eq "warning" -and $IncludeWarnings) {
                    $totalWarnings++

                    # Count by rule
                    if ($warningsByRule.ContainsKey($rule)) {
                        $warningsByRule[$rule]++
                    } else {
                        $warningsByRule[$rule] = 1
                    }

                    # Count by file
                    if ($currentFile) {
                        if ($warningsByFile.ContainsKey($currentFile)) {
                            $warningsByFile[$currentFile]++
                        } else {
                            $warningsByFile[$currentFile] = 1
                        }
                    }
                }
            }
        }
    } catch {
        Write-Warning "Error parsing $($logFile.Name): $_"
    }
}

# Generate report
Write-Info "`nGenerating analysis report...`n"

$timestamp = Get-Date -Format "yyyy-MM-dd-HHmmss"
$reportPath = Join-Path $OutputDirectory "lint-error-analysis-$timestamp.md"

$report = @()
$report += "# Lint Error Analysis Report"
$report += ""
$report += "**Generated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$report += "**Log Files Analyzed:** $($logFiles.Count)"
$report += "**Total Errors:** $totalErrors"
if ($IncludeWarnings) {
    $report += "**Total Warnings:** $totalWarnings"
}
$report += ""
$report += "---"
$report += ""

# Section 1: Top Error Rules
$report += "## Top Error Rules"
$report += ""
$report += "| Rank | Rule | Count | % of Total |"
$report += "|------|------|-------|------------|"

$rank = 1
$sortedErrorRules = $errorsByRule.GetEnumerator() | Sort-Object -Property Value -Descending

foreach ($rule in $sortedErrorRules) {
    $percentage = [math]::Round(($rule.Value / $totalErrors) * 100, 1)
    $report += "| $rank | ``$($rule.Key)`` | $($rule.Value) | $percentage% |"
    $rank++
}

$report += ""
$report += "---"
$report += ""

# Section 2: Files with Most Errors
$report += "## Files with Most Errors"
$report += ""
$report += "| Rank | File | Error Count |"
$report += "|------|------|-------------|"

$rank = 1
$sortedFiles = $errorsByFile.GetEnumerator() | Sort-Object -Property Value -Descending | Select-Object -First 20

foreach ($file in $sortedFiles) {
    # Shorten file path for readability
    $shortPath = $file.Key -replace 'C:\\github-claude\\calculator-website-test\\', ''
    $report += "| $rank | ``$shortPath`` | $($file.Value) |"
    $rank++
}

$report += ""
$report += "---"
$report += ""

# Section 3: Error Breakdown by Rule
$report += "## Detailed Error Breakdown by Rule"
$report += ""

foreach ($rule in $sortedErrorRules) {
    $report += "### ``$($rule.Key)`` ($($rule.Value) errors)"
    $report += ""

    # Find files affected by this rule
    $affectedFiles = @()
    foreach ($file in $filesWithErrors.Keys) {
        if ($filesWithErrors[$file].ContainsKey($rule.Key)) {
            $shortPath = $file -replace 'C:\\github-claude\\calculator-website-test\\', ''
            $affectedFiles += @{
                Path = $shortPath
                Count = $filesWithErrors[$file][$rule.Key]
            }
        }
    }

    # Sort by count
    $affectedFiles = $affectedFiles | Sort-Object -Property Count -Descending | Select-Object -First 10

    $report += "**Top affected files:**"
    $report += ""
    foreach ($af in $affectedFiles) {
        $report += "- ``$($af.Path)`` - $($af.Count) occurrence(s)"
    }
    $report += ""
}

$report += "---"
$report += ""

# Section 4: Warnings (if included)
if ($IncludeWarnings -and $totalWarnings -gt 0) {
    $report += "## Warnings Summary"
    $report += ""
    $report += "| Rule | Count |"
    $report += "|------|-------|"

    $sortedWarningRules = $warningsByRule.GetEnumerator() | Sort-Object -Property Value -Descending

    foreach ($rule in $sortedWarningRules) {
        $report += "| ``$($rule.Key)`` | $($rule.Value) |"
    }

    $report += ""
    $report += "---"
    $report += ""
}

# Section 5: Recommendations
$report += "## Recommendations"
$report += ""
$report += "### High Priority Fixes"
$report += ""

# Get top 3 error rules
$topRules = $sortedErrorRules | Select-Object -First 3

foreach ($topRule in $topRules) {
    $report += "#### Fix ``$($topRule.Key)`` ($($topRule.Value) errors)"
    $report += ""

    # Add specific recommendations based on rule
    switch -Wildcard ($topRule.Key) {
        "*no-explicit-any*" {
            $report += "**Issue:** Using ``any`` type defeats TypeScript's type safety."
            $report += ""
            $report += "**Solution:**"
            $report += '```typescript'
            $report += "// Bad"
            $report += "function process(data: any) { ... }"
            $report += ""
            $report += "// Good"
            $report += "interface ProcessData {"
            $report += "  id: string;"
            $report += "  value: number;"
            $report += "}"
            $report += "function process(data: ProcessData) { ... }"
            $report += '```'
        }
        "*prefer-const*" {
            $report += "**Issue:** Variables declared with ``let`` that are never reassigned."
            $report += ""
            $report += "**Solution:** Run ``npm run lint -- --fix`` to auto-fix most instances."
            $report += '```bash'
            $report += "npm run lint -- --fix"
            $report += '```'
        }
        "*no-unused-vars*" {
            $report += "**Issue:** Unused variables, imports, or parameters."
            $report += ""
            $report += "**Solution:** Remove unused code or prefix with underscore if intentionally unused."
            $report += '```typescript'
            $report += "// If intentionally unused (e.g., in function signature)"
            $report += "function handler(_req, res) { ... }"
            $report += '```'
        }
        "*react-hooks*" {
            $report += "**Issue:** React Hooks rules violation."
            $report += ""
            $report += "**Solution:** Review React Hooks documentation and fix hook calls."
        }
        default {
            $report += "**Issue:** ESLint rule violation."
            $report += ""
            $report += "**Solution:** Review ESLint documentation for ``$($topRule.Key)``."
        }
    }

    $report += ""
}

$report += "### Suggested Workflow"
$report += ""
$report += "1. **Auto-fix what you can:**"
$report += '   ```powershell'
$report += "   cd C:\github-claude\calculator-website-test\claude\<branch-name>"
$report += "   npm run lint -- --fix"
$report += '   ```'
$report += ""
$report += "2. **Manually fix remaining errors:**"
$report += "   - Focus on high-priority rules first"
$report += "   - Fix one file at a time"
$report += "   - Run lint after each fix to verify"
$report += ""
$report += "3. **Re-run lint check:**"
$report += '   ```powershell'
$report += "   cd C:\github-claude"
$report += "   .\run-npm-sequential.ps1 -NpmCommand lint -SkipOnError"
$report += '   ```'
$report += ""

$report += "---"
$report += ""
$report += "## Related Documentation"
$report += ""
$report += "- [sequential-npm-runner-guide.md](sequential-npm-runner-guide.md)"
$report += "- [lint-analysis.md](lint-analysis.md)"
$report += ""

# Save report
$report | Out-File -FilePath $reportPath -Encoding UTF8

Write-Success "Analysis complete!`n"

# Print summary to console
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "=========================================`n" -ForegroundColor Cyan

Write-Host "Total Errors: " -NoNewline
Write-Host $totalErrors -ForegroundColor Red

if ($IncludeWarnings) {
    Write-Host "Total Warnings: " -NoNewline
    Write-Host $totalWarnings -ForegroundColor Yellow
}

Write-Host "`nTop 5 Error Rules:" -ForegroundColor Cyan
$topFive = $sortedErrorRules | Select-Object -First 5
$i = 1
foreach ($rule in $topFive) {
    Write-Host "  $i. " -NoNewline -ForegroundColor Gray
    Write-Host "$($rule.Key): " -NoNewline -ForegroundColor White
    Write-Host "$($rule.Value) errors" -ForegroundColor Red
    $i++
}

Write-Host "`nFiles with Most Errors:" -ForegroundColor Cyan
$topFiles = $errorsByFile.GetEnumerator() | Sort-Object -Property Value -Descending | Select-Object -First 5
$i = 1
foreach ($file in $topFiles) {
    $shortPath = $file.Key -replace 'C:\\github-claude\\calculator-website-test\\', ''
    Write-Host "  $i. " -NoNewline -ForegroundColor Gray
    Write-Host "$shortPath - " -NoNewline -ForegroundColor White
    Write-Host "$($file.Value) errors" -ForegroundColor Red
    $i++
}

Write-Host "`nReport saved to:" -ForegroundColor Cyan
Write-Host "  $reportPath" -ForegroundColor Gray

Write-Success "`n✓ Analysis complete!`n"
