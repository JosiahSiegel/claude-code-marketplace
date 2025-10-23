---
description: Run all tests with intelligent selection (unit, integration, E2E)
---

# Run All Tests

## Purpose
Execute the complete test suite with intelligent test selection based on project structure and recent changes.

## Process

1. **Detect Test Infrastructure**
   - Check for vitest.config.js and playwright.config.js
   - Identify test directories (tests/unit, tests/integration, tests/e2e)
   - Detect test file patterns

2. **Analyze Recent Changes**
   - Check git status for changed files
   - Determine which test types are affected:
     - Pure function changes → Unit tests only
     - API/integration changes → Unit + Integration tests
     - UI changes → All tests including E2E
     - Config changes → All tests

3. **Run Tests in Optimal Order**
   - Start with fastest tests first (unit → integration → E2E)
   - Use parallel execution when possible
   - Stop on first failure if --fail-fast flag detected

4. **Execute Test Commands**
   ```bash
   # For Vitest (unit + integration)
   npm run test
   # or
   vitest run

   # For Playwright (E2E)
   npm run test:e2e
   # or
   npx playwright test
   ```

5. **Report Results**
   - Summarize pass/fail counts
   - Highlight failed tests
   - Show execution time
   - Suggest next steps if failures occur

## Intelligent Selection Examples

**Scenario 1: Only utility functions changed**
- Run: Unit tests only
- Skip: E2E tests (unnecessary)

**Scenario 2: API endpoints modified**
- Run: Unit + Integration tests
- Run: Related E2E tests only

**Scenario 3: UI components changed**
- Run: Full test suite including E2E

## Error Handling

If tests fail:
- Display clear error messages
- Suggest running `/test-master:debug` for detailed analysis
- Offer to update snapshots if snapshot failures detected
- Provide links to failed test files

## Performance Tips

- Use `--reporter=dot` for faster output in CI
- Enable parallel execution with appropriate worker count
- Consider `--bail` flag to stop on first failure
