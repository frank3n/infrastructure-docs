# GitHub Personal Access Token - Permissions Guide

## 🔐 Do You Need GitHub Token Permissions?

### Short Answer
**For basic Git Worktrees setup: NO, you don't need a GitHub token.**

Git Worktrees work with standard Git operations (clone, fetch, pull, push) which use:
- HTTPS authentication (username + password/token)
- SSH keys (recommended)
- No special API access needed

### When You DO Need a GitHub Token
The GitHub MCP server in your cline_mcp_settings.json needs a token for:
- Creating/managing GitHub issues via Cline
- Accessing repository metadata via API
- Managing pull requests
- GitHub Actions integration
- Private repository access via API

---

## 🎯 For Multi-Branch Testing (Git Worktrees)

### Option 1: SSH Keys (Recommended)
**No GitHub token needed!**

```bash
# Git Bash - Check if you have SSH keys
ls -al ~/.ssh

# If you see id_rsa and id_rsa.pub, you're set!
# If not, create SSH key:
ssh-keygen -t ed25519 -C "your_email@example.com"

# Add to GitHub:
# 1. Copy public key: cat ~/.ssh/id_ed25519.pub
# 2. Go to https://github.com/settings/keys
# 3. Click "New SSH key"
# 4. Paste your public key
```

**Clone with SSH:**
```bash
# Use this in setup-worktrees.ps1
git clone git@github.com:frank3n/calculator-website.git
```

### Option 2: HTTPS with Personal Access Token
If you prefer HTTPS or have issues with SSH:

```bash
# Use token as password when prompted
git clone https://github.com/frank3n/calculator-website.git
# Username: your_github_username
# Password: your_personal_access_token
```

### Option 3: HTTPS with Credential Manager (Windows)
**No manual token needed!**

Windows Credential Manager stores your credentials automatically.

```bash
# First time: enter username and password
git clone https://github.com/frank3n/calculator-website.git

# Windows stores credentials
# Future operations: no password needed
```

---

## 🔑 GitHub Token Permissions (If You Need One)

### For MCP Server (in your cline_mcp_settings.json)

Your current config shows:
```json
"github": {
  "env": {
    "GITHUB_PERSONAL_ACCESS_TOKEN": "your_github_token_here"
  }
}
```

### Required Permissions for GitHub MCP:
Go to https://github.com/settings/tokens → Generate new token (classic)

**Minimal Permissions Needed:**
- ✅ **repo** (Full control of private repositories)
  - Required for accessing repository contents
  - Needed for issues, PRs, commits
  
**Optional (based on what you want to do):**
- ✅ **workflow** (if using GitHub Actions)
- ✅ **read:org** (if working with organization repos)
- ✅ **read:user** (for user information)

**Not Needed for Basic Git Operations:**
- ❌ admin:org
- ❌ delete_repo
- ❌ admin:repo_hook

### Creating the Token

1. **Go to GitHub Settings**
   - https://github.com/settings/tokens
   - Click "Generate new token (classic)"

2. **Configure Token**
   - Note: "Cline MCP Server - Calculator Website"
   - Expiration: 90 days (or your preference)
   - Select scopes:
     - [x] repo (all sub-items)
     - [x] workflow (if needed)

3. **Generate and Copy**
   - Click "Generate token"
   - **Copy immediately** (you won't see it again!)
   - Store in password manager

4. **Update Your Config**
   ```json
   {
     "github": {
       "env": {
         "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxxxxxxxxxxxxxxxxxxx"
       }
     }
   }
   ```

---

## 🛠️ Recommended Setup for Your Use Case

### For Git Worktrees (Multi-Branch Testing)

**Best Option: SSH Keys**
```bash
# Git Bash - One-time setup
ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519.pub  # Copy this

# Add to GitHub: https://github.com/settings/keys
```

**Update setup-worktrees.ps1:**
```powershell
# Change line:
$RepoUrl = "git@github.com:frank3n/calculator-website.git"
# Instead of:
$RepoUrl = "https://github.com/frank3n/calculator-website.git"
```

### For Cline MCP GitHub Server

**Create Token with 'repo' permissions:**
1. https://github.com/settings/tokens
2. Generate new token (classic)
3. Select: [x] repo
4. Copy token
5. Update C:\Users\Administrator\AppData\Roaming\Claude\claude_desktop_config.json

---

## 📋 Quick Decision Guide

```
Do you need to use Git Worktrees?
│
├─ YES → Do you have SSH keys setup?
│        │
│        ├─ YES → ✅ No token needed! Use SSH clone
│        │
│        └─ NO → Choose:
│               ├─ Setup SSH keys (recommended)
│               ├─ Use HTTPS with Windows Credential Manager
│               └─ Use HTTPS with Personal Access Token
│
└─ Want to use Cline MCP GitHub features?
         │
         └─ YES → ✅ Create token with 'repo' permissions
                   Update cline_mcp_settings.json
```

---

## 🔒 Security Best Practices

### For Personal Access Tokens

1. **Never Commit Tokens**
   ```bash
   # Add to .gitignore
   echo "*.token" >> .gitignore
   echo ".env.local" >> .gitignore
   echo "config/*token*" >> .gitignore
   ```

2. **Use Minimal Permissions**
   - Only enable what you need
   - Review permissions regularly
   - Regenerate if compromised

3. **Set Expiration**
   - Use 90-day expiration
   - Create calendar reminder to renew
   - Rotate tokens regularly

4. **Store Securely**
   - Use password manager (1Password, Bitwarden, KeePass)
   - Never in plain text files
   - Never in code comments

5. **Monitor Usage**
   - Check https://github.com/settings/tokens
   - Review "Last used" dates
   - Delete unused tokens

### For SSH Keys

1. **Use Passphrase**
   ```bash
   # When creating key:
   ssh-keygen -t ed25519 -C "email@example.com"
   # Enter passphrase when prompted
   ```

2. **Use SSH Agent**
   ```bash
   # Git Bash
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_ed25519
   ```

3. **Backup Keys**
   - Store private key backup securely
   - Never share private key
   - Public key can be shared freely

---

## 🧪 Testing Your Setup

### Test SSH Connection
```bash
# Git Bash
ssh -T git@github.com

# Expected output:
# Hi username! You've successfully authenticated...
```

### Test HTTPS Connection
```bash
# Git Bash
git clone https://github.com/frank3n/calculator-website.git test-clone
cd test-clone
git fetch

# If prompted for password, enter token
```

### Test Git Worktrees
```bash
# Git Bash
cd C:\github-code\calculator-website-test
git worktree list

# Should show all your worktrees
```

---

## 📝 Summary

### For Multi-Branch Testing (Git Worktrees)
- ❌ **No GitHub API token required**
- ✅ **Use SSH keys** (recommended)
- ✅ **Or HTTPS with Windows Credential Manager**
- ✅ **Or HTTPS with Personal Access Token**

### For Cline MCP GitHub Integration
- ✅ **Requires Personal Access Token**
- ✅ **Needs 'repo' permission**
- ✅ **Already configured in your cline_mcp_settings.json**
- ⚠️ **Replace "your_github_token_here" with actual token**

### Your Updated cline_mcp_settings.json
```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_YourActualTokenHere"
      }
    }
  }
}
```

---

## 🎯 Recommended Next Steps

1. **For Git Worktrees:**
   ```bash
   # Option A: Setup SSH (one-time, 5 minutes)
   ssh-keygen -t ed25519 -C "your@email.com"
   # Add to GitHub: https://github.com/settings/keys
   
   # Option B: Use HTTPS (just works with Windows)
   # No additional setup needed
   ```

2. **For GitHub MCP (if you want to use it):**
   ```
   1. Go to: https://github.com/settings/tokens
   2. Generate new token (classic)
   3. Select: [x] repo
   4. Copy token
   5. Update: cline_mcp_settings.json
   ```

3. **Test Everything:**
   ```powershell
   # PowerShell 7
   cd C:\github-claude
   .\setup-worktrees.ps1 -Branches @("main")
   ```

---

**Questions?**
- Check GitHub Docs: https://docs.github.com/en/authentication
- SSH Setup: https://docs.github.com/en/authentication/connecting-to-github-with-ssh
- Token Setup: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token
