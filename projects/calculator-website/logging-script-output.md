# Logging PowerShell Script Output

## Overview
Several methods to run the `setup-worktrees.ps1` script and save output to a log file simultaneously.

## Option 1: Using Tee-Object (Recommended)
Shows output on screen AND saves to file:

```powershell
.\setup-worktrees.ps1 | Tee-Object -FilePath "setup-log.txt"
```

**Pros:**
- See output in real-time
- Output saved to file
- Simple syntax

**Cons:**
- Only captures standard output by default

## Option 2: Capture All Output Streams
Includes errors, warnings, and verbose output:

```powershell
.\setup-worktrees.ps1 *>&1 | Tee-Object -FilePath "setup-log.txt"
```

**Pros:**
- Captures ALL output (errors, warnings, info)
- Shows on screen while logging
- Best for debugging

**Cons:**
- None

## Option 3: Using Start-Transcript
Logs the entire PowerShell session:

```powershell
Start-Transcript -Path "setup-log.txt"
.\setup-worktrees.ps1
Stop-Transcript
```

**Pros:**
- Captures everything including commands typed
- Good for full session recording

**Cons:**
- Requires manual start/stop
- Includes extra transcript metadata

## Option 4: Redirect to File Only
Saves to file without showing on screen:

```powershell
# Standard output only
.\setup-worktrees.ps1 > setup-log.txt

# All output streams (errors, warnings, etc.)
.\setup-worktrees.ps1 *> setup-log.txt
```

**Pros:**
- Simple syntax
- Fast

**Cons:**
- No screen output (can't monitor progress)

## Option 5: Append to Existing Log
Useful for running multiple times:

```powershell
.\setup-worktrees.ps1 | Tee-Object -FilePath "setup-log.txt" -Append
```

**Pros:**
- Keeps history of multiple runs
- Doesn't overwrite previous logs

**Cons:**
- Log file can grow large

## Recommended Commands

### For Single Run with Timestamped Log
```powershell
.\setup-worktrees.ps1 *>&1 | Tee-Object -FilePath "C:\github-claude\calculator-website-test\setup-log-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').txt"
```

Creates a log file like: `setup-log-2025-12-07-143052.txt`

### For Multiple Runs with Append
```powershell
$logFile = "C:\github-claude\calculator-website-test\setup-log.txt"
"=== Run started: $(Get-Date) ===" | Out-File -FilePath $logFile -Append
.\setup-worktrees.ps1 *>&1 | Tee-Object -FilePath $logFile -Append
```

### Quick and Simple
```powershell
.\setup-worktrees.ps1 | Tee-Object setup-log.txt
```

## Understanding Output Streams

PowerShell has multiple output streams:

- **Stream 1:** Success/Standard output
- **Stream 2:** Errors
- **Stream 3:** Warnings
- **Stream 4:** Verbose
- **Stream 5:** Debug
- **Stream 6:** Information

### Redirection Examples

```powershell
# Only errors
.\setup-worktrees.ps1 2> errors.txt

# Only warnings
.\setup-worktrees.ps1 3> warnings.txt

# All streams to one file
.\setup-worktrees.ps1 *> all-output.txt

# All streams to screen AND file
.\setup-worktrees.ps1 *>&1 | Tee-Object all-output.txt
```

## Important Notes

1. **Colored Output:** The colored output (Green, Cyan, Yellow, Red) from `Write-Host` won't appear with colors in the log file, but all text will be captured.

2. **File Encoding:** PowerShell uses UTF-16 LE by default for `Out-File`. To use UTF-8:
   ```powershell
   .\setup-worktrees.ps1 | Tee-Object -FilePath "setup-log.txt" | Out-File -Encoding UTF8
   ```

3. **Real-time Logging:** `Tee-Object` buffers output. For truly real-time logging, consider using `Start-Transcript`.

4. **Log Location:** Relative paths (like `setup-log.txt`) create the log in your current directory. Use absolute paths for consistency.

## Example Session

```powershell
# Navigate to script directory
cd C:\github-claude

# Run with full logging and timestamped file
.\setup-worktrees.ps1 *>&1 | Tee-Object -FilePath "C:\github-claude\calculator-website-test\setup-log-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').txt"
```

This will:
- Show all output on screen in real-time
- Save everything to a timestamped log file
- Include errors, warnings, and all other output
- Create a permanent record of the setup process

## Viewing Log Files

```powershell
# View entire log
Get-Content setup-log.txt

# View last 50 lines
Get-Content setup-log.txt -Tail 50

# Search for errors
Select-String -Path setup-log.txt -Pattern "error|failed|✗"

# Open in default text editor
notepad setup-log.txt
```
