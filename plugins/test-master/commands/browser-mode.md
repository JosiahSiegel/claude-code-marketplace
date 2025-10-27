---
description: Run Vitest tests in Browser Mode using Playwright (Vitest 4.0+)
---

# Browser Mode Testing

## Purpose
Run Vitest tests in a real browser environment using Playwright, providing access to browser-specific APIs and more realistic test conditions.

## Overview

**What is Browser Mode?**
- Vitest 4.0+ feature (stable as of October 2025)
- Uses Playwright to run tests in real browsers (Chromium, Firefox, WebKit)
- Changes the test environment from Node.js to browser
- NOT a replacement for E2E tools - still unit/integration testing

**When to Use:**
- Testing browser-specific APIs (Canvas, WebGL, localStorage, etc.)
- Testing visual components that require real DOM rendering
- Verifying cross-browser compatibility at unit level
- When happy-dom or jsdom aren't accurate enough

**When NOT to Use:**
- For pure JavaScript logic tests (use happy-dom instead - faster)
- For full user workflow testing (use Playwright E2E instead)
- When test performance is critical (browser mode is slower)

## Process

1. **Configure Browser Mode**

Add to `vitest.config.js`:
```javascript
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    browser: {
      enabled: true,
      name: 'chromium', // or 'firefox' or 'webkit'
      provider: { name: 'playwright' }, // Vitest 4.0 syntax (object instead of string)
      headless: true, // Set false to see browser during tests
      // Optional: enable tracing for debugging
      trace: 'on-first-retry', // or 'on' or 'retain-on-failure'
    },
  },
});
```

2. **Install Dependencies**

```bash
# Install Playwright browsers
npx playwright install chromium firefox webkit

# Or install specific browser
npx playwright install chromium
```

3. **Run Browser Mode Tests**

```bash
# Run all tests in browser mode
vitest run --browser

# Run with specific browser
vitest run --browser.name=chromium
vitest run --browser.name=firefox
vitest run --browser.name=webkit

# Run in headed mode (see browser)
vitest run --browser --browser.headless=false

# Run with tracing enabled
vitest run --browser --browser.trace=on

# Watch mode with browser
vitest --browser
```

4. **Write Browser-Specific Tests**

```javascript
import { describe, it, expect } from 'vitest';

describe('Browser APIs', () => {
  it('should access localStorage', () => {
    localStorage.setItem('test', 'value');
    expect(localStorage.getItem('test')).toBe('value');
    localStorage.clear();
  });

  it('should test Canvas API', () => {
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');

    expect(ctx).toBeTruthy();
    ctx.fillStyle = 'red';
    ctx.fillRect(0, 0, 100, 100);

    // Test canvas content
    const imageData = ctx.getImageData(50, 50, 1, 1);
    expect(imageData.data[0]).toBe(255); // Red channel
  });

  it('should test Web Components', () => {
    class MyElement extends HTMLElement {
      connectedCallback() {
        this.innerHTML = '<p>Hello</p>';
      }
    }

    customElements.define('my-element', MyElement);

    const element = document.createElement('my-element');
    document.body.appendChild(element);

    expect(element.querySelector('p').textContent).toBe('Hello');
  });

  it('should test IntersectionObserver', () => {
    const callback = vi.fn();
    const observer = new IntersectionObserver(callback);

    const element = document.createElement('div');
    document.body.appendChild(element);

    observer.observe(element);
    expect(observer).toBeTruthy();
    observer.disconnect();
  });
});
```

## Multi-Browser Testing

Test across browsers in parallel:

```javascript
// vitest.config.js
export default defineConfig({
  test: {
    // Run tests in all browsers
    browser: {
      enabled: true,
      instances: [
        { browser: 'chromium' },
        { browser: 'firefox' },
        { browser: 'webkit' },
      ],
    },
  },
});
```

Or use workspace mode:

```javascript
// vitest.workspace.js
export default [
  {
    test: {
      name: 'chromium',
      browser: { enabled: true, name: 'chromium' },
    },
  },
  {
    test: {
      name: 'firefox',
      browser: { enabled: true, name: 'firefox' },
    },
  },
  {
    test: {
      name: 'webkit',
      browser: { enabled: true, name: 'webkit' },
    },
  },
];
```

## Debugging Browser Mode Tests

### 1. Visual Debugging (Headed Mode)

```bash
# See the browser while tests run
vitest --browser --browser.headless=false
```

### 2. Use Playwright Traces

```bash
# Generate trace files
vitest run --browser --browser.trace=on

# View trace (path shown in test output)
npx playwright show-trace path/to/trace.zip
```

### 3. VS Code Integration

- Install Vitest VS Code extension
- Click "Debug Test" button above test
- Set breakpoints in test code
- Step through execution in browser context

### 4. Browser DevTools

```javascript
it('should debug in browser', async () => {
  // This opens browser DevTools (when not headless)
  debugger;

  const result = someFunction();
  expect(result).toBe(expected);
});
```

## Performance Considerations

**Browser Mode is Slower:**
- Starting browser: ~1-2 seconds per session
- Test execution: ~2-5x slower than happy-dom
- Use selectively for tests that need real browser

**Optimization Tips:**
```javascript
export default defineConfig({
  test: {
    browser: {
      enabled: true,
      // Reuse browser context across tests
      isolate: false, // Faster but less isolation
    },
    // Only run browser tests when needed
    include: ['tests/browser/**/*.test.js'],
  },
});
```

## Common Patterns

### Testing Visual Components

```javascript
it('should render component correctly', () => {
  const component = document.createElement('div');
  component.className = 'card';
  component.innerHTML = `
    <h2>Title</h2>
    <p>Content</p>
  `;
  document.body.appendChild(component);

  const heading = component.querySelector('h2');
  expect(heading.textContent).toBe('Title');
  expect(getComputedStyle(heading).fontSize).toBe('24px');
});
```

### Testing Async Browser APIs

```javascript
it('should test fetch API', async () => {
  const response = await fetch('https://api.example.com/data');
  const data = await response.json();

  expect(response.ok).toBe(true);
  expect(data).toHaveProperty('results');
});
```

### Testing User Interactions

```javascript
it('should handle click events', () => {
  const button = document.createElement('button');
  button.textContent = 'Click me';

  const handler = vi.fn();
  button.addEventListener('click', handler);

  document.body.appendChild(button);
  button.click();

  expect(handler).toHaveBeenCalledTimes(1);
});
```

## Troubleshooting

**Browser Not Found:**
```bash
# Install Playwright browsers
npx playwright install
```

**Port Already in Use:**
```javascript
// Change server port
export default defineConfig({
  test: {
    browser: {
      enabled: true,
      api: {
        port: 51205, // Custom port
      },
    },
  },
});
```

**Tests Timing Out:**
```javascript
// Increase timeout for browser tests
export default defineConfig({
  test: {
    browser: { enabled: true },
    testTimeout: 30000, // 30 seconds
  },
});
```

**Browser Crashes:**
- Check system resources (browser needs memory)
- Run with `--browser.headless=true`
- Update Playwright: `npm install -D playwright@latest`

## Comparison: Browser Mode vs E2E

| Feature | Browser Mode | E2E (Playwright) |
|---------|-------------|------------------|
| Purpose | Unit/Integration tests in browser | User workflow testing |
| Speed | Slower than Node, faster than E2E | Slowest (full app) |
| Setup | Vitest config | Separate test files |
| Assertions | Vitest expect() | Playwright expect() |
| When to use | Browser API testing | Full user journeys |

## Best Practices

1. **Use selectively** - Only for tests that need real browser
2. **Start with happy-dom** - Upgrade to browser mode if needed
3. **Test cross-browser** - Run on Chromium, Firefox, WebKit
4. **Enable traces** - For debugging failing tests
5. **Isolate tests** - Don't share state between browser tests
6. **Clean up** - Remove DOM elements after each test
7. **Use headed mode** - For debugging, use headless for CI

## CI/CD Integration

```yaml
# GitHub Actions example
- name: Install Playwright Browsers
  run: npx playwright install --with-deps

- name: Run Browser Tests
  run: npm run test:browser
  env:
    CI: true

- name: Upload Traces
  if: failure()
  uses: actions/upload-artifact@v3
  with:
    name: playwright-traces
    path: test-results/**/trace.zip
```

## Next Steps

- Use `/test-master:visual-regression` for screenshot testing
- Use `/test-master:e2e` for full user workflow testing
- Use `/test-master:debug` to troubleshoot failing browser tests
