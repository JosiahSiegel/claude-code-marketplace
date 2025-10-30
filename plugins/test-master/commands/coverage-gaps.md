---
description: Find uncovered code and suggest test improvements
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

# Find Coverage Gaps

## Purpose
Analyze coverage reports to identify untested code and suggest where to add tests.

## Process

1. **Generate Coverage**
   ```bash
   vitest run --coverage --reporter=json
   ```

2. **Parse Coverage Data**
   - Read coverage/coverage-final.json
   - Identify files below thresholds
   - Find uncovered lines, branches, functions

3. **Analyze Gaps**

   **By File:**
   ```
   Critical gaps found:

   src/auth/validate.js: 45% coverage
   - Lines 23-45: Error handling not tested
   - Function validatePassword: Not covered
   - Branches: Only happy path tested

   src/api/users.js: 62% coverage
   - Lines 89-102: Edge cases not tested
   - Function deleteUser: Not covered
   ```

   **By Category:**
   - **Error handling:** 23% uncovered
   - **Edge cases:** 31% uncovered
   - **Happy paths:** 95% covered

4. **Suggest Tests**

   For each gap, suggest:
   ```
   📝 Suggested test for src/auth/validate.js:

   it('should reject weak passwords', () => {
     expect(validatePassword('123')).toBe(false);
   });

   it('should handle null input', () => {
     expect(() => validatePassword(null)).toThrow();
   });
   ```

5. **Prioritize Gaps**
   - **High priority:** Critical code, security functions
   - **Medium:** Core business logic
   - **Low:** Utility functions, simple getters

## Output Format

```
Coverage Gaps Analysis
======================

🔴 Critical Gaps (High Priority)
  src/security/auth.js: 45% coverage
  - Missing error path tests
  - Edge cases not covered
  Suggested: Add 3 tests for error scenarios

  src/payment/process.js: 60% coverage
  - Missing validation tests
  Suggested: Add 2 tests for input validation

⚠️  Important Gaps (Medium Priority)
  src/api/users.js: 72% coverage
  - Missing DELETE method test
  Suggested: Add 1 test for deletion

✓ Minor Gaps (Low Priority)
  src/utils/format.js: 85% coverage
  - Some edge cases not tested

Summary:
  Total gaps: 15
  High priority: 5
  Medium priority: 7
  Low priority: 3

Estimated effort: 2-3 hours to close critical gaps
```

## After Analysis

- Create tests for high-priority gaps
- Track progress
- Re-run coverage
- Verify gaps are closed
