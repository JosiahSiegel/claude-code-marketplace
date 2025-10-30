---
description: Analyze and fix failing tests automatically
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

# Fix Failing Tests

## Purpose
Automatically analyze failing tests and suggest or apply fixes for common failure patterns.

## Process

1. **Run Tests and Capture Failures**
   ```bash
   vitest run --reporter=verbose
   ```

2. **Analyze Failure Patterns**

   **Assertion Failures:**
   - Compare expected vs actual
   - Identify mismatched values
   - Suggest fixes

   **Timeout Failures:**
   - Identify slow operations
   - Suggest increasing timeout
   - Suggest adding await

   **Snapshot Mismatches:**
   - Show diff
   - Ask to update snapshots

   **Mock Failures:**
   - Check mock setup
   - Verify mock calls
   - Suggest fixes

3. **Suggest Fixes**

   **For assertion failure:**
   ```javascript
   // Failing test
   expect(result).toBe(43);

   // Actual value: 42
   // Suggestion: Update assertion to match actual value
   // or fix implementation to return 43
   ```

   **For timeout:**
   ```javascript
   // Failing: Test timeout
   // Suggestion: Add await or increase timeout

   test('async operation', async () => {
     await someAsyncFunction();  // Add missing await
   }, 10000);  // Or increase timeout
   ```

4. **Apply Automatic Fixes**

   Can auto-fix:
   - Update snapshots
   - Add missing awaits (with user confirmation)
   - Fix import paths
   - Update mock expectations

5. **Report Results**
   ```
   Fixed 3 of 5 failing tests:
   ✓ Updated snapshots
   ✓ Added missing await
   ✓ Fixed import path

   Remaining 2 require manual intervention:
   - Assertion logic error in user.test.js:45
   - Complex mock setup needed in api.test.js:89
   ```

## Common Fixes

**1. Snapshot Updates**
```bash
vitest run --update-snapshots
```

**2. Add Missing Await**
```javascript
// Before
const result = fetchData();

// After
const result = await fetchData();
```

**3. Fix Timeout**
```javascript
test('slow test', async () => {
  // ...
}, 10000);  // Increase timeout
```

**4. Reset Mocks**
```javascript
beforeEach(() => {
  vi.clearAllMocks();  // Add missing cleanup
});
```

## After Fixing

- Re-run tests to verify fixes
- Review any manual fixes needed
- Commit fixes to version control
