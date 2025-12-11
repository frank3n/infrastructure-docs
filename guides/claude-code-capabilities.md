# Claude Code - Capabilities and Limitations

**Date**: December 11, 2025
**Tool**: Claude Code CLI

---

## What is Claude Code?

Claude Code is a **command-line interface (CLI) tool** that runs in your terminal. It's different from the web-based Claude interfaces and has specific capabilities and limitations.

---

## What Claude Code CAN Access ✅

### 1. Current Conversation
- ✅ Full history of the current CLI session
- ✅ All messages and responses in this conversation
- ✅ Context from earlier in the session
- ✅ Conversation summaries when context gets large

### 2. Local Files and Directories
- ✅ Read files on your local machine
- ✅ Write and edit files
- ✅ Search through codebases
- ✅ Execute bash commands
- ✅ Run scripts and tools

### 3. Remote Systems (via SSH)
- ✅ Access VPS servers via SSH
- ✅ Run commands on remote systems
- ✅ Read/write files on remote servers
- ✅ Deploy applications
- ✅ Check server status

### 4. Development Tools
- ✅ Git operations (clone, commit, push, etc.)
- ✅ npm/yarn commands
- ✅ Build tools and compilers
- ✅ Test runners
- ✅ Linters and formatters

### 5. GitHub Integration (via gh CLI)
- ✅ Clone repositories
- ✅ Create branches
- ✅ Create pull requests
- ✅ List issues
- ✅ Manage repositories

### 6. Background Processes
- ✅ Monitor running background tasks
- ✅ Check output from long-running commands
- ✅ Track server processes

---

## What Claude Code CANNOT Access ❌

### 1. Web-Based Claude Interfaces
- ❌ **Cannot access claude.ai/code**
- ❌ Cannot see chat logs from web interface
- ❌ Cannot access conversations sorted by GitHub repos
- ❌ Cannot browse web-based chat history
- ❌ Cannot access other Claude web features

### 2. Other Chat Sessions
- ❌ Cannot access previous CLI sessions (unless you provide summary)
- ❌ Cannot see conversations from other users
- ❌ Cannot access shared conversation links
- ❌ No persistent memory between sessions

### 3. External Websites
- ❌ Cannot browse arbitrary websites (has WebFetch but limited)
- ❌ Cannot access private web dashboards
- ❌ Cannot log into web services
- ❌ Cannot see your browser tabs or history

### 4. System Information Beyond Tools
- ❌ Cannot see what's in your clipboard
- ❌ Cannot access GUI applications
- ❌ Cannot see your desktop
- ❌ Cannot access files without explicit permission

---

## Key Differences: Claude Code vs claude.ai/code

| Feature | Claude Code (CLI) | claude.ai/code (Web) |
|---------|-------------------|----------------------|
| **Interface** | Terminal/Command Line | Web Browser |
| **File Access** | Direct filesystem access | Limited, requires explicit sharing |
| **Conversation History** | Current session only | Persistent across sessions |
| **GitHub Integration** | Full via gh CLI | Via GitHub OAuth |
| **Chat Organization** | Single active session | Multiple chats, sortable by repo |
| **Session Continuity** | Requires summaries | Automatic |
| **SSH Access** | Direct SSH commands | Not available |
| **Background Tasks** | Can monitor multiple | Limited |

---

## How to Share Information from claude.ai/code

If you need Claude Code to reference information from a previous claude.ai/code session:

### Option 1: Copy and Paste
```
1. Open the chat on claude.ai/code
2. Copy the relevant messages or information
3. Paste into Claude Code CLI conversation
4. Claude Code can now see and use that information
```

### Option 2: Save to File
```bash
# Save chat content to a file
cat > previous-chat.md << 'EOF'
[Paste your chat content here]
EOF

# Ask Claude Code to read it
# Claude Code will then read the file
```

### Option 3: Export Documentation
```
1. If the chat contains documentation or code
2. Save it to a file in your project
3. Claude Code can read and work with it
```

---

## Best Practices

### When Using Claude Code CLI

1. **Provide Context**
   - Claude Code only knows what you tell it
   - If referencing previous work, provide summaries
   - Include relevant file paths and commands

2. **Use Files for Persistence**
   - Save important information to files
   - Create documentation as you work
   - Use Git to track changes

3. **Leverage Tools**
   - Use Read tool for files
   - Use Bash for system commands
   - Use Git for version control

4. **Session Management**
   - Claude Code sessions can be continued via summaries
   - Important context can be preserved in project files
   - Document decisions and configurations

### When Switching Between Interfaces

1. **From Web to CLI**
   - Save important code/docs from web chat to files
   - Copy configuration details to your project
   - Use Git to sync across sessions

2. **From CLI to Web**
   - Commit changes to Git
   - Push to GitHub
   - Web interface can reference the repository

---

## Common Questions

### Q: Can Claude Code see my chat history on claude.ai/code?
**A**: No. Claude Code (CLI) and claude.ai/code (web) are separate interfaces with separate conversation histories.

### Q: How do I give Claude Code context from a previous chat?
**A**: Copy relevant information from the web chat and paste it into the CLI conversation, or save it to a file.

### Q: Can Claude Code access GitHub repos discussed in web chats?
**A**: Only if you explicitly clone them or tell Claude Code about them. It cannot see what was discussed in other interfaces.

### Q: Does Claude Code remember previous CLI sessions?
**A**: Not automatically. Sessions can be continued via summaries, but there's no automatic memory between sessions.

### Q: Can I use both Claude Code and claude.ai/code together?
**A**: Yes! Use claude.ai/code for planning and discussion, then use Claude Code CLI for actual implementation and file operations.

---

## Example Workflow: Web + CLI

### Planning Phase (claude.ai/code)
1. Discuss project architecture
2. Plan implementation approach
3. Get clarification on requirements
4. Organize thoughts by repository

### Implementation Phase (Claude Code CLI)
1. Clone the repository
2. Read and modify files
3. Run tests and builds
4. Deploy to servers
5. Create commits and PRs

### Documentation Phase (Both)
1. Draft docs in claude.ai/code
2. Save to files via Claude Code CLI
3. Commit to repository
4. Update README and guides

---

## Technical Details

### Claude Code Architecture
- **Tool**: CLI application
- **Access**: Terminal-based
- **Permissions**: Full filesystem access (with user permission)
- **Capabilities**: File I/O, shell commands, SSH, Git, etc.

### Session Continuity
- **Current Session**: Full access to conversation history
- **Summarization**: Automatic when context gets large
- **Resumption**: Can continue sessions via summaries
- **Persistence**: Information saved to files persists

### Security Considerations
- ✅ Claude Code asks before executing destructive commands
- ✅ Respects file permissions
- ✅ Cannot access data outside current session without explicit commands
- ✅ No automatic access to web services or APIs

---

## Useful Commands

### Check Session Context
```bash
# Claude Code automatically tracks conversation
# Use files for important persistent data
```

### Save Important Information
```bash
# Create documentation
cat > docs/decision-log.md << 'EOF'
Important decisions and context
EOF
```

### Reference Previous Work
```bash
# Read existing documentation
cat docs/previous-implementation.md

# Check Git history
git log --oneline
```

---

## Summary

**Claude Code is a powerful CLI tool** that:
- ✅ Has direct access to your filesystem and servers
- ✅ Can execute commands and automate tasks
- ✅ Works with Git, npm, and other development tools
- ❌ Cannot access web-based Claude interfaces
- ❌ Does not share conversation history with claude.ai/code
- ❌ Requires explicit context for each session

**For best results**: Use claude.ai/code for planning and Claude Code CLI for implementation, with Git as the bridge between them.

---

**Last Updated**: December 11, 2025
**Related Documentation**:
- [Claude Code Documentation](https://claude.com/claude-code)
- [GitHub CLI Guide](../references/command-cheatsheets.md)
- [Session Management](../workflows/git-workflows.md)
