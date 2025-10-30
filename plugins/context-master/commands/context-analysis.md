---
description: Analyze context usage and suggest optimization strategies for ongoing session
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

# Context Analysis

## Purpose
Analyze current context usage in the conversation and suggest optimization strategies to maintain efficiency throughout long sessions.

## When to Use
- When working on complex, multi-phase projects
- After completing several tasks in one session
- When responses start feeling unfocused
- To proactively manage context before issues arise

## Instructions

### Step 1: Assess Current Context State

Analyze the current session:

```
□ Session Assessment:
  - How many tasks have been completed?
  - Are we working on related or unrelated tasks?
  - Is there accumulated context from previous tasks?
  - Have we created planning documents or artifacts?
```

### Step 2: Identify Context Optimization Opportunities

Look for these patterns:

**Good Context Management (Keep Doing):**
- ✅ Using extended thinking for complex decisions
- ✅ Creating artifacts for code/documents
- ✅ Breaking tasks into explicit phases
- ✅ Planning before implementing multi-file projects

**Context Inefficiencies (Improve):**
- ❌ Inline code in conversation instead of artifacts
- ❌ Long explanations without artifacts
- ❌ Jumping between unrelated tasks without boundaries
- ❌ Re-explaining decisions already made

### Step 3: Calculate Estimated Context Savings

Provide metrics:

```
Current Session Analysis:
- Tasks completed: [N]
- Multi-file projects: [N]
- Context-efficient patterns used: [Yes/No]

Estimated token usage:
- With current approach: ~[X] tokens
- With optimizations: ~[Y] tokens
- Potential savings: ~[Z] tokens ([%]%)
```

### Step 4: Recommend Optimization Strategies

Based on analysis, suggest:

**Immediate Actions:**
- "Let's use extended thinking for the next complex decision"
- "Create a decisions.md artifact to track our choices"
- "Use `/clear` before starting the next unrelated task"

**For Remaining Session:**
- "Delegate complex analysis to subagents (if using Claude Code)"
- "Create planning artifacts for upcoming multi-file work"
- "Use progressive task decomposition for large features"

### Step 5: Explain Thinking Delegation (If Applicable)

If the user has access to Claude Code, explain:

```
For maximum efficiency, create thinking-enabled subagents:

python scripts/create_subagent.py architecture-advisor --type deep_analyzer
python scripts/create_subagent.py pattern-researcher --type researcher

Then delegate complex decisions:
/agent architecture-advisor "Analyze [complex decision]"

Benefit: Deep thinking happens in isolation, main context stays clean.
Context efficiency: ~23x improvement (5K tokens → 200 tokens per analysis)
```

## Example Output

```
📊 Context Analysis

Current Session:
- Completed 3 multi-file projects
- Used planning before creation: ✅
- Created artifacts for code: ✅
- Used extended thinking: ✅

Token Efficiency:
- Estimated usage: ~9,000 tokens
- Without context-master patterns: ~24,000 tokens
- Savings achieved: ~15,000 tokens (62%)

Recommendations for Remaining Session:
1. Continue using planning before multi-file creation
2. Create a project-decisions.md artifact for reference
3. For next complex decision, use thinking delegation if available
4. Consider `/clear` before next major task switch

Great context management so far! You're on track to sustain high-quality
work throughout this session.
```

## Benefits
- Proactive context management
- Awareness of efficiency gains
- Actionable recommendations
- Sustained session quality
- Educational for users learning context optimization

## Metrics to Track

**Session Efficiency Indicators:**
- Planning used before multi-file creation
- Artifacts created vs inline content
- Extended thinking usage
- Clear phase boundaries
- Token savings vs traditional approach

**Warning Signs to Watch For:**
- Responses getting less focused
- Referencing old, irrelevant info
- Requests for re-explanation
- Long, unfocused answers
