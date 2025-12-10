# Batch fix TypeScript 'any' errors in API route files
$routesPath = "C:\github-claude\calculator-website-test\claude\calculator-affiliate-niches-01LXPQjEUAmFJPm6NjT3Jz6E\api\src\routes"
$servicesPath = "C:\github-claude\calculator-website-test\claude\calculator-affiliate-niches-01LXPQjEUAmFJPm6NjT3Jz6E\api\src\services"

$helperFunction = @"
// Helper function to safely extract error message
function getErrorMessage(error: unknown): string {
  if (error instanceof Error) return error.message
  return String(error)
}
"@

$filesToFix = @(
    "$routesPath\scheduler.ts",
    "$routesPath\sessions.ts",
    "$routesPath\queue.ts",
    "$routesPath\reports.ts",
    "$routesPath\test.ts",
    "$routesPath\webhooks.ts",
    "$servicesPath\linkTester.ts",
    "$servicesPath\ipVerification.ts",
    "$servicesPath\requestQueue.ts",
    "$servicesPath\scheduler.ts",
    "$servicesPath\webhooks.ts",
    "$servicesPath\reports.ts"
)

$fixedCount = 0
$totalErrors = 0

foreach ($file in $filesToFix) {
    if (!(Test-Path $file)) {
        Write-Host "Skipping $file (not found)" -ForegroundColor Yellow
        continue
    }

    Write-Host "Processing: $file" -ForegroundColor Cyan
    $content = Get-Content $file -Raw
    $originalContent = $content

    # Count errors before
    $errorsBefore = ([regex]::Matches($content, 'error: any')).Count

    # Add helper function if not present and there are error: any
    if ($content -notmatch 'function getErrorMessage' -and $content -match 'error: any') {
        # Find 'const router = Router()' and add after it
        if ($content -match '(const router = Router\(\))') {
            $content = $content -replace '(const router = Router\(\))', "`$1`n`n$helperFunction"
        }
        # Or find first export/function and add before it
        elseif ($content -match '(export .+?(?:function|const))') {
            $content = $content -replace '(export .+?(?:function|const))', "$helperFunction`n`n`$1"
        }
    }

    # Replace error: any with error: unknown
    $content = $content -replace '(\s+)\} catch \(error: any\) \{', '$1} catch (error: unknown) {'

    # Replace error.message with getErrorMessage(error)
    $content = $content -replace 'error\.message \|\| ''Internal server error''', "getErrorMessage(error) || 'Internal server error'"
    $content = $content -replace 'error\.message \|\| "Internal server error"', 'getErrorMessage(error) || "Internal server error"'
    $content = $content -replace 'error\.message \|\|', 'getErrorMessage(error) ||'

    # Count errors after
    $errorsAfter = ([regex]::Matches($content, 'error: any')).Count
    $errorsFixed = $errorsBefore - $errorsAfter

    if ($content -ne $originalContent) {
        Set-Content $file $content -NoNewline
        Write-Host "  ✓ Fixed $errorsFixed errors" -ForegroundColor Green
        $fixedCount++
        $totalErrors += $errorsFixed
    } else {
        Write-Host "  No changes needed" -ForegroundColor Gray
    }
}

Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "Batch Fix Complete!" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Files processed: $fixedCount" -ForegroundColor Green
Write-Host "Total errors fixed: $totalErrors" -ForegroundColor Green
