---
description: Update mock data fixtures to match current API schemas
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
