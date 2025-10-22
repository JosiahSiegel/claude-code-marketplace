#!/usr/bin/env python3
"""
Generate a CLAUDE.md file for context-efficient Claude Code workflows.

Usage:
    python generate_claude_md.py [--type TYPE] [--output PATH]

Types:
    - general: General-purpose project (default)
    - backend: Backend API/service project
    - frontend: Frontend web application
    - fullstack: Full-stack application
    - data: Data science/ML project
    - library: Library/package project
"""

import argparse
import os
from pathlib import Path

TEMPLATES = {
    "general": """# Claude Code Configuration

## Project Overview
<!-- Describe your project's purpose, architecture, and key components -->

## Context Management Strategy

### When to Use Subagents
- **Code searches**: Use subagents to search through large codebases
- **File analysis**: Delegate multi-file analysis to subagents
- **Research tasks**: Use subagents for documentation lookups
- **Testing**: Isolate test runs in subagents

### Context Commands
- Use `/clear` between major tasks to reset context
- Use `/compact` before complex multi-step work
- Use `think` for planning complex changes

## Development Workflow

1. **Planning Phase**: Use "think" to analyze approach
2. **Implementation**: Keep main context focused on current task
3. **Verification**: Use subagents for testing and validation
4. **Cleanup**: `/clear` before starting new features

## Allowed Tools
- File operations (read, write, edit)
- Git operations (commit, branch, status)
- Shell commands for building and testing
- Subagent delegation

## Code Style
<!-- Add your project's code style guidelines -->

## Escalation Rules
- Ask before making breaking changes
- Confirm before deleting files
- Verify test results before committing
""",
    
    "backend": """# Claude Code Configuration - Backend Project

## Project Overview
<!-- Describe your API/service architecture -->

## Context Management Strategy

### When to Use Subagents
- **Database queries**: Delegate schema exploration to subagents
- **API documentation**: Use subagents to search through API docs
- **Log analysis**: Isolate log file analysis in subagents
- **Dependency analysis**: Check dependencies in isolated context
- **Test runs**: Execute test suites in subagents

### Context Commands
- `/clear` between feature implementations
- `/compact` before multi-endpoint refactoring
- `think hard` for API design decisions

## Development Workflow

1. **Schema Review**: Subagent explores DB schema
2. **Planning**: Main context designs endpoint logic
3. **Implementation**: Focus on current endpoint
4. **Testing**: Subagent runs integration tests
5. **Commit**: After test verification

## API Patterns
<!-- Add your API conventions (REST, GraphQL, etc.) -->

## Database
<!-- Add your schema info or reference documentation -->

## Testing Strategy
- Unit tests required for business logic
- Integration tests for API endpoints
- Use subagents for test execution

## Escalation Rules
- Confirm before database migrations
- Ask before changing API contracts
- Verify backward compatibility
""",
    
    "frontend": """# Claude Code Configuration - Frontend Project

## Project Overview
<!-- Describe your frontend architecture (React, Vue, Angular, etc.) -->

## Context Management Strategy

### When to Use Subagents
- **Component searches**: Find similar components across codebase
- **Style analysis**: Isolate CSS/styling investigations
- **Bundle analysis**: Check dependencies and imports
- **Test runs**: Execute component tests in subagents
- **Build verification**: Run builds in isolated context

### Context Commands
- `/clear` between component implementations
- `/compact` before large refactoring
- `think` for component architecture decisions

## Development Workflow

1. **Component Planning**: Design component structure
2. **Implementation**: Focus on current component
3. **Styling**: Apply consistent design system
4. **Testing**: Subagent runs component tests
5. **Build Check**: Subagent verifies build

## Component Patterns
<!-- Add your component conventions -->

## Styling Approach
<!-- CSS-in-JS, Tailwind, CSS Modules, etc. -->

## State Management
<!-- Redux, Context API, Zustand, etc. -->

## Testing Strategy
- Component tests required
- Use Testing Library best practices
- Subagents handle test execution

## Escalation Rules
- Confirm before major architectural changes
- Ask before adding new dependencies
- Verify accessibility requirements
""",
    
    "fullstack": """# Claude Code Configuration - Full-Stack Project

## Project Overview
<!-- Describe your full-stack architecture -->

## Context Management Strategy

### When to Use Subagents
- **Frontend searches**: Delegate component searches
- **Backend analysis**: Isolate API endpoint analysis
- **Database operations**: Schema exploration in subagents
- **Build processes**: Run builds in isolated contexts
- **Test suites**: Execute frontend and backend tests separately

### Context Commands
- `/clear` between frontend/backend context switches
- `/compact` before cross-stack refactoring
- `think hard` for architectural decisions

## Development Workflow

1. **Planning**: Design full-stack feature flow
2. **Backend First**: Implement API endpoints
3. **Frontend**: Build UI components
4. **Integration**: Connect frontend to backend
5. **Testing**: Subagents test both layers

## Stack
- **Frontend**: <!-- React, Vue, etc. -->
- **Backend**: <!-- Node.js, Python, etc. -->
- **Database**: <!-- PostgreSQL, MongoDB, etc. -->

## API Patterns
<!-- REST, GraphQL, tRPC, etc. -->

## Testing Strategy
- Unit tests for business logic
- Integration tests for APIs
- Component tests for UI
- E2E tests for critical flows

## Escalation Rules
- Confirm before database migrations
- Ask before API contract changes
- Verify cross-stack impacts
""",
    
    "data": """# Claude Code Configuration - Data Science Project

## Project Overview
<!-- Describe your data pipeline and analysis goals -->

## Context Management Strategy

### When to Use Subagents
- **Data exploration**: Delegate large dataset analysis
- **Model searches**: Find similar models in codebase
- **Documentation**: Research library documentation
- **Experiment runs**: Execute training in subagents
- **Result analysis**: Isolate metrics computation

### Context Commands
- `/clear` between experiments
- `/compact` before model refactoring
- `think harder` for model architecture decisions

## Development Workflow

1. **Data Exploration**: Subagent analyzes dataset
2. **Feature Engineering**: Design features in main context
3. **Model Development**: Implement and iterate
4. **Evaluation**: Subagent runs evaluation metrics
5. **Documentation**: Record experiment results

## Data Pipeline
<!-- Add your data sources and processing steps -->

## Model Architecture
<!-- Add your model details -->

## Experiment Tracking
<!-- MLflow, Weights & Biases, etc. -->

## Testing Strategy
- Unit tests for data processing
- Validation tests for model outputs
- Subagents handle long-running tests

## Escalation Rules
- Confirm before large dataset operations
- Ask before changing data schemas
- Verify model performance before deployment
""",
    
    "library": """# Claude Code Configuration - Library Project

## Project Overview
<!-- Describe your library's purpose and API -->

## Context Management Strategy

### When to Use Subagents
- **API searches**: Find similar functions across codebase
- **Documentation**: Research upstream dependencies
- **Example analysis**: Review usage examples
- **Test execution**: Run test suites in subagents
- **Build verification**: Check builds across versions

### Context Commands
- `/clear` between feature implementations
- `/compact` before API refactoring
- `think` for public API design

## Development Workflow

1. **API Design**: Plan function signatures
2. **Implementation**: Implement core logic
3. **Documentation**: Write docstrings and examples
4. **Testing**: Comprehensive test coverage
5. **Verification**: Subagent runs full test suite

## API Principles
- Maintain backward compatibility
- Clear, consistent naming
- Comprehensive documentation
- Type hints/annotations

## Testing Strategy
- Unit tests for all public APIs
- Integration tests for workflows
- Docstring examples as doctests
- Subagents handle test execution

## Documentation
- Docstrings required for all public APIs
- Usage examples in docs/
- Changelog maintenance

## Escalation Rules
- Confirm before breaking API changes
- Ask before adding dependencies
- Verify semantic versioning
"""
}


def generate_claude_md(project_type: str, output_path: str) -> None:
    """Generate a CLAUDE.md file from a template."""
    if project_type not in TEMPLATES:
        raise ValueError(f"Unknown project type: {project_type}. Choose from: {', '.join(TEMPLATES.keys())}")
    
    content = TEMPLATES[project_type]
    
    # Create parent directory if it doesn't exist
    output_file = Path(output_path)
    output_file.parent.mkdir(parents=True, exist_ok=True)
    
    # Write the file
    output_file.write_text(content)
    print(f"✅ Generated CLAUDE.md at {output_path}")
    print(f"   Template: {project_type}")
    print(f"\n📝 Next steps:")
    print(f"   1. Review and customize the generated CLAUDE.md")
    print(f"   2. Fill in project-specific details")
    print(f"   3. Commit it to your repository")


def main():
    parser = argparse.ArgumentParser(
        description="Generate a CLAUDE.md file for context-efficient Claude Code workflows"
    )
    parser.add_argument(
        "--type",
        choices=list(TEMPLATES.keys()),
        default="general",
        help="Project type template to use"
    )
    parser.add_argument(
        "--output",
        default="./CLAUDE.md",
        help="Output path for the CLAUDE.md file"
    )
    
    args = parser.parse_args()
    generate_claude_md(args.type, args.output)


if __name__ == "__main__":
    main()
