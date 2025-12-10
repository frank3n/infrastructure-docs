# CLAUDE.md

## Permissions

Allow all operations in this project directory:
- File creation, editing, and deletion
- Running build commands, tests, and scripts
- Installing dependencies
- Git operations
- Shell command execution
- SSH operations and remote server access
- All MCP tools and operations

## Response Formatting

When providing content that may be saved (documentation, guides, config examples):
- Wrap in a ```markdown code fence so raw formatting is preserved when copied
- This allows direct paste into Phoenix Code or other editors with proper rendering

## Conversation Logging

### Purpose
Track conversation history during long-running tasks (TypeScript improvements, refactoring, etc.) with timestamped entries in reverse chronological order.

### Configuration
For each project, create a documentation folder and conversation log:

```bash
# Determine project name from repository or directory
PROJECT_NAME=$(basename "$PWD")

# Create documentation folder
DOCS_FOLDER="C:/github-claude/${PROJECT_NAME}-documentation"
mkdir -p "$DOCS_FOLDER"

# Initialize conversation log
LOG_FILE="$DOCS_FOLDER/CONVERSATION-LOG.md"
```

### Log File Format

**File:** `CONVERSATION-LOG.md`
**Location:** `C:/github-claude/{project-name}-documentation/`

**Structure:**
- Newest entries at the top (reverse chronological)
- Each entry separated by 30 dashes (`------------------------------`)
- Timestamp in format: `YYYY-MM-DD HH:MM`
- Clear status indicators (✅ Complete, 📋 In Progress, ⚠️ Warning)

### Template

```markdown
# Conversation Log - {Project Name} {Task Description}

This file contains the conversation history for {task description}, with newest entries at the top.

---

## YYYY-MM-DD HH:MM - Entry Title

**User Request:**
- List of user requests or questions

**Assistant Action:**
Description of what was done

**Status:** In Progress / Complete ✅ / Blocked ⚠️

**Results:**
- Key outcomes
- Metrics
- Links

**Next Steps:**
- Action items

------------------------------

## YYYY-MM-DD HH:MM - Previous Entry

...

------------------------------
```

### Usage Instructions

When starting a new task that requires conversation tracking:

1. **Create the log file:**
```bash
cat > "C:/github-claude/{project-name}-documentation/CONVERSATION-LOG.md" << 'EOF'
# Conversation Log - {Project Name} {Task Description}

This file contains the conversation history for {task description}, with newest entries at the top.

---

## YYYY-MM-DD HH:MM - Initial Entry

**User Request:**
{Initial request}

**Assistant Action:**
{What you're starting}

**Status:** In Progress

------------------------------
EOF

2. **Update with each major milestone:**

Prepend new entries to the top of the file (newest first).

3. **Reference in responses:**
- Tell the user updates are being logged
- Reference the log file location
- Keep user informed of progress

### Example Entry

```
## 2025-12-09 13:35 - TypeScript Strict Mode Complete ✅

**Status:** All 32 errors fixed successfully!

**Results:**
- ✅ TypeScript Errors: 32 → 0
- ✅ Type Coverage: 92.39% (web), 91.33% (API)
- ✅ Build: Successful
- ✅ PR Created: https://github.com/user/repo/pull/1

**Files Modified:** 15 files

**Next Steps:**
- Review and merge PR

------------------------------
```

### Best Practices

**Update Frequency:**
- After completing each major phase
- When user asks for updates
- At natural breakpoints (commits, PR creation)
- When encountering issues

**Entry Content:**
- Be concise but informative
- Include metrics and numbers
- Add links to PRs, commits, documentation
- Note warnings or issues

**Status Indicators:**
- ✅ Complete
- 📋 In Progress / Pending
- ⚠️ Warning / Issue
- ❌ Error / Failed
- 🎉 Major milestone

### Integration with Documentation

Standard structure:

```
C:/github-claude/{project-name}-documentation/
├── README.md                 # Project overview
├── BASELINE-SCAN.md         # Initial analysis
├── CONVERSATION-LOG.md      # Timeline (this file)
├── STATUS.md                # Current status
├── ERROR-FIXES.md           # Technical details
├── COMPLETION-SUMMARY.md    # Final results
├── REVIEW-AND-MERGE-GUIDE.md # Merge instructions
└── *.log files              # Command outputs
```

### When to Use

**Use for:**
- Multi-step tasks (>30 minutes)
- Complex refactoring or improvements
- Tasks with multiple phases
- When user requests status updates

**Don't use for:**
- Simple one-off questions
- Quick fixes (<5 minutes)
- Read-only exploration

### Auto-Detection

Automatically use correct documentation folder:

```bash
PROJECT_NAME=$(basename "$PWD")
DOCS_FOLDER="C:/github-claude/${PROJECT_NAME}-documentation"
LOG_FILE="${DOCS_FOLDER}/CONVERSATION-LOG.md"
mkdir -p "$DOCS_FOLDER"
```

### Entry Separator

Always use exactly 30 dashes:
```
------------------------------
```
