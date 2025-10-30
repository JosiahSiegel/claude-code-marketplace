---
description: Generate CI/CD test workflows (GitHub Actions, GitLab CI)
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

# Generate CI/CD Configuration

## Purpose
Generate CI/CD pipeline configurations for running tests automatically on GitHub Actions or GitLab CI.

## Process

1. **Detect CI Platform**
   - GitHub (create .github/workflows/)
   - GitLab (create .gitlab-ci.yml)
   - Other (provide examples)

2. **Generate GitHub Actions Workflow**

   **.github/workflows/test.yml:**
   ```yaml
   name: Tests

   on:
     push:
       branches: [main, develop]
     pull_request:
       branches: [main]

   jobs:
     test:
       runs-on: ubuntu-latest

       steps:
         - uses: actions/checkout@v3

         - name: Setup Node.js
           uses: actions/setup-node@v3
           with:
             node-version: '18'
             cache: 'npm'

         - name: Install dependencies
           run: npm ci

         - name: Run unit tests
           run: npm run test:unit

         - name: Run integration tests
           run: npm run test:integration

         - name: Generate coverage
           run: npm run test:coverage

         - name: Upload coverage
           uses: codecov/codecov-action@v3
           with:
             files: ./coverage/lcov.info

     e2e:
       runs-on: ubuntu-latest

       steps:
         - uses: actions/checkout@v3

         - name: Setup Node.js
           uses: actions/setup-node@v3
           with:
             node-version: '18'
             cache: 'npm'

         - name: Install dependencies
           run: npm ci

         - name: Install Playwright
           run: npx playwright install --with-deps

         - name: Run E2E tests
           run: npm run test:e2e

         - name: Upload test results
           if: failure()
           uses: actions/upload-artifact@v3
           with:
             name: playwright-report
             path: playwright-report/
   ```

3. **Generate GitLab CI Configuration**

   **.gitlab-ci.yml:**
   ```yaml
   stages:
     - test
     - e2e

   test:
     stage: test
     image: node:18
     script:
       - npm ci
       - npm run test:unit
       - npm run test:integration
       - npm run test:coverage
     coverage: '/Lines\s*:\s*(\d+\.\d+)%/'
     artifacts:
       reports:
         coverage_report:
           coverage_format: cobertura
           path: coverage/cobertura-coverage.xml

   e2e:
     stage: e2e
     image: mcr.microsoft.com/playwright:v1.40.0-focal
     script:
       - npm ci
       - npx playwright install
       - npm run test:e2e
     artifacts:
       when: on_failure
       paths:
         - playwright-report/
   ```

4. **Add Coverage Badges**

   Update README.md:
   ```markdown
   ![Tests](https://github.com/username/repo/workflows/Tests/badge.svg)
   [![codecov](https://codecov.io/gh/username/repo/branch/main/graph/badge.svg)](https://codecov.io/gh/username/repo)
   ```

5. **Configure Coverage Services**

   **Codecov:**
   ```yaml
   # codecov.yml
   coverage:
     status:
       project:
         default:
           target: 80%
           threshold: 2%
   ```

## Advanced CI Features

**Matrix Testing:**
```yaml
strategy:
  matrix:
    node-version: [16, 18, 20]
    os: [ubuntu-latest, windows-latest, macos-latest]
```

**Parallel Execution:**
```yaml
- name: Run E2E tests (shard 1/4)
  run: npx playwright test --shard=1/4
```

**Conditional Runs:**
```yaml
if: github.event_name == 'pull_request'
```

## After Generation

- CI configuration file created
- Tests run automatically on push/PR
- Coverage reports uploaded
- Test results visible in CI
