---
description: Run mutation testing to measure test quality and effectiveness
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

# Mutation Testing

## Purpose
Measure the quality of your tests by introducing deliberate code mutations (bugs) and verifying that tests catch them. Goes beyond traditional coverage to ensure tests actually verify behavior.

## Overview

**What is Mutation Testing?**
- Introduces small changes (mutations) to your code
- Runs tests against mutated code
- Measures how many mutations tests catch
- Identifies weak or missing test assertions

**Why Mutation Testing?**
Traditional coverage measures which lines were **executed**, but not whether tests actually **verify** behavior. Mutation testing ensures tests would catch real bugs.

**Key Metrics:**
- **Mutation Score**: % of mutations killed by tests (target: 80%+)
- **Survived Mutations**: Code changes tests didn't catch (need better tests)
- **Killed Mutations**: Code changes tests caught (good tests)

## Process

### 1. Install Mutation Testing Tool

```bash
# Stryker - Most popular JavaScript mutation testing framework
npm install -D @stryker-mutator/core
npm install -D @stryker-mutator/vitest-runner

# Initialize configuration
npx stryker init
```

### 2. Configure Stryker for Vitest

**stryker.config.json:**
```json
{
  "$schema": "./node_modules/@stryker-mutator/core/schema/stryker-schema.json",
  "packageManager": "npm",
  "testRunner": "vitest",
  "vitest": {
    "configFile": "vitest.config.js"
  },
  "mutate": [
    "src/**/*.js",
    "!src/**/*.test.js",
    "!src/**/*.spec.js"
  ],
  "coverageAnalysis": "perTest",
  "thresholds": {
    "high": 80,
    "low": 60,
    "break": 60
  },
  "reporters": ["html", "clear-text", "progress", "dashboard"]
}
```

### 3. Run Mutation Tests

```bash
# Run mutation testing
npx stryker run

# Run on specific files
npx stryker run --mutate "src/auth/**/*.js"

# Run with different configuration
npx stryker run --configFile stryker-ci.config.json

# Dry run to see what would be mutated
npx stryker run --dryRun
```

### 4. Review Mutation Report

After running, open the HTML report:
```bash
open reports/mutation/html/index.html
```

**Report shows:**
- Overall mutation score
- File-by-file breakdown
- Specific mutations (survived vs killed)
- Code snippets with mutations highlighted

## Understanding Mutations

### Common Mutation Types

**1. Arithmetic Operators**
```javascript
// Original
function add(a, b) {
  return a + b;
}

// Mutated
function add(a, b) {
  return a - b; // Changed + to -
}
```

**Test should catch this:**
```javascript
test('adds numbers', () => {
  expect(add(2, 3)).toBe(5); // Would fail with mutation
});
```

**2. Comparison Operators**
```javascript
// Original
function isAdult(age) {
  return age >= 18;
}

// Mutated
function isAdult(age) {
  return age > 18; // Changed >= to >
}
```

**Test should catch this:**
```javascript
test('18 is adult', () => {
  expect(isAdult(18)).toBe(true); // Would fail with mutation
});
```

**3. Boolean Literals**
```javascript
// Original
function isEnabled() {
  return true;
}

// Mutated
function isEnabled() {
  return false; // Inverted boolean
}
```

**4. Conditional Boundaries**
```javascript
// Original
function inRange(value, min, max) {
  return value >= min && value <= max;
}

// Mutations
// - Remove first condition: value <= max
// - Remove second condition: value >= min
// - Change && to ||
```

**5. String Literals**
```javascript
// Original
function greet(name) {
  return `Hello, ${name}!`;
}

// Mutated
function greet(name) {
  return `"; // Empty string
}
```

**6. Array Literals**
```javascript
// Original
function getDefaults() {
  return [1, 2, 3];
}

// Mutated
function getDefaults() {
  return []; // Empty array
}
```

## Analyzing Results

### Killed Mutations (Good)

```
✓ Mutant killed by test
  File: src/validation.js:10
  Mutation: Changed >= to >
  Test: validation.test.js:15 "validates minimum age"
```

**Interpretation:** Test successfully caught this mutation. Good test coverage.

### Survived Mutations (Need Attention)

```
✗ Mutant survived
  File: src/calculation.js:20
  Mutation: Changed + to -
  No test caught this mutation
```

**Action:** Add or improve test to cover this scenario:
```javascript
test('should calculate total correctly', () => {
  const result = calculateTotal(10, 5);
  expect(result).toBe(15); // Now catches the mutation
});
```

### Equivalent Mutations (Expected)

Some mutations are equivalent to original code and can't be killed:

```javascript
// Original
if (x === 0) return false;

// Mutated (equivalent)
if (!(x !== 0)) return false;
```

**Action:** Mark as ignored or accept lower score.

## Improving Mutation Score

### Example: Weak Test

**Original Code:**
```javascript
function validateEmail(email) {
  if (!email) return false;
  if (!email.includes('@')) return false;
  return true;
}
```

**Weak Test:**
```javascript
test('validates email', () => {
  const result = validateEmail('[email protected]');
  expect(result).toBeDefined(); // Too weak!
});
```

**Mutations that survive:**
- Change `false` to `true`
- Remove `!email.includes('@')`
- Change `includes` to `startsWith`

### Example: Strong Test

```javascript
describe('validateEmail', () => {
  test('returns true for valid email', () => {
    expect(validateEmail('[email protected]')).toBe(true);
  });

  test('returns false for null', () => {
    expect(validateEmail(null)).toBe(false);
  });

  test('returns false for email without @', () => {
    expect(validateEmail('invalidemail')).toBe(false);
  });

  test('returns false for empty string', () => {
    expect(validateEmail('')).toBe(false);
  });
});
```

**Result:** All mutations killed. High mutation score.

## Advanced Configuration

### Ignore Specific Mutations

```json
{
  "mutator": {
    "excludedMutations": [
      "StringLiteral", // Don't mutate string literals
      "ObjectLiteral"  // Don't mutate object literals
    ]
  }
}
```

### Target Critical Code Only

```json
{
  "mutate": [
    "src/auth/**/*.js",      // Critical authentication
    "src/payment/**/*.js",   // Critical payment
    "!src/utils/**/*.js"     // Skip utilities
  ]
}
```

### Timeout Configuration

```json
{
  "timeoutMS": 5000,        // Test timeout
  "timeoutFactor": 1.5      // Multiply normal test time
}
```

### Performance Optimization

```json
{
  "coverageAnalysis": "perTest", // Faster: only run tests that cover mutated code
  "maxTestRunnerReuse": 0,       // Reuse test runners
  "concurrency": 4               // Parallel mutations
}
```

## CI/CD Integration

### GitHub Actions

```yaml
name: Mutation Tests

on:
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 2 * * 0' # Weekly on Sunday

jobs:
  mutation-testing:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm ci
      - run: npx stryker run
        env:
          STRYKER_DASHBOARD_API_KEY: ${{ secrets.STRYKER_API_KEY }}

      - name: Check mutation score
        run: |
          SCORE=$(jq '.mutationScore' reports/mutation/mutation-report.json)
          if (( $(echo "$SCORE < 80" | bc -l) )); then
            echo "Mutation score $SCORE% is below threshold"
            exit 1
          fi

      - name: Upload report
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: mutation-report
          path: reports/mutation/
```

### Dashboard Integration

```json
{
  "dashboard": {
    "project": "github.com/org/repo",
    "version": "main",
    "module": "frontend"
  }
}
```

Visit https://dashboard.stryker-mutator.io to see historical mutation scores.

## Best Practices

### 1. Start with Critical Code

```bash
# Focus on high-value code first
npx stryker run --mutate "src/auth/**/*.js"
npx stryker run --mutate "src/payment/**/*.js"
```

### 2. Set Realistic Thresholds

```json
{
  "thresholds": {
    "high": 80,   // Excellent
    "low": 60,    // Needs improvement
    "break": 60   // Fail build below this
  }
}
```

### 3. Run Regularly, Not Always

```yaml
# Weekly mutation testing (not on every commit)
- cron: '0 2 * * 0'
```

**Reason:** Mutation testing is slow. Run on schedule or manually.

### 4. Combine with Traditional Coverage

```bash
# Regular tests with coverage
npm run test:coverage

# Periodic mutation testing
npm run test:mutation
```

### 5. Review Survived Mutations

```javascript
// Add to package.json
{
  "scripts": {
    "test:mutation": "stryker run",
    "test:mutation:review": "open reports/mutation/html/index.html"
  }
}
```

## Common Patterns

### Testing Edge Cases

Mutation testing reveals missing edge cases:

```javascript
// Code
function divide(a, b) {
  return a / b;
}

// Weak test
test('divides', () => {
  expect(divide(10, 2)).toBe(5);
});

// Mutation survives: What if b === 0?

// Strong test
test('divides correctly', () => {
  expect(divide(10, 2)).toBe(5);
});

test('throws on division by zero', () => {
  expect(() => divide(10, 0)).toThrow();
});
```

### Testing Return Values

```javascript
// Code
function processData(data) {
  if (!data) return null;
  return { processed: true };
}

// Weak test
test('processes data', () => {
  const result = processData({ value: 1 });
  expect(result).toBeDefined(); // Too weak
});

// Mutation survives: return { processed: false }

// Strong test
test('processes data', () => {
  const result = processData({ value: 1 });
  expect(result).toEqual({ processed: true }); // Specific assertion
});
```

### Testing All Branches

```javascript
// Code
function getStatus(count) {
  if (count === 0) return 'empty';
  if (count < 10) return 'low';
  return 'high';
}

// Weak test
test('gets status', () => {
  expect(getStatus(5)).toBe('low');
});

// Mutations survive for count === 0 and count >= 10

// Strong tests
test('returns empty for zero', () => {
  expect(getStatus(0)).toBe('empty');
});

test('returns low for small count', () => {
  expect(getStatus(5)).toBe('low');
});

test('returns high for large count', () => {
  expect(getStatus(15)).toBe('high');
});
```

## Troubleshooting

**Mutation testing is too slow:**
- Use `coverageAnalysis: "perTest"`
- Limit mutated files
- Increase concurrency
- Run less frequently

**Low mutation score but high coverage:**
- Tests execute code but don't assert behavior
- Improve assertion specificity
- Add edge case tests

**Too many equivalent mutations:**
- Mark as ignored in Stryker config
- Accept slightly lower score

**Tests timing out:**
- Increase `timeoutMS` and `timeoutFactor`
- Optimize slow tests

## Comparison: Coverage vs Mutation Testing

| Metric | Code Coverage | Mutation Testing |
|--------|--------------|------------------|
| **Measures** | Lines executed | Mutations caught |
| **Speed** | Fast | Slow |
| **Frequency** | Every run | Periodic |
| **Target** | 80%+ | 80%+ |
| **Purpose** | Completeness | Effectiveness |
| **False confidence** | High | Low |

**Recommendation:** Use both. Coverage for completeness, mutation for quality.

## Resources

- [Stryker Mutator](https://stryker-mutator.io/)
- [Mutation Testing Introduction](https://stryker-mutator.io/docs/General/mutation-testing-introduction/)
- [Stryker Dashboard](https://dashboard.stryker-mutator.io/)

## Next Steps

- Use `/test-master:coverage` to check baseline coverage first
- Use `/test-master:coverage-gaps` to identify untested code
- Use `/test-master:fix-failing` to improve weak tests
- Run mutation testing periodically to ensure test quality
