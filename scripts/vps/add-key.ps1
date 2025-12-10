# PowerShell script to add SSH key to VPS
$password = "V9AkbrTAx74xdRfKdHnh"
$server = "138.199.218.115"
$user = "root"
$pubKey = Get-Content "ssh-keys/fedora-vps-key.pub"

# Use plink if available, otherwise provide manual instructions
$plinkPath = Get-Command plink -ErrorAction SilentlyContinue

if ($plinkPath) {
    echo $password | plink -ssh -batch -pw $password $user@$server "mkdir -p ~/.ssh && echo '$pubKey' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && chmod 700 ~/.ssh && echo 'Key added successfully'"
} else {
    Write-Host "Installing plink is recommended. For now, using alternative method..."

    # Create a temporary file with the commands
    $commands = @"
mkdir -p ~/.ssh
echo '$pubKey' >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh
echo 'Key added successfully'
"@

    $commands | ssh -o StrictHostKeyChecking=no $user@$server
}
