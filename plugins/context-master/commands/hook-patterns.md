---
description: Discover 2025 hook patterns for automated context management in Claude Code
---

## 🚨 CRITICAL GUIDELINES

### Windows File Path Requirements

**MANDATORY: Always Use Backslashes on Windows for File Paths**

When using Edit or Write tools on Windows, you MUST use backslashes (`\`) in file paths, NOT forward slashes (`/`).

**Examples:**
- ❌ WRONG: `D:/repos/project/file.tsx`
- ✅ CORRECT: `D:\repos\project\file.tsx`

This applies to:
- Edit tool file_path parameter
- Write tool file_path parameter
- All file operations on Windows systems


### Documentation Guidelines

**NEVER create new documentation files unless explicitly requested by the user.**

- **Priority**: Update existing README.md files rather than creating new documentation
- **Repository cleanliness**: Keep repository root clean - only README.md unless user requests otherwise
- **Style**: Documentation should be concise, direct, and professional - avoid AI-generated tone
- **User preference**: Only create additional .md files when user specifically asks for documentation


---

# Hook Patterns for Context Optimization

## Purpose
Discover and implement 2025 hook patterns that automatically manage context using Claude Code's PreToolUse, PostToolUse, and SessionStart hooks.

## When to Use
- Setting up automated context management in long sessions
- Implementing project-specific context strategies
- Creating autonomous context monitoring
- Building context-aware tool validation

## 2025 Hook Capabilities

### PreToolUse Hook
Runs BEFORE any tool is executed. Perfect for:
- Context budget validation (block operations if >85% full)
- Tool eligibility checks
- Automated `/clear` or `/compact` triggers
- Permission/safety validation

### PostToolUse Hook
Runs AFTER tool completes. Perfect for:
- Context health monitoring
- Automatic documentation of findings
- Triggering `/compact` if context growing too fast
- Test result analysis and reporting

### SessionStart Hook
Runs when session begins. Perfect for:
- Loading CLAUDE.md context
- Initializing project-specific strategies
- Setting autonomy rules
- Loading previous session findings

## Common 2025 Patterns

### Pattern 1: Auto-Compact on Context Growth
```yaml
PostToolUse:
  trigger: "context_used > 10000 in_last_10_calls"
  action: "/compact with summary of last 10 findings"
  message: "Context growing. Compacting to maintain clarity."
```

### Pattern 2: Research-Phase Automation
```yaml
SessionStart:
  load: "RESEARCH.md if exists"
  message: "Resuming research from [RESEARCH.md]"
  
PostToolUse:
  trigger: "when tool is search"
  action: "append results to RESEARCH.md"
  message: "Added findings to research document"
```

### Pattern 3: Multi-File Project Planning
```yaml
PreToolUse:
  trigger: "when tool is write AND file pattern matches {*.html,*.jsx,*.tsx}"
  action: "Check ARCHITECTURE_PLAN.md exists"
  message: "Reference architecture plan for ordering"
  
PostToolUse:
  trigger: "after write tool"
  action: "update PROJECT_STATUS.md with completion"
  message: "Tracked file creation in project status"
```

### Pattern 4: Test-Driven Context Management
```yaml
PostToolUse:
  trigger: "when tool is bash AND 'test' in command"
  action: |
    if failing_tests > 0:
      /agent test-analyzer "think deeply about failures"
    else:
      append results to TEST_RESULTS.md
```

## Implementation Steps

1. **Create `.claude/hooks/` directory**
2. **Define hook files** (e.g., `context-auto-manage.yaml`)
3. **Configure triggers and actions**
4. **Test with context monitoring**
5. **Commit hooks to repository**

## Benefits

- **Autonomous Management**: Context stays optimized automatically
- **Session Continuity**: Research and decisions persist across `/clear`
- **Team Alignment**: Hooks apply to all team members working on project
- **Learning**: Hooks can document patterns for future reference

## See Also

- **Advanced Patterns**: See plugin-master for custom hook development
- **Subagent Integration**: Combine hooks with thinking-enabled subagents
- **Context Strategies**: See references/context_strategies.md for detailed workflows

