---
description: Run Vitest unit tests only
---

# Run Unit Tests

## Purpose
Execute unit tests using Vitest, focusing on individual functions and modules in isolation.

## Process

1. **Locate Unit Tests**
   - Check tests/unit/**/*.test.js
   - Verify vitest.config.js configuration
   - Identify test file patterns

2. **Run Unit Tests**
   ```bash
   # Run all unit tests
   vitest run tests/unit

   # Or use npm script if defined
   npm run test:unit

   # Run specific file
   vitest run tests/unit/specific-file.test.js

   # With coverage
   vitest run tests/unit --coverage
   ```

3. **Parse Output**
   - Count passing/failing tests
   - Identify slow tests (>100ms)
   - Detect flaky tests (inconsistent results)

4. **Report Results**
   - Summary of test results
   - Failed test details with file locations
   - Suggest fixes for common failures

## Configuration

Ensure vitest.config.js includes:
```javascript
export default {
  test: {
    include: ['tests/unit/**/*.test.js'],
    environment: 'happy-dom', // or 'jsdom'
    coverage: {
      provider: 'v8',
      include: ['src/**/*.js']
    }
  }
}
```

## Common Patterns

**Testing Pure Functions:**
```javascript
import { describe, it, expect } from 'vitest';
import { myFunction } from '../src/myFunction.js';

describe('myFunction', () => {
  it('should return expected result', () => {
    expect(myFunction(input)).toBe(expectedOutput);
  });
});
```

**Testing with Mocks:**
```javascript
import { vi } from 'vitest';

const mockFn = vi.fn();
// Use mockFn in tests
```

## Troubleshooting

- **Import errors:** Check file paths and module resolution
- **Environment issues:** Verify 'happy-dom' or 'jsdom' is installed
- **Async timing:** Use `await` properly or increase timeout
