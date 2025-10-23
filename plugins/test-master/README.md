# test-master

Complete management plugin for **Vitest + Playwright + MSW** testing infrastructure. This production-ready plugin provides comprehensive test automation, debugging, and infrastructure management for modern JavaScript projects.

## 🚀 Features

### Core Test Management
- **Run all tests** with intelligent selection based on changed files
- **Unit, integration, and E2E test execution** with separate commands
- **Watch mode** for continuous testing during development
- **Coverage analysis** with detailed reports and gap identification
- **Interactive debugging** with trace analysis and headed mode

### Test File Management
- **Auto-scaffolding** for unit, integration, and E2E tests with proper boilerplate
- **Helper utilities** for assertions, DOM manipulation, fixtures, mocks, and state
- **Fixture generation** for consistent mock data across tests
- **Test infrastructure** organization following best practices

### MSW Integration
- **Mock handler generation** for API endpoints (GET, POST, PUT, DELETE, PATCH)
- **Fixture management** for API response data
- **MSW debugging** to diagnose interception issues
- **Stateful mocks** for complex testing scenarios

### Coverage Analysis
- **Comprehensive reports** in multiple formats (text, HTML, JSON, LCOV)
- **Gap analysis** to identify untested code
- **Threshold management** for per-file and global coverage requirements
- **Prioritized suggestions** for improving coverage

### Test Debugging
- **Automatic fix suggestions** for common test failures
- **Snapshot management** with guided updates
- **Playwright trace analysis** with timeline, screenshots, and network activity
- **Headed mode execution** for visual debugging

### CI/CD Integration
- **GitHub Actions workflow** generation
- **GitLab CI configuration** generation
- **Parallel execution** optimization
- **Test artifact management** (traces, screenshots, videos)

## 📦 Installation

### Via GitHub Marketplace (Recommended)

```bash
# Add the marketplace
/plugin marketplace add claude-code-marketplace/claude-code-marketplace

# Install the plugin
/plugin install test-master@claude-code-marketplace
```

### Local Installation (Mac/Linux)

⚠️ **Windows users:** Use GitHub marketplace installation method instead.

```bash
# Extract to plugins directory
unzip test-master.zip -d ~/.local/share/claude/plugins/
```

## 🎯 Technology Stack

- **Vitest 3.x** - Unit and integration testing with multi-project support
- **Playwright 1.56+** - E2E browser testing across Chrome, Firefox, Safari, mobile
- **MSW (Mock Service Worker) 2.x** - API mocking for both Vitest and Playwright
- **happy-dom** - Fast DOM simulation for Vitest
- **@vitest/coverage-v8** - Code coverage analysis

## 📖 Commands

### Core Test Management

| Command | Description |
|---------|-------------|
| `/test-master:run` | Run all tests with intelligent selection |
| `/test-master:unit` | Run Vitest unit tests only |
| `/test-master:integration` | Run Vitest integration tests |
| `/test-master:e2e` | Run Playwright E2E tests |
| `/test-master:watch` | Start Vitest watch mode |
| `/test-master:coverage` | Generate coverage reports |
| `/test-master:debug` | Debug failing tests interactively |

### Test File Management

| Command | Description |
|---------|-------------|
| `/test-master:create-unit <module>` | Scaffold unit test with boilerplate |
| `/test-master:create-integration <feature>` | Scaffold integration test |
| `/test-master:create-e2e <workflow>` | Scaffold Playwright E2E test |
| `/test-master:create-helper <type>` | Create test helper utility |
| `/test-master:create-fixture` | Create mock data fixture |

### Configuration Management

| Command | Description |
|---------|-------------|
| `/test-master:init` | Initialize complete test infrastructure |
| `/test-master:configure` | Interactive configuration wizard |
| `/test-master:validate-config` | Validate all test configurations |

### MSW Integration

| Command | Description |
|---------|-------------|
| `/test-master:create-mock <api-name>` | Generate MSW handler for endpoint |
| `/test-master:update-fixtures` | Update mock response data |
| `/test-master:debug-msw` | Debug MSW request handling |

### Coverage Analysis

| Command | Description |
|---------|-------------|
| `/test-master:coverage-report` | Generate and display coverage |
| `/test-master:coverage-gaps` | Find untested code |
| `/test-master:set-thresholds` | Update coverage thresholds |

### Test Debugging

| Command | Description |
|---------|-------------|
| `/test-master:fix-failing` | Analyze and fix failing tests |
| `/test-master:update-snapshots` | Update Vitest snapshots |
| `/test-master:trace` | Analyze Playwright traces |
| `/test-master:headed` | Run E2E tests in visible browser |

### CI/CD Integration

| Command | Description |
|---------|-------------|
| `/test-master:ci-config` | Generate CI/CD test workflows |
| `/test-master:parallel` | Configure parallel execution |
| `/test-master:artifacts` | Manage test artifacts |

## 🤖 Specialized Agent

The plugin includes the **test-expert** agent that provides:

- Comprehensive test strategy and architecture
- Advanced debugging techniques
- Testing best practices and patterns
- Mock data architecture guidance
- E2E test patterns and selectors
- Coverage optimization strategies
- Production-ready test infrastructure design

The agent **proactively activates** when you:
- Mention testing, Vitest, Playwright, or MSW
- Ask about test creation or debugging
- Need test infrastructure guidance
- Have failing tests or coverage issues

## 📁 Expected Test Structure

The plugin works best with this recommended structure:

```
tests/
├── unit/                      # Pure function/module tests
│   └── *.test.js
├── integration/               # Multi-module interaction tests
│   └── *.test.js
├── e2e/                       # Playwright browser tests
│   └── *.spec.js
├── helpers/                   # Shared test utilities
│   ├── assertions.js          # Custom assertions
│   ├── dom.js                 # DOM setup/teardown
│   ├── fixtures.js            # Test data factories
│   ├── mocks.js               # Mock creators
│   └── state.js               # State management
├── fixtures/                  # Mock data files
│   ├── mock-data.json
│   └── api-responses.json
├── mocks/                     # MSW setup
│   ├── handlers.js            # Request handlers
│   └── server.js              # MSW server
├── setup.js                   # Global setup (MSW + DOM)
├── setup-msw-only.js          # MSW-only setup
├── vitest-global-setup.js     # Global hooks
└── README.md                  # Testing documentation
```

## 🚀 Quick Start

### 1. Initialize Test Infrastructure

```bash
/test-master:init
```

This sets up:
- Directory structure
- Configuration files (vitest.config.js, playwright.config.js)
- MSW mock server
- Sample tests
- NPM scripts

### 2. Create Your First Test

```bash
# Unit test
/test-master:create-unit myFunction

# Integration test
/test-master:create-integration userWorkflow

# E2E test
/test-master:create-e2e loginFlow
```

### 3. Run Tests

```bash
# All tests
/test-master:run

# Specific type
/test-master:unit
/test-master:e2e

# With coverage
/test-master:coverage
```

### 4. Debug Failures

```bash
# Interactive debugging
/test-master:debug

# Visual debugging (E2E)
/test-master:headed

# Trace analysis
/test-master:trace
```

## 💡 Usage Examples

### Create and Mock an API Endpoint

```bash
# 1. Create MSW handler
/test-master:create-mock /api/users

# 2. Create integration test
/test-master:create-integration userApi

# 3. Run tests
/test-master:integration
```

### Set Up CI/CD

```bash
# Generate GitHub Actions workflow
/test-master:ci-config

# Configure parallel execution
/test-master:parallel

# Validate everything works
/test-master:run
```

### Improve Coverage

```bash
# Generate coverage report
/test-master:coverage

# Find gaps
/test-master:coverage-gaps

# Set new thresholds
/test-master:set-thresholds
```

## 🎯 Best Practices Supported

### Vitest Multi-Project Setup

```javascript
projects: [
  {
    test: {
      name: 'unit-and-integration',
      include: ['tests/unit/**/*.test.js', 'tests/integration/**/*.test.js'],
      environment: 'happy-dom',
      setupFiles: ['./tests/setup.js']
    }
  }
]
```

### Coverage with Per-File Thresholds

```javascript
coverage: {
  thresholds: {
    lines: 80,
    'src/critical/**/*.js': { lines: 95, functions: 100 }
  }
}
```

### Playwright Multi-Device Matrix

```javascript
projects: [
  { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
  { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
  { name: 'webkit', use: { ...devices['Desktop Safari'] } },
  { name: 'Mobile Chrome', use: { ...devices['Pixel 5'] } }
]
```

### MSW Handler Patterns

```javascript
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.get('/api/users', () => {
    return HttpResponse.json({ users: [...] });
  })
];
```

## 🔧 Configuration

The plugin automatically handles configuration for:

- **vitest.config.js** - Test runner, coverage, environments
- **playwright.config.js** - Browsers, devices, artifacts
- **tests/setup.js** - Global test setup with MSW
- **tests/mocks/server.js** - MSW server instance
- **tests/mocks/handlers.js** - HTTP request handlers

Use `/test-master:configure` for interactive configuration wizard.

## 📊 Coverage Integration

Works seamlessly with:

- **Codecov** - Automatic upload via CI
- **Coveralls** - LCOV report generation
- **SonarQube** - Quality gate integration
- **GitHub Actions** - Coverage status checks

## 🐛 Debugging Support

### Vitest Debugging
- Verbose output with stack traces
- Node.js debugger integration
- VS Code debugging support
- Watch mode for rapid iteration

### Playwright Debugging
- Headed mode (visible browser)
- Trace viewer with timeline
- Screenshot on failure
- Video recording
- Inspector with step-through

### MSW Debugging
- Request interception logging
- Handler matching diagnostics
- Response validation
- Network activity tracking

## 🌐 Cross-Platform Support

- **Windows** - Full support (use GitHub marketplace installation)
- **macOS** - Full support
- **Linux** - Full support
- **CI environments** - Optimized configurations for GitHub Actions, GitLab CI

## 📚 Documentation

Each command includes comprehensive inline documentation:

```bash
# View command help
/help test-master:create-unit
```

The test-expert agent provides contextual guidance and best practices automatically.

## 🤝 Contributing

This plugin follows Claude Code plugin best practices:

- Convention over configuration
- Comprehensive error handling
- Cross-platform compatibility
- Production-ready defaults
- Extensive documentation

## 📝 License

MIT

## 🔗 Links

- **Plugin Repository:** [claude-code-marketplace](https://github.com/claude-code-marketplace/claude-code-marketplace)
- **Vitest Docs:** https://vitest.dev/
- **Playwright Docs:** https://playwright.dev/
- **MSW Docs:** https://mswjs.io/

## 💬 Support

For issues, questions, or contributions:
- Use the test-expert agent for testing guidance
- Check command documentation with `/help`
- Report issues via GitHub

---

**Made with ❤️ for modern JavaScript testing**

Ensure production-ready testing infrastructure with Vitest + Playwright + MSW.
