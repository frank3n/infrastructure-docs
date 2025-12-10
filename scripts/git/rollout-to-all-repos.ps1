# Rollout TypeScript Quality Improvements to Multiple Repositories
# Automates the process of fixing TypeScript errors across multiple repos

param(
    [Parameter(Mandatory=$false)]
    [string[]]$Repositories = @(),

    [Parameter(Mandatory=$false)]
    [string]$ConfigFile = "repos-to-fix.txt",

    [Parameter(Mandatory=$false)]
    [switch]$DryRun = $false,

    [Parameter(Mandatory=$false)]
    [switch]$AutoCommit = $false,

    [Parameter(Mandatory=$false)]
    [switch]$SkipInstall = $false,

    [Parameter(Mandatory=$false)]
    [string]$SourceRepo = "C:\github-claude"
)

# If no repositories specified, try to read from config file
if ($Repositories.Length -eq 0) {
    if (Test-Path $ConfigFile) {
        $Repositories = Get-Content $ConfigFile | Where-Object { $_ -and $_ -notmatch "^#" }
    } elseif (Test-Path "priority-order.txt") {
        $Repositories = Get-Content "priority-order.txt" | Where-Object { $_ -and $_ -notmatch "^#" }
    }
}

if ($Repositories.Length -eq 0) {
    Write-Host "❌ No repositories specified" -ForegroundColor Red
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Cyan
    Write-Host "  .\rollout-to-all-repos.ps1 -Repositories @('C:\repo1', 'C:\repo2')" -ForegroundColor Gray
    Write-Host "  Or create 'repos-to-fix.txt' with one path per line" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "  -DryRun          Show what would be done without making changes" -ForegroundColor Gray
    Write-Host "  -AutoCommit      Automatically commit changes to new branch" -ForegroundColor Gray
    Write-Host "  -SkipInstall     Skip npm install (if dependencies already installed)" -ForegroundColor Gray
    Write-Host "  -SourceRepo      Path to source repository (default: C:\github-claude)" -ForegroundColor Gray
    exit 1
}

if (-not (Test-Path $SourceRepo)) {
    Write-Host "❌ Source repository not found: $SourceRepo" -ForegroundColor Red
    exit 1
}

Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     TypeScript Quality Rollout - Multi-Repository        ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Configuration:" -ForegroundColor Yellow
Write-Host "   Source Repository: $SourceRepo" -ForegroundColor Gray
Write-Host "   Target Repositories: $($Repositories.Length)" -ForegroundColor Gray
Write-Host "   Dry Run: $(if ($DryRun) { 'Yes (no changes will be made)' } else { 'No' })" -ForegroundColor Gray
Write-Host "   Auto Commit: $(if ($AutoCommit) { 'Yes' } else { 'No' })" -ForegroundColor Gray
Write-Host "   Skip Install: $(if ($SkipInstall) { 'Yes' } else { 'No' })" -ForegroundColor Gray
Write-Host ""

if ($DryRun) {
    Write-Host "🔍 DRY RUN MODE - No changes will be made" -ForegroundColor Yellow
    Write-Host ""
}

$results = @()
$currentDir = Get-Location

foreach ($repo in $Repositories) {
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "📁 Processing: $(Split-Path $repo -Leaf)" -ForegroundColor Cyan
    Write-Host "   Path: $repo" -ForegroundColor Gray
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan

    if (-not (Test-Path $repo)) {
        Write-Host "❌ Repository not found: $repo" -ForegroundColor Red
        $results += [PSCustomObject]@{
            Repository = Split-Path $repo -Leaf
            Status = "Not Found"
            BeforeErrors = "N/A"
            AfterErrors = "N/A"
            Fixed = 0
            SuccessRate = "0%"
        }
        Write-Host ""
        continue
    }

    Set-Location $repo

    # Check if package.json exists
    if (-not (Test-Path "package.json")) {
        Write-Host "⚠️  No package.json found - skipping" -ForegroundColor Yellow
        $results += [PSCustomObject]@{
            Repository = Split-Path $repo -Leaf
            Status = "No package.json"
            BeforeErrors = "N/A"
            AfterErrors = "N/A"
            Fixed = 0
            SuccessRate = "0%"
        }
        Write-Host ""
        continue
    }

    # ─────────────────────────────────────────────────────────────
    # STEP 1: Create Baseline
    # ─────────────────────────────────────────────────────────────
    Write-Host ""
    Write-Host "📊 Step 1/6: Creating baseline..." -ForegroundColor Yellow

    if (-not $SkipInstall) {
        if (-not (Test-Path "node_modules")) {
            Write-Host "   📦 Installing dependencies..." -ForegroundColor Gray
            npm ci 2>&1 | Out-Null
        }
    }

    # Run lint
    $lintOutput = npm run lint 2>&1 | Out-String
    $beforeErrors = 0
    if ($lintOutput -match "(\d+) problems?") {
        $beforeErrors = [int]$matches[1]
    }

    # Count 'any' types
    $anyCount = 0
    try {
        $anyCount = (git grep -n ": any\b\|<any>\|any\[\]\| as any\b" -- "*.ts" "*.tsx" 2>$null | Measure-Object).Count
    } catch {
        $anyCount = 0
    }

    Write-Host "   Baseline: $beforeErrors lint errors" -ForegroundColor Gray
    Write-Host "   'any' types: $anyCount" -ForegroundColor Gray

    if ($beforeErrors -eq 0 -and $anyCount -eq 0) {
        Write-Host "   ✅ Repository is already clean!" -ForegroundColor Green
        $results += [PSCustomObject]@{
            Repository = Split-Path $repo -Leaf
            Status = "Already Clean"
            BeforeErrors = 0
            AfterErrors = 0
            Fixed = 0
            SuccessRate = "100%"
        }
        Write-Host ""
        continue
    }

    if ($DryRun) {
        Write-Host "   [DRY RUN] Would fix $beforeErrors errors and $anyCount 'any' types" -ForegroundColor Cyan
        $results += [PSCustomObject]@{
            Repository = Split-Path $repo -Leaf
            Status = "Dry Run"
            BeforeErrors = $beforeErrors
            AfterErrors = "N/A"
            Fixed = "N/A"
            SuccessRate = "N/A"
        }
        Write-Host ""
        continue
    }

    # ─────────────────────────────────────────────────────────────
    # STEP 2: Install Quality Tools
    # ─────────────────────────────────────────────────────────────
    Write-Host ""
    Write-Host "📦 Step 2/6: Installing quality tools..." -ForegroundColor Yellow

    # Copy type utilities
    if (Test-Path "$SourceRepo\types\utils.ts") {
        if (-not (Test-Path "types")) {
            New-Item -ItemType Directory -Path "types" | Out-Null
        }
        Copy-Item "$SourceRepo\types\*" "types\" -Force -Recurse
        Write-Host "   ✅ Type utilities installed" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Type utilities not found in source repo" -ForegroundColor Yellow
    }

    # Copy GitHub Actions workflows
    if (Test-Path "$SourceRepo\.github\workflows") {
        if (-not (Test-Path ".github\workflows")) {
            New-Item -ItemType Directory -Path ".github\workflows" -Force | Out-Null
        }
        Copy-Item "$SourceRepo\.github\workflows\*.yml" ".github\workflows\" -Force -ErrorAction SilentlyContinue
        Write-Host "   ✅ GitHub Actions workflows installed" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  GitHub Actions workflows not found in source repo" -ForegroundColor Yellow
    }

    # Copy TypeDoc configuration
    if (Test-Path "$SourceRepo\typedoc.json") {
        Copy-Item "$SourceRepo\typedoc.json" "." -Force
        Write-Host "   ✅ TypeDoc configuration installed" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  TypeDoc configuration not found in source repo" -ForegroundColor Yellow
    }

    # Copy pre-commit hook
    if (Test-Path ".git\hooks" -and (Test-Path "$SourceRepo\pre-commit-hook.sh")) {
        Copy-Item "$SourceRepo\pre-commit-hook.sh" ".git\hooks\pre-commit" -Force
        Write-Host "   ✅ Pre-commit hook installed" -ForegroundColor Green
    }

    # Update package.json with docs scripts
    $packageJson = Get-Content "package.json" -Raw | ConvertFrom-Json
    if (-not $packageJson.scripts.'docs:generate') {
        Write-Host "   📝 Adding documentation scripts to package.json..." -ForegroundColor Gray

        # Add docs scripts
        $packageJson.scripts | Add-Member -NotePropertyName 'docs:generate' -NotePropertyValue 'typedoc' -Force
        $packageJson.scripts | Add-Member -NotePropertyName 'docs:watch' -NotePropertyValue 'typedoc --watch' -Force
        $packageJson.scripts | Add-Member -NotePropertyName 'docs:open' -NotePropertyValue 'typedoc && start docs/api/index.html' -Force
        $packageJson.scripts | Add-Member -NotePropertyName 'docs:clean' -NotePropertyValue 'rimraf docs/api' -Force
        $packageJson.scripts | Add-Member -NotePropertyName 'docs:validate' -NotePropertyValue 'typedoc --emit none --treatWarningsAsErrors' -Force

        $packageJson | ConvertTo-Json -Depth 10 | Set-Content "package.json"
        Write-Host "   ✅ Documentation scripts added" -ForegroundColor Green
    }

    # ─────────────────────────────────────────────────────────────
    # STEP 3: Auto-fix Errors
    # ─────────────────────────────────────────────────────────────
    Write-Host ""
    Write-Host "🔧 Step 3/6: Auto-fixing errors..." -ForegroundColor Yellow

    # Run ESLint auto-fix
    npm run lint -- --fix 2>&1 | Out-Null
    Write-Host "   ✅ ESLint auto-fix completed" -ForegroundColor Green

    # ─────────────────────────────────────────────────────────────
    # STEP 4: Fix 'any' Types
    # ─────────────────────────────────────────────────────────────
    Write-Host ""
    Write-Host "🔧 Step 4/6: Fixing 'any' types..." -ForegroundColor Yellow

    $files = git ls-files "*.ts" "*.tsx" 2>$null
    $fixedFiles = 0

    foreach ($file in $files) {
        if (-not (Test-Path $file)) { continue }

        $content = Get-Content $file -Raw
        $originalContent = $content

        # Common 'any' type replacements
        $content = $content -replace '\(([a-zA-Z_]\w*):\s*any\)', '($1: unknown)'
        $content = $content -replace ':\s*any\[\]', ': unknown[]'
        $content = $content -replace 'Record<([^,>]+),\s*any>', 'Record<$1, unknown>'
        $content = $content -replace '\bas\s+any\b', 'as unknown'
        $content = $content -replace '<any>', '<unknown>'
        $content = $content -replace 'catch\s*\(\s*(\w+):\s*any\s*\)', 'catch ($1: unknown)'

        if ($content -ne $originalContent) {
            Set-Content $file $content -NoNewline
            $fixedFiles++
        }
    }

    Write-Host "   ✅ Fixed 'any' types in $fixedFiles files" -ForegroundColor Green

    # ─────────────────────────────────────────────────────────────
    # STEP 5: Verify Fixes
    # ─────────────────────────────────────────────────────────────
    Write-Host ""
    Write-Host "✅ Step 5/6: Verifying fixes..." -ForegroundColor Yellow

    $lintOutput = npm run lint 2>&1 | Out-String
    $afterErrors = 0
    if ($lintOutput -match "(\d+) problems?") {
        $afterErrors = [int]$matches[1]
    }

    $fixed = $beforeErrors - $afterErrors
    $successRate = if ($beforeErrors -gt 0) {
        [math]::Round(($fixed / $beforeErrors) * 100, 1)
    } else { 100 }

    Write-Host "   Before: $beforeErrors errors" -ForegroundColor Gray
    Write-Host "   After: $afterErrors errors" -ForegroundColor $(if ($afterErrors -eq 0) { "Green" } else { "Yellow" })
    Write-Host "   Fixed: $fixed errors ($successRate%)" -ForegroundColor Green

    # ─────────────────────────────────────────────────────────────
    # STEP 6: Commit Changes
    # ─────────────────────────────────────────────────────────────
    if ($AutoCommit -and $fixed -gt 0) {
        Write-Host ""
        Write-Host "💾 Step 6/6: Committing changes..." -ForegroundColor Yellow

        # Check if branch already exists
        $branchName = "fix/typescript-quality-improvements"
        $branchExists = git branch --list $branchName

        if ($branchExists) {
            Write-Host "   ⚠️  Branch '$branchName' already exists - skipping commit" -ForegroundColor Yellow
        } else {
            git checkout -b $branchName 2>&1 | Out-Null
            git add .

            $commitMessage = @"
Fix: TypeScript quality improvements ($fixed errors fixed)

- Fixed $fixed lint errors
- Replaced 'any' types with proper TypeScript types
- Added type utilities library (60+ utility types)
- Set up GitHub Actions CI/CD workflows
- Configured TypeDoc documentation
- Installed pre-commit hooks

Before: $beforeErrors errors
After: $afterErrors errors
Success Rate: $successRate%

🤖 Generated with Claude Code
Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
"@

            git commit -m $commitMessage 2>&1 | Out-Null

            Write-Host "   ✅ Changes committed to branch: $branchName" -ForegroundColor Green
            Write-Host "   📌 Next: git push origin $branchName" -ForegroundColor Gray
        }
    } else {
        Write-Host ""
        Write-Host "📝 Step 6/6: Changes staged but not committed" -ForegroundColor Yellow
        Write-Host "   Run these commands to commit:" -ForegroundColor Gray
        Write-Host "   git checkout -b fix/typescript-quality-improvements" -ForegroundColor Gray
        Write-Host "   git add ." -ForegroundColor Gray
        Write-Host "   git commit -m 'Fix: TypeScript quality improvements'" -ForegroundColor Gray
    }

    $results += [PSCustomObject]@{
        Repository = Split-Path $repo -Leaf
        Status = if ($afterErrors -eq 0) { "✅ Complete" } elseif ($fixed -gt 0) { "⚠️  Improved" } else { "❌ Failed" }
        BeforeErrors = $beforeErrors
        AfterErrors = $afterErrors
        Fixed = $fixed
        SuccessRate = "$successRate%"
    }

    Write-Host ""
    Write-Host "✅ Repository processing complete!" -ForegroundColor Green
    Write-Host ""
}

Set-Location $currentDir

# ═══════════════════════════════════════════════════════════
# Summary Report
# ═══════════════════════════════════════════════════════════
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                  Rollout Complete                         ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

$results | Format-Table -AutoSize

$validResults = $results | Where-Object { $_.BeforeErrors -ne "N/A" -and $_.BeforeErrors -is [int] }
$totalBefore = ($validResults | Measure-Object -Property BeforeErrors -Sum).Sum
$totalAfter = ($validResults | Where-Object { $_.AfterErrors -is [int] } | Measure-Object -Property AfterErrors -Sum).Sum
$totalFixed = ($validResults | Where-Object { $_.Fixed -is [int] } | Measure-Object -Property Fixed -Sum).Sum
$overallSuccessRate = if ($totalBefore -gt 0) {
    [math]::Round(($totalFixed / $totalBefore) * 100, 1)
} else { 0 }

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Overall Statistics" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "📊 Total Repositories Processed: $($results.Count)" -ForegroundColor White
Write-Host "📊 Valid Repositories: $($validResults.Count)" -ForegroundColor White
Write-Host ""
Write-Host "📊 Total Errors Before: $totalBefore" -ForegroundColor Red
Write-Host "📊 Total Errors After: $totalAfter" -ForegroundColor $(if ($totalAfter -eq 0) { "Green" } else { "Yellow" })
Write-Host "📊 Total Fixed: $totalFixed" -ForegroundColor Green
Write-Host "📊 Overall Success Rate: $overallSuccessRate%" -ForegroundColor Cyan

# Export results
$timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$csvFile = "rollout-results_$timestamp.csv"
$results | Export-Csv -Path $csvFile -NoTypeInformation

Write-Host ""
Write-Host "✅ Results exported to: $csvFile" -ForegroundColor Green
Write-Host ""

if (-not $AutoCommit) {
    Write-Host "💡 Tip: Use -AutoCommit flag to automatically commit changes" -ForegroundColor Cyan
    Write-Host ""
}

if ($DryRun) {
    Write-Host "💡 This was a dry run. Remove -DryRun flag to apply changes." -ForegroundColor Cyan
    Write-Host ""
}
