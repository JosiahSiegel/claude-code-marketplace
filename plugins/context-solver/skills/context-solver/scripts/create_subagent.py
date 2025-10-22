#!/usr/bin/env python3
"""
Create a subagent configuration for Claude Code.

Usage:
    python create_subagent.py <agent_name> [--type TYPE] [--output DIR]

Types:
    - researcher: For documentation and code searches with deep analysis
    - tester: For running tests and validation with failure analysis
    - analyzer: For code analysis and architectural insights
    - builder: For build and deployment tasks
    - deep_analyzer: For complex decisions requiring extensive thinking
"""

import argparse
import json
from pathlib import Path

SUBAGENT_TEMPLATES = {
    "researcher": {
        "name": "{agent_name}",
        "description": "Research and documentation lookup agent with deep analysis",
        "instructions": """You are a research specialist. Your job is to:
- Search through documentation efficiently
- THINK DEEPLY about findings using extended thinking
- Analyze patterns and implications
- Synthesize insights with reasoning
- Return concise, well-reasoned summaries

IMPORTANT: For complex research, use extended thinking before responding:
- Use "think hard" for multi-source analysis
- Use "ultrathink" for architecture pattern evaluation
- Your thinking happens in YOUR isolated context
- Return only the analysis summary to the main agent

The main agent needs your INSIGHTS, not raw data.""",
        "tools": ["read", "search", "web_search"],
        "autonomy": "medium"
    },
    
    "tester": {
        "name": "{agent_name}",
        "description": "Testing and validation agent with analysis",
        "instructions": """You are a testing specialist. Your job is to:
- Execute test suites
- Validate code changes
- ANALYZE test failures deeply
- Identify root causes and patterns
- Report clear, actionable results

IMPORTANT: When test failures occur, use extended thinking:
- Use "think hard" to analyze failure patterns
- Consider root causes and related issues
- Your analysis happens in YOUR isolated context
- Return actionable findings to the main agent

Focus on test execution and insightful result reporting.""",
        "tools": ["bash", "read", "write"],
        "autonomy": "high"
    },
    
    "analyzer": {
        "name": "{agent_name}",
        "description": "Code analysis and deep architectural insight agent",
        "instructions": """You are a code analysis specialist. Your job is to:
- Analyze code structure and patterns
- THINK DEEPLY about implications and tradeoffs
- Identify potential issues and opportunities
- Compute complexity metrics
- Find dependencies and relationships

IMPORTANT: Always use extended thinking for analysis:
- Use "think harder" for architecture analysis
- Use "ultrathink" for complex system evaluation
- Consider multiple perspectives and edge cases
- Your deep reasoning happens in YOUR isolated context
- Return concise analysis with key insights to the main agent

Provide actionable insights backed by reasoning.""",
        "tools": ["read", "search", "bash"],
        "autonomy": "medium"
    },
    
    "builder": {
        "name": "{agent_name}",
        "description": "Build and deployment agent",
        "instructions": """You are a build specialist. Your job is to:
- Execute build processes
- Run deployment scripts
- Verify build outputs
- Report build status and errors

Focus on build execution and clear status reporting. Return success/failure and any errors.""",
        "tools": ["bash", "read"],
        "autonomy": "high"
    },
    
    "deep_analyzer": {
        "name": "{agent_name}",
        "description": "Deep analysis agent with mandatory extended thinking",
        "instructions": """You are a deep analysis specialist. Your PRIMARY function is to think deeply before responding.

MANDATORY WORKFLOW:
1. Always start with "ultrathink" for complex analysis
2. Consider multiple approaches and perspectives
3. Evaluate tradeoffs, implications, and edge cases
4. Reason through consequences and alternatives
5. Synthesize findings into clear recommendations

Your extended thinking happens in YOUR isolated context - this is your superpower.
The main agent only sees your conclusions, not your reasoning process.

RETURN FORMAT:
- Brief conclusion (2-3 sentences)
- Key reasoning points (3-5 bullets)
- Recommendation with rationale
- Any important caveats

The main agent trusts your deep analysis. Give them confidence through thorough thinking.""",
        "tools": ["read", "search", "bash", "web_search"],
        "autonomy": "high"
    }
}

CLAUDE_CODE_FORMAT = """# {agent_name}

{description}

## Instructions

{instructions}

## Allowed Tools

{tools}

## Autonomy Level

{autonomy_description}
"""

AUTONOMY_DESCRIPTIONS = {
    "low": "Ask for confirmation before taking actions. Provide recommendations.",
    "medium": "Take standard actions autonomously. Ask for confirmation on significant changes.",
    "high": "Execute tasks fully autonomously. Report results when complete."
}


def create_subagent(agent_name: str, agent_type: str, output_dir: str) -> None:
    """Create a subagent configuration file."""
    if agent_type not in SUBAGENT_TEMPLATES:
        raise ValueError(
            f"Unknown agent type: {agent_type}. "
            f"Choose from: {', '.join(SUBAGENT_TEMPLATES.keys())}"
        )
    
    template = SUBAGENT_TEMPLATES[agent_type].copy()
    template["name"] = agent_name
    
    # Create output directory
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)
    
    # Create .claude/agents directory structure
    agents_dir = output_path / ".claude" / "agents"
    agents_dir.mkdir(parents=True, exist_ok=True)
    
    # Generate agent file in Claude Code format
    agent_file = agents_dir / f"{agent_name}.md"
    
    tools_list = "\n".join(f"- {tool}" for tool in template["tools"])
    autonomy_desc = AUTONOMY_DESCRIPTIONS[template["autonomy"]]
    
    content = CLAUDE_CODE_FORMAT.format(
        agent_name=agent_name,
        description=template["description"],
        instructions=template["instructions"],
        tools=tools_list,
        autonomy_description=autonomy_desc
    )
    
    agent_file.write_text(content)
    
    # Also create a JSON version for programmatic use
    json_file = agents_dir / f"{agent_name}.json"
    json_file.write_text(json.dumps(template, indent=2))
    
    print(f"✅ Created subagent: {agent_name}")
    print(f"   Type: {agent_type}")
    print(f"   Location: {agent_file}")
    print(f"\n📝 Next steps:")
    print(f"   1. Review and customize {agent_file}")
    print(f"   2. Use in Claude Code with: /agent {agent_name}")
    print(f"   3. Commit to version control")
    
    # Print usage example
    print(f"\n💡 Usage example:")
    print(f"   /agent {agent_name} [your task description]")


def main():
    parser = argparse.ArgumentParser(
        description="Create a subagent configuration for Claude Code"
    )
    parser.add_argument(
        "agent_name",
        help="Name for the subagent (e.g., 'test-runner', 'doc-searcher')"
    )
    parser.add_argument(
        "--type",
        choices=list(SUBAGENT_TEMPLATES.keys()),
        default="researcher",
        help="Type of subagent to create"
    )
    parser.add_argument(
        "--output",
        default=".",
        help="Output directory (default: current directory)"
    )
    
    args = parser.parse_args()
    
    create_subagent(args.agent_name, args.type, args.output)


if __name__ == "__main__":
    main()
