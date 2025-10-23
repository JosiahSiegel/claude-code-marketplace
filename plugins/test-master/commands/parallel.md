---
description: Configure parallel test execution for faster runs
---

# Configure Parallel Execution

## Purpose
Optimize test execution by running tests in parallel across multiple workers.

## Process

1. **Current Configuration**
   Check current parallel settings:
   ```javascript
   // vitest.config.js
   export default {
     test: {
       threads: true,
       maxThreads: 4,
       minThreads: 1
     }
   };
   ```

2. **Optimize Worker Count**
   ```javascript
   // Use CPU count
   import os from 'os';

   export default {
     test: {
       maxThreads: os.cpus().length,
       // Or set explicitly
       maxThreads: 8
     }
   };
   ```

3. **Playwright Parallel Config**
   ```javascript
   // playwright.config.js
   export default {
     workers: process.env.CI ? 1 : undefined,
     // or explicit count
     workers: 4,
     // Fully parallel tests
     fullyParallel: true
   };
   ```

4. **Test Sharding**
   ```bash
   # Split tests across CI machines
   npx playwright test --shard=1/4
   npx playwright test --shard=2/4
   npx playwright test --shard=3/4
   npx playwright test --shard=4/4
   ```

## Best Practices

**Vitest:**
- Use threads for CPU-bound tests
- Use processes for tests needing isolation
- Set maxThreads to CPU count
- Disable for debugging

**Playwright:**
- Use workers for faster execution
- Set workers=1 in CI for stability
- Use fullyParallel for independent tests
- Disable for debugging

## After Configuration

- Tests run in parallel
- Execution time reduced
- Resource usage optimized
- CI builds faster
