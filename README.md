# Claude Code Marketplace

> A curated collection of Claude Code plugins for plugin development, context optimization, and productivity tools

## 📦 Available Plugins

### [plugin-creator](./plugins/plugin-creator)
Comprehensive plugin development toolkit that enables Claude to autonomously create, package, and publish Claude Code plugins.

**What it does:**
- Generates complete plugin structures with best practices
- Creates marketplace-ready ZIP packages
- Provides 5 slash commands, 1 specialized agent, and comprehensive documentation

**Install:** `/plugin install plugin-creator@JosiahSiegel`

### [context-solver](./plugins/context-solver)
Optimal planning and context management for multi-file projects, reducing token usage by ~62% on average.

**What it does:**
- Plans optimal file creation order before implementation
- Prevents redundant work through dependency-aware architecture
- Provides extended thinking delegation patterns

**Install:** `/plugin install context-solver@JosiahSiegel`

## 🚀 Quick Start

**1. Add this marketplace:**
```bash
/plugin marketplace add JosiahSiegel/claude-code-marketplace
```

**2. Install plugins:**
```bash
/plugin install plugin-creator@JosiahSiegel
/plugin install context-solver@JosiahSiegel
```

**3. Start using:**
- Plugin Creator: `"Create a Git workflow plugin"`
- Context Solver: `/plan-project` before multi-file tasks

## 📖 Documentation

Each plugin includes detailed documentation:
- **plugin-creator**: See [`plugins/plugin-creator/README.md`](./plugins/plugin-creator/README.md)
- **context-solver**: See [`plugins/context-solver/README.md`](./plugins/context-solver/README.md)

## 🤝 Contributing

Want to add a plugin to this marketplace? See [`CONTRIBUTING.md`](./CONTRIBUTING.md) for guidelines.

## 📊 Marketplace Info

- **Owner:** Josiah Siegel
- **Repository:** https://github.com/JosiahSiegel/claude-code-marketplace
- **License:** MIT
- **Issues:** [Report here](https://github.com/JosiahSiegel/claude-code-marketplace/issues)

## 📄 License

MIT - See [LICENSE](./LICENSE) for details.
