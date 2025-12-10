# Scan All Repositories for TypeScript Errors
# Provides comprehensive assessment of TypeScript quality across multiple repos

param(
    [Parameter(Mandatory=$false)]
    [string[]]$Repositories = @(),

    [Parameter(Mandatory=$false)]
    [string]$ConfigFile = "repos-to-scan.txt"
)

# If no repositories specified, try to read from config file
if ($Repositories.Length -eq 0 -and (Test-Path $ConfigFile)) {
    $Repositories = Get-Content $ConfigFile | Where-Object { $_ -and $_ -notmatch "^#" }
}

if ($Repositories.Length -eq 0) {
    Write-Host "❌ No repositories specified" -ForegroundColor Red
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Cyan
    Write-Host "  .\scan-all-repos.ps1 -Repositories @('C:\repo1', 'C:\repo2')" -ForegroundColor Gray
    Write-Host "  Or create 'repos-to-scan.txt' with one path per line" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Example repos-to-scan.txt:" -ForegroundColor Cyan
    Write-Host "  C:\github\calculator-website" -ForegroundColor Gray
    Write-Host "  C:\github\trading-platform" -ForegroundColor Gray
    Write-Host "  C:\github\api-gateway" -ForegroundColor Gray
    exit 1
}

Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     Multi-Repository TypeScript Quality Scanner          ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "📊 Scanning $($Repositories.Length) repositories..." -ForegroundColor Yellow
Write-Host ""

$results = @()
$currentDir = Get-Location

foreach ($repo in $Repositories) {
    Write-Host "─────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "📁 Repository: $(Split-Path $repo -Leaf)" -ForegroundColor Yellow
    Write-Host "   Path: $repo" -ForegroundColor Gray

    if (-not (Test-Path $repo)) {
        Write-Host "   ❌ Repository not found" -ForegroundColor Red
        $results += [PSCustomObject]@{
            Repository = Split-Path $repo -Leaf
            Path = $repo
            Status = "Not Found"
            TotalErrors = "N/A"
            AnyTypeCount = "N/A"
            HasCI = "N/A"
            HasTypeDoc = "N/A"
            HasPreCommitHook = "N/A"
        }
        continue
    }

    Set-Location $repo

    # Check if package.json exists
    if (-not (Test-Path "package.json")) {
        Write-Host "   ⚠️  No package.json found" -ForegroundColor Yellow
        $results += [PSCustomObject]@{
            Repository = Split-Path $repo -Leaf
            Path = $repo
            Status = "No package.json"
            TotalErrors = "N/A"
            AnyTypeCount = "N/A"
            HasCI = "N/A"
            HasTypeDoc = "N/A"
            HasPreCommitHook = "N/A"
        }
        continue
    }

    # Check if node_modules exists
    if (-not (Test-Path "node_modules")) {
        Write-Host "   📦 Installing dependencies..." -ForegroundColor Gray
        npm ci 2>&1 | Out-Null
    }

    # Check if lint script exists
    $packageJson = Get-Content "package.json" | ConvertFrom-Json
    if (-not $packageJson.scripts.lint) {
        Write-Host "   ⚠️  No lint script found" -ForegroundColor Yellow
        $results += [PSCustomObject]@{
            Repository = Split-Path $repo -Leaf
            Path = $repo
            Status = "No lint script"
            TotalErrors = "N/A"
            AnyTypeCount = "N/A"
            HasCI = Test-Path ".github/workflows"
            HasTypeDoc = Test-Path "typedoc.json"
            HasPreCommitHook = Test-Path ".git/hooks/pre-commit"
        }
        continue
    }

    # Run lint and count errors
    Write-Host "   🔍 Running lint check..." -ForegroundColor Gray
    $lintOutput = npm run lint 2>&1 | Out-String

    $errorCount = 0
    if ($lintOutput -match "(\d+) problems?") {
        $errorCount = [int]$matches[1]
    }

    # Count 'any' types
    Write-Host "   🔍 Scanning for 'any' types..." -ForegroundColor Gray
    $anyCount = 0
    try {
        $anyCount = (git grep -n ": any\b\|<any>\|any\[\]\| as any\b" -- "*.ts" "*.tsx" 2>$null | Measure-Object).Count
    } catch {
        $anyCount = 0
    }

    # Count TypeScript files
    $tsFileCount = (Get-ChildItem -Path "src" -Filter "*.ts" -Recurse -ErrorAction SilentlyContinue | Measure-Object).Count
    $tsxFileCount = (Get-ChildItem -Path "src" -Filter "*.tsx" -Recurse -ErrorAction SilentlyContinue | Measure-Object).Count
    $totalTsFiles = $tsFileCount + $tsxFileCount

    # Check for CI/CD
    $hasCI = Test-Path ".github/workflows"
    $ciFiles = if ($hasCI) {
        (Get-ChildItem ".github/workflows" -Filter "*.yml" | Measure-Object).Count
    } else { 0 }

    # Check for TypeDoc
    $hasTypeDoc = Test-Path "typedoc.json"

    # Check for pre-commit hook
    $hasPreCommitHook = Test-Path ".git/hooks/pre-commit"

    # Check for type utilities
    $hasTypeUtils = Test-Path "types/utils.ts"

    # Determine status
    $status = if ($errorCount -eq 0 -and $anyCount -eq 0) {
        "✅ Clean"
    } elseif ($errorCount -lt 50) {
        "⚠️  Needs Work"
    } else {
        "❌ Critical"
    }

    Write-Host "   📊 Lint errors: $errorCount" -ForegroundColor $(if ($errorCount -eq 0) { "Green" } else { "Red" })
    Write-Host "   📊 'any' types: $anyCount" -ForegroundColor $(if ($anyCount -eq 0) { "Green" } else { "Yellow" })
    Write-Host "   📊 TypeScript files: $totalTsFiles" -ForegroundColor Gray
    Write-Host "   📊 CI/CD: $(if ($hasCI) { '✅ Yes (' + $ciFiles + ' workflows)' } else { '❌ No' })" -ForegroundColor $(if ($hasCI) { "Green" } else { "Red" })
    Write-Host "   📊 TypeDoc: $(if ($hasTypeDoc) { '✅ Yes' } else { '❌ No' })" -ForegroundColor $(if ($hasTypeDoc) { "Green" } else { "Red" })
    Write-Host "   📊 Pre-commit: $(if ($hasPreCommitHook) { '✅ Yes' } else { '❌ No' })" -ForegroundColor $(if ($hasPreCommitHook) { "Green" } else { "Red" })
    Write-Host "   📊 Type Utils: $(if ($hasTypeUtils) { '✅ Yes' } else { '❌ No' })" -ForegroundColor $(if ($hasTypeUtils) { "Green" } else { "Red" })
    Write-Host "   📊 Status: $status" -ForegroundColor Gray

    $results += [PSCustomObject]@{
        Repository = Split-Path $repo -Leaf
        Path = $repo
        Status = $status
        TotalErrors = $errorCount
        AnyTypeCount = $anyCount
        TypeScriptFiles = $totalTsFiles
        HasCI = if ($hasCI) { "Yes ($ciFiles)" } else { "No" }
        HasTypeDoc = if ($hasTypeDoc) { "Yes" } else { "No" }
        HasPreCommitHook = if ($hasPreCommitHook) { "Yes" } else { "No" }
        HasTypeUtils = if ($hasTypeUtils) { "Yes" } else { "No" }
        EstimatedEffort = if ($errorCount -eq 0) {
            "0h"
        } elseif ($errorCount -lt 50) {
            "1-2h"
        } elseif ($errorCount -lt 150) {
            "3-5h"
        } else {
            "5-8h"
        }
    }
}

Set-Location $currentDir

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                    Scan Complete                          ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

# Display results table
$results | Format-Table -Property Repository, Status, TotalErrors, AnyTypeCount, TypeScriptFiles, HasCI, HasTypeDoc, EstimatedEffort -AutoSize

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Summary Statistics" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan

$validResults = $results | Where-Object { $_.TotalErrors -ne "N/A" }

$totalErrors = ($validResults | Where-Object { $_.TotalErrors -is [int] } | Measure-Object -Property TotalErrors -Sum).Sum
$totalAny = ($validResults | Where-Object { $_.AnyTypeCount -is [int] } | Measure-Object -Property AnyTypeCount -Sum).Sum
$totalTsFiles = ($validResults | Where-Object { $_.TypeScriptFiles -is [int] } | Measure-Object -Property TypeScriptFiles -Sum).Sum
$reposWithCI = ($validResults | Where-Object { $_.HasCI -like "Yes*" }).Count
$reposWithTypeDoc = ($validResults | Where-Object { $_.HasTypeDoc -eq "Yes" }).Count
$reposWithPreCommit = ($validResults | Where-Object { $_.HasPreCommitHook -eq "Yes" }).Count
$reposWithTypeUtils = ($validResults | Where-Object { $_.HasTypeUtils -eq "Yes" }).Count
$cleanRepos = ($validResults | Where-Object { $_.Status -like "*Clean*" }).Count

Write-Host "📊 Total Repositories Scanned: $($results.Count)" -ForegroundColor White
Write-Host "📊 Valid Repositories: $($validResults.Count)" -ForegroundColor White
Write-Host ""
Write-Host "📊 Total Lint Errors: $totalErrors" -ForegroundColor $(if ($totalErrors -eq 0) { "Green" } else { "Red" })
Write-Host "📊 Total 'any' Types: $totalAny" -ForegroundColor $(if ($totalAny -eq 0) { "Green" } else { "Yellow" })
Write-Host "📊 Total TypeScript Files: $totalTsFiles" -ForegroundColor Gray
Write-Host ""
Write-Host "📊 Repositories with CI/CD: $reposWithCI / $($validResults.Count)" -ForegroundColor $(if ($reposWithCI -eq $validResults.Count) { "Green" } else { "Yellow" })
Write-Host "📊 Repositories with TypeDoc: $reposWithTypeDoc / $($validResults.Count)" -ForegroundColor $(if ($reposWithTypeDoc -eq $validResults.Count) { "Green" } else { "Yellow" })
Write-Host "📊 Repositories with Pre-commit: $reposWithPreCommit / $($validResults.Count)" -ForegroundColor $(if ($reposWithPreCommit -eq $validResults.Count) { "Green" } else { "Yellow" })
Write-Host "📊 Repositories with Type Utils: $reposWithTypeUtils / $($validResults.Count)" -ForegroundColor $(if ($reposWithTypeUtils -eq $validResults.Count) { "Green" } else { "Yellow" })
Write-Host ""
Write-Host "✅ Clean Repositories: $cleanRepos / $($validResults.Count)" -ForegroundColor $(if ($cleanRepos -eq $validResults.Count) { "Green" } else { "Yellow" })

# Recommendations
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Recommendations" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan

$criticalRepos = $validResults | Where-Object { $_.Status -like "*Critical*" }
$needsWorkRepos = $validResults | Where-Object { $_.Status -like "*Needs Work*" }

if ($criticalRepos.Count -gt 0) {
    Write-Host ""
    Write-Host "🔴 Critical (>50 errors) - Fix immediately:" -ForegroundColor Red
    foreach ($repo in $criticalRepos | Sort-Object -Property TotalErrors -Descending) {
        Write-Host "   • $($repo.Repository): $($repo.TotalErrors) errors (Est: $($repo.EstimatedEffort))" -ForegroundColor Red
    }
}

if ($needsWorkRepos.Count -gt 0) {
    Write-Host ""
    Write-Host "⚠️  Needs Work (1-49 errors) - Plan for next sprint:" -ForegroundColor Yellow
    foreach ($repo in $needsWorkRepos | Sort-Object -Property TotalErrors -Descending) {
        Write-Host "   • $($repo.Repository): $($repo.TotalErrors) errors (Est: $($repo.EstimatedEffort))" -ForegroundColor Yellow
    }
}

$needsCI = $validResults | Where-Object { $_.HasCI -eq "No" }
if ($needsCI.Count -gt 0) {
    Write-Host ""
    Write-Host "📋 Add CI/CD to these repositories:" -ForegroundColor Cyan
    foreach ($repo in $needsCI) {
        Write-Host "   • $($repo.Repository)" -ForegroundColor Gray
    }
}

# Export results
$timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$csvFile = "scan-results_$timestamp.csv"
$results | Export-Csv -Path $csvFile -NoTypeInformation

Write-Host ""
Write-Host "✅ Results exported to: $csvFile" -ForegroundColor Green

# Create priority file
$priorityFile = "priority-order.txt"
$validResults |
    Sort-Object -Property @{Expression={if ($_.TotalErrors -is [int]) {$_.TotalErrors} else {0}}; Descending=$true} |
    Select-Object -ExpandProperty Path |
    Set-Content $priorityFile

Write-Host "✅ Priority order exported to: $priorityFile" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Review the results and prioritize repositories" -ForegroundColor Gray
Write-Host "  2. Use priority-order.txt for rollout sequence" -ForegroundColor Gray
Write-Host "  3. Run: .\rollout-to-all-repos.ps1 -DryRun" -ForegroundColor Gray
Write-Host ""
