# Mount VPS with maximum debugging
Write-Host "Testing SSHFS mount with maximum debug output..." -ForegroundColor Cyan
Write-Host ""

$env:SSHFS_DEBUG = "1"

$arguments = @(
    "root@138.199.218.115:/mnt/storage",
    "X:",
    "-o", "IdentityFile=C:/2025-claude-code-laptop/projects/vps-management/ssh-keys/fedora-vps-key",
    "-o", "StrictHostKeyChecking=no",
    "-o", "ServerAliveInterval=15",
    "-o", "ServerAliveCountMax=3",
    "-o", "volname=VPS-Storage",
    "-o", "sshfs_debug",
    "-f",
    "-d"
)

Write-Host "Command: `"C:\Program Files\SSHFS-Win\bin\sshfs.exe`" $($arguments -join ' ')" -ForegroundColor Yellow
Write-Host ""
Write-Host "Running with full debug output (press Ctrl+C to stop):" -ForegroundColor Yellow
Write-Host "================================================================" -ForegroundColor Gray

& "C:\Program Files\SSHFS-Win\bin\sshfs.exe" $arguments

Write-Host ""
Write-Host "================================================================" -ForegroundColor Gray
Write-Host "SSHFS process ended." -ForegroundColor Yellow
Read-Host "Press Enter to exit"
