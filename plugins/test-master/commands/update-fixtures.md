---
description: Update mock data fixtures to match current API schemas
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

# Update Fixtures

## Purpose
Update mock data fixtures to keep test data in sync with current API schemas and production data structures.

## Process

1. **Scan Existing Fixtures**
   - List all fixture files in tests/fixtures/
   - Identify JSON and JS fixtures
   - Check last modified dates

2. **Check for Schema Changes**
   - Compare fixture structure to current API responses
   - Identify missing fields
   - Detect deprecated fields
   - Check data type mismatches

3. **Update Fixtures**

   **Add missing fields:**
   ```javascript
   // Old: { id: 1, name: "John" }
   // New: { id: 1, name: "John", email: "john@example.com", createdAt: "2024-01-01" }
   ```

4. **Validate and Test**
   ```bash
   npm test
   ```

## Common Updates

- Add timestamp fields (createdAt/updatedAt)
- Normalize ID types (string to number)
- Add relationship fields
- Update enum values
- Fix data type mismatches

## After Updating

1. All fixtures updated successfully
2. Tests pass with new fixtures
3. Documentation updated
4. Backups created
5. Changes committed to version control
