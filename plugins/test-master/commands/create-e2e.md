---
description: Scaffold a new Playwright E2E test
---

# Create E2E Test

## Purpose
Generate an end-to-end test file using Playwright to verify user workflows in a real browser.

## Process

1. **Gather Information**
   - User workflow to test (e.g., login, checkout, signup)
   - Pages involved
   - User actions (clicks, form inputs, navigation)
   - Expected outcomes

2. **Create Test File Structure**

```javascript
import { test, expect } from '@playwright/test';

test.describe('{Workflow Name}', () => {
  test('should complete {workflow} successfully', async ({ page }) => {
    // Navigate to starting page
    await page.goto('https://example.com/start');

    // Perform user actions
    await page.fill('input[name="username"]', 'testuser');
    await page.fill('input[name="password"]', 'password123');
    await page.click('button[type="submit"]');

    // Verify outcome
    await expect(page).toHaveURL('https://example.com/dashboard');
    await expect(page.locator('h1')).toContainText('Welcome');
  });

  test('should show error for invalid input', async ({ page }) => {
    await page.goto('https://example.com/start');

    await page.fill('input[name="username"]', '');
    await page.click('button[type="submit"]');

    // Verify error message
    await expect(page.locator('.error')).toBeVisible();
    await expect(page.locator('.error')).toContainText('Username required');
  });
});
```

3. **Analyze User Flow**
   - Map out step-by-step user actions
   - Identify form fields and buttons
   - Determine wait conditions
   - Plan assertions

4. **Generate Test Scenarios**

## Common E2E Patterns

### Form Submission Flow

```javascript
test('should submit contact form', async ({ page }) => {
  await page.goto('https://example.com/contact');

  // Fill form fields
  await page.fill('input[name="name"]', 'John Doe');
  await page.fill('input[name="email"]', '[email protected]');
  await page.fill('textarea[name="message"]', 'Test message');

  // Submit form
  await page.click('button:has-text("Send")');

  // Wait for success message
  await expect(page.locator('.success')).toBeVisible();
  await expect(page.locator('.success')).toContainText('Message sent');
});
```

### Multi-Page Navigation

```javascript
test('should navigate through checkout process', async ({ page }) => {
  // Step 1: Add item to cart
  await page.goto('https://example.com/products/1');
  await page.click('button:has-text("Add to Cart")');

  // Step 2: View cart
  await page.click('a[href="/cart"]');
  await expect(page.locator('.cart-item')).toHaveCount(1);

  // Step 3: Proceed to checkout
  await page.click('button:has-text("Checkout")');
  await expect(page).toHaveURL(/.*checkout/);

  // Step 4: Fill shipping info
  await page.fill('#address', '123 Main St');
  await page.fill('#city', 'New York');
  await page.click('button:has-text("Continue")');

  // Step 5: Complete order
  await page.fill('#card-number', '4242424242424242');
  await page.click('button:has-text("Place Order")');

  // Verify success
  await expect(page.locator('.order-confirmation')).toBeVisible();
});
```

### Authentication Flow

```javascript
test('should login and access protected page', async ({ page }) => {
  // Go to login page
  await page.goto('https://example.com/login');

  // Login
  await page.fill('input[name="email"]', '[email protected]');
  await page.fill('input[name="password"]', 'password123');
  await page.click('button[type="submit"]');

  // Wait for redirect
  await page.waitForURL('https://example.com/dashboard');

  // Verify authenticated state
  await expect(page.locator('.user-menu')).toBeVisible();
  await expect(page.locator('.user-email')).toContainText('[email protected]');

  // Access protected page
  await page.goto('https://example.com/settings');
  await expect(page.locator('h1')).toContainText('Settings');
});
```

### Search and Filter

```javascript
test('should search and filter products', async ({ page }) => {
  await page.goto('https://example.com/products');

  // Search
  await page.fill('input[placeholder="Search"]', 'laptop');
  await page.press('input[placeholder="Search"]', 'Enter');

  // Wait for results
  await page.waitForSelector('.product-card');
  const products = await page.locator('.product-card').count();
  expect(products).toBeGreaterThan(0);

  // Apply filter
  await page.click('input[value="in-stock"]');
  await page.waitForTimeout(500); // Wait for filter to apply

  // Verify filtered results
  const filteredProducts = await page.locator('.product-card').count();
  expect(filteredProducts).toBeLessThanOrEqual(products);
});
```

### Modal Interactions

```javascript
test('should open and close modal', async ({ page }) => {
  await page.goto('https://example.com/dashboard');

  // Open modal
  await page.click('button:has-text("Settings")');
  await expect(page.locator('.modal')).toBeVisible();

  // Interact with modal
  await page.fill('.modal input[name="username"]', 'newusername');
  await page.click('.modal button:has-text("Save")');

  // Verify modal closes
  await expect(page.locator('.modal')).not.toBeVisible();

  // Verify changes saved
  await expect(page.locator('.success-message')).toBeVisible();
});
```

## Selector Strategies

**Best practices for reliable selectors:**

```javascript
// ✅ Good - Use data-testid
await page.click('[data-testid="submit-button"]');

// ✅ Good - Use accessible roles
await page.click('role=button[name="Submit"]');

// ✅ Good - Use text content
await page.click('button:has-text("Submit")');

// ⚠️ OK - Use IDs (if stable)
await page.click('#submit-button');

// ❌ Avoid - Fragile CSS selectors
await page.click('div > div.container > button.btn.btn-primary');
```

## Waiting Strategies

```javascript
// Wait for navigation
await page.waitForURL('**/dashboard');

// Wait for element
await page.waitForSelector('.data-loaded');

// Wait for load state
await page.waitForLoadState('networkidle');

// Wait for function
await page.waitForFunction(() => window.dataReady === true);

// Wait for API response
await page.waitForResponse('**/api/data');
```

## Handling Dynamic Content

```javascript
test('should handle loading states', async ({ page }) => {
  await page.goto('https://example.com/data');

  // Verify loading indicator appears
  await expect(page.locator('.loading')).toBeVisible();

  // Wait for data to load
  await expect(page.locator('.loading')).not.toBeVisible();
  await expect(page.locator('.data-table')).toBeVisible();

  // Verify data rendered
  const rows = await page.locator('.data-row').count();
  expect(rows).toBeGreaterThan(0);
});
```

## Mobile Testing

```javascript
test('should work on mobile devices', async ({ page }) => {
  // Set mobile viewport
  await page.setViewportSize({ width: 375, height: 667 });

  await page.goto('https://example.com');

  // Verify mobile menu
  await expect(page.locator('.mobile-menu-button')).toBeVisible();
  await page.click('.mobile-menu-button');

  // Verify menu opens
  await expect(page.locator('.mobile-menu')).toBeVisible();
});
```

## Configuration

Add test file to playwright.config.js projects:

```javascript
export default defineConfig({
  testDir: './tests/e2e',
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
    }
  ],
  use: {
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    trace: 'retain-on-failure'
  }
});
```

## Best Practices

1. **Test user flows, not implementation** - Focus on what users do
2. **Use stable selectors** - Prefer data-testid, roles, text
3. **Wait explicitly** - Don't use hard-coded timeouts
4. **Test across browsers** - Run on Chrome, Firefox, Safari
5. **Handle loading states** - Wait for content to load
6. **Test error scenarios** - Not just happy path
7. **Keep tests independent** - Each test should work alone
8. **Use Page Object Model** - For complex pages

## After Creating

1. Run: `npx playwright test tests/e2e/{workflow}.spec.js`
2. Verify test passes on all browsers
3. Check screenshots/videos if test fails
4. Add more scenarios for edge cases
5. Run in headed mode to debug: `npx playwright test --headed`
