---
description: Prepare and publish Claude Code plugins to GitHub marketplaces with complete documentation
---

# Publish Plugin Command

Guide you through publishing your plugin to a GitHub marketplace with all necessary setup and documentation.

## Usage

This command helps you:
- Create marketplace-ready structure
- Generate marketplace.json
- Package plugin files
- Create repository structure
- Provide publishing instructions
- Set up version management

## Process

Claude will:

1. **Validate plugin** - Check plugin structure and files
2. **Create marketplace structure** - Generate marketplace-ready layout
3. **Generate marketplace.json** - With proper owner and plugin metadata
4. **Create documentation** - README with installation instructions
5. **Package as ZIP** - GitHub-ready marketplace archive
6. **Provide GitHub guide** - Step-by-step publishing instructions

## Examples

**First time publishing:**
> /publish-plugin for my-first-plugin

**Update existing:**
> /publish-plugin to update version 2.0

**Team marketplace:**
> /publish-plugin for company internal tools

## Publishing Options

**Individual Plugin:**
- Single plugin in its own repository
- Direct installation: `/plugin marketplace add user/repo`

**Marketplace Collection:**
- Multiple plugins in one repository
- Organized catalog with categories
- Team or community distribution

**Private/Internal:**
- Private GitHub repositories
- Enterprise team distribution
- Access control via GitHub permissions

## Output

- Marketplace ZIP file ready for GitHub
- Complete README.md with installation instructions
- Publishing checklist
- Version management guidance
- GitHub repository setup instructions
- Marketing tips for community plugins

## After Publishing

Share your plugin:
1. Upload to GitHub
2. Add to community directories:
   - claudecodemarketplace.com
   - claude-plugins.dev
3. Share in Claude Developers Discord
4. Create usage examples and tutorials
