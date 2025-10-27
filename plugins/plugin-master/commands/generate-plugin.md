---
description: Rapidly generate a complete Claude Code plugin with all files and structure ready to use
---

# Generate Plugin

Quickly scaffold a production-ready plugin with sensible defaults and minimal user input required.

## Purpose

Accelerated plugin creation optimized for speed - autonomously generates complete plugin structures by inferring requirements from brief descriptions. Ideal for rapid prototyping or when you have a clear plugin concept.

## Instructions

1. **Auto-activate plugin-master skill** for templates and best practices
2. **Infer everything possible**:
   - Plugin name from description
   - Required components (commands/agents/skills)
   - Appropriate keywords and metadata
3. **Be maximally autonomous** - ask zero questions unless critical ambiguity exists
4. **Generate immediately**:
   - Fetch latest docs if needed
   - Detect git context automatically
   - Create all files with working examples
   - Provide GitHub-ready structure
5. **Output concise instructions** focused on immediate next steps

## Key Differences from /create-plugin

- **More autonomous** - Asks fewer questions, infers more aggressively
- **Faster** - Optimized for speed over customization
- **Simpler output** - Streamlined instructions for experienced users
- **Default templates** - Uses proven patterns without extensive explanation

Use `/create-plugin` for guided creation with more control.
Use `/generate-plugin` for fast scaffolding with smart defaults.

## Example Usage

```
/generate-plugin for API testing
/generate-plugin deployment helper
/generate-plugin code quality checks
```

Provides complete plugin ready for immediate testing or customization.
