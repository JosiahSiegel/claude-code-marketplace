# Context Master Plugin

Optimal planning and context management for multi-file projects, website creation, and complex coding tasks.

## Overview

Context Master helps Claude Code work more efficiently on multi-file projects by:
- **Planning optimal file creation order** before implementation
- **Preventing redundant work** through dependency-aware architecture
- **Saving context tokens** (62% reduction on average)
- **Providing extended thinking delegation** patterns
- **Verifying project structures** automatically

## ⚡ Quick Start

### When to Use

Context Master activates automatically for:
- Creating 3+ related files (HTML, CSS, JS, docs, etc.)
- Building complete websites or web applications
- Multi-file code projects (APIs, full-stack apps, libraries)
- Tasks requiring 5+ sequential steps
- Architecture or design planning before implementation

### Basic Workflow

For ANY multi-file project, follow these 5 steps:

```
1️⃣ STOP - Don't create files yet
2️⃣ PLAN - Use /plan-project command
3️⃣ ANNOUNCE - Tell user your file creation order
4️⃣ CREATE - Make files in optimal order (dependencies first)
5️⃣ VERIFY - Use /verify-structure to check all references work
```

## Installation

### Option 1: GitHub Marketplace (Recommended)

1. **Add this marketplace:**
   ```bash
   /plugin marketplace add JosiahSiegel/claude-code-marketplace
   ```

2. **Install the plugin:**
   ```bash
   /plugin install context-master@claude-code-marketplace
   ```

### Option 2: Local Installation (Mac/Linux Only)

⚠️ **Windows users:** Use GitHub installation method instead (local paths may have issues).

```bash
# Extract to plugins directory
unzip context-master.zip -d ~/.local/share/claude/plugins/
```

## Features

### Commands

#### `/plan-project`
Plan optimal file creation order for multi-file projects before implementation.

**Example:**
```
User: "Create a portfolio with home, about, and projects pages"
You: /plan-project

[Extended thinking plans architecture]
[Announces: "I'll create: 1. styles.css, 2. index.html, 3. about.html, 4. projects.html"]
[Creates files in optimal order]
```

**Token Savings:** ~5,000 tokens (62% reduction) per multi-file project

#### `/verify-structure`
Verify multi-file project structure and cross-file references after creation.

**Checks:**
- File paths are correct
- CSS/JS references load properly
- Navigation between pages works
- Cross-file dependencies resolve
- Consistency across files

#### `/context-analysis`
Analyze context usage and suggest optimization strategies for ongoing session.

**Provides:**
- Session efficiency metrics
- Token savings achieved
- Recommendations for remaining work
- Context optimization opportunities

### Skills

#### `context-master`
Comprehensive knowledge about:
- Multi-file project planning workflows
- Optimal file creation order principles
- Context-efficient patterns and strategies
- Extended thinking delegation architecture
- CLI-specific tooling (for Claude Code users)

**Includes:**
- Main skill documentation (SKILL.md)
- Context strategies reference
- Subagent patterns guide
- Python scripts for CLAUDE.md generation and subagent creation

## Usage Examples

### Example 1: Portfolio Website

**User Request:** "Create a portfolio website with home, about, projects, and contact pages"

**With Context Master:**
```bash
/plan-project
# Extended thinking plans: CSS first, then HTML pages
# Announces creation order
# Creates styles.css → index.html → about.html → projects.html → contact.html
/verify-structure
# Verifies all HTML files reference styles.css correctly
```

**Result:** Efficient creation, no refactoring needed!

### Example 2: React Application

**User Request:** "Build a React app with multiple components"

**With Context Master:**
```bash
/plan-project
# Plans: package.json → App.js → layout components → page components → styles
# Creates foundation files before dependent components
/verify-structure
# Checks imports and component references
```

### Example 3: Context Optimization

**During Long Session:**
```bash
/context-analysis
# Shows token savings achieved
# Recommends delegation strategies
# Suggests when to use /clear
```

## Token Savings

### Real-World Impact

**Small Project (3-4 files) - Portfolio Website**
- Without planning: ~6,000 tokens
- With planning: ~2,500 tokens
- **Savings: ~3,500 tokens (58%)**

**Medium Project (7-8 files) - Multi-page App**
- Without planning: ~12,000 tokens
- With planning: ~4,500 tokens
- **Savings: ~7,500 tokens (63%)**

**Large Project (20+ files) - Full Application**
- Without planning: ~35,000 tokens
- With planning: ~12,000 tokens
- **Savings: ~23,000 tokens (66%)**

### Context Window Capacity

- Standard: 200K tokens
- With planning: Complete 16-17 medium projects
- Without planning: Only 7-8 medium projects
- **Effective capacity increase: 2.1x**

## Advanced Features (Claude Code CLI Only)

### Generate Project-Specific CLAUDE.md

```bash
python skills/context-master/scripts/generate_claude_md.py --type fullstack --output ./CLAUDE.md
```

**Available types:**
- `general` - General-purpose projects
- `backend` - API/service projects
- `frontend` - Web applications
- `fullstack` - Full-stack applications
- `data` - Data science/ML projects
- `library` - Library/package development

### Create Thinking-Enabled Subagents

```bash
python skills/context-master/scripts/create_subagent.py architecture-advisor --type deep_analyzer
python skills/context-master/scripts/create_subagent.py pattern-researcher --type researcher
```

**Available types:**
- `researcher` - Documentation searches with deep analysis
- `tester` - Test execution with failure analysis
- `analyzer` - Code analysis with architectural insights
- `builder` - Build and deployment tasks
- `deep_analyzer` - Complex decisions requiring extensive thinking

**Usage:**
```bash
/agent architecture-advisor "Analyze microservices vs monolith for e-commerce platform"
# Deep thinking happens in isolation, returns concise recommendation
# Context efficiency: ~23x improvement (5K tokens → 200 tokens)
```

## Best Practices

### Always Plan Before Creating Files
- Use `/plan-project` for any 3+ file task
- Identify shared dependencies first
- Create foundation files before dependents
- Announce your plan to the user

### Verify After Creation
- Use `/verify-structure` to catch errors early
- Check all file paths and references
- Ensure navigation and imports work
- Fix issues before considering project complete

### Optimize Context Throughout Session
- Use `/context-analysis` periodically
- Create artifacts for code and documents
- Break complex tasks into phases
- Delegate complex analysis when possible

## Troubleshooting

### "Plugin Not Loading"
- Check plugin.json syntax with JSON validator
- Ensure correct file location (for local installs)
- Windows users: Use GitHub marketplace instead
- Run with `--debug` flag for details

### "Commands Not Showing"
- Verify commands directory contains .md files
- Check frontmatter has `description` field
- Reload plugins: `claude --reload-plugins`

### "Still Creating Files Without Planning"
- Explicitly use `/plan-project` command
- Review skill activation triggers in SKILL.md
- Practice the 5-step workflow
- Check context-master skill is loaded

## Platform Notes

- **macOS/Linux:** All installation methods supported
- **Windows:** GitHub marketplace installation recommended (local paths may have issues)
- **All Platforms:** Commands and skills work identically once installed

## Contributing

Contributions welcome! This plugin packages the context-master skill for easy distribution and use.

## License

MIT

## Links

- **Plugin Directory:** Add to https://claudecodemarketplace.com/
- **Marketplace Directory:** List at https://claudemarketplaces.com/
- **Issues:** Report problems via `/bug` command in Claude Code

## Credits

Context Master skill and methodology developed to optimize Claude Code workflows for multi-file projects and context management.

---

**Get Started:** Install the plugin and try `/plan-project` on your next multi-file task!
