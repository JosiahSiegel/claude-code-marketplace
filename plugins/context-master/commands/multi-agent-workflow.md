---
description: 2025 multi-agent workflows for complex projects using thinking delegation
---

# Multi-Agent Workflow Patterns (2025)

## Purpose
Implement 2025 multi-agent workflows that parallelize complex analysis while maintaining lean main context through thinking delegation architecture.

## When to Use
- Large projects with multiple independent tasks
- Requiring deep analysis on several fronts simultaneously
- Full-stack features (frontend + backend + testing)
- Complex architectural decisions with dependencies
- Extended sessions needing sustained analytical depth

## Core 2025 Architecture

```
Main Session (Orchestrator)
├─ Stays lean and focused
├─ Makes integration decisions
└─ Receives summaries only

        ↓ delegates with thinking triggers ↓

Parallel Agent Layer (Isolated Contexts)
├─ Agent A: Frontend architecture analysis (ultrathink)
├─ Agent B: Backend performance analysis (ultrathink)
├─ Agent C: Security implications (ultrathink)
├─ Agent D: Team capacity assessment (ultrathink)
└─ Each uses 4-6K thinking tokens in isolation

        ↑ returns concise recommendations ↑

Main Session (Synthesis)
├─ Receives 4 summaries (~200 tokens each)
├─ Makes integrated architectural decision
└─ Context used: ~800 tokens vs 20K+ traditional
```

## Practical Pattern: Full-Stack Feature Decision

### Scenario
Deciding on state management for large e-commerce app (Redux vs Zustand vs Jotai vs Context API)

### Traditional Approach (Main Context)
- Think about each option: 3K tokens
- Think about tradeoffs: 2K tokens
- Think about team fit: 2K tokens
- Total: 7K tokens in main context

### 2025 Multi-Agent Approach
```
Step 1: Parallel Deep Analysis (agents in isolation)
- /agent tech-analyzer "Ultrathink: Performance comparison"
  [Returns: ~200 token summary with metrics]
  
- /agent security-analyzer "Ultrathink: Bundle size and security"
  [Returns: ~200 token summary with findings]
  
- /agent team-analyzer "Ultrathink: Team expertise and maintenance"
  [Returns: ~200 token summary with assessment]
  
- /agent pattern-analyzer "Ultrathink: Integration patterns"
  [Returns: ~200 token summary with guidance]

Step 2: Synthesis in Main (lean context)
- Main: "Based on these 4 analyses, recommend approach"
- Decision made with 800 tokens vs 7K traditionally
- Efficiency gain: 8.75x
```

## Pattern 1: Parallel Architecture Assessment

**Create 4 Agents:**
```bash
python create_subagent.py perf-analyzer --type deep_analyzer
python create_subagent.py security-analyzer --type deep_analyzer
python create_subagent.py team-analyzer --type deep_analyzer
python create_subagent.py cost-analyzer --type deep_analyzer
```

**Workflow:**
```
1. Describe architecture challenge
2. Delegate to 4 agents in parallel:
   /agent perf-analyzer "Ultrathink about [aspect]"
   /agent security-analyzer "Ultrathink about [aspect]"
   /agent team-analyzer "Ultrathink about [aspect]"
   /agent cost-analyzer "Ultrathink about [aspect]"
3. Receive 4 summaries
4. Main context makes integrated decision
```

## Pattern 2: Research → Analysis → Recommendation

**Create 3 Agents:**
```bash
python create_subagent.py pattern-researcher --type researcher
python create_subagent.py pattern-analyzer --type analyzer
python create_subagent.py pattern-recommender --type deep_analyzer
```

**Workflow:**
```
Step 1: Research Phase
/agent pattern-researcher "Search and think about [patterns]"
[Returns findings]

Step 2: Analysis Phase
/agent pattern-analyzer "Analyze these patterns for [context]"
[Returns structured analysis]

Step 3: Recommendation Phase
/agent pattern-recommender "Synthesize and recommend best fit"
[Returns recommendation with rationale]

Main: Make decision based on recommendation
```

## Pattern 3: Implementation with Parallel Verification

**Create 3 Agents:**
```bash
python create_subagent.py code-analyzer --type analyzer
python create_subagent.py test-runner --type tester
python create_subagent.py security-checker --type analyzer
```

**Workflow:**
```
Main: Implement feature (focused context)

After implementation:
/agent code-analyzer "Analyze architecture of [feature]"
/agent test-runner "Run tests and think about coverage gaps"
/agent security-checker "Think about security implications"

Receive 3 parallel assessments
Main: Address findings based on priorities
```

## 2025 Context Efficiency Metrics

### Small Feature (1-2 files)
- Traditional: 4K tokens
- With delegation: 1K tokens
- Efficiency: 4x

### Medium Feature (3-5 files)
- Traditional: 12K tokens
- With delegation: 2K tokens
- Efficiency: 6x

### Large Feature (6+ files)
- Traditional: 35K tokens
- With delegation: 4K tokens
- Efficiency: 8.75x

### Full-Stack Architectural Decision
- Traditional: 25K tokens (thinking + analysis + decision)
- With delegation: 3K tokens (4x summaries + synthesis)
- Efficiency: 8.3x

## Anti-Pattern: Over-Delegation

Don't use agents for:
- Single file edits
- Quick queries with obvious answers
- Simple tasks fitting in main context
- Decision-making requiring full project context

**Cost vs Benefit Rule:**
- If task takes < 2K tokens: Do in main
- If task needs < 5 minutes: Do in main
- If task can be decomposed: Consider agents
- If task needs deep analysis: Use agents

## Integration with Context Master Workflow

### Before Implementation
1. Plan project structure (existing /plan-project)
2. Use agents for deep decision analysis (NEW)
3. Create project-specific CLAUDE.md

### During Implementation
4. Use agents for:
   - Architecture validation checks
   - Test execution and analysis
   - Code pattern research
   - Security analysis

### After Implementation
5. Use /context-analysis command to assess efficiency

## Summary: When Thinking Delegation Saves Most

1. **Architecture Decisions**: 8-10x efficiency
2. **Technology Evaluations**: 6-8x efficiency
3. **Refactoring Analysis**: 7-9x efficiency
4. **Security Assessment**: 5-7x efficiency
5. **Performance Optimization**: 6-8x efficiency

Thinking delegation is most valuable when decisions require deep reasoning but main context needs to stay focused on execution.

