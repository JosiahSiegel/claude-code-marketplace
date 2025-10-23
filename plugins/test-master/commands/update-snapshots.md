---
description: Update Vitest snapshots for changed components
---

# Update Snapshots

## Purpose
Update Vitest snapshots when component output or data structures legitimately change.

## Process

1. **Review Snapshot Failures**
   ```bash
   vitest run
   ```

   Shows diff:
   ```
   - Expected
   + Received

   - <div>Old Text</div>
   + <div>New Text</div>
   ```

2. **Verify Changes Are Intentional**
   - Review the diff carefully
   - Ensure changes are expected
   - Check no accidental modifications

3. **Update Snapshots**

   **All snapshots:**
   ```bash
   vitest run --update-snapshots
   # or
   vitest run -u
   ```

   **In watch mode:**
   Press `u` to update all failing snapshots

   **Specific test file:**
   ```bash
   vitest run tests/unit/component.test.js -u
   ```

4. **Review Updated Snapshots**
   - Check git diff
   - Verify changes make sense
   - Ensure no unintended updates

5. **Run Tests Again**
   ```bash
   vitest run
   ```

   All tests should now pass.

## When to Update Snapshots

**✅ Update when:**
- Component output intentionally changed
- UI text updated
- Data structure evolved
- New fields added to responses

**❌ Don't update when:**
- Test is legitimately failing
- Changes are bugs, not features
- You haven't reviewed the diff
- Updates are purely to make tests pass

## Snapshot Best Practices

1. **Review before updating** - Always check the diff
2. **Update selectively** - Only update relevant snapshots
3. **Keep snapshots small** - Snapshot specific parts, not entire pages
4. **Commit snapshot updates** - Include in same commit as code changes
5. **Document why** - Explain snapshot updates in commit message

## Example Workflow

```bash
# Make code change
vim src/components/Button.js

# Run tests (snapshots fail)
vitest run

# Review diff
git diff tests/__snapshots__/

# Update if changes are correct
vitest run -u

# Verify tests pass
vitest run

# Commit together
git add src/components/Button.js tests/__snapshots__/
git commit -m "Update button text (updated snapshots)"
```

## After Updating

- All snapshot tests pass
- Changes reviewed and verified
- Snapshots committed to version control
- Team notified of snapshot updates
