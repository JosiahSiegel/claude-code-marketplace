---
description: Update coverage thresholds in configuration
---

# Set Coverage Thresholds

## Purpose
Update coverage thresholds in vitest.config.js to enforce minimum test coverage standards.

## Process

1. **Current Thresholds**
   Read vitest.config.js and display current thresholds:
   ```
   Current thresholds:
   - Lines: 70%
   - Functions: 70%
   - Branches: 65%
   - Statements: 70%
   ```

2. **Suggest New Thresholds**
   Based on current coverage:
   ```
   Current coverage: 85%
   Suggested threshold: 80% (5% buffer)
   ```

3. **Ask for New Values**
   ```
   Enter new thresholds:
   ? Lines (70%): › 80
   ? Functions (70%): › 80
   ? Branches (65%): › 75
   ? Statements (70%): › 80
   ```

4. **Per-File Thresholds**
   ```
   Add per-file thresholds for critical files? (yes/no) › yes

   ? File pattern: › src/security/**/*.js
   ? Lines: › 95
   ? Functions: › 100
   ```

5. **Update Configuration**
   ```javascript
   export default {
     test: {
       coverage: {
         thresholds: {
           lines: 80,
           functions: 80,
           branches: 75,
           statements: 80,
           'src/security/**/*.js': {
             lines: 95,
             functions: 100
           }
         }
       }
     }
   };
   ```

6. **Verify**
   ```bash
   npm run test:coverage
   ```

## Best Practices

- Set thresholds 5-10% below current coverage
- Higher thresholds for critical code
- Gradually increase over time
- Don't chase 100% coverage

## After Setting

- Thresholds updated in vitest.config.js
- Tests run to verify compliance
- Team notified of new standards
