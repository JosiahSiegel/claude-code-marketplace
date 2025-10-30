---
description: Validate all test configuration files
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

# Validate Test Configuration

## Purpose
Check all test configuration files for correctness, completeness, and potential issues.

## Process

1. **Check Config Files Exist**
   - [ ] vitest.config.js exists
   - [ ] playwright.config.js exists (if using Playwright)
   - [ ] tests/setup.js exists (if configured)
   - [ ] tests/mocks/server.js exists (if using MSW)

2. **Validate Vitest Configuration**

   Check for:
   - Valid JavaScript syntax
   - Required fields present
   - Coverage provider specified
   - Test patterns configured
   - Environment specified

   ```javascript
   // Expected structure
   export default {
     test: {
       environment: 'happy-dom', // or 'jsdom', 'node'
       globals: true,
       coverage: {
         provider: 'v8', // or 'istanbul'
         reporter: [...],
         include: [...],
         exclude: [...]
       }
     }
   }
   ```

   **Common Issues:**
   - Missing environment
   - Invalid coverage provider
   - Incorrect file patterns
   - Missing setupFiles path

3. **Validate Playwright Configuration**

   Check for:
   - Valid testDir path
   - At least one project configured
   - Valid baseURL
   - Reporter configured

   ```javascript
   // Expected structure
   export default {
     testDir: './tests/e2e',
     use: {
       baseURL: 'http://localhost:3000'
     },
     projects: [
       { name: 'chromium', use: {...} }
     ]
   }
   ```

   **Common Issues:**
   - testDir doesn't exist
   - No projects defined
   - Invalid baseURL
   - Missing browser configurations

4. **Validate Directory Structure**

   Ensure directories match config:
   ```
   tests/
   ├── unit/           ✓ Exists
   ├── integration/    ✓ Exists
   ├── e2e/            ✓ Exists
   ├── helpers/        ✓ Exists
   ├── fixtures/       ✓ Exists
   ├── mocks/          ✓ Exists
   ├── setup.js        ✓ Exists
   └── README.md       ✓ Exists
   ```

5. **Validate Dependencies**

   Check package.json for required packages:

   **Vitest:**
   - [ ] vitest
   - [ ] @vitest/ui (optional)
   - [ ] @vitest/coverage-v8 or @vitest/coverage-istanbul
   - [ ] happy-dom or jsdom

   **Playwright:**
   - [ ] @playwright/test

   **MSW:**
   - [ ] msw

6. **Validate Test Files**

   Check test files follow conventions:
   - Unit tests: `tests/unit/**/*.test.js`
   - Integration tests: `tests/integration/**/*.test.js`
   - E2E tests: `tests/e2e/**/*.spec.js`

7. **Run Syntax Check**

   ```bash
   # Check Vitest config loads
   node -c vitest.config.js

   # Check Playwright config loads
   node -c playwright.config.js

   # Actually try loading configs
   vitest --version
   npx playwright test --list
   ```

8. **Validate Coverage Settings**

   Check coverage configuration:
   - Reasonable thresholds (not 100% everywhere)
   - Include patterns cover source code
   - Exclude patterns cover test files
   - Reporter formats specified

   **Warnings:**
   ```
   ⚠️  Coverage threshold of 100% may be too strict
   ⚠️  Include pattern may miss some source files
   ⚠️  Exclude pattern missing 'tests/**'
   ```

9. **Check for Anti-Patterns**

   **Bad:**
   ```javascript
   // Hard-coded paths (non-portable)
   include: ['C:\Users\me\project\src\**\*.js']

   // Overly aggressive exclusions
   exclude: ['**/*.js'] // Excludes everything!

   // Missing important exclusions
   exclude: [] // Will try to cover node_modules!
   ```

   **Good:**
   ```javascript
   // Relative paths
   include: ['src/**/*.js']

   // Specific exclusions
   exclude: [
     'node_modules/**',
     'dist/**',
     '**/*.test.js',
     'tests/**'
   ]
   ```

10. **Validate MSW Setup**

    If MSW is configured:
    - [ ] tests/mocks/handlers.js exists
    - [ ] tests/mocks/server.js exists and exports server
    - [ ] Setup file imports and starts server
    - [ ] Handlers export array

    ```javascript
    // Valid handler structure
    import { http, HttpResponse } from 'msw';

    export const handlers = [
      http.get('/api/test', () => {
        return HttpResponse.json({ data: 'test' });
      })
    ];
    ```

11. **Check NPM Scripts**

    Verify package.json has test scripts:
    - [ ] "test" script exists
    - [ ] "test:coverage" script exists
    - [ ] "test:e2e" script exists (if using Playwright)

## Validation Report

Generate detailed report:

```
Test Configuration Validation Report
=====================================

✅ Config Files
  ✓ vitest.config.js found and valid
  ✓ playwright.config.js found and valid
  ✓ tests/setup.js found
  ✓ tests/mocks/server.js found

✅ Dependencies
  ✓ vitest@3.0.0 installed
  ✓ @playwright/test@1.56.0 installed
  ✓ msw@2.0.0 installed
  ✓ happy-dom@12.0.0 installed

✅ Directory Structure
  ✓ tests/unit exists
  ✓ tests/integration exists
  ✓ tests/e2e exists
  ✓ tests/helpers exists
  ✓ tests/fixtures exists
  ✓ tests/mocks exists

⚠️  Warnings
  ⚠️  Coverage threshold of 95% is very strict
  ⚠️  No test files found in tests/e2e/

❌ Errors
  ❌ playwright.config.js: baseURL points to non-existent server
  ❌ vitest.config.js: setupFiles path incorrect (./test/setup.js should be ./tests/setup.js)

📊 Summary
  Total checks: 25
  Passed: 22
  Warnings: 2
  Errors: 2

🔧 Recommended Actions:
  1. Fix baseURL in playwright.config.js
  2. Correct setupFiles path in vitest.config.js
  3. Consider lowering coverage threshold to 80%
  4. Add at least one E2E test
```

## Auto-Fix Common Issues

Offer to fix common problems:

```
Found 2 fixable issues:

1. setupFiles path incorrect
   Current: ./test/setup.js
   Should be: ./tests/setup.js
   Fix? (yes/no) › yes

2. Missing exclude pattern for tests
   Current: exclude: ['node_modules/**']
   Should add: 'tests/**'
   Fix? (yes/no) › yes

✅ Fixed 2 issues!
```

## Exit Codes

- **0:** All validations passed
- **1:** Warnings found (non-critical)
- **2:** Errors found (critical)

## CI/CD Integration

Use in CI pipeline:

```yaml
# .github/workflows/test.yml
- name: Validate test configuration
  run: npx test-master validate-config
```

## After Validation

If errors found:
- Display clear error messages
- Suggest fixes
- Provide links to documentation
- Offer to run `/test-master:configure` to fix

If warnings found:
- Explain potential issues
- Suggest improvements
- Continue with tests

If all valid:
- Display success message
- Show configuration summary
- Ready to run tests
