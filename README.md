# Claude Code Marketplace

> A curated collection of Claude Code plugins for plugin development, context optimization, and productivity tools

## 📦 Available Plugins

### [plugin-master](./plugins/plugin-master)
Comprehensive plugin development toolkit that enables Claude to autonomously create, package, and publish Claude Code plugins.

**What it does:**
- Generates complete plugin structures with best practices
- Creates marketplace-ready ZIP packages
- Provides 5 slash commands, 1 specialized agent, and comprehensive documentation

**Install:** `/plugin install plugin-master@claude-code-marketplace`

### [context-master](./plugins/context-master)
Optimal planning and context management for multi-file projects, reducing token usage by ~62% on average.

**What it does:**
- Plans optimal file creation order before implementation
- Prevents redundant work through dependency-aware architecture
- Provides extended thinking delegation patterns

**Install:** `/plugin install context-master@claude-code-marketplace`

### [azure-to-docker-master](./plugins/azure-to-docker-master)
Complete Azure-to-Docker containerization system for creating local development environments from Azure infrastructure.

**What it does:**
- Programmatically extracts Azure resource configurations
- Generates production-ready Dockerfiles and docker-compose.yml
- Exports Azure SQL/PostgreSQL/MySQL databases for local containers
- Provides 3 powerful automation scripts (2,000+ lines of code)
- Includes comprehensive documentation (8,500+ lines)

**Install:** `/plugin install azure-to-docker-master@claude-code-marketplace`

## 🚀 Quick Start

**1. Add this marketplace:**
```bash
/plugin marketplace add JosiahSiegel/claude-code-marketplace
```

**2. Install plugins:**
```bash
/plugin install plugin-master@claude-code-marketplace
/plugin install context-master@claude-code-marketplace
/plugin install azure-to-docker-master@claude-code-marketplace
```

**3. Start using:**
- Plugin Master: `"Create a Git workflow plugin"`
- Context Master: `/plan-project` before multi-file tasks
- Azure-to-Docker Master: `/extract-infrastructure` to containerize Azure resources

## 📖 Documentation

Each plugin includes detailed documentation:
- **plugin-master**: See [`plugins/plugin-master/README.md`](./plugins/plugin-master/README.md)
- **context-master**: See [`plugins/context-master/README.md`](./plugins/context-master/README.md)
- **azure-to-docker-master**: See [`plugins/azure-to-docker-master/README.md`](./plugins/azure-to-docker-master/README.md)

## 🤝 Contributing

Want to add a plugin to this marketplace? See [`CONTRIBUTING.md`](./CONTRIBUTING.md) for guidelines.

## 📊 Marketplace Info

- **Owner:** Josiah Siegel
- **Repository:** https://github.com/JosiahSiegel/claude-code-marketplace
- **License:** MIT
- **Issues:** [Report here](https://github.com/JosiahSiegel/claude-code-marketplace/issues)

## 📄 License

MIT - See [LICENSE](./LICENSE) for details.
