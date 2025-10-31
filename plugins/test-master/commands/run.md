---
description: Run all tests with intelligent selection (unit, integration, E2E)
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

## Windows and Git Bash Execution

### Cross-Platform Test Execution

When running tests on Windows, especially in Git Bash/MINGW:

**✅ Recommended Approach - Use NPM Scripts:**
```bash
# Always prefer npm scripts (handles path conversion automatically)
npm test
npm run test:unit
npm run test:e2e
```

**✅ Alternative - Disable Path Conversion:**
```bash
# If running vitest/playwright directly in Git Bash
MSYS_NO_PATHCONV=1 vitest run
MSYS_NO_PATHCONV=1 playwright test
```

**⚠️ Direct Commands May Have Issues:**
```bash
# May encounter path conversion issues in Git Bash
vitest run
playwright test
```

### Common Git Bash Issues

**Issue: "No such file or directory" errors**
```bash
# Solution: Use npm scripts
npm test

# Or disable path conversion
MSYS_NO_PATHCONV=1 npm test
```

**Issue: Test files not found**
- Ensure vitest.config.js uses relative paths
- Check that include patterns use forward slashes: `tests/unit/**/*.test.js`
- Avoid absolute paths starting with /c/ or C:\

**Issue: Playwright browser launch failures**
```bash
# Clear interfering environment variables
unset DISPLAY
npm run test:e2e
```

### Shell Detection

Tests can detect Git Bash environment if needed:

```javascript
// In test setup or configuration
function isGitBash() {
  return !!(process.env.MSYSTEM); // MINGW64, MINGW32, MSYS
}

if (isGitBash()) {
  console.log('Running tests in Git Bash/MINGW');
}
```

For comprehensive Windows/Git Bash testing guidance, see `skills/windows-git-bash-testing.md`.
