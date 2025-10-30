---
description: Run Vitest integration tests
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

# Run Integration Tests

## Purpose
Execute integration tests that verify multiple modules working together, including API interactions with MSW mocks.

## Process

1. **Locate Integration Tests**
   - Check tests/integration/**/*.test.js
   - Verify MSW setup in tests/setup.js
   - Confirm test environment configuration

2. **Run Integration Tests**
   ```bash
   # Run all integration tests
   vitest run tests/integration

   # Or use npm script
   npm run test:integration

   # With MSW debugging
   DEBUG=msw:* vitest run tests/integration

   # Watch mode for development
   vitest watch tests/integration
   ```

3. **Verify MSW Setup**
   - Check that tests/mocks/server.js is configured
   - Ensure handlers are properly defined
   - Verify mock responses match API contracts

4. **Parse Results**
   - Check for API mocking issues
   - Identify integration points that failed
   - Detect timing or race condition problems

## MSW Integration

Integration tests should use MSW for API mocking:

**Setup (tests/setup.js):**
```javascript
import { beforeAll, afterEach, afterAll } from 'vitest';
import { server } from './mocks/server.js';

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

**Test Example:**
```javascript
import { describe, it, expect } from 'vitest';
import { fetchUserData } from '../src/api.js';

describe('API Integration', () => {
  it('should fetch user data', async () => {
    const data = await fetchUserData(1);
    expect(data).toHaveProperty('id', 1);
    expect(data).toHaveProperty('name');
  });
});
```

## Multi-Project Setup

For projects with separate integration test configuration:

```javascript
// vitest.config.js
export default {
  projects: [
    {
      test: {
        name: 'integration',
        include: ['tests/integration/**/*.test.js'],
        environment: 'happy-dom',
        setupFiles: ['./tests/setup.js'],
        testTimeout: 10000 // Longer timeout for integration tests
      }
    }
  ]
}
```

## Common Issues

- **MSW not intercepting:** Check server.listen() is called
- **Timeout errors:** Increase testTimeout for slower operations
- **State leakage:** Ensure afterEach() resets handlers properly
- **Mock mismatches:** Verify handler URLs match actual API calls
