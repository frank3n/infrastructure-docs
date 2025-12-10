#!/bin/bash
# Script to add SSH key to VPS

SERVER="138.199.218.115"
USER="root"
PASSWORD="V9AkbrTAx74xdRfKdHnh"
PUBKEY=$(cat ssh-keys/fedora-vps-key.pub)

# Using SSH with password (requires manual password entry or sshpass)
echo "Adding SSH key to $SERVER..."
echo "You will be prompted for the password: $PASSWORD"

ssh -o StrictHostKeyChecking=no $USER@$SERVER << EOF
mkdir -p ~/.ssh
echo "$PUBKEY" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh
echo "Key added successfully!"
exit
EOF
