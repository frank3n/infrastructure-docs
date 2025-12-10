# Mount VPS storage to X: drive using SSHFS
Write-Host "Mounting VPS storage to X: drive..." -ForegroundColor Cyan

$sshfsPath = "C:\Program Files\SSHFS-Win\bin\sshfs.exe"
$keyPath = "C:/2025-claude-code-laptop/projects/vps-management/ssh-keys/fedora-vps-key"
$vpsHost = "root@138.199.218.115"
$remotePath = "/mnt/storage"
$driveLetter = "X:"

# Build the arguments
$arguments = @(
    "$vpsHost`:$remotePath",
    $driveLetter,
    "-o", "IdentityFile=`"$keyPath`"",
    "-o", "StrictHostKeyChecking=no",
    "-o", "ServerAliveInterval=15",
    "-o", "ServerAliveCountMax=3",
    "-o", "reconnect",
    "-o", "volname=VPS-Storage"
)

Write-Host "Executing: $sshfsPath" -ForegroundColor Yellow
Write-Host "Arguments: $($arguments -join ' ')" -ForegroundColor Yellow
Write-Host ""

try {
    # Start the process and capture output
    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName = $sshfsPath
    $processInfo.Arguments = $arguments -join " "
    $processInfo.UseShellExecute = $false
    $processInfo.RedirectStandardOutput = $true
    $processInfo.RedirectStandardError = $true
    $processInfo.CreateNoWindow = $false

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $processInfo
    $process.Start() | Out-Null

    Write-Host "SSHFS process started (PID: $($process.Id))" -ForegroundColor Green
    Write-Host "Waiting for mount to initialize..." -ForegroundColor Yellow
    Start-Sleep -Seconds 3

    # Check if drive is accessible
    if (Test-Path $driveLetter) {
        Write-Host ""
        Write-Host "SUCCESS: X: drive is mounted!" -ForegroundColor Green
        Write-Host "You can now access your VPS storage at X: drive in Windows Explorer" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "WARNING: X: drive not yet accessible. The mount may still be initializing." -ForegroundColor Yellow
        Write-Host "Check if the SSHFS process is still running." -ForegroundColor Yellow
    }

    # Capture any error output
    if (!$process.HasExited) {
        $stderr = $process.StandardError.ReadToEnd()
        if ($stderr) {
            Write-Host ""
            Write-Host "Error output:" -ForegroundColor Red
            Write-Host $stderr -ForegroundColor Red
        }
    }
} catch {
    Write-Host ""
    Write-Host "ERROR: Failed to start SSHFS" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host ""
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
