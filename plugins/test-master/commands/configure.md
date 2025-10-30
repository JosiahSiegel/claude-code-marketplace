---
description: Interactive configuration wizard for test setup
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

# Configure Tests

## Purpose
Interactively configure test settings, thresholds, and preferences through a guided wizard.

## Process

1. **Present Configuration Options**
   - Coverage thresholds
   - Test timeout settings
   - Browser selection for E2E
   - Reporter preferences
   - Parallel execution settings

2. **Gather User Preferences**

   Ask questions about:

   **Coverage Thresholds:**
   - What minimum line coverage? (default: 70%)
   - What minimum function coverage? (default: 70%)
   - What minimum branch coverage? (default: 65%)
   - Any per-file thresholds for critical files?

   **Test Execution:**
   - Default test timeout? (default: 5000ms)
   - Number of retry attempts? (default: 0)
   - Run tests in parallel? (default: yes)
   - Number of workers? (default: CPU count)

   **E2E Configuration:**
   - Which browsers to test? (Chrome, Firefox, Safari, all)
   - Include mobile devices? (yes/no)
   - Base URL for E2E tests? (default: http://localhost:3000)
   - Video recording? (on-failure, always, never)

   **Reporter Settings:**
   - Console reporter style? (verbose, dot, minimal)
   - Generate HTML reports? (yes/no)
   - Generate JSON reports? (yes/no)

3. **Update Configuration Files**

   Based on answers, update:
   - vitest.config.js
   - playwright.config.js
   - package.json scripts

4. **Example Interactive Flow**

```
? What minimum line coverage do you require? (70%) › 80
? What minimum function coverage? (70%) › 80
? What minimum branch coverage? (65%) › 75
? Test timeout in milliseconds? (5000) › 10000
? Number of parallel workers? (auto) › 4
? Which browsers for E2E? (all) › chrome, firefox
? Include mobile testing? (yes) › yes
? Base URL for E2E tests? › http://localhost:8080
? Video on test failure? (yes) › yes
? Reporter style? (verbose) › dot
```

5. **Apply Configuration**

Update vitest.config.js:
```javascript
export default defineConfig({
  test: {
    globals: true,
    environment: 'happy-dom',
    testTimeout: 10000,
    coverage: {
      provider: 'v8',
      thresholds: {
        lines: 80,
        functions: 80,
        branches: 75,
        statements: 80
      }
    }
  }
});
```

Update playwright.config.js:
```javascript
export default defineConfig({
  testDir: './tests/e2e',
  workers: 4,
  use: {
    baseURL: 'http://localhost:8080',
    video: 'retain-on-failure'
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] }
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] }
    },
    {
      name: 'Mobile Chrome',
      use: { ...devices['Pixel 5'] }
    },
    {
      name: 'Mobile Safari',
      use: { ...devices['iPhone 12'] }
    }
  ]
});
```

6. **Validate Configuration**

After updating:
- Parse config files to ensure valid JavaScript
- Check for conflicting settings
- Verify paths exist
- Test that configurations load correctly

## Configuration Presets

Offer common presets:

**Strict (High Quality):**
```javascript
{
  coverage: { lines: 90, functions: 90, branches: 85 },
  testTimeout: 5000,
  retries: 0
}
```

**Balanced (Recommended):**
```javascript
{
  coverage: { lines: 75, functions: 75, branches: 70 },
  testTimeout: 5000,
  retries: 1
}
```

**Lenient (Legacy Code):**
```javascript
{
  coverage: { lines: 50, functions: 50, branches: 40 },
  testTimeout: 10000,
  retries: 2
}
```

## Advanced Settings

**Per-File Coverage:**
```javascript
coverage: {
  thresholds: {
    lines: 70,
    'src/critical/**/*.js': {
      lines: 95,
      functions: 100
    }
  }
}
```

**Environment-Specific Config:**
```javascript
// Use CI-optimized settings
if (process.env.CI) {
  config.workers = 1;
  config.retries = 2;
  config.reporter = 'dot';
}
```

## Configuration Validation

After updating configs, verify:

```bash
# Check Vitest config loads
vitest --version

# Check Playwright config loads
npx playwright test --list
```

## Backup Original Config

Before modifying, create backup:

```bash
cp vitest.config.js vitest.config.js.backup
cp playwright.config.js playwright.config.js.backup
```

## Summary Output

```
✅ Configuration updated successfully!

📝 Changes made:
- Coverage thresholds: 80% lines, 80% functions, 75% branches
- Test timeout: 10000ms
- Parallel workers: 4
- E2E browsers: Chrome, Firefox, Mobile Chrome, Mobile Safari
- Video on failure: enabled
- Base URL: http://localhost:8080

🔧 Updated files:
- vitest.config.js
- playwright.config.js

💾 Backups created:
- vitest.config.js.backup
- playwright.config.js.backup

🚀 Test your new configuration:
npm test
```
