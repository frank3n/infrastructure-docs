# Install pre-commit hooks for all worktrees
# Prevents TypeScript 'any' types from being committed

$MainRepo = "C:\github-claude\calculator-website-test"
$HookSource = "C:\github-claude\pre-commit-hook.sh"

Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     Installing Pre-commit Hooks for All Worktrees         ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Check if hook source exists
if (-not (Test-Path $HookSource)) {
    Write-Host "❌ Error: Hook file not found at $HookSource" -ForegroundColor Red
    exit 1
}

# Install hook in main repository
Write-Host "📦 Installing hook in main repository..." -ForegroundColor Yellow
$mainHookPath = Join-Path $MainRepo ".git\hooks\pre-commit"
$mainHookDir = Split-Path $mainHookPath -Parent

if (-not (Test-Path $mainHookDir)) {
    New-Item -ItemType Directory -Path $mainHookDir -Force | Out-Null
}

Copy-Item $HookSource $mainHookPath -Force
Write-Host "   ✅ Installed: $mainHookPath" -ForegroundColor Green

# Get all worktrees
Set-Location $MainRepo
$worktrees = git worktree list --porcelain | Select-String "^worktree " | ForEach-Object { $_.ToString().Replace("worktree ", "") }

$installedCount = 1  # Main repo

foreach ($worktreePath in $worktrees) {
    if ($worktreePath -eq $MainRepo) {
        continue  # Skip main repo (already installed)
    }

    Write-Host ""
    Write-Host "📦 Processing worktree: $worktreePath" -ForegroundColor Yellow

    # Check if worktree has .git file (linked worktree)
    $gitFile = Join-Path $worktreePath ".git"

    if (Test-Path $gitFile -PathType Leaf) {
        # Read the git directory path from .git file
        $gitDirContent = Get-Content $gitFile
        $gitDirPath = $gitDirContent -replace "gitdir: ", ""

        # Handle relative paths
        if (-not [System.IO.Path]::IsPathRooted($gitDirPath)) {
            $gitDirPath = Join-Path $worktreePath $gitDirPath
            $gitDirPath = [System.IO.Path]::GetFullPath($gitDirPath)
        }

        $hookPath = Join-Path $gitDirPath "hooks\pre-commit"
        $hookDir = Split-Path $hookPath -Parent

        if (-not (Test-Path $hookDir)) {
            New-Item -ItemType Directory -Path $hookDir -Force | Out-Null
        }

        Copy-Item $HookSource $hookPath -Force
        Write-Host "   ✅ Installed: $hookPath" -ForegroundColor Green
        $installedCount++
    }
    elseif (Test-Path (Join-Path $worktreePath ".git") -PathType Container) {
        # Regular .git directory
        $hookPath = Join-Path $worktreePath ".git\hooks\pre-commit"
        $hookDir = Split-Path $hookPath -Parent

        if (-not (Test-Path $hookDir)) {
            New-Item -ItemType Directory -Path $hookDir -Force | Out-Null
        }

        Copy-Item $HookSource $hookPath -Force
        Write-Host "   ✅ Installed: $hookPath" -ForegroundColor Green
        $installedCount++
    }
    else {
        Write-Host "   ⚠️  Skipped: No .git found" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                  Installation Complete!                    ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "✅ Installed pre-commit hooks in $installedCount location(s)" -ForegroundColor Green
Write-Host ""
Write-Host "📋 What this does:" -ForegroundColor Cyan
Write-Host "   • Blocks commits containing TypeScript 'any' types" -ForegroundColor White
Write-Host "   • Maintains code quality automatically" -ForegroundColor White
Write-Host "   • Runs before every git commit" -ForegroundColor White
Write-Host ""
Write-Host "🧪 To test the hook:" -ForegroundColor Cyan
Write-Host '   echo "const test: any = 1;" > test.ts' -ForegroundColor Gray
Write-Host "   git add test.ts" -ForegroundColor Gray
Write-Host '   git commit -m "test"  # Should be blocked' -ForegroundColor Gray
Write-Host ""
Write-Host "⚠️  To bypass (emergency only):" -ForegroundColor Yellow
Write-Host "   git commit --no-verify" -ForegroundColor Gray
Write-Host ""
