---
description: Visual regression testing with Vitest 4.0 Browser Mode
---

# Visual Regression Testing

## Purpose
Detect unintended visual changes in UI components by comparing screenshots over time using Vitest 4.0+ Browser Mode.

## Overview

**What is Visual Regression Testing?**
- Automated comparison of UI screenshots
- Detects visual changes in components, layouts, and styles
- Catches CSS bugs, rendering issues, and design regressions
- Available in Vitest 4.0+ Browser Mode (October 2025)

**When to Use:**
- Testing UI components for visual consistency
- Catching unintended CSS changes
- Verifying responsive design across breakpoints
- Testing theming and dark mode
- Cross-browser visual compatibility

**When NOT to Use:**
- For functional behavior testing (use unit tests)
- For user interaction flows (use E2E tests)
- For dynamic content that changes frequently

## Process

1. **Configure Visual Testing**

Add to `vitest.config.js`:
```javascript
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    browser: {
      enabled: true,
      name: 'chromium',
      provider: 'playwright',
      headless: true,
    },
    // Screenshot comparison settings
    expect: {
      toMatchSnapshot: {
        threshold: 0.2, // 0-1, higher = more tolerance
        failureThreshold: 0.01, // % of pixels that can differ
        failureThresholdType: 'percent', // or 'pixel'
      },
    },
  },
});
```

2. **Write Visual Tests**

```javascript
import { describe, it, expect } from 'vitest';

describe('Button Component Visual Tests', () => {
  it('should match baseline screenshot', async () => {
    // Create and style component
    const button = document.createElement('button');
    button.className = 'btn-primary';
    button.textContent = 'Click Me';
    document.body.appendChild(button);

    // Take screenshot and compare
    await expect(button).toMatchSnapshot();
  });

  it('should match hover state', async () => {
    const button = document.createElement('button');
    button.className = 'btn-primary';
    button.textContent = 'Hover Me';
    document.body.appendChild(button);

    // Trigger hover state
    button.classList.add('hover');

    await expect(button).toMatchSnapshot('button-hover');
  });

  it('should match disabled state', async () => {
    const button = document.createElement('button');
    button.className = 'btn-primary';
    button.textContent = 'Disabled';
    button.disabled = true;
    document.body.appendChild(button);

    await expect(button).toMatchSnapshot('button-disabled');
  });
});
```

3. **Generate Baseline Screenshots**

```bash
# First run creates baseline snapshots
vitest run --browser tests/visual

# Snapshots saved to __snapshots__/ directory
```

4. **Run Visual Regression Tests**

```bash
# Compare against baselines
vitest run --browser tests/visual

# Update baselines when changes are intentional
vitest run --browser tests/visual --update-snapshots
# or press 'u' in watch mode
```

## Common Patterns

### Testing Component States

```javascript
describe('Card Component', () => {
  it('should render default state', async () => {
    const card = createCard({
      title: 'Test Card',
      content: 'Test content',
    });
    document.body.appendChild(card);

    await expect(card).toMatchSnapshot('card-default');
  });

  it('should render loading state', async () => {
    const card = createCard({ loading: true });
    document.body.appendChild(card);

    await expect(card).toMatchSnapshot('card-loading');
  });

  it('should render error state', async () => {
    const card = createCard({
      error: 'Something went wrong'
    });
    document.body.appendChild(card);

    await expect(card).toMatchSnapshot('card-error');
  });
});
```

### Testing Responsive Design

```javascript
describe('Responsive Layout', () => {
  const sizes = [
    { name: 'mobile', width: 375, height: 667 },
    { name: 'tablet', width: 768, height: 1024 },
    { name: 'desktop', width: 1920, height: 1080 },
  ];

  sizes.forEach(({ name, width, height }) => {
    it(`should render correctly on ${name}`, async () => {
      // Set viewport size
      await page.setViewportSize({ width, height });

      const layout = createLayout();
      document.body.appendChild(layout);

      await expect(layout).toMatchSnapshot(`layout-${name}`);
    });
  });
});
```

### Testing Dark Mode

```javascript
describe('Theme Support', () => {
  it('should render light theme', async () => {
    document.body.setAttribute('data-theme', 'light');

    const component = createComponent();
    document.body.appendChild(component);

    await expect(component).toMatchSnapshot('theme-light');
  });

  it('should render dark theme', async () => {
    document.body.setAttribute('data-theme', 'dark');

    const component = createComponent();
    document.body.appendChild(component);

    await expect(component).toMatchSnapshot('theme-dark');
  });
});
```

### Testing Animations

```javascript
describe('Animation States', () => {
  it('should match initial state', async () => {
    const element = document.createElement('div');
    element.className = 'fade-in';
    document.body.appendChild(element);

    await expect(element).toMatchSnapshot('animation-start');
  });

  it('should match final state', async () => {
    const element = document.createElement('div');
    element.className = 'fade-in';
    document.body.appendChild(element);

    // Wait for animation to complete
    await new Promise(resolve => setTimeout(resolve, 1000));

    await expect(element).toMatchSnapshot('animation-end');
  });
});
```

### Full Page Screenshots

```javascript
it('should match full page layout', async () => {
  // Create complex page layout
  const page = createPageLayout({
    header: true,
    sidebar: true,
    content: 'Lorem ipsum...',
    footer: true,
  });
  document.body.appendChild(page);

  // Take full page screenshot
  await expect(document.body).toMatchSnapshot('full-page');
});
```

## Advanced Configuration

### Custom Snapshot Options

```javascript
it('should match with custom threshold', async () => {
  const component = createComponent();
  document.body.appendChild(component);

  await expect(component).toMatchSnapshot({
    threshold: 0.5, // More tolerance
    failureThreshold: 0.05, // Allow 5% difference
  });
});
```

### Ignoring Dynamic Content

```javascript
it('should ignore timestamp', async () => {
  const card = document.createElement('div');
  card.innerHTML = `
    <h2>Static Title</h2>
    <p class="timestamp">${new Date().toISOString()}</p>
    <p>Static content</p>
  `;
  document.body.appendChild(card);

  // Hide dynamic content before snapshot
  card.querySelector('.timestamp').style.visibility = 'hidden';

  await expect(card).toMatchSnapshot();
});
```

### Multiple Browser Comparison

```javascript
// vitest.workspace.js
export default [
  {
    test: {
      name: 'chromium-visual',
      browser: { enabled: true, name: 'chromium' },
      include: ['tests/visual/**/*.test.js'],
    },
  },
  {
    test: {
      name: 'firefox-visual',
      browser: { enabled: true, name: 'firefox' },
      include: ['tests/visual/**/*.test.js'],
    },
  },
  {
    test: {
      name: 'webkit-visual',
      browser: { enabled: true, name: 'webkit' },
      include: ['tests/visual/**/*.test.js'],
    },
  },
];
```

## Debugging Failed Visual Tests

### 1. View Diff Images

```bash
# After test failure, check diff images in:
# __snapshots__/__diff_output__/

# Shows:
# - expected.png (baseline)
# - actual.png (current)
# - diff.png (highlighted differences)
```

### 2. Investigate Failures

```javascript
it('should match component', async () => {
  const component = createComponent();
  document.body.appendChild(component);

  try {
    await expect(component).toMatchSnapshot();
  } catch (error) {
    // Take debug screenshot
    await page.screenshot({
      path: 'debug-screenshot.png',
      fullPage: true
    });
    throw error;
  }
});
```

### 3. Common Failure Causes

**Font Rendering Differences:**
- Use web fonts, not system fonts
- Ensure fonts load before screenshot

**Animation Timing:**
- Disable animations in tests
- Wait for animations to complete

**Dynamic Content:**
- Mock dates, random values
- Hide or replace dynamic elements

**Anti-aliasing Differences:**
- Increase threshold tolerance
- Use same OS for tests and CI

## Best Practices

1. **Keep baselines in version control**
   - Commit snapshot images to git
   - Review visual changes in PRs

2. **Name snapshots descriptively**
   ```javascript
   await expect(button).toMatchSnapshot('primary-button-hover-state');
   ```

3. **Test isolated components**
   - Reset styles between tests
   - Use clean DOM for each test

4. **Set appropriate thresholds**
   - Too strict: false positives from anti-aliasing
   - Too loose: miss real visual bugs
   - Start with 0.1-0.2 threshold

5. **Wait for fonts and images**
   ```javascript
   // Wait for web fonts
   await document.fonts.ready;

   // Wait for images
   await page.waitForLoadState('networkidle');
   ```

6. **Test in controlled environment**
   - Use consistent viewport sizes
   - Use headless mode (consistent rendering)
   - Disable animations for testing

7. **Organize visual tests separately**
   ```
   tests/
     visual/
       components/
         button.visual.test.js
         card.visual.test.js
       layouts/
         homepage.visual.test.js
   ```

## CI/CD Integration

### GitHub Actions

```yaml
name: Visual Regression Tests

on: [pull_request]

jobs:
  visual-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: 18

      - name: Install dependencies
        run: npm ci

      - name: Install Playwright browsers
        run: npx playwright install --with-deps chromium

      - name: Run visual tests
        run: npm run test:visual

      - name: Upload diff images
        if: failure()
        uses: actions/upload-artifact@v3
        with:
          name: visual-diffs
          path: tests/visual/__snapshots__/__diff_output__/

      - name: Comment PR with diffs
        if: failure()
        uses: actions/github-script@v6
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: '⚠️ Visual regression tests failed. Check diff images in artifacts.'
            })
```

## Comparison: Visual vs E2E Screenshots

| Feature | Visual Regression | E2E Screenshots |
|---------|------------------|-----------------|
| Purpose | Component appearance | Full page/flow |
| Speed | Fast (unit-level) | Slower (integration) |
| Scope | Single components | Complete pages |
| Setup | Vitest Browser Mode | Playwright config |
| Best for | CSS changes | Layout changes |

## Troubleshooting

**Flaky Visual Tests:**
```javascript
// Ensure fonts loaded
await document.fonts.ready;

// Wait for animations
const element = document.querySelector('.animated');
await waitForAnimationEnd(element);

// Disable animations globally
document.body.style.animation = 'none';
document.body.style.transition = 'none';
```

**Different Results on CI vs Local:**
- Use Docker for consistent environment
- Use same OS (Linux) for local dev and CI
- Lock Playwright version

**Large Snapshot Files:**
- Test smaller components, not full pages
- Use JPEG for photos, PNG for UI
- Compress snapshot images

**Too Many False Positives:**
- Increase threshold tolerance
- Use `failureThreshold: 'percent'` instead of 'pixel'
- Mask dynamic content

## Integration with Other Tools

### Percy / Chromatic Alternative

Visual regression testing with Vitest is an open-source alternative to:
- Percy (Browserstack)
- Chromatic (Storybook)
- Applitools

**Advantages:**
- No third-party service required
- Runs in your CI pipeline
- Snapshots committed to your repo

**Disadvantages:**
- Manual baseline management
- No visual review UI
- Larger repository size

## Next Steps

- Use `/test-master:browser-mode` to understand browser testing
- Use `/test-master:update-snapshots` to update baselines
- Use `/test-master:debug` to troubleshoot visual test failures
- Consider Storybook for component development + visual testing
