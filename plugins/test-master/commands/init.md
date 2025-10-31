---
description: Initialize complete test infrastructure in a new repository
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

# Initialize Test Infrastructure

## Purpose
Set up a complete, production-ready testing infrastructure with Vitest, Playwright, and MSW in an existing or new project.

## Process

1. **Analyze Existing Project**
   - Check package.json for existing dependencies
   - Identify project type (React, Vue, vanilla JS, etc.)
   - Detect build tool (Vite, Webpack, etc.)
   - Check for existing test setup

2. **Install Dependencies**

   ```bash
   # Install Vitest 4.0 and related packages (released October 22, 2025)
   npm install -D vitest@^4.0.0 @vitest/ui@^4.0.0 @vitest/coverage-v8@^4.0.0 happy-dom

   # Optional: Install Vitest browser mode provider (for browser testing)
   npm install -D @vitest/browser-playwright@^4.0.0

   # Install Playwright 1.56+ (released October 2025)
   npm install -D @playwright/test@^1.56.0

   # Install Playwright browsers
   npx playwright install

   # Install MSW 2.x (Mock Service Worker)
   npm install -D msw@^2.0.0

   # Install testing utilities (if React/Vue)
   npm install -D @testing-library/react @testing-library/user-event # For React
   # or
   npm install -D @testing-library/vue # For Vue
   ```

3. **Create Directory Structure**

   ```bash
   mkdir -p tests/unit
   mkdir -p tests/integration
   mkdir -p tests/e2e
   mkdir -p tests/helpers
   mkdir -p tests/fixtures
   mkdir -p tests/mocks
   ```

4. **Generate Configuration Files**

   **vitest.config.js (Vitest 4.0 - Released October 2025):**
   ```javascript
   import { defineConfig } from 'vitest/config';

   export default defineConfig({
     test: {
       // Global test settings
       globals: true,
       environment: 'happy-dom',

       // Setup files
       setupFiles: ['./tests/setup.js'],

       // Coverage configuration
       coverage: {
         provider: 'v8',
         reporter: ['text', 'html', 'json', 'lcov'],
         reportsDirectory: './coverage',
         include: ['src/**/*.js'],
         exclude: [
           'node_modules/**',
           'dist/**',
           '**/*.config.js',
           '**/*.test.js',
           'tests/**'
         ],
         thresholds: {
           lines: 70,
           functions: 70,
           branches: 65,
           statements: 70
         }
       },

       // Optional: Browser Mode configuration (Vitest 4.0 - Stable)
       // Requires: npm install -D @vitest/browser-playwright
       // browser: {
       //   enabled: true,
       //   name: 'chromium',
       //   provider: 'playwright', // Vitest 4.0 syntax (uses @vitest/browser-playwright)
       //   headless: true,
       //   trace: 'on-first-retry' // Playwright trace integration
       // },

       // Multi-project setup
       projects: [
         {
           test: {
             name: 'unit-and-integration',
             include: [
               'tests/unit/**/*.test.js',
               'tests/integration/**/*.test.js'
             ],
             environment: 'happy-dom',
             setupFiles: ['./tests/setup.js']
           }
         },
         {
           test: {
             name: 'node-environment',
             include: ['tests/unit/**/*.node.test.js'],
             environment: 'node',
             setupFiles: ['./tests/setup-msw-only.js']
           }
         }
       ]
     }
   });
   ```

   **playwright.config.js:**
   ```javascript
   import { defineConfig, devices } from '@playwright/test';

   export default defineConfig({
     testDir: './tests/e2e',

     // Run tests in files in parallel
     fullyParallel: true,

     // Fail the build on CI if you accidentally left test.only
     forbidOnly: !!process.env.CI,

     // Retry on CI only
     retries: process.env.CI ? 2 : 0,

     // Opt out of parallel tests on CI
     workers: process.env.CI ? 1 : undefined,

     // Reporter to use
     reporter: process.env.CI ? 'dot' : 'list',

     // Shared settings for all projects
     use: {
       // Base URL for page.goto()
       baseURL: process.env.BASE_URL || 'http://localhost:3000',

       // Collect trace when retrying the failed test
       trace: 'retain-on-failure',

       // Screenshot on failure
       screenshot: 'only-on-failure',

       // Video on failure
       video: 'retain-on-failure'
     },

     // Configure projects for major browsers and devices
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
         name: 'webkit',
         use: { ...devices['Desktop Safari'] }
       },
       {
         name: 'Mobile Chrome',
         use: { ...devices['Pixel 5'] }
       },
       {
         name: 'Mobile Safari',
         use: { ...devices['iPhone 12'] }
       }
     ],

     // Run your local dev server before starting the tests
     webServer: {
       command: 'npm run dev',
       url: 'http://localhost:3000',
       reuseExistingServer: !process.env.CI,
       timeout: 120000
     }
   });
   ```

5. **Create Setup Files**

   **tests/setup.js** (MSW + DOM setup):
   ```javascript
   import { beforeAll, afterEach, afterAll } from 'vitest';
   import { server } from './mocks/server.js';

   // Start MSW server before all tests
   beforeAll(() => server.listen({ onUnhandledRequest: 'error' }));

   // Reset handlers after each test
   afterEach(() => server.resetHandlers());

   // Clean up after all tests
   afterAll(() => server.close());

   // Mock localStorage
   const localStorageMock = {
     getItem: vi.fn(),
     setItem: vi.fn(),
     removeItem: vi.fn(),
     clear: vi.fn(),
   };
   global.localStorage = localStorageMock;

   // Mock window.matchMedia
   Object.defineProperty(window, 'matchMedia', {
     writable: true,
     value: vi.fn().mockImplementation((query) => ({
       matches: false,
       media: query,
       onchange: null,
       addListener: vi.fn(),
       removeListener: vi.fn(),
       addEventListener: vi.fn(),
       removeEventListener: vi.fn(),
       dispatchEvent: vi.fn(),
     })),
   });
   ```

   **tests/setup-msw-only.js** (Node environment):
   ```javascript
   import { beforeAll, afterEach, afterAll } from 'vitest';
   import { server } from './mocks/server.js';

   beforeAll(() => server.listen({ onUnhandledRequest: 'error' }));
   afterEach(() => server.resetHandlers());
   afterAll(() => server.close());
   ```

6. **Create MSW Configuration (2025 Best Practices - Happy Path First)**

   **tests/mocks/handlers.js:**
   ```javascript
   import { http, HttpResponse } from 'msw';

   // 2025 Pattern: Define SUCCESS scenarios as baseline (happy paths first)
   // Domain-based organization for scalability
   // Override per test for error scenarios

   // User domain handlers (happy paths)
   export const userHandlers = [
     http.get('/api/users', () => {
       return HttpResponse.json({
         users: [
           { id: 1, name: 'John Doe', email: '[email protected]' },
           { id: 2, name: 'Jane Smith', email: '[email protected]' }
         ]
       });
     }),

     http.get('/api/users/:id', ({ params }) => {
       return HttpResponse.json({
         id: params.id,
         name: 'John Doe',
         email: '[email protected]'
       });
     }),
   ];

   // Product domain handlers (happy paths)
   export const productHandlers = [
     http.get('/api/products', () => {
       return HttpResponse.json({
         products: [
           { id: 1, name: 'Product A', price: 29.99 },
           { id: 2, name: 'Product B', price: 49.99 }
         ]
       });
     }),
   ];

   // Combine all domain handlers
   export const handlers = [
     ...userHandlers,
     ...productHandlers
     // Add more domain handlers as your API grows
   ];

   // ERROR scenarios: Override in individual tests using server.use()
   // Example in test:
   // server.use(
   //   http.get('/api/users', () => HttpResponse.json({ error: 'Failed' }, { status: 500 }))
   // );
   ```

   **tests/mocks/server.js:**
   ```javascript
   import { setupServer } from 'msw/node';
   import { handlers } from './handlers.js';

   export const server = setupServer(...handlers);
   ```

7. **Add NPM Scripts**

   Update package.json:
   ```json
   {
     "scripts": {
       "test": "vitest run",
       "test:unit": "vitest run tests/unit",
       "test:integration": "vitest run tests/integration",
       "test:watch": "vitest watch",
       "test:ui": "vitest --ui",
       "test:coverage": "vitest run --coverage",
       "test:e2e": "playwright test",
       "test:e2e:headed": "playwright test --headed",
       "test:e2e:debug": "playwright test --debug",
       "test:e2e:ui": "playwright test --ui",
       "test:mutation": "stryker run"
     }
   }
   ```

8. **Create Sample Tests**

   **tests/unit/example.test.js:**
   ```javascript
   import { describe, it, expect } from 'vitest';

   describe('Example Unit Test', () => {
     it('should pass', () => {
       expect(true).toBe(true);
     });

     it('should add numbers correctly', () => {
       expect(1 + 1).toBe(2);
     });
   });
   ```

   **tests/integration/api.test.js:**
   ```javascript
   import { describe, it, expect } from 'vitest';
   import { http, HttpResponse } from 'msw';
   import { server } from '../mocks/server.js';

   describe('API Integration (MSW 2.x)', () => {
     it('should fetch users from happy path handler', async () => {
       // Uses baseline handler from handlers.js
       const response = await fetch('/api/users');
       const data = await response.json();

       expect(data.users).toHaveLength(2);
       expect(data.users[0]).toHaveProperty('name');
     });

     it('should handle API error with runtime override', async () => {
       // Override happy path for this specific test
       server.use(
         http.get('/api/users', () => {
           return HttpResponse.json(
             { error: 'Server error' },
             { status: 500 }
           );
         })
       );

       const response = await fetch('/api/users');
       expect(response.status).toBe(500);
     });
   });
   ```

   **tests/e2e/example.spec.js:**
   ```javascript
   import { test, expect } from '@playwright/test';

   test('basic test', async ({ page }) => {
     await page.goto('http://localhost:3000');
     await expect(page).toHaveTitle(/Home/);
   });
   ```

9. **Create Testing Documentation**

   **tests/README.md:**
   ```markdown
   # Testing Guide

   ## Overview

   This project uses:
   - **Vitest** - Unit and integration testing
   - **Playwright** - E2E browser testing
   - **MSW** - API mocking

   ## Running Tests

   ### All Tests
   \`\`\`bash
   npm test
   \`\`\`

   ### Unit Tests Only
   \`\`\`bash
   npm run test:unit
   \`\`\`

   ### Integration Tests
   \`\`\`bash
   npm run test:integration
   \`\`\`

   ### E2E Tests
   \`\`\`bash
   npm run test:e2e
   \`\`\`

   ### Watch Mode (for development)
   \`\`\`bash
   npm run test:watch
   \`\`\`

   ### Coverage Report
   \`\`\`bash
   npm run test:coverage
   \`\`\`

   ## Test Structure

   - \`tests/unit/\` - Unit tests for individual functions/modules
   - \`tests/integration/\` - Integration tests for multi-module workflows
   - \`tests/e2e/\` - End-to-end browser tests
   - \`tests/helpers/\` - Shared test utilities
   - \`tests/fixtures/\` - Mock data
   - \`tests/mocks/\` - MSW handlers

   ## Writing Tests

   See examples in each test directory.

   ## CI/CD

   Tests run automatically on:
   - Every pull request
   - Every push to main branch

   ## Coverage Requirements

   - Lines: 70%
   - Functions: 70%
   - Branches: 65%
   ```

10. **Git Ignore Updates**

    Add to .gitignore:
    ```
    # Test coverage
    coverage/
    .nyc_output/

    # Playwright
    playwright-report/
    test-results/
    playwright/.cache/

    # Vitest
    .vitest/
    ```

## Verification Steps

After initialization:

1. **Run unit tests:** `npm run test:unit`
2. **Run integration tests:** `npm run test:integration`
3. **Generate coverage:** `npm run test:coverage`
4. **Run E2E tests:** `npm run test:e2e`
5. **Open test UI:** `npm run test:ui`

## Output Summary

Provide clear summary:

```
✅ Test infrastructure initialized successfully!

📦 Installed packages:
- vitest, @vitest/ui, @vitest/coverage-v8
- @playwright/test
- msw
- happy-dom

📁 Created directories:
- tests/unit
- tests/integration
- tests/e2e
- tests/helpers
- tests/fixtures
- tests/mocks

⚙️ Generated configs:
- vitest.config.js
- playwright.config.js
- tests/setup.js
- tests/mocks/server.js

✨ Added npm scripts:
- npm test - Run all tests
- npm run test:unit - Unit tests only
- npm run test:integration - Integration tests
- npm run test:e2e - E2E tests
- npm run test:coverage - Coverage report

🚀 Next steps:
1. Run: npm test
2. Write your first test in tests/unit/
3. Add API handlers in tests/mocks/handlers.js
4. See tests/README.md for more info
```

## Windows and Git Bash Considerations

### Path Configuration for Cross-Platform Support

When initializing test infrastructure on Windows, especially with Git Bash:

**✅ Best Practices:**
```javascript
// vitest.config.js - Use relative paths
export default defineConfig({
  test: {
    // ✅ Good - Relative paths work everywhere
    include: ['tests/unit/**/*.test.js'],
    setupFiles: ['./tests/setup.js'],

    // ❌ Bad - Absolute paths cause issues in Git Bash
    // include: ['/c/project/tests/unit/**/*.test.js']
  }
});
```

**✅ NPM Scripts for Reliable Execution:**
```json
{
  "scripts": {
    "test": "vitest run",              // Works in all shells
    "test:watch": "vitest watch",
    "test:e2e": "playwright test"      // Handles paths automatically
  }
}
```

### Running Tests in Git Bash

**Recommended execution methods:**
```bash
# ✅ Best - Use npm scripts (handles path conversion)
npm test
npm run test:e2e

# ✅ Good - Disable path conversion if needed
MSYS_NO_PATHCONV=1 vitest run

# ⚠️ May have issues in Git Bash
vitest run  # Can encounter path conversion issues
```

### Common Git Bash Issues During Setup

**Issue 1: Module installation paths**
```bash
# If npm install has path issues in Git Bash
MSYS_NO_PATHCONV=1 npm install -D vitest @playwright/test msw

# Or use npm normally (usually handles this)
npm install -D vitest @playwright/test msw
```

**Issue 2: Playwright browser installation**
```bash
# Use npx for correct path handling
npx playwright install

# If issues persist, run from Windows Command Prompt once:
# cmd.exe /c "npx playwright install"
# Then return to Git Bash for test execution
```

**Issue 3: Directory creation in Git Bash**
```bash
# Use mkdir -p (works in Git Bash)
mkdir -p tests/{unit,integration,e2e,helpers,fixtures,mocks}

# Or create directories individually
mkdir -p tests/unit
mkdir -p tests/integration
mkdir -p tests/e2e
```

### Shell Detection in Setup

Add shell detection to setup files if needed:

```javascript
// tests/setup.js - Detect Git Bash environment
function isGitBash() {
  return !!(process.env.MSYSTEM); // MINGW64, MINGW32, MSYS
}

if (isGitBash()) {
  console.log('Running in Git Bash/MINGW environment');
  // Apply any Git Bash-specific configuration
}

// Continue with standard setup...
```

For comprehensive Windows/Git Bash testing guidance, see the `windows-git-bash-testing.md` skill.

## Troubleshooting

- **If Playwright browsers fail:** Run `npx playwright install`
- **If MSW errors:** Ensure using MSW 2.x compatible syntax
- **If tests timeout:** Increase timeout in configs
- **If coverage fails:** Check include/exclude patterns in vitest.config.js
- **If "No such file" errors in Git Bash:** Use npm scripts or set MSYS_NO_PATHCONV=1
- **If module imports fail:** Use relative paths, avoid absolute paths starting with /c/ or C:\
- **If Playwright fails in Git Bash:** Clear DISPLAY variable: `unset DISPLAY && npx playwright test`
