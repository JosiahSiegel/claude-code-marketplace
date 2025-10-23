---
description: Run Playwright E2E browser tests
---

# Run E2E Tests

## Purpose
Execute end-to-end tests using Playwright across multiple browsers and devices.

## Process

1. **Verify Playwright Setup**
   - Check playwright.config.js exists
   - Ensure browsers are installed
   - Verify test files in tests/e2e/**/*.spec.js

2. **Run E2E Tests**
   ```bash
   # Run all E2E tests
   npx playwright test

   # Or use npm script
   npm run test:e2e

   # Run specific browser
   npx playwright test --project=chromium

   # Run specific test file
   npx playwright test tests/e2e/login.spec.js

   # Debug mode (headed browser)
   npx playwright test --debug

   # Run on specific device
   npx playwright test --project="Mobile Chrome"
   ```

3. **Analyze Results**
   - Check pass/fail rates across browsers
   - Identify browser-specific failures
   - Review screenshots and videos for failures
   - Examine Playwright traces

4. **Generate Reports**
   ```bash
   # Open HTML report
   npx playwright show-report

   # View traces for failed tests
   npx playwright show-trace trace.zip
   ```

## Multi-Browser Configuration

Ensure playwright.config.js includes device matrix:

```javascript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
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
  use: {
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    trace: 'retain-on-failure'
  }
});
```

## Test Patterns

**Page Object Model:**
```javascript
import { test, expect } from '@playwright/test';

test('user can login', async ({ page }) => {
  await page.goto('https://example.com/login');
  await page.fill('input[name="email"]', '[email protected]');
  await page.fill('input[name="password"]', 'password123');
  await page.click('button[type="submit"]');
  await expect(page).toHaveURL('/dashboard');
});
```

**Mobile Testing:**
```javascript
test('mobile navigation works', async ({ page }) => {
  await page.goto('https://example.com');
  await page.click('[aria-label="Open menu"]');
  await expect(page.locator('nav')).toBeVisible();
});
```

## Performance Tips

- Run in parallel: Configure `workers` in playwright.config.js
- Use sharding for CI: `--shard=1/4`
- Skip unnecessary tests: Use `test.skip()` or `.only()`
- Reuse authentication state: Save login state between tests

## Troubleshooting

- **Flaky tests:** Add explicit waits or use `waitForLoadState()`
- **Slow tests:** Check for unnecessary `page.waitForTimeout()` calls
- **Selector issues:** Use Playwright Inspector to find correct selectors
- **CI failures:** Check screenshot/video artifacts for visual debugging
