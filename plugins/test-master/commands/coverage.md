---
description: Generate comprehensive test coverage reports
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

# Generate Coverage

## Purpose
Analyze test coverage across the codebase and generate detailed reports.

## Process

1. **Run Tests with Coverage**
   ```bash
   # Generate coverage for all tests
   vitest run --coverage

   # Or use npm script
   npm run test:coverage

   # Coverage for specific directory
   vitest run tests/unit --coverage
   ```

2. **Generate Multiple Report Formats**
   ```bash
   # Text summary in terminal
   vitest run --coverage --reporter=text

   # HTML report (opens in browser)
   vitest run --coverage --reporter=html

   # JSON for programmatic analysis
   vitest run --coverage --reporter=json

   # LCOV for CI/CD integrations
   vitest run --coverage --reporter=lcov
   ```

3. **Analyze Coverage Reports**
   - Open coverage/index.html in browser
   - Review line, branch, function, and statement coverage
   - Identify uncovered code paths
   - Check per-file coverage percentages

4. **Identify Coverage Gaps**
   - Sort files by coverage percentage
   - Find critical files with low coverage
   - Prioritize testing based on code importance
   - Suggest new tests for uncovered code

5. **Report Summary**
   ```
   Coverage Summary:
   ----------------
   Statements   : 85.2% ( 1234/1448 )
   Branches     : 78.6% ( 567/721 )
   Functions    : 82.3% ( 234/284 )
   Lines        : 85.8% ( 1201/1400 )

   Files needing attention:
   - src/utils/parser.js: 45% coverage
   - src/api/auth.js: 62% coverage
   ```

## Configuration

Set up coverage in vitest.config.js:

```javascript
export default {
  test: {
    coverage: {
      provider: 'v8', // or 'istanbul'
      reporter: ['text', 'html', 'json', 'lcov'],
      reportsDirectory: './coverage',

      // Files to include
      include: ['src/**/*.js'],

      // Files to exclude
      exclude: [
        'node_modules/**',
        'dist/**',
        '**/*.config.js',
        '**/*.test.js',
        'tests/**'
      ],

      // Global thresholds
      thresholds: {
        lines: 80,
        functions: 80,
        branches: 75,
        statements: 80
      },

      // Per-file thresholds for critical files
      perFile: true,
      'src/auth/validate.js': {
        lines: 95,
        functions: 100,
        branches: 90
      }
    }
  }
}
```

## Coverage Thresholds

**Enforce minimum coverage:**

```javascript
// Fail tests if coverage is below threshold
coverage: {
  thresholds: {
    lines: 80,
    functions: 80,
    branches: 75,
    statements: 80
  }
}
```

**Per-file thresholds for critical code:**

```javascript
coverage: {
  perFile: true,
  thresholds: {
    // Global defaults
    lines: 70,

    // Critical files need higher coverage
    'src/security/**/*.js': {
      lines: 95,
      functions: 100
    },
    'src/payment/**/*.js': {
      lines: 90,
      functions: 95
    }
  }
}
```

## Interpreting Coverage

**Coverage Types:**

1. **Line Coverage:** % of lines executed
2. **Statement Coverage:** % of statements executed
3. **Branch Coverage:** % of code branches taken (if/else, switch)
4. **Function Coverage:** % of functions called

**Good Coverage Guidelines:**

- **Critical code (auth, payment, security):** 95%+
- **Core business logic:** 85%+
- **Utilities and helpers:** 80%+
- **UI components:** 70%+
- **Configuration files:** Can be lower

**Coverage Anti-Patterns:**

❌ **Don't chase 100% coverage blindly**
- Focus on meaningful tests
- Some code is hard to test (error handlers, edge cases)
- Quality > Quantity

❌ **Don't game the metrics**
- Tests should verify behavior, not just execute code
- Avoid tests that don't assert anything

✅ **Do prioritize:**
- Complex logic
- Critical business functions
- Bug-prone areas
- Public APIs

## CI/CD Integration

**Fail CI if coverage drops:**

```bash
# In CI pipeline
vitest run --coverage --reporter=json

# Check if coverage meets threshold (exit 1 if fails)
```

**Upload to coverage services:**

```bash
# Codecov
bash <(curl -s https://codecov.io/bash)

# Coveralls
cat coverage/lcov.info | coveralls
```

## Troubleshooting

- **Low coverage:** Use `/test-master:coverage-gaps` to find untested code
- **Flaky coverage:** Ensure tests are deterministic
- **Incorrect coverage:** Check `include`/`exclude` patterns in config
- **Slow coverage:** Use v8 provider instead of istanbul
