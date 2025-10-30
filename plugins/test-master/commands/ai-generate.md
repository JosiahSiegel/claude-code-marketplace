---
description: Generate Playwright tests using AI agents (planner/generator/healer) - Playwright 1.55+
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

# AI-Powered Test Generation

## Purpose
Use Playwright AI Test Agents to automatically generate, maintain, and heal E2E tests using Large Language Models (Playwright 1.55+).

## Overview

**What are Playwright Test Agents?**
- Three specialized AI agents introduced in Playwright 1.55
- Guide LLMs to explore apps, generate tests, and repair failures
- Reduce manual test writing effort by 60-80%
- Available as custom agent definitions for Claude Code and other LLMs

**The Three Agents:**

1. **Planner Agent** - Explores the application and produces a Markdown test plan
2. **Generator Agent** - Transforms the Markdown plan into executable Playwright Test files
3. **Healer Agent** - Executes tests and automatically repairs failing tests

## Process

### 1. Install Playwright Test Agents

```bash
# Install Playwright 1.55 or later
npm install -D @playwright/test@latest

# Verify version
npx playwright --version
# Should be 1.55.0 or higher
```

### 2. Use the Planner Agent

**Goal**: Explore the application and create a test plan

```markdown
# Agent: Planner
# Task: Explore https://example.com and create E2E test plan

## Instructions:
1. Navigate to the application
2. Identify key user workflows
3. Document interactive elements (buttons, forms, links)
4. Create comprehensive test scenarios
5. Output as structured Markdown

## Output Format:
- Test Suite Name
- Test Scenarios (Given/When/Then)
- Expected Outcomes
- Selectors and Locators
```

**Example Planner Output:**

```markdown
# Test Plan: E-Commerce Checkout Flow

## Test Suite: User Purchase Journey

### Test 1: Successful Product Purchase
**Given**: User is on homepage
**When**: User searches for "laptop", adds to cart, proceeds to checkout, fills payment info
**Then**: Order confirmation page displays with order number

**Key Elements:**
- Search input: `input[type="search"]`
- Add to cart button: `button:has-text("Add to Cart")`
- Checkout button: `a[href="/checkout"]`
- Payment form: `form#payment-form`
- Confirmation: `.order-confirmation`

### Test 2: Empty Cart Validation
**Given**: User has empty cart
**When**: User clicks cart icon
**Then**: "Your cart is empty" message displays

**Key Elements:**
- Cart icon: `button[aria-label="Shopping cart"]`
- Empty message: `.empty-cart-message`
```

### 3. Use the Generator Agent

**Goal**: Convert test plan to executable Playwright code

```markdown
# Agent: Generator
# Task: Convert test plan to Playwright Test code

## Input: [Test Plan Markdown from Planner]

## Instructions:
1. Create Playwright Test file structure
2. Use role-based locators (getByRole, getByLabel)
3. Add auto-waiting and assertions
4. Include page object patterns for reusability
5. Add comments for clarity
6. Use TypeScript if project uses it
```

**Example Generator Output:**

```typescript
// tests/e2e/checkout.spec.ts
import { test, expect } from '@playwright/test';

test.describe('User Purchase Journey', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('https://example.com');
  });

  test('Successful Product Purchase', async ({ page }) => {
    // Search for product
    await page.getByRole('searchbox').fill('laptop');
    await page.getByRole('searchbox').press('Enter');

    // Wait for search results
    await expect(page.getByText('Search Results')).toBeVisible();

    // Add first product to cart
    await page.getByRole('button', { name: 'Add to Cart' }).first().click();

    // Verify item added notification
    await expect(page.getByText('Added to cart')).toBeVisible();

    // Proceed to checkout
    await page.getByRole('link', { name: 'Checkout' }).click();

    // Fill payment information
    await page.getByLabel('Card Number').fill('4111111111111111');
    await page.getByLabel('Expiry Date').fill('12/25');
    await page.getByLabel('CVV').fill('123');
    await page.getByLabel('Name on Card').fill('Test User');

    // Submit order
    await page.getByRole('button', { name: 'Place Order' }).click();

    // Verify order confirmation
    await expect(page.locator('.order-confirmation')).toBeVisible();
    await expect(page.getByText(/Order #\d+/)).toBeVisible();
  });

  test('Empty Cart Validation', async ({ page }) => {
    // Click cart icon
    await page.getByRole('button', { name: 'Shopping cart' }).click();

    // Verify empty cart message
    await expect(page.getByText('Your cart is empty')).toBeVisible();
    await expect(page.getByRole('button', { name: 'Checkout' })).toBeDisabled();
  });
});
```

### 4. Use the Healer Agent

**Goal**: Automatically fix failing tests

```markdown
# Agent: Healer
# Task: Analyze and repair failing tests

## Instructions:
1. Run the test suite
2. Capture failure screenshots and traces
3. Analyze error messages and stack traces
4. Identify root cause (selector changed, timing issue, assertion incorrect)
5. Propose fixes with explanations
6. Update test code
7. Re-run to verify fix
```

**Example Healer Output:**

```markdown
# Test Failure Analysis

## Failed Test: "Successful Product Purchase"

**Error:**
```
Error: Locator.click: Timeout 30000ms exceeded.
Element: button:has-text("Add to Cart")
```

**Root Cause:**
Button text changed from "Add to Cart" to "Add To Basket"

**Fix Applied:**
```diff
- await page.getByRole('button', { name: 'Add to Cart' }).first().click();
+ await page.getByRole('button', { name: 'Add To Basket' }).first().click();
```

**Alternative (More Resilient):**
Use test ID instead:
```typescript
await page.getByTestId('add-to-cart-button').first().click();
```

**Recommendation:**
Ask development team to add stable data-testid attributes to interactive elements.
```

## Complete Workflow

### Step-by-Step AI-Assisted Test Creation

```bash
# 1. Plan Phase
# Use Planner agent to explore app and create test plan
# Output: test-plan.md

# 2. Generate Phase
# Use Generator agent to convert plan to code
# Output: tests/e2e/feature.spec.ts

# 3. Execute Phase
npx playwright test

# 4. Heal Phase (if failures occur)
# Use Healer agent to analyze and fix failures
# Output: Updated tests/e2e/feature.spec.ts

# 5. Verify Phase
npx playwright test --retries=0
```

## Best Practices

### 1. Provide Clear Context to Agents

```markdown
# Good Agent Prompt
**Application**: E-commerce site at https://example.com
**User Role**: Customer making a purchase
**Key Flows**: Search → Add to Cart → Checkout → Payment
**Authentication**: Use test account (email: test@example.com, password: Test123!)
**Known Issues**: Payment form loads slowly, add 2-second wait
```

### 2. Review Generated Code

**AI is not perfect - always review:**
- Selectors might be too fragile (use data-testid when possible)
- Waits might be missing (add explicit waits for slow elements)
- Assertions might be insufficient (verify all critical data)
- Error handling might be incomplete (add try-catch where needed)

### 3. Iterate with Agents

```markdown
# Iteration Example

## First Generation:
[AI generates basic test]

## Refinement Request:
"Add error scenarios: invalid credit card, expired card, insufficient funds"

## Second Generation:
[AI adds error test cases]

## Final Review:
[Human verifies and merges]
```

### 4. Combine with Traditional Testing

```typescript
// Use AI for scaffolding
// Then add custom logic and edge cases manually

test('AI-generated: Successful checkout', async ({ page }) => {
  // AI-generated happy path
  await performCheckout(page);
  await expect(page.getByText('Order confirmed')).toBeVisible();
});

test('Manual: Checkout with discount code', async ({ page }) => {
  // Human-added edge case
  await performCheckout(page, { discountCode: 'SAVE20' });
  await expect(page.getByText('20% discount applied')).toBeVisible();
});
```

## Advanced Patterns

### Multi-Agent Collaboration

```markdown
# Workflow: Complex Feature Testing

## Phase 1: Discovery (Planner Agent)
- Explore authentication flow
- Document all form fields
- Identify validation rules
- List error messages

## Phase 2: Code Generation (Generator Agent)
- Create login test suite
- Add positive test cases
- Add negative test cases
- Include boundary conditions

## Phase 3: Optimization (Human + Healer)
- Run tests and capture failures
- Use Healer to fix broken selectors
- Human adds performance assertions
- Human adds accessibility checks

## Phase 4: Maintenance (Healer Agent)
- Monitor test failures in CI
- Auto-heal when selectors change
- Alert on structural changes
- Propose test updates
```

### Agent-Generated Page Objects

```markdown
# Prompt for Generator Agent

Create Page Object Model for login page with:
- URL navigation
- Form field methods (email, password)
- Submit method
- Error message getters
- Success navigation assertion
```

**Generated Output:**

```typescript
// pages/LoginPage.ts
import { Page, expect } from '@playwright/test';

export class LoginPage {
  constructor(private page: Page) {}

  async navigate() {
    await this.page.goto('/login');
  }

  async fillEmail(email: string) {
    await this.page.getByLabel('Email address').fill(email);
  }

  async fillPassword(password: string) {
    await this.page.getByLabel('Password').fill(password);
  }

  async submit() {
    await this.page.getByRole('button', { name: 'Sign In' }).click();
  }

  async login(email: string, password: string) {
    await this.fillEmail(email);
    await this.fillPassword(password);
    await this.submit();
  }

  async getErrorMessage() {
    return this.page.locator('.error-message').textContent();
  }

  async expectSuccessfulLogin() {
    await expect(this.page).toHaveURL(/\/dashboard/);
    await expect(this.page.getByText('Welcome back')).toBeVisible();
  }
}
```

## Limitations and Considerations

### What AI Agents Can Do Well:
✅ Generate boilerplate test structure
✅ Identify common user flows
✅ Create role-based locators
✅ Fix simple selector changes
✅ Document test scenarios
✅ Generate page objects

### What AI Agents Cannot Do Well:
❌ Understand complex business logic
❌ Validate data accuracy
❌ Test security vulnerabilities
❌ Handle multi-step authentication flows
❌ Test performance characteristics
❌ Ensure accessibility compliance

### Human Oversight Required:
- Security-sensitive tests (payment, authentication)
- Performance benchmarks
- Accessibility validation
- Complex state management
- Edge cases and boundary conditions

## Integration with CI/CD

```yaml
# GitHub Actions example
name: AI-Powered E2E Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: 18

      - name: Install dependencies
        run: npm ci

      - name: Install Playwright Browsers
        run: npx playwright install --with-deps

      - name: Run Playwright tests
        run: npx playwright test
        continue-on-error: true

      - name: Analyze failures with Healer Agent
        if: failure()
        run: |
          # Use Healer agent to analyze test-results/
          # Generate fix recommendations
          # Create PR comment with suggested fixes

      - name: Upload Playwright Report
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: playwright-report
          path: playwright-report/
```

## Troubleshooting

**Agent generates brittle selectors:**
- Prompt: "Use data-testid attributes and role-based locators only"
- Review and refactor generated selectors

**Agent misses edge cases:**
- Manually add boundary conditions
- Provide examples in prompt: "Include tests for: empty fields, special characters, max length"

**Healer cannot fix test:**
- Check if application structure changed significantly
- Manually inspect with Playwright Inspector
- Update test logic, not just selectors

**Generated tests are too verbose:**
- Prompt: "Use Page Object Model pattern"
- Extract common actions into helper functions

## Cost Considerations

**Using AI agents with Claude or other LLMs:**
- Planner: ~2000-5000 tokens per flow
- Generator: ~1000-3000 tokens per test
- Healer: ~1000-2000 tokens per failure

**Optimization tips:**
- Use agents for scaffolding, not line-by-line generation
- Cache test plans for similar flows
- Batch multiple test scenarios in one prompt
- Use smaller models for simple fixes

## Next Steps

- Use `/test-master:create-e2e` for manual E2E test creation
- Use `/test-master:debug` to analyze AI-generated test failures
- Use `/test-master:trace` to view detailed execution traces
- Combine AI generation with traditional TDD practices
