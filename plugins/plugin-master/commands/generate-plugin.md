---
description: Rapidly generate a complete Claude Code plugin with all files and structure ready to use
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
