---
description: Real-time context optimization for ongoing sessions
---

# Optimize Context

## Purpose
Analyze current context usage and provide real-time optimization recommendations for the ongoing session. Useful for maintaining efficiency during long or complex work.

## When to Use
- Mid-session when unsure about context health
- Before starting a large new task
- When responses start feeling unfocused
- To proactively manage context before issues arise

## Instructions

### Step 1: Assess Session State

Analyze the current context:
- How many tasks have been completed?
- What content is still relevant?
- What can be archived or cleared?
- Are we approaching capacity limits?

### Step 2: Recommend Immediate Actions

Based on context state, recommend:

**If context 50-75% full:**
- Continue current work normally
- Document decisions in artifacts
- Prepare for /compact before next major task

**If context 75-85% full:**
- Use /compact with a summary
- Archive key decisions to document
- Prepare for /clear before next feature

**If context 85%+ full:**
- Use /clear immediately
- Summarize current progress
- Start next task with fresh context

### Step 3: Suggest Strategic Improvements

For the remaining session:
- Which tasks should use thinking delegation?
- Where could recursive delegation help?
- Should we use clear-and-verify for remaining features?
- What should be documented in artifacts vs. context?

### Step 4: Provide Metrics

Show context efficiency metrics:
- Estimated tokens used so far
- Estimated tokens remaining
- Potential savings with recommended approach
- Features/tasks that can fit in remaining budget

## Example Output

```
📊 Context Optimization Analysis

Current Context State:
- Usage: 68% (136K of 200K)
- Tasks completed: 3
- Key artifacts: 5
- Remaining capacity: 64K

Recommendations:
1. Continue current feature
2. Before next major feature: Use /compact
3. Delegate architecture decisions to deep_analyzer
4. Document design choices in DECISIONS.md

Expected Capacity:
- Current feature: ~5K tokens remaining
- Next feature: ~10K tokens
- Can sustain 5-6 more medium features

Actions:
1. Continue implementation
2. At 80%: Run /compact "Archive implementation details"
3. Next feature: Use thinking delegation
```

## Benefits
- Proactive context management
- Sustained session quality
- Clear visibility into token budget
- Data-driven decision making
- Prevents context crises

## See Also
- /context-analysis - Full session analysis
- /plan-project - Multi-file project planning
- references/context_strategies.md - Detailed context management workflows
