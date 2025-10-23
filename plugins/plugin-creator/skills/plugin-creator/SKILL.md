---
name: plugin-creator
description: "PROACTIVELY activate when users want to: create/add/build plugins, skills, commands, agents, or any Claude Code components. Automatically creates complete plugin structures with all files and GitHub-ready ZIPs. Triggers: 'create plugin', 'add skill', 'create command', 'add agent', 'build component', 'make skill', 'new plugin', 'package skill'. ALWAYS fetches latest documentation first to ensure correct structure."
license: MIT
---

# Plugin Creator - Complete Beginner's Guide

This skill provides comprehensive, step-by-step guidance for creating Claude Code plugins, from your very first plugin to publishing it for the world to use. **No prior plugin experience required!**

## 🎯 Quick Navigation

**Complete Beginners** → Start with [What is Claude Code?](#what-is-claude-code)
**First Plugin** → Jump to [Your First Plugin in 10 Minutes](#your-first-plugin-in-10-minutes)
**Create Plugin Now** → See [Creating Plugin Output](#creating-plugin-output)
**Ready to Publish** → Go to [Publishing Your Plugin](#publishing-your-plugin-to-a-marketplace)
**Looking for Advanced** → See [Advanced Plugin Development](#advanced-plugin-development)

## 🚀 Creating Plugin Output

**IMPORTANT:** When users ask to create a plugin, don't just teach them - **actually create the files AND ZIP them** for them!

**CRITICAL: BE AUTONOMOUS** - Create comprehensive output immediately with sensible defaults. Don't ask questions unless the request is genuinely ambiguous.

### ⚠️ ALWAYS FETCH LATEST DOCUMENTATION FIRST

**BEFORE creating any plugin**, Claude must ALWAYS fetch the latest plugin documentation. The official docs are the **SOURCE OF TRUTH** for structure and required fields:

```
web_fetch: https://docs.claude.com/en/docs/claude-code/plugins-reference
web_fetch: https://docs.claude.com/en/docs/claude-code/plugin-marketplaces
```

**CRITICAL:** Follow the structure and requirements from the fetched documentation, NOT just the templates in this skill. The templates below are reference examples that may become outdated - **the official docs you fetch are always correct**.

This ensures:
- All required fields (like `owner` in marketplace.json, component registration in plugin.json) are included
- Latest structural requirements are followed
- New features or requirements aren't missed
- You're working with current, accurate information

**Workflow:**
1. Fetch documentation (always)
2. Read and understand current requirements
3. Use templates below as starting points only
4. Verify your plugin.json structure matches what you learned from the docs
5. Create the plugin following the official docs structure

### ⚠️ CRITICAL: Verify Component Registration

**After fetching the official docs**, verify the current plugin structure requirements. The documentation will show the correct approach.

**Current Implementation** (verify this matches what you read in the docs):
- Components are discovered automatically by file convention (convention over configuration)
- Commands, agents, and skills don't need to be registered in plugin.json
- Simply placing files in the correct directories (`commands/`, `agents/`, `skills/`) is sufficient
- The plugin.json file only needs metadata fields (name, version, description, author, keywords, license)

**Correct plugin.json structure:**
```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "My plugin",
  "author": {
    "name": "Your Name",
    "email": "[email protected]"
  },
  "keywords": ["keyword1", "keyword2"],
  "license": "MIT"
}
```

**Remember:** Always verify against the official documentation you fetched, but the current implementation uses file-based discovery (convention over configuration).

### Autonomous Creation Principles

1. **Default to action, not questions** - If you can infer what they want, just build it
2. **Be comprehensive** - Include commands, agents, skills, and README by default
3. **Make it work** - Create functional examples, not placeholders
4. **Infer intelligently** - Derive name, purpose, and components from their request
5. **Only ask when truly unclear** - If "create a plugin" has no context, then ask. Otherwise, build.
6. **Always create ZIPs** - Package everything as downloadable ZIP files for easy distribution

### Examples of Autonomous Inference

**User says:** "Create a plugin for Git workflows"
**Claude does:** Immediately creates git-workflow-helper with PR, commit, and branch commands + agent, packages as ZIP

**User says:** "Make a deployment plugin"  
**Claude does:** Creates deployment-helper with deploy, rollback, status commands + deployment agent, packages as ZIP

**User says:** "Build a code review plugin"
**Claude does:** Creates code-review-helper with review commands + security/quality agents, packages as ZIP

**User says:** "Create a plugin of the plugin-creator skill"
**Claude does:** Creates plugin-creator plugin packaging the skill as an Agent Skill, packages as ZIP

**When to ask:** "Create a plugin" (no context) → Ask what it should do

This skill enables Claude to:
1. **Create complete plugin directory structures** ready to use
2. **Generate all necessary files** (plugin.json, commands, agents, etc.)
3. **Package as ZIP files** for easy download and distribution
4. **Output GitHub-ready marketplace structure as ZIP** for immediate publishing
5. **Provide working examples** not just documentation

### When to Create Output

Create actual plugin files when users say things like:
- "Create a plugin for X"
- "Make me a plugin that does Y"
- "Build a plugin"
- "Generate a plugin structure"
- "I want a plugin for my team"
- "Package this as a plugin"

### How to Create Plugin Output (ZIP-First Workflow)

**BE AUTONOMOUS BY DEFAULT** - Don't ask questions unless the request is truly ambiguous. Infer intent and create comprehensive output with sensible defaults.

**Step 1: Fetch Latest Documentation & Infer Requirements**

**First, ALWAYS fetch the latest plugin documentation:**
```
web_fetch: https://docs.claude.com/en/docs/claude-code/plugins-reference
web_fetch: https://docs.claude.com/en/docs/claude-code/plugin-marketplaces
```

Then, from the user's request, automatically determine:
- Plugin purpose (from their description)
- Components needed (include commands, agents, and skills by default)
- Scope (assume public/shareable unless specified otherwise)
- Name (derive from purpose or use their suggested name)

**Only ask questions if:**
- Request is genuinely unclear (e.g., "create a plugin" with no context)
- Technical details are critical and not inferable (e.g., specific API they want to integrate)
- User explicitly asks for customization

**Default approach: Create comprehensive plugin with all relevant components**

**Step 2: Create Directory Structure in Working Directory**
Use bash_tool to create the full structure in /home/claude first:

```bash
cd /home/claude
mkdir -p PLUGIN_NAME/.claude-plugin
mkdir -p PLUGIN_NAME/commands
mkdir -p PLUGIN_NAME/agents
mkdir -p PLUGIN_NAME/skills
mkdir -p PLUGIN_NAME/hooks
mkdir -p PLUGIN_NAME/scripts
```

**Step 3: Create All Necessary Files**

Based on what you learned from the fetched documentation, use file_create to generate:
- `.claude-plugin/plugin.json` (manifest) **structured according to the official docs**
  - Verify if commands need to be registered (check docs)
  - Verify if agents need to be registered (check docs)
  - Verify if skills need to be registered (check docs)
  - Include all required fields from docs
- Command files in `commands/`
- Agent files in `agents/`
- Skills in `skills/`
- `README.md` (documentation)
- Any scripts needed

**Key principle:** Use the structure you learned from the fetched documentation, not assumptions from templates.

**Step 4: Create GitHub-Ready Marketplace Structure AND Update Existing Marketplace**

**CRITICAL: Always update the existing marketplace.json if working in a marketplace repository!**

First, check if you're in a marketplace repo:
```bash
# Check if marketplace.json exists in the repo root
if [[ -f .claude-plugin/marketplace.json ]]; then
    echo "In marketplace repo - will update marketplace.json"
fi
```

If in a marketplace repository:
1. **Update the existing `.claude-plugin/marketplace.json`** to add the new plugin entry
2. Use the Read tool to get current marketplace.json structure
3. Add new plugin entry to the plugins array following the format from the fetched marketplace docs
4. Preserve all existing plugins in the array
5. Use Edit tool to update marketplace.json with the new entry

Example of updating marketplace.json:
```json
{
  "plugins": [
    // ... existing plugins ...
    {
      "name": "new-plugin-name",
      "source": "./plugins/new-plugin-name",
      "description": "Plugin description from plugin.json",
      "version": "1.0.0",
      "author": {
        "name": "Author Name"
      },
      "keywords": ["keyword1", "keyword2"]
    }
  ]
}
```

Also create a standalone marketplace-ready version:

```bash
cd /home/claude
mkdir -p PLUGIN_NAME-marketplace/.claude-plugin
mkdir -p PLUGIN_NAME-marketplace/plugins
cp -r PLUGIN_NAME PLUGIN_NAME-marketplace/plugins/
```

Copy plugin into marketplace structure and create standalone marketplace.json.

**Step 5: Create ZIP Files**
Package everything as downloadable ZIPs:

```bash
cd /home/claude
# Create plugin ZIP
zip -r PLUGIN_NAME.zip PLUGIN_NAME/

# Create marketplace ZIP (GitHub-ready)
zip -r PLUGIN_NAME-marketplace.zip PLUGIN_NAME-marketplace/

# Move ZIPs to outputs directory
mv PLUGIN_NAME.zip /mnt/user-data/outputs/
mv PLUGIN_NAME-marketplace.zip /mnt/user-data/outputs/
```

**Step 6: Provide Download Links and Instructions**
Give the user:
- Download link to plugin ZIP: `computer:///mnt/user-data/outputs/PLUGIN_NAME.zip`
- Download link to marketplace ZIP: `computer:///mnt/user-data/outputs/PLUGIN_NAME-marketplace.zip`
- Installation instructions with GitHub-first approach
- Note about Windows local path issues

### Output Format with GitHub-First Instructions

After creating ZIPs, provide this format:

```markdown
# ✅ Plugin Created: [Plugin Name]

## 📦 Download Your Plugin

### For GitHub Publishing (Recommended)
[Download PLUGIN_NAME-marketplace.zip](computer:///mnt/user-data/outputs/PLUGIN_NAME-marketplace.zip)

**Why GitHub first?**
- Windows users may have path issues with local plugin installation
- GitHub hosting works reliably across all platforms
- Easy updates and version control
- Shareable with your team

**Quick Start:**
1. Download the marketplace ZIP above
2. Extract it locally
3. Create a new GitHub repository
4. Upload all extracted files to your repo
5. Make the repository public
6. Install: `/plugin marketplace add YOUR_USERNAME/YOUR_REPO`

### For Local Testing (Advanced Users)
[Download PLUGIN_NAME.zip](computer:///mnt/user-data/outputs/PLUGIN_NAME.zip)

⚠️ **Note for Windows users:** Local plugin paths may not work correctly on Windows due to path resolution issues. GitHub installation is strongly recommended.

**Local Installation (Mac/Linux):**
1. Download the plugin ZIP above
2. Extract to `~/.local/share/claude/plugins/PLUGIN_NAME`
3. Use: `/help` to see your new commands

## 📖 What's Included

- **Commands:** [list commands]
- **Agents:** [list agents]
- **Skills:** [list skills]

## 🚀 Installation Instructions

### Option 1: GitHub (Recommended for All Users)

1. **Download the marketplace ZIP** (link above)
2. **Create a new GitHub repository:**
   - Go to github.com
   - Click "New repository"
   - Name it something like "claude-plugins" or "my-claude-marketplace"
   - Make it **public**
   - Don't initialize with README

3. **Upload your files:**
   - Extract the marketplace ZIP
   - Upload all files to your repository
   - Commit with message "Add PLUGIN_NAME plugin"

4. **Add the marketplace in Claude Code:**
   ```bash
   /plugin marketplace add YOUR_USERNAME/YOUR_REPO
   ```

5. **Install the plugin:**
   ```bash
   /plugin install PLUGIN_NAME@YOUR_USERNAME
   ```

### Option 2: Local Installation (Mac/Linux Only)

⚠️ **Windows users:** This method has known issues. Use GitHub installation instead.

1. **Download the plugin ZIP** (link above)
2. **Extract to plugins directory:**
   ```bash
   mkdir -p ~/.local/share/claude/plugins
   unzip PLUGIN_NAME.zip -d ~/.local/share/claude/plugins/
   ```
3. **Verify installation:**
   ```bash
   /help
   ```

## 🎯 Next Steps

- Test your plugin with `/help` to see commands
- Try `/agents` to see available agents
- Modify files as needed
- Share your plugin with the community!
```

### Output Templates

**⚠️ IMPORTANT:** These templates are REFERENCE EXAMPLES ONLY. Always verify against the official documentation you fetched. Requirements may have changed since these examples were written.

**Use these templates as:**
- Starting points for structure
- Examples of what fields typically exist
- Reference for markdown format

**DO NOT use these templates as:**
- The definitive structure (use fetched docs for that)
- A substitute for reading the official documentation
- Assumed to be current (always verify)

#### plugin.json Template (Reference Example - Verify Against Docs)
```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "Clear description of what this plugin does",
  "author": {
    "name": "Author Name",
    "email": "[email protected]"
  },
  "keywords": ["relevant", "keywords", "for", "discovery"],
  "license": "MIT"
}
```

**Note:** Components (commands, agents, skills) are discovered automatically from their respective directories - no registration needed in plugin.json.

**Before using:** Check the fetched documentation to confirm this structure is still current and includes all required fields.

#### Command File Template
```markdown
---
description: Brief description of what this command does
---

# Command Name

## Purpose
Explain what this command accomplishes and when to use it.

## Instructions
1. Step-by-step instructions for Claude
2. Be specific and clear
3. Include examples

## Examples
Show how to use this command.
```

#### README.md Template
```markdown
# Plugin Name

Brief description of what this plugin does.

## Installation

### Via Marketplace (Recommended)

\`\`\`bash
/plugin marketplace add your-username/repo-name
/plugin install plugin-name@your-username
\`\`\`

### Local Installation (Mac/Linux)

⚠️ **Windows users:** Use marketplace installation method instead.

\`\`\`bash
# Extract ZIP to plugins directory
unzip plugin-name.zip -d ~/.local/share/claude/plugins/
\`\`\`

## Features

- Feature 1
- Feature 2
- Feature 3

## Usage

Examples of how to use the plugin.

## Platform Notes

- **macOS/Linux:** All installation methods supported
- **Windows:** GitHub marketplace installation recommended (local paths may have issues)

## License

MIT
```

#### marketplace.json Template (Reference Example - Verify Against Docs)
```json
{
  "name": "your-username",
  "description": "My Claude Code plugins",
  "owner": {
    "name": "Your Name",
    "email": "[email protected]"
  },
  "plugins": [
    {
      "name": "plugin-name",
      "source": "./plugins/plugin-name",
      "description": "Plugin description",
      "version": "1.0.0",
      "keywords": ["keyword1", "keyword2"]
    }
  ]
}
```

**Before using:** Verify this structure against the fetched marketplace documentation. Check for any additional required fields or changed formats.

### Example: Creating a Deployment Plugin (ZIP Workflow)

**User:** "Create a plugin that helps with deployment"

**Claude should:**

0. **FIRST: Fetch latest documentation:**
```
web_fetch: https://docs.claude.com/en/docs/claude-code/plugins-reference
web_fetch: https://docs.claude.com/en/docs/claude-code/plugin-marketplaces
```

1. **Infer and create autonomously:**
   - Purpose: Deployment assistance
   - Name: deployment-helper
   - Components: Commands for deploy, rollback, status checks
   - Include: Agent for deployment troubleshooting
   - Scope: Team/public use

2. **Create the structure in working directory:**
```bash
cd /home/claude
mkdir -p deployment-helper/.claude-plugin
mkdir -p deployment-helper/commands
mkdir -p deployment-helper/agents
```

3. **Generate files based on fetched documentation:**
   - Create `plugin.json` structured according to what you learned from the docs
   - Example structure (verify this matches the docs you fetched):
   ```json
   {
     "name": "deployment-helper",
     "version": "1.0.0",
     "description": "Streamline deployment workflows with automated commands",
     "author": {
       "name": "Your Name",
       "email": "[email protected]"
     },
     "keywords": ["deployment", "devops", "automation"],
     "license": "MIT"
   }
   ```
   - Create `commands/deploy-staging.md` with deployment instructions
   - Create `commands/deploy-production.md` with production deployment
   - Create `commands/rollback.md` with rollback procedures
   - Create `agents/deployment-troubleshooter.md` with troubleshooting agent
   - Create comprehensive `README.md` with platform notes
   - **Note:** Commands and agents will be discovered automatically from their directories

4. **Create marketplace structure:**
```bash
mkdir -p deployment-helper-marketplace/.claude-plugin
mkdir -p deployment-helper-marketplace/plugins
cp -r deployment-helper deployment-helper-marketplace/plugins/
```

5. **Create marketplace.json based on fetched docs:**
   Example structure (verify against the marketplace docs you fetched):
```json
{
  "name": "your-username",
  "description": "Deployment assistance plugins",
  "owner": {
    "name": "Your Name",
    "email": "[email protected]"
  },
  "plugins": [
    {
      "name": "deployment-helper",
      "source": "./plugins/deployment-helper",
      "description": "Streamline deployment workflows",
      "version": "1.0.0",
      "keywords": ["deployment", "devops", "automation"]
    }
  ]
}
```

6. **Package as ZIPs:**
```bash
# Create both ZIPs
zip -r deployment-helper.zip deployment-helper/
zip -r deployment-helper-marketplace.zip deployment-helper-marketplace/

# Move to outputs
mv deployment-helper.zip /mnt/user-data/outputs/
mv deployment-helper-marketplace.zip /mnt/user-data/outputs/
```

7. **Provide download links and instructions:**
```markdown
# ✅ Plugin Created: Deployment Helper

## 📦 Download Your Plugin

### For GitHub Publishing (Recommended)
[Download deployment-helper-marketplace.zip](computer:///mnt/user-data/outputs/deployment-helper-marketplace.zip)

**Why GitHub first?**
- Works reliably on Windows, Mac, and Linux
- Easy sharing with your team
- Simple updates and version control

**Quick Start:**
1. Download the marketplace ZIP above
2. Extract and upload to a new GitHub repository
3. Make the repo public
4. Run: `/plugin marketplace add YOUR_USERNAME/YOUR_REPO`
5. Install: `/plugin install deployment-helper@YOUR_USERNAME`

### For Local Testing (Mac/Linux)
[Download deployment-helper.zip](computer:///mnt/user-data/outputs/deployment-helper.zip)

⚠️ **Windows users:** Local paths may not work. Use GitHub method instead.

## 📖 What's Included

- **Commands:**
  - `/deploy-staging` - Deploy to staging environment
  - `/deploy-production` - Deploy to production with safety checks
  - `/rollback` - Quick rollback to previous version
  
- **Agents:**
  - Deployment Troubleshooter - Diagnoses and fixes deployment issues

## 🚀 Next Steps

1. Download the marketplace ZIP
2. Upload to GitHub
3. Add marketplace and install
4. Try `/deploy-staging` to test!
```

### Critical Guidelines for Output Creation

**DO:**
- ✅ **ALWAYS fetch latest plugin docs first** (plugins-reference and plugin-marketplaces)
- ✅ **Follow the structure from the fetched docs, not just templates** (docs = source of truth)
- ✅ **Check if .claude-plugin/marketplace.json exists in repo root**
- ✅ **UPDATE existing marketplace.json when creating plugins in a marketplace repo** (CRITICAL!)
- ✅ Actually create files (use file_create tool)
- ✅ Verify component registration method against fetched docs
- ✅ Create complete, working examples
- ✅ Generate both plugin and marketplace structures
- ✅ **ALWAYS create ZIP files** for both plugin and marketplace
- ✅ Double-check all required fields from docs are included
- ✅ Provide computer:// download links to ZIPs
- ✅ Include GitHub-first installation instructions
- ✅ Warn Windows users about local path issues
- ✅ Make content specific to user's needs
- ✅ Test that structure is correct before packaging

**DON'T:**
- ❌ **Skip fetching the latest documentation** (most critical step!)
- ❌ **Blindly copy templates without verifying against fetched docs**
- ❌ **Forget to update existing marketplace.json when in a marketplace repo** (CRITICAL!)
- ❌ Assume requirements haven't changed
- ❌ Just show example code without creating files
- ❌ Create incomplete structures
- ❌ Skip creating ZIP files
- ❌ Forget the marketplace.json in standalone marketplace
- ❌ Use placeholder content without customizing
- ❌ Provide only directory links (users can't download directories!)
- ❌ Forget to mention Windows path limitations
- ❌ Skip GitHub-first recommendations

### Platform-Specific Notes for Users

**Windows Users:**
- ⚠️ Local plugin installation may not work due to path resolution issues
- ✅ GitHub marketplace installation works reliably
- ✅ Always use the marketplace method for best results

**Mac/Linux Users:**
- ✅ Both local and GitHub installation methods work
- 💡 GitHub method still recommended for easy updates and sharing

### Ready-to-Upload GitHub Structure (in ZIP)

When creating marketplace ZIP, ensure it contains this structure:

```
plugin-name-marketplace/
├── .claude-plugin/
│   └── marketplace.json          # Marketplace manifest
├── plugins/
│   └── plugin-name/              # The actual plugin
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── commands/
│       ├── agents/
│       └── README.md
└── README.md                     # Marketplace README
```

Users can extract this ZIP and upload directly to GitHub!

## What is Claude Code?

<introduction>
Claude Code is a command-line tool that lets you work with Claude AI directly in your terminal. Instead of copying code back and forth between a browser and your code editor, Claude can read your files, run commands, and help you code right where you work.

Think of it like having an AI pair programmer in your terminal who can:
- Read and understand your project
- Write and edit code
- Run tests and commands
- Help debug issues
- Learn from custom instructions you provide

**Plugins extend Claude Code** by adding new commands, agents, and capabilities. If you're new to coding or command-line tools, don't worry - this guide starts from the very beginning.
</introduction>

### Why Would I Create a Plugin?

Plugins let you:
- **Teach Claude your workflow** - Create commands for tasks you do repeatedly
- **Share your expertise** - Package your knowledge to help others
- **Customize Claude** - Add domain-specific abilities (deployment, testing, etc.)
- **Automate tasks** - Turn multi-step processes into single commands
- **Build tools for teams** - Create shared commands for your company

You don't need to be a programmer to create useful plugins!

## Your First Plugin in 10 Minutes

<first_plugin_tutorial>
Let's create a simple plugin that helps with git commits. No prior plugin experience needed!

### What We'll Build

A plugin with a single command: `/commit-smart` that helps write better commit messages.

### Step 1: Ask Claude to Create It

Just say:

> "Create a plugin that helps me write better git commit messages"

Claude will:
1. Create all the necessary files
2. Package it as a ZIP
3. Give you download links
4. Provide installation instructions

### Step 2: Download and Upload to GitHub

1. Click the marketplace ZIP download link Claude provides
2. Extract the ZIP file
3. Go to GitHub and create a new repository
4. Upload the extracted files to your repo
5. Make the repository public

### Step 3: Install Your Plugin

In Claude Code:

```bash
/plugin marketplace add YOUR_USERNAME/YOUR_REPO
/plugin install commit-helper@YOUR_USERNAME
```

### Step 4: Use It!

```bash
/commit-smart
```

Claude will now help you write a great commit message!

### What Just Happened?

You created, published, and installed your first plugin! Here's what you made:

1. **A plugin** - A collection of capabilities for Claude
2. **A command** - `/commit-smart` that Claude can use
3. **A marketplace** - A GitHub repo hosting your plugin
4. **A shareable tool** - Anyone can now use your plugin!

That's it! You're now a plugin creator. Everything else in this guide builds on these basics.
</first_plugin_tutorial>

## Understanding Plugin Basics

### What's in a Plugin?

A plugin is a folder with this structure:

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json       # ← Required: Tells Claude about your plugin
├── commands/             # ← Optional: Custom commands
│   └── my-command.md
├── agents/               # ← Optional: Specialized AI assistants
│   └── my-agent.md
├── skills/               # ← Optional: Knowledge to teach Claude
│   └── my-skill.md
└── README.md            # ← Recommended: How to use your plugin
```

Only the `.claude-plugin/plugin.json` file is **required**. Everything else is optional!

### The Five Types of Plugin Components

**IMPORTANT:** Always fetch and check the official documentation to understand how components should be structured and registered.

#### 1. Commands (The Most Common)
Commands are custom instructions that you invoke with `/command-name`.

**Example:** A `/deploy` command that knows your deployment process.

**When to use:** When you want to trigger a specific workflow or task.

**File location:** `commands/deploy.md`

```markdown
---
description: Deploy to production with safety checks
---

# Deploy Command

## Purpose
This command guides Claude through our production deployment process.

## Instructions
1. Check that all tests pass
2. Review the changelog
3. Create a backup
4. Deploy to production
5. Run smoke tests
6. Notify the team
```

#### 2. Agents (Specialized Assistants)
Agents are AI assistants with specific roles or expertise.

**Example:** A "Security Reviewer" agent that checks code for vulnerabilities.

**When to use:** When you want Claude to adopt a specific perspective or expertise.

**File location:** `agents/security-reviewer.md`

```markdown
---
agent: true
---

# Security Reviewer

You are a security expert reviewing code for vulnerabilities. Focus on:

- SQL injection risks
- XSS vulnerabilities  
- Authentication issues
- Data exposure

Always explain security issues in simple terms and suggest fixes.
```

#### 3. Skills (Teaching Claude)
Skills provide Claude with knowledge about your domain, tools, or processes.

**Example:** A skill explaining your company's API structure.

**When to use:** When Claude needs to understand something specific to your context.

**File location:** `skills/our-api.md`

```markdown
---
name: our-api
description: Knowledge about our company's API structure
---

# Our API Documentation

## Overview
Our API follows REST principles with JSON payloads.

## Authentication
We use JWT tokens in the Authorization header...

## Common Endpoints
- `GET /api/users` - List users
- `POST /api/users` - Create user
...
```

#### 4. Hooks (Advanced: Auto-Triggers)
Hooks automatically run scripts or commands when certain events happen.

**Example:** Auto-format code after Claude edits a file.

**When to use:** When you want automatic behavior without manual commands.

**File location:** `.claude-plugin/hooks.json`

```json
{
  "PostToolUse": [
    {
      "matcher": "Write",
      "hooks": [
        {
          "type": "command",
          "command": "./scripts/format.sh"
        }
      ]
    }
  ]
}
```

#### 5. MCP Servers (Advanced: External Tools)
MCP (Model Context Protocol) servers let Claude use external tools and APIs.

**Example:** A server that lets Claude interact with your company's database.

**When to use:** When you need Claude to access external systems or services.

**Configuration in:** `.claude-plugin/plugin.json`

```json
{
  "name": "my-plugin",
  "mcpServers": {
    "my-tool": {
      "command": "npx",
      "args": ["-y", "@my-company/mcp-server"]
    }
  }
}
```

### Plugin vs Marketplace: What's the Difference?

**Plugin:**
- A single tool with commands/agents/skills
- One folder with a plugin.json
- Like a single app on your phone

**Marketplace:**
- A collection of plugins
- One folder containing multiple plugins
- Like an app store containing many apps

Most people create one marketplace that holds all their plugins.

## Creating Your Plugin Structure

<plugin_structure_details>
When Claude creates a plugin for you, it generates all files automatically. But here's what each file does so you can customize it:

### The Required File: plugin.json

This is the only required file. It tells Claude Code about your plugin:

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "What this plugin does",
  "author": {
    "name": "Your Name",
    "email": "[email protected]"
  },
  "keywords": ["helpful", "search", "terms"],
  "license": "MIT"
}
```

**Important fields:**
- `name`: Must be unique, use kebab-case (my-plugin-name)
- `version`: Follow semantic versioning (1.0.0)
- `description`: Help others find your plugin

### Commands Directory

Each markdown file here becomes a `/command-name` in Claude Code.

**Naming:** The filename becomes the command name.
- `deploy.md` → `/deploy`
- `review-pr.md` → `/review-pr`

**Content:** Instructions for Claude on what to do when command is invoked.

### Agents Directory

Each markdown file here becomes an agent Claude can use.

**Naming:** Use descriptive names for the file.
- `security-expert.md` → "Security Expert" agent

**Content:** Instructions that define the agent's role and expertise.

**Required frontmatter:**
```markdown
---
agent: true
---
```

### Skills Directory

Skills teach Claude about your context. Each file is loaded into Claude's context when needed.

**Naming:** Use descriptive names.
- `company-api.md`
- `deployment-process.md`

**Content:** Documentation, guides, or knowledge Claude should know.

### Optional Directories

- `hooks/` - Scripts that run automatically
- `scripts/` - Helper scripts your plugin uses
- `bin/` - Binary tools or executables

## Publishing Your Plugin to a Marketplace

<publishing_guide>
The easiest way to share your plugin is via a GitHub marketplace. Claude creates both plugin and marketplace ZIPs for you automatically!

### Quick Publishing Steps

1. **Download the marketplace ZIP** Claude created for you
2. **Create a GitHub repository:**
   - Go to github.com
   - Click "New repository"
   - Give it a name like "my-claude-plugins"
   - Make it **public** (required for others to use it)
   - Don't initialize with README (you have one in the ZIP)

3. **Upload your files:**
   - Extract the marketplace ZIP
   - Upload all files to your repository
   - Make sure `.claude-plugin/marketplace.json` is in the root

4. **Verify structure:**
```
your-repo/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   └── your-plugin/
│       ├── .claude-plugin/
│       │   └── plugin.json
│       └── ...
└── README.md
```

5. **That's it!** Your marketplace is live. Anyone can now add it:
```bash
/plugin marketplace add YOUR_USERNAME/REPO_NAME
```

### The Marketplace.json File

After fetching the marketplace documentation, Claude creates this file according to the official structure. Here's a reference example (verify against docs):

```json
{
  "name": "my-marketplace",
  "description": "My collection of Claude Code plugins",
  "owner": {
    "name": "Your Name",
    "email": "[email protected]"
  },
  "plugins": [
    {
      "name": "plugin-name",
      "source": "./plugins/plugin-name",
      "description": "Plugin description",
      "version": "1.0.0",
      "keywords": ["keyword1", "keyword2"]
    }
  ]
}
```

**Key points from typical marketplace structure:**
- `source` points to where your plugin lives in the repo
- You can have multiple plugins in one marketplace
- The `name` in marketplace.json typically matches your GitHub username
- Check the docs for all required fields (structure may have evolved)

### Testing Before Publishing

Before making your repo public, test locally:

1. **Extract your plugin ZIP** to test location:
```bash
unzip my-plugin.zip -d ~/.local/share/claude/plugins/
```

2. **Test in Claude Code:**
```bash
/help          # See your commands
/agents        # See your agents
```

3. **Fix any issues**, then proceed to publish

### Updating Your Plugin

When you make changes:

1. **Update version** in plugin.json (e.g., 1.0.0 → 1.0.1)
2. **Update version** in marketplace.json
3. **Commit and push** to GitHub
4. **Users update** with:
```bash
/plugin marketplace update marketplace-name
/plugin update plugin-name
```

### Making Your Plugin Discoverable

Add your marketplace to community directories:
- https://claudecodemarketplace.com/ - Plugin directory
- https://claudemarketplaces.com/ - Marketplace directory

Include good keywords in your plugin.json for searchability!
</publishing_guide>

## Testing Your Plugin

<testing_guide>
Before sharing your plugin, test it thoroughly:

### Local Testing (Mac/Linux Only)

⚠️ **Windows users:** Skip to GitHub testing method below.

1. **Extract plugin ZIP to plugins directory:**
```bash
mkdir -p ~/.local/share/claude/plugins
unzip my-plugin.zip -d ~/.local/share/claude/plugins/
```

2. **Restart Claude Code or run:**
```bash
claude --reload-plugins
```

3. **Verify plugin loaded:**
```bash
/plugin list
```

4. **Test each component:**
```bash
/help                    # See your commands
/agents                  # See your agents
/your-command           # Test a command
```

### GitHub Testing (All Platforms)

This works reliably on Windows, Mac, and Linux:

1. **Create a private test repository** on GitHub
2. **Upload your marketplace ZIP contents** to the repo
3. **Make repo public** (required for Claude Code to access)
4. **Add marketplace:**
```bash
/plugin marketplace add YOUR_USERNAME/YOUR_TEST_REPO
```
5. **Install and test:**
```bash
/plugin install my-plugin@YOUR_USERNAME
/help
```

### Common Testing Checklist

- [ ] Plugin appears in `/plugin list`
- [ ] Commands show in `/help`
- [ ] Agents show in `/agents`
- [ ] Commands execute without errors
- [ ] Agents provide expected behavior
- [ ] README renders correctly on GitHub
- [ ] No sensitive information in files
- [ ] All paths work (especially scripts)

### Debug Mode

If something's not working:

```bash
claude --debug
```

This shows detailed loading information and error messages.
</testing_guide>

## Real-World Plugin Examples

<plugin_examples>
Let's look at practical plugins you might create:

### Example 1: PR Review Helper

**Purpose:** Help create thorough pull request reviews.

**Structure:**
```
pr-review-helper/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── review-pr.md
│   ├── check-tests.md
│   └── suggest-improvements.md
├── agents/
│   ├── code-reviewer.md
│   └── security-reviewer.md
└── README.md
```

**Key command** (`commands/review-pr.md`):
```markdown
---
description: Perform a comprehensive PR review
---

# PR Review

## Purpose
Review pull requests thoroughly for code quality, security, and best practices.

## Process
1. Read all changed files
2. Check for security issues
3. Verify tests exist
4. Check code style
5. Suggest improvements
6. Write review summary

## Security Checklist
- SQL injection risks
- XSS vulnerabilities
- Exposed secrets
- Auth/authorization issues
```

**To create this:** Just ask Claude:
> "Create a PR review plugin with commands for reviewing code, checking tests, and suggesting improvements. Include agents for code and security review."

### Example 2: Team Onboarding

**Purpose:** Help new team members get up to speed.

**Structure:**
```
team-onboarding/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── setup-environment.md
│   ├── explain-architecture.md
│   └── common-tasks.md
├── skills/
│   ├── our-tech-stack.md
│   ├── code-standards.md
│   └── deployment-process.md
└── README.md
```

**Key skill** (`skills/our-tech-stack.md`):
```markdown
---
name: our-tech-stack
description: Overview of our company's technology choices
---

# Our Tech Stack

## Frontend
- React 18 with TypeScript
- TailwindCSS for styling
- Vite as build tool

## Backend
- Node.js with Express
- PostgreSQL database
- Redis for caching

## Deployment
- Docker containers
- AWS ECS for hosting
- GitHub Actions for CI/CD

## Code Standards
- ESLint + Prettier
- Test coverage > 80%
- All PRs need 2 approvals
```

**To create this:** Tell Claude:
> "Create a team onboarding plugin that explains our tech stack, deployment process, and common tasks. Use skills for documentation."

### Example 3: API Integration Helper

**Purpose:** Make it easy to work with a specific API.

**Structure:**
```
stripe-helper/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── create-customer.md
│   ├── create-subscription.md
│   └── handle-webhook.md
├── skills/
│   └── stripe-api.md
├── agents/
│   └── payment-expert.md
└── README.md
```

**Skill** teaches Claude the API, **commands** handle common tasks, **agent** provides expertise.

**To create this:** Ask Claude:
> "Create a plugin for Stripe API integration with commands for creating customers, subscriptions, and handling webhooks. Include a payment expert agent."

### Example 4: Documentation Generator

**Purpose:** Automatically generate project documentation.

**Structure:**
```
docs-generator/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── generate-api-docs.md
│   ├── generate-readme.md
│   └── update-changelog.md
└── README.md
```

**These plugins show you don't need complex structures.** Even simple plugins with 1-3 commands can be incredibly useful!
</plugin_examples>

## Tips for Better Plugins

<plugin_tips>
### Writing Good Commands

**DO:**
- ✅ Be specific about steps
- ✅ Include examples
- ✅ Handle error cases
- ✅ Explain *why* not just *what*

**DON'T:**
- ❌ Be vague ("do something")
- ❌ Skip error handling
- ❌ Assume context
- ❌ Write a novel (keep focused)

**Example of good vs bad:**

❌ **Bad:**
```markdown
Check the code for issues
```

✅ **Good:**
```markdown
# Code Review Process

1. Read all changed files
2. Check for:
   - SQL injection (look for string concatenation in queries)
   - XSS (check for unescaped user input in HTML)
   - Exposed secrets (search for API keys, passwords)
3. Verify tests exist for new functions
4. Suggest specific improvements with code examples
5. Rate severity: Low/Medium/High
```

### Writing Good Agents

Agents should have:
1. **Clear role:** What expertise do they provide?
2. **Perspective:** How do they approach problems?
3. **Constraints:** What DON'T they do?

**Example:**
```markdown
---
agent: true
---

# Performance Optimizer

You are a performance optimization expert. Your role is to identify and fix performance bottlenecks in code.

## Your Approach
- Always measure before optimizing
- Focus on algorithmic improvements first
- Consider memory usage alongside CPU time
- Explain trade-offs clearly

## You DON'T
- Optimize prematurely
- Sacrifice readability for minor gains
- Recommend without profiling data
```

### Writing Good Skills

Skills should:
1. **Be focused:** One skill = one topic
2. **Be scannable:** Use headers and lists
3. **Include examples:** Show don't just tell
4. **Stay updated:** Update as things change

**Structure:**
```markdown
---
name: skill-name
description: One-line summary
---

# Skill Title

## Overview
Brief introduction

## Key Concepts
- Concept 1: Explanation
- Concept 2: Explanation

## Examples
Concrete examples

## Common Pitfalls
What to avoid

## Related Information
Links or references
```

### Keep Plugins Focused

**Better:** 5 small focused plugins
**Worse:** 1 giant plugin that does everything

Why? 
- Easier to maintain
- Easier for others to use
- Faster loading
- Clearer purpose

**Example:**
Instead of "dev-helper" plugin with 20 commands, create:
- "git-helper" - Git workflows
- "deploy-helper" - Deployment tasks
- "test-helper" - Testing utilities
- "docs-helper" - Documentation

### Version Control

Keep your plugins in Git:
1. Tracks changes over time
2. Enables collaboration
3. Users can see history
4. Easy rollback if needed

### Documentation

Your README should answer:
1. **What does this plugin do?** (One sentence)
2. **Why would I use it?** (The problem it solves)
3. **How do I install it?** (Exact commands)
4. **How do I use it?** (Examples)
5. **What are the commands?** (List with descriptions)

See the README template in [Output Templates](#output-templates) above.
</plugin_tips>

## Common Issues and Solutions

<troubleshooting>
### Plugin Not Loading

**Symptoms:** Plugin doesn't appear in `/plugin list`

**Solutions:**
1. **Check plugin.json syntax**
   - Valid JSON?
   - Required fields present?
   - Use a JSON validator

2. **Check file location (for local plugins - Mac/Linux only)**
   - Should be: `~/.local/share/claude/plugins/PLUGIN_NAME/`
   - Not: `~/.local/share/claude/plugins/PLUGIN_NAME/PLUGIN_NAME/`
   
3. **Windows users:** Local plugins may not work. Use GitHub marketplace instead:
   ```bash
   /plugin marketplace add YOUR_USERNAME/YOUR_REPO
   ```

4. **Reload plugins:**
   ```bash
   claude --reload-plugins
   ```

5. **Check debug output:**
   ```bash
   claude --debug
   ```

### Commands Not Showing Up

**Symptoms:** Plugin loads but commands missing from `/help`

**Solutions:**
1. **Check if registration is required (check the official docs)**
   - Fetch and read: https://docs.claude.com/en/docs/claude-code/plugins-reference
   - See if commands need to be registered in plugin.json
   - If yes, verify your plugin.json has the proper structure
   - Compare your plugin.json to the examples in the docs
   
2. **Check file location**
   - Commands must be in `commands/` directory
   - Directly in the directory, not in subdirectories
   
3. **Check frontmatter**
   - Must have `---` delimiters
   - `description` field recommended
   
4. **Check filename**
   - Must end in `.md`
   - No spaces in name (use hyphens)
   
5. **Reload:**
   ```bash
   claude --reload-plugins
   ```

### Agents Not Appearing

**Symptoms:** Plugin loads but agents missing from `/agents`

**Solutions:**
1. **Check if registration is required (check the official docs)**
   - Fetch and read: https://docs.claude.com/en/docs/claude-code/plugins-reference
   - See if agents need to be registered in plugin.json
   - If yes, verify your plugin.json has the proper structure
   - Compare your plugin.json to the examples in the docs
   
2. **Check frontmatter**
   - Must include `agent: true`
   - Must have `---` delimiters
   
3. **Check file location**
   - Must be in `agents/` directory
   
4. **Check filename**
   - Must end in `.md`

### Marketplace Not Found

**Symptoms:** Can't add marketplace, says not found

**Solutions:**
1. **Check repository is public**
   - Private repos need authentication
   - Make sure you didn't typo the username/repo name
   
2. **Check marketplace.json exists**
   - Must be at `.claude-plugin/marketplace.json`
   - In the repository root
   
3. **Try full URL**
   - Instead of `username/repo`
   - Try `https://github.com/username/repo.git`

### "Plugin Failed to Load" Error

**Symptoms:** Error message when installing

**Solutions:**
1. **Check for typos in JSON files**
   - Missing commas, brackets
   - Use a JSON validator
   
2. **Check file permissions**
   - Can Claude Code read the files?
   - Try `chmod +x` on script files
   
3. **Check logs**
   - Run `claude --debug` to see detailed errors
   - Look for specific error messages

### Windows Local Path Issues

**Symptoms:** Plugin works on Mac/Linux but not Windows

**Solutions:**
1. **Use GitHub marketplace method:**
   - This is the recommended approach for Windows
   - Upload to GitHub and install via marketplace
   
2. **Alternative:** Use WSL (Windows Subsystem for Linux)
   - Install WSL2
   - Install Claude Code in WSL
   - Follow Linux installation steps

### Still Stuck?

<getting_unstuck>
If you're still having trouble:

1. **Ask Claude directly**
   - "Help me debug my plugin"
   - "Fetch the latest plugin troubleshooting docs"
   
2. **Check existing plugins**
   - Browse https://claudecodemarketplace.com/
   - Look at their GitHub repos for examples
   - Copy structure that works
   
3. **Get community help**
   - Claude Developers Discord
   - GitHub discussions
   - Stack Overflow (tag: claude-code)
   
4. **File a bug report**
   - Use `/bug` command in Claude Code
   - Or file issue on GitHub
</getting_unstuck>
</troubleshooting>

## Advanced Plugin Development

Once you're comfortable with the basics, explore these advanced topics:

### Progressive Disclosure in Skills

Skills can load information gradually to save context:

```markdown
---
name: advanced-skill
description: Loads details only when needed
---

# Advanced Skill

## Overview
High-level description always loaded.

## <details id="detail-1">
### Detailed Topic 1
This section only loads when Claude needs it.
</details>

## <details id="detail-2">
### Detailed Topic 2
Another section that loads on-demand.
</details>
```

### Dynamic Hook Configuration

Create hooks that adapt to the environment:

```json
{
  "PostToolUse": [
    {
      "matcher": "Write|Edit",
      "hooks": [
        {
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/scripts/smart-formatter.sh",
          "env": {
            "PROJECT_TYPE": "auto-detect"
          }
        }
      ]
    }
  ]
}
```

### Multi-Plugin Workflows

Design plugins that work together:

1. **Base plugin** - Core functionality
2. **Extension plugins** - Add specific features
3. **Users install what they need**

Example: Git plugin + GitHub plugin + GitLab plugin

### Environment Variables

Use `${CLAUDE_PLUGIN_ROOT}` for plugin-relative paths:

```json
{
  "mcpServers": {
    "my-tool": {
      "command": "${CLAUDE_PLUGIN_ROOT}/bin/server",
      "args": ["--config", "${CLAUDE_PLUGIN_ROOT}/config.json"]
    }
  }
}
```

### Plugin Testing Framework

Create a testing workflow:

1. **Local marketplace** for development
2. **Test scripts** to validate structure
3. **CI/CD** to check on every commit
4. **Beta testing** with small group first

## Best Practices Summary

### For Beginners

✅ **DO:**
- Start simple (one command is fine!)
- Test using GitHub method (works everywhere)
- Write clear descriptions
- Include examples in README
- Ask for help when stuck

❌ **DON'T:**
- Try to build everything at once
- Skip testing
- Hardcode sensitive information
- Use complicated structures initially
- Rely on local paths on Windows

### Naming Conventions

- **Plugin names:** `my-plugin-name` (kebab-case)
- **Command names:** `/do-something` (verb-based, kebab-case)
- **Agent names:** `Role Describer` (clear role indication)
- **File names:** lowercase with hyphens

### Security Checklist

Before publishing:
- [ ] No API keys or passwords in code
- [ ] Use environment variables for secrets
- [ ] Document security requirements
- [ ] Review scripts for security issues
- [ ] Consider what permissions plugin needs

### Documentation Checklist

Every plugin should have:
- [ ] README.md with installation instructions
- [ ] Usage examples for each feature
- [ ] Required configuration explained
- [ ] Platform-specific notes (Windows/Mac/Linux)
- [ ] License file
- [ ] Contributing guidelines (optional)

### Platform Compatibility Checklist

- [ ] README mentions platform compatibility
- [ ] Windows users directed to GitHub method
- [ ] Local paths avoided in favor of GitHub
- [ ] Installation tested on multiple platforms
- [ ] Clear warnings about platform limitations

## Quick Reference

### Required Files

```
my-plugin/
└── .claude-plugin/
    └── plugin.json       # ← This file is REQUIRED
```

### Minimal plugin.json

**Basic structure (verify against current docs):**
```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "What this plugin does"
}
```

**With full metadata:**
```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "What this plugin does",
  "author": {
    "name": "Your Name",
    "email": "[email protected]"
  },
  "keywords": ["keyword1", "keyword2"],
  "license": "MIT"
}
```

**Note:** Components (commands, agents, skills) don't need to be registered in plugin.json - they are discovered automatically from their directories.

### Minimal marketplace.json

**Example structure (verify against current marketplace docs):**
```json
{
  "name": "my-marketplace",
  "owner": {
    "name": "Your Name",
    "email": "[email protected]"
  },
  "plugins": [
    {
      "name": "my-plugin",
      "source": "./plugins/my-plugin"
    }
  ]
}
```

**Note:** Check the fetched marketplace documentation for all required fields.

### Essential Commands

```bash
# Marketplace management
/plugin marketplace add username/repo
/plugin marketplace list
/plugin marketplace update marketplace-name
/plugin marketplace remove marketplace-name

# Plugin management
/plugin install plugin-name@marketplace-name
/plugin list
/plugin uninstall plugin-name

# Testing
/help                      # See your commands
/agents                    # See your agents
claude --debug             # Debug mode
```

### Installation Methods by Platform

**Windows:**
```bash
# RECOMMENDED: GitHub marketplace
/plugin marketplace add YOUR_USERNAME/YOUR_REPO
/plugin install plugin-name@YOUR_USERNAME
```

**Mac/Linux:**
```bash
# Option 1: GitHub marketplace (recommended)
/plugin marketplace add YOUR_USERNAME/YOUR_REPO
/plugin install plugin-name@YOUR_USERNAME

# Option 2: Local installation
unzip plugin-name.zip -d ~/.local/share/claude/plugins/
```

## Additional Resources

### Official Documentation
- **Plugins Guide:** https://docs.claude.com/en/docs/claude-code/plugins
- **Marketplace Guide:** https://docs.claude.com/en/docs/claude-code/plugin-marketplaces
- **Plugins Reference:** https://docs.claude.com/en/docs/claude-code/plugins-reference
- **MCP Documentation:** https://docs.claude.com/en/docs/claude-code/mcp
- **Skills Engineering:** https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills

### Community Resources
- **Plugin Directory:** https://claudecodemarketplace.com/
- **Marketplace Directory:** https://claudemarketplaces.com/
- **Official GitHub:** https://github.com/anthropics/claude-code
- **Claude Developers Discord:** Join for help and discussion
- **Community Plugins:** Browse GitHub for examples and inspiration

### Related Skills
- **skill-creator:** Create optimized Skills to package in plugins
- **context-solver:** Optimize multi-file plugin development

## Conclusion

You now have everything you need to create, test, and publish Claude Code plugins!

**Remember:**
- Start simple - your first plugin can be just one command
- Use GitHub marketplace for reliable cross-platform distribution
- Test thoroughly before sharing
- Don't hesitate to ask for help
- Share your work with the community

**Your journey:**
1. ✅ Created your first plugin
2. ✅ Learned plugin structure
3. ✅ Packaged as downloadable ZIPs
4. ✅ Published to a marketplace
5. 🎯 Next: Build something useful!

**Platform compatibility:**
- ✅ GitHub method works on all platforms
- ⚠️ Local installation may have issues on Windows
- 💡 Always provide ZIP downloads for users

<final_encouragement>
Every expert was once a beginner. Your first plugin doesn't need to be perfect - it just needs to exist. Start simple, learn as you go, and before you know it, you'll be creating sophisticated plugins that help developers around the world.

Now go build something awesome! 🚀
</final_encouragement>
