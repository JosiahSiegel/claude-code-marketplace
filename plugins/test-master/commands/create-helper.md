---
description: Create test helper utilities (assertions/dom/fixtures/mocks/state)
---

# Create Test Helper

## Purpose
Generate reusable test utilities to reduce duplication and improve test maintainability.

## Helper Types

### 1. Custom Assertions (tests/helpers/assertions.js)

Custom expect matchers for domain-specific assertions.

```javascript
import { expect } from 'vitest';

// Extend Vitest matchers
expect.extend({
  toBeValidEmail(received) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    const pass = emailRegex.test(received);

    return {
      pass,
      message: () =>
        pass
          ? `expected ${received} not to be a valid email`
          : `expected ${received} to be a valid email`
    };
  },

  toBeWithinRange(received, min, max) {
    const pass = received >= min && received <= max;

    return {
      pass,
      message: () =>
        pass
          ? `expected ${received} not to be within range ${min}-${max}`
          : `expected ${received} to be within range ${min}-${max}`
    };
  },

  toHaveBeenCalledWithMatch(received, expected) {
    const pass = received.mock.calls.some(call =>
      call.some(arg =>
        JSON.stringify(arg).includes(JSON.stringify(expected))
      )
    );

    return {
      pass,
      message: () =>
        pass
          ? `expected mock not to be called with ${JSON.stringify(expected)}`
          : `expected mock to be called with ${JSON.stringify(expected)}`
    };
  }
});

// Usage in tests:
// expect('[email protected]').toBeValidEmail();
// expect(25).toBeWithinRange(18, 65);
// expect(mockFn).toHaveBeenCalledWithMatch({ id: 123 });
```

### 2. DOM Helpers (tests/helpers/dom.js)

Utilities for DOM manipulation and setup in tests.

```javascript
import { cleanup } from '@testing-library/react';
import { afterEach } from 'vitest';

// Auto-cleanup after each test
afterEach(() => {
  cleanup();
  document.body.innerHTML = '';
  localStorage.clear();
  sessionStorage.clear();
});

/**
 * Create a DOM element for testing
 */
export function createTestElement(tag = 'div', attrs = {}) {
  const element = document.createElement(tag);
  Object.entries(attrs).forEach(([key, value]) => {
    if (key === 'textContent') {
      element.textContent = value;
    } else if (key === 'innerHTML') {
      element.innerHTML = value;
    } else {
      element.setAttribute(key, value);
    }
  });
  document.body.appendChild(element);
  return element;
}

/**
 * Simulate DOM event
 */
export function triggerEvent(element, eventType, eventData = {}) {
  const event = new Event(eventType, { bubbles: true, cancelable: true });
  Object.assign(event, eventData);
  element.dispatchEvent(event);
  return event;
}

/**
 * Wait for element to appear
 */
export async function waitForElement(selector, timeout = 3000) {
  const start = Date.now();
  while (Date.now() - start < timeout) {
    const element = document.querySelector(selector);
    if (element) return element;
    await new Promise(resolve => setTimeout(resolve, 50));
  }
  throw new Error(`Element ${selector} not found within ${timeout}ms`);
}

/**
 * Setup localStorage mock
 */
export function mockLocalStorage() {
  let store = {};

  return {
    getItem: (key) => store[key] || null,
    setItem: (key, value) => { store[key] = value.toString(); },
    removeItem: (key) => { delete store[key]; },
    clear: () => { store = {}; },
    get length() { return Object.keys(store).length; },
    key: (index) => Object.keys(store)[index] || null
  };
}

// Usage in tests:
// const button = createTestElement('button', { textContent: 'Click me' });
// triggerEvent(button, 'click');
// const modal = await waitForElement('.modal');
```

### 3. Fixture Helpers (tests/helpers/fixtures.js)

Factory functions for creating test data.

```javascript
/**
 * Create a test user object
 */
export function createUser(overrides = {}) {
  return {
    id: Math.floor(Math.random() * 10000),
    email: `user${Date.now()}@example.com`,
    name: 'Test User',
    role: 'user',
    createdAt: new Date().toISOString(),
    ...overrides
  };
}

/**
 * Create multiple users
 */
export function createUsers(count = 3, overrides = {}) {
  return Array.from({ length: count }, (_, i) =>
    createUser({ ...overrides, name: `Test User ${i + 1}` })
  );
}

/**
 * Create a test product
 */
export function createProduct(overrides = {}) {
  return {
    id: Math.floor(Math.random() * 10000),
    name: 'Test Product',
    price: 99.99,
    stock: 10,
    category: 'electronics',
    ...overrides
  };
}

/**
 * Create API response wrapper
 */
export function createApiResponse(data, overrides = {}) {
  return {
    success: true,
    data,
    timestamp: new Date().toISOString(),
    ...overrides
  };
}

/**
 * Create error response
 */
export function createErrorResponse(message = 'An error occurred', code = 'ERROR') {
  return {
    success: false,
    error: {
      message,
      code,
      timestamp: new Date().toISOString()
    }
  };
}

// Usage in tests:
// const user = createUser({ role: 'admin' });
// const users = createUsers(5);
// const product = createProduct({ price: 199.99 });
// const response = createApiResponse({ users });
```

### 4. Mock Helpers (tests/helpers/mocks.js)

Reusable mocks for common dependencies.

```javascript
import { vi } from 'vitest';

/**
 * Create a mock fetch function
 */
export function createMockFetch(responses = {}) {
  return vi.fn((url) => {
    const response = responses[url] || { data: 'default' };

    return Promise.resolve({
      ok: true,
      status: 200,
      json: () => Promise.resolve(response),
      text: () => Promise.resolve(JSON.stringify(response)),
      ...response.overrides
    });
  });
}

/**
 * Mock console methods
 */
export function mockConsole() {
  const original = {
    log: console.log,
    warn: console.warn,
    error: console.error
  };

  const mocks = {
    log: vi.fn(),
    warn: vi.fn(),
    error: vi.fn()
  };

  console.log = mocks.log;
  console.warn = mocks.warn;
  console.error = mocks.error;

  return {
    mocks,
    restore: () => {
      console.log = original.log;
      console.warn = original.warn;
      console.error = original.error;
    }
  };
}

/**
 * Create mock API client
 */
export function createMockApiClient() {
  return {
    get: vi.fn().mockResolvedValue({ data: [] }),
    post: vi.fn().mockResolvedValue({ data: {} }),
    put: vi.fn().mockResolvedValue({ data: {} }),
    delete: vi.fn().mockResolvedValue({ success: true })
  };
}

/**
 * Mock timer helpers
 */
export function setupTimers() {
  vi.useFakeTimers();

  return {
    tick: (ms) => vi.advanceTimersByTime(ms),
    runAll: () => vi.runAllTimers(),
    restore: () => vi.useRealTimers()
  };
}

// Usage in tests:
// global.fetch = createMockFetch({
//   '/api/users': { data: [{ id: 1, name: 'Test' }] }
// });
// const { mocks, restore } = mockConsole();
// const api = createMockApiClient();
// const timers = setupTimers();
```

### 5. State Helpers (tests/helpers/state.js)

Manage application state in tests.

```javascript
/**
 * Create a test store
 */
export function createTestStore(initialState = {}) {
  let state = { ...initialState };
  const listeners = [];

  return {
    getState: () => ({ ...state }),

    setState: (newState) => {
      state = { ...state, ...newState };
      listeners.forEach(listener => listener(state));
    },

    subscribe: (listener) => {
      listeners.push(listener);
      return () => {
        const index = listeners.indexOf(listener);
        if (index > -1) listeners.splice(index, 1);
      };
    },

    reset: () => {
      state = { ...initialState };
      listeners.length = 0;
    }
  };
}

/**
 * Wait for state condition
 */
export async function waitForState(store, condition, timeout = 3000) {
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => {
      reject(new Error('State condition timeout'));
    }, timeout);

    const unsubscribe = store.subscribe((state) => {
      if (condition(state)) {
        clearTimeout(timer);
        unsubscribe();
        resolve(state);
      }
    });

    // Check immediately
    if (condition(store.getState())) {
      clearTimeout(timer);
      unsubscribe();
      resolve(store.getState());
    }
  });
}

/**
 * Spy on state changes
 */
export function spyOnStateChanges(store) {
  const changes = [];

  const unsubscribe = store.subscribe((state) => {
    changes.push({ state: { ...state }, timestamp: Date.now() });
  });

  return {
    changes,
    unsubscribe,
    getChangeCount: () => changes.length,
    getLastChange: () => changes[changes.length - 1]
  };
}

// Usage in tests:
// const store = createTestStore({ count: 0 });
// store.setState({ count: 1 });
// await waitForState(store, state => state.loaded === true);
// const spy = spyOnStateChanges(store);
```

## Process

1. **Ask which helper type to create** (if not specified)
2. **Generate appropriate helper file**
3. **Include usage examples in comments**
4. **Export all utilities**
5. **Create index.js for easy imports**

## Helper Index File

Create tests/helpers/index.js to export all helpers:

```javascript
export * from './assertions.js';
export * from './dom.js';
export * from './fixtures.js';
export * from './mocks.js';
export * from './state.js';

// Usage in tests:
// import { createUser, mockConsole, waitForElement } from '../helpers';
```

## After Creating

1. Import helper in test files
2. Use throughout test suite to reduce duplication
3. Add more helpers as needed
4. Document helper functions with JSDoc comments
