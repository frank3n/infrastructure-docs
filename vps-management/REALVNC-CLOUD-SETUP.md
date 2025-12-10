# RealVNC Cloud Connection Setup

## What You Have Now

✅ RealVNC Server 7.15.0 installed on your VPS
✅ Virtual Mode daemon running
✅ Ready for cloud connectivity

## Getting a Cloud Connection Code

### Step 1: Create a RealVNC Account (Free)

1. Go to https://www.realvnc.com/en/connect/
2. Click "Sign up" or "Get started"
3. Choose the **FREE** plan (supports up to 5 devices)
4. Complete registration

### Step 2: Get Your Join Token

1. Log in to https://manage.realvnc.com
2. Navigate to **Devices** → **Deployment**
3. Click **"Create join token"** or **"Get deployment token"**
4. Copy the token (looks like: `ey...` or a long string)

### Step 3: Join Your VPS to the Cloud

Run this command on your local machine (replace TOKEN with your actual token):

```bash
ssh fedora-vps "sudo vncserver-x11 -virtual -joincloud TOKEN -joinname 'Fedora-VPS'"
```

Example:
```bash
ssh fedora-vps "sudo vncserver-x11 -virtual -joincloud eyJhbGciOiJIUzI1NiIsInR5... -joinname 'Fedora-VPS'"
```

### Step 4: Connect from Anywhere

1. Download **RealVNC Viewer**: https://www.realvnc.com/en/connect/download/viewer/
2. Open RealVNC Viewer
3. Sign in with your RealVNC account
4. Your VPS will appear in "Your Team" devices
5. Click to connect - no port forwarding or SSH tunnel needed!

## Quick Command Reference

### Check Cloud Status
```bash
ssh fedora-vps "vncserver-x11 -virtual -cloudstatus"
```

### Leave Cloud (Disconnect)
```bash
ssh fedora-vps "sudo vncserver-x11 -virtual -leavecloud"
```

### Rejoin Cloud
```bash
ssh fedora-vps "sudo vncserver-x11 -virtual -joincloud TOKEN -rejoin"
```

## Alternative: Direct Connection (Without Cloud)

If you don't want to use cloud connectivity, you can still use direct connection:

### Start VNC Virtual Session
```bash
ssh fedora-vps "vncserver-virtual :1"
```

### Connect via SSH Tunnel
```bash
# Create tunnel
ssh -L 5901:localhost:5901 fedora-vps

# Connect VNC viewer to localhost:5901
```

## RealVNC Free vs Paid

| Feature | Free | Professional | Enterprise |
|---------|------|--------------|------------|
| Devices | Up to 5 | Up to 10 | Unlimited |
| Cloud Connect | ✅ Yes | ✅ Yes | ✅ Yes |
| File Transfer | ✅ Yes | ✅ Yes | ✅ Yes |
| Chat | ✅ Yes | ✅ Yes | ✅ Yes |
| Session Recording | ❌ No | ✅ Yes | ✅ Yes |
| MFA | ❌ No | ✅ Yes | ✅ Yes |

**Free plan is perfect for personal use!**

## Benefits of Cloud Connect

✅ **No port forwarding needed**
✅ **No firewall configuration**
✅ **Connect from anywhere** (mobile, tablet, any computer)
✅ **Automatic reconnection** if connection drops
✅ **256-bit AES encryption**
✅ **File transfer built-in**
✅ **Clipboard sharing**
✅ **Chat with remote user**

## Troubleshooting

### "Failed to join cloud"
- Check your internet connection
- Verify the token is correct and not expired
- Make sure virtuald service is running: `sudo systemctl status vncserver-virtuald`

### "Device already joined"
- If you need to rejoin, use `-rejoin` flag
- Or leave cloud first, then rejoin

### Check Service Status
```bash
ssh fedora-vps "sudo systemctl status vncserver-virtuald.service"
```

### View Logs
```bash
ssh fedora-vps "sudo journalctl -u vncserver-virtuald.service -n 50"
```

## Security Notes

- Cloud connections are end-to-end encrypted
- RealVNC uses industry-standard security protocols
- Your VPS never exposes VNC ports to the internet
- All traffic goes through RealVNC's secure relay servers
- You can revoke device access anytime from your RealVNC account

## Next Steps

1. **Create your free RealVNC account**: https://www.realvnc.com/en/connect/
2. **Get your join token** from the deployment section
3. **Run the join command** (see Step 3 above)
4. **Download RealVNC Viewer** and sign in
5. **Connect to your VPS** - it will appear in your device list!

---

**Pro Tip**: Once joined to the cloud, you can connect from your phone or tablet using the RealVNC Viewer mobile app!
