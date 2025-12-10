# PowerShell Danger Mode - Execution Policy Guide

**Created:** 2025-12-07
**Purpose:** Running PowerShell scripts with maximum permissions

---

## Option 1: Set Execution Policy to Bypass (Current Session Only)

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
```

This only affects the current PowerShell window and is safe.

## Option 2: Unrestricted Execution Policy (Permanent - USE WITH CAUTION)

```powershell
# For current user only (safer)
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -Force

# For entire machine (requires Admin - DANGEROUS)
Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy Unrestricted -Force
```

## Option 3: Run Individual Scripts with Bypass (Safest)

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\your-script.ps1
```

This is what we've been using - it's the safest "danger mode" option.

## Option 4: Full Admin + Unrestricted (MAXIMUM DANGER)

```powershell
# Run PowerShell as Administrator, then:
Set-ExecutionPolicy Unrestricted -Force

# Now run your script
.\your-script.ps1
```

## Current Recommended Approach

For our lint fix scripts, continue using:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\log-fix-session.ps1 -Phase manual
```

## If You Need to Bypass Additional Safety Checks

If you're asking about the script's internal safety checks, scripts can be modified to add a `-Force` or `-DangerMode` parameter that skips validation.

**Common scenarios:**
- Skip worktree validation
- Skip npm install checks
- Skip error handling
- Force overwrite files
- Skip confirmation prompts

---

## Security Implications

### Bypass (Recommended)
- ✅ Safe for trusted scripts
- ✅ Only affects current session
- ✅ No permanent system changes

### Unrestricted (Caution)
- ⚠️ Allows all scripts to run
- ⚠️ Permanent change
- ⚠️ Security risk if running untrusted scripts

### RemoteSigned (Default)
- ✅ Secure default
- ⚠️ Requires scripts to be signed or local
- ℹ️ Standard Windows setting

---

## Checking Current Policy

```powershell
Get-ExecutionPolicy -List
```

Output shows policies for each scope:
- MachinePolicy
- UserPolicy
- Process
- CurrentUser
- LocalMachine

---

## Reverting to Default

```powershell
# Remove user-level policy
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Undefined

# System will fall back to RemoteSigned (default)
```

---

**Status:** Reference guide
**Use Case:** Running PowerShell scripts in calculator-website project
