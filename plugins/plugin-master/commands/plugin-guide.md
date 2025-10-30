---
description: Comprehensive plugin development reference from beginner basics to advanced patterns
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

# Plugin Guide

Access tailored guidance on Claude Code plugin development based on your experience level and specific questions.

## Purpose

Adaptive reference system that provides beginner tutorials, intermediate how-tos, or advanced patterns depending on user needs. Automatically activates plugin-master skill for complete documentation access.

## Instructions

1. **Activate plugin-master skill** - Provides full beginner's guide
2. **Assess user needs**:
   - Beginners: "What is Claude Code?" → "First Plugin in 10 Minutes" tutorial
   - Intermediate: Specific topics (commands, agents, skills, hooks, MCP)
   - Advanced: Progressive disclosure, environment vars, testing frameworks
   - Troubleshooting: Platform issues, validation errors, loading problems
3. **Provide targeted guidance** with code examples and practical steps
4. **Reference official docs** when appropriate (docs.claude.com)
5. **Adapt depth** - Quick answers for specific questions, comprehensive tutorials for broad topics

## Quick Topic Index

**Getting Started:**
- What is Claude Code and why plugins?
- First plugin tutorial (10 minutes)
- Installation methods (GitHub recommended)

**Core Concepts:**
- Plugin structure (plugin.json, directories)
- Commands (slash command creation)
- Agents (specialized assistants)
- Skills (knowledge documents)
- Hooks (event automation)
- MCP servers (external tool integration)

**Publishing:**
- Marketplace structure
- GitHub publishing workflow
- Version management
- Community distribution

**Platform Issues:**
- Windows path limitations (use GitHub method)
- Mac/Linux local installation
- Cross-platform compatibility

**Troubleshooting:**
- Plugin not loading
- Commands not appearing
- JSON validation errors
- Marketplace setup issues

## Example Usage

```
/plugin-guide getting started
/plugin-guide how to create commands
/plugin-guide Windows installation help
/plugin-guide advanced hooks
```

Returns context-appropriate guidance with examples and next steps.
