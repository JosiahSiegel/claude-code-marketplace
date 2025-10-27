---
description: Debug failing tests interactively with detailed analysis
---

# Debug Tests

## Purpose
Analyze and debug failing tests with detailed error analysis, stack traces, and suggestions for fixes.

## Process

1. **Run Tests and Capture Failures**
   ```bash
   # Run tests and see detailed errors
   vitest run --reporter=verbose

   # Or for Playwright
   npx playwright test --reporter=list
   ```

2. **Analyze Failure Types**

   **For Vitest:**
   - Assertion failures (expect() mismatches)
   - Timeout errors (async tests)
   - Import/module errors
   - Mock/spy failures
   - Snapshot mismatches

   **For Playwright:**
   - Selector not found
   - Navigation timeout
   - Screenshot mismatches
   - Network errors
   - Browser crashes

3. **Interactive Debugging**

   **Vitest Debug Mode:**
   ```bash
   # Run with Node debugger
   node --inspect-brk ./node_modules/vitest/vitest.js run

   # Then open chrome://inspect in Chrome
   ```

   **Playwright Debug Mode:**
   ```bash
   # Run with inspector (headed mode + pause)
   npx playwright test --debug

   # Run specific test in debug mode
   npx playwright test tests/e2e/login.spec.js --debug
   ```

4. **Examine Stack Traces**
   - Identify exact line where test failed
   - Check call stack for context
   - Review variables at time of failure

5. **Suggest Fixes**
   - Analyze error message patterns
   - Suggest common solutions
   - Provide code examples for fixes

## Common Failure Patterns

### Vitest Failures

**1. Assertion Failure**
```
Error: expected 42 to be 43
```
**Fix:** Check test expectation or implementation logic

**2. Async Timeout**
```
Error: Test timeout of 5000ms exceeded
```
**Fix:**
```javascript
// Increase timeout
test('async operation', async () => {
  // ... test code
}, 10000); // 10 second timeout

// Or fix async handling
await someAsyncFunction(); // Don't forget await!
```

**3. Mock Not Called**
```
Error: expected mock to be called
```
**Fix:**
```javascript
// Ensure mock is actually invoked
const mockFn = vi.fn();
myFunction(mockFn); // Must call it!
expect(mockFn).toHaveBeenCalled();
```

**4. Snapshot Mismatch**
```
Error: Snapshot mismatch
```
**Fix:** Review changes, then update snapshots:
```bash
vitest run --update-snapshots
# or in watch mode: press 'u'
```

### Playwright Failures

**1. Selector Not Found**
```
Error: Timeout 30000ms exceeded waiting for selector
```
**Fix:**
```javascript
// Use better selectors
await page.click('[data-testid="submit-button"]'); // Better
await page.click('button:has-text("Submit")'); // Better than CSS

// Or wait for element
await page.waitForSelector('[data-testid="submit-button"]');
await page.click('[data-testid="submit-button"]');
```

**2. Navigation Timeout**
```
Error: Navigation timeout of 30000ms exceeded
```
**Fix:**
```javascript
// Wait for network idle
await page.goto('https://example.com', {
  waitUntil: 'networkidle'
});

// Or increase timeout
await page.goto('https://example.com', {
  timeout: 60000
});
```

**3. Flaky Test (Intermittent Failure)**
```
Test passes sometimes, fails other times
```
**Fix:**
```javascript
// Add explicit waits
await page.waitForLoadState('domcontentloaded');

// Wait for specific condition
await page.waitForFunction(() =>
  window.dataLoaded === true
);

// Avoid hard-coded timeouts
// ❌ await page.waitForTimeout(1000);
// ✅ await page.waitForSelector('[data-ready="true"]');
```

## Advanced Debugging

### Use Playwright Trace Viewer

**For Playwright E2E Tests:**
```bash
# Run with tracing
npx playwright test --trace on

# View trace for failed test
npx playwright show-trace trace.zip

# In trace viewer:
# - See timeline of actions
# - View DOM snapshots at each step
# - Check network requests
# - See console logs
# - Review screenshots
```

**For Vitest 4.0+ with Browser Mode:**
```bash
# Run tests with trace generation
vitest run --browser --browser.trace on

# Traces available as test reporter annotations
# View trace file from test output
npx playwright show-trace path/to/trace.zip

# Trace includes:
# - Test execution timeline
# - Browser interactions
# - DOM state at each step
# - Network activity
# - Console logs
```

### Use VS Code Debugger

**For Vitest:**

`.vscode/launch.json`:
```json
{
  "type": "node",
  "request": "launch",
  "name": "Debug Vitest",
  "runtimeExecutable": "npm",
  "runtimeArgs": ["run", "test"],
  "console": "integratedTerminal",
  "internalConsoleOptions": "neverOpen"
}
```

**For Vitest 4.0+ Browser Mode:**
- Install Vitest VS Code extension
- Click "Debug Test" button above test in editor
- Works seamlessly with Browser Mode tests
- Breakpoints and step-through debugging supported

**For Playwright:**

`.vscode/launch.json`:
```json
{
  "type": "node",
  "request": "launch",
  "name": "Debug Playwright",
  "program": "${workspaceFolder}/node_modules/@playwright/test/cli.js",
  "args": ["test", "--debug"],
  "console": "integratedTerminal"
}
```

### Add Debug Logging

**Vitest:**
```javascript
import { describe, it, expect } from 'vitest';

it('debugs values', () => {
  const result = myFunction();
  console.log('DEBUG:', result); // Simple logging
  expect(result).toBe(expected);
});
```

**Playwright:**
```javascript
test('debugs page state', async ({ page }) => {
  console.log('Current URL:', page.url());
  console.log('Page title:', await page.title());

  // Screenshot for visual debugging
  await page.screenshot({ path: 'debug.png' });
});
```

## Systematic Debugging Workflow

1. **Isolate the failing test**
   ```bash
   vitest run path/to/failing-test.test.js
   ```

2. **Run in watch mode for quick iteration**
   ```bash
   vitest watch path/to/failing-test.test.js
   ```

3. **Add debug logging**
   - Log variable values
   - Log execution flow
   - Check assumptions

4. **Use test.only() to focus**
   ```javascript
   test.only('this specific failing test', () => {
     // Only this test runs
   });
   ```

5. **Check test isolation**
   ```bash
   # Run test in isolation
   vitest run --no-threads path/to/test.test.js
   ```

6. **Review mocks and setup**
   - Check beforeEach/beforeAll hooks
   - Verify mocks are reset between tests
   - Ensure no shared state

7. **Compare with working tests**
   - Look at similar passing tests
   - Check for differences in setup
   - Verify patterns are consistent

## When to Ask for Help

If after debugging you still can't fix it:
- Use `/test-master:fix-failing` for automated analysis
- Invoke the test-expert agent for specialized guidance
- Review test documentation and examples
- Check for known issues in Vitest/Playwright GitHub repos
