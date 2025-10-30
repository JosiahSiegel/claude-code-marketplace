---
description: Test Claude Code plugin structure, validation, and functionality with automated checks
---

# Test Plugin

Comprehensive testing workflow for Claude Code plugins before publishing.

## Purpose

Validate plugin structure, manifests, components, and cross-platform compatibility to ensure production-ready quality.

## Testing Workflow

### 1. Structural Validation

Check plugin directory structure and required files:

```bash
# Verify plugin root structure
if [[ ! -f .claude-plugin/plugin.json ]]; then
    echo "ERROR: plugin.json not found in .claude-plugin/"
    exit 1
fi

# Check for at least one component type
if [[ ! -d commands ]] && [[ ! -d agents ]] && [[ ! -d skills ]] && [[ ! -d hooks ]]; then
    echo "WARNING: No component directories found (commands/, agents/, skills/, hooks/)"
fi

echo "✓ Plugin structure valid"
```

### 2. Manifest Validation

Validate plugin.json schema and required fields:

```bash
# Check JSON validity
if ! cat .claude-plugin/plugin.json | jq . > /dev/null 2>&1; then
    echo "ERROR: Invalid JSON in plugin.json"
    exit 1
fi

# Verify required fields
NAME=$(cat .claude-plugin/plugin.json | jq -r '.name')
if [[ "$NAME" == "null" ]] || [[ -z "$NAME" ]]; then
    echo "ERROR: 'name' field required in plugin.json"
    exit 1
fi

# Check author field structure (must be object, not string)
AUTHOR_TYPE=$(cat .claude-plugin/plugin.json | jq -r 'type(.author)')
if [[ "$AUTHOR_TYPE" == "string" ]]; then
    echo "ERROR: 'author' must be an object { \"name\": \"...\" }, not a string"
    exit 1
fi

# Check version format (must be string)
VERSION_TYPE=$(cat .claude-plugin/plugin.json | jq -r 'type(.version)')
if [[ "$VERSION_TYPE" != "string" ]]; then
    echo "ERROR: 'version' must be a string (e.g., \"1.0.0\"), not a number"
    exit 1
fi

# Check keywords format (must be array)
KEYWORDS_TYPE=$(cat .claude-plugin/plugin.json | jq -r 'type(.keywords)')
if [[ "$KEYWORDS_TYPE" == "string" ]]; then
    echo "ERROR: 'keywords' must be an array [\"word1\", \"word2\"], not a string"
    exit 1
fi

echo "✓ Manifest validation passed"
```

### 3. Component Validation

Check commands, agents, and skills structure:

```bash
# Validate commands
if [[ -d commands ]]; then
    for cmd in commands/*.md; do
        if [[ -f "$cmd" ]]; then
            # Check for frontmatter
            if ! head -1 "$cmd" | grep -q "^---$"; then
                echo "WARNING: $cmd missing frontmatter"
            fi
        fi
    done
    echo "✓ Commands validated"
fi

# Validate agents
if [[ -d agents ]]; then
    for agent in agents/*.md; do
        if [[ -f "$agent" ]]; then
            # Agents require specific frontmatter
            if ! grep -q "^name:" "$agent" && ! grep -q "^agent:" "$agent"; then
                echo "WARNING: $agent missing name or agent field in frontmatter"
            fi
        fi
    done
    echo "✓ Agents validated"
fi

# Validate Agent Skills
if [[ -d skills ]]; then
    for skill_dir in skills/*/; do
        if [[ -d "$skill_dir" ]]; then
            if [[ ! -f "${skill_dir}SKILL.md" ]]; then
                echo "ERROR: ${skill_dir} missing SKILL.md file"
                exit 1
            fi
            # Check skill frontmatter
            if ! grep -q "^name:" "${skill_dir}SKILL.md"; then
                echo "ERROR: ${skill_dir}SKILL.md missing 'name' in frontmatter"
                exit 1
            fi
            if ! grep -q "^description:" "${skill_dir}SKILL.md"; then
                echo "ERROR: ${skill_dir}SKILL.md missing 'description' in frontmatter"
                exit 1
            fi
        fi
    done
    echo "✓ Agent Skills validated"
fi
```

### 4. Portability Check

Ensure no hardcoded paths or user-specific information:

```bash
# Check for common path issues
if grep -r "C:\\\\" . 2>/dev/null | grep -v ".git" | grep -v "node_modules"; then
    echo "ERROR: Found Windows hardcoded paths (C:\\)"
    exit 1
fi

if grep -r "/Users/" . 2>/dev/null | grep -v ".git" | grep -v "node_modules" | grep -v "example"; then
    echo "WARNING: Found macOS user paths (/Users/)"
fi

if grep -r "/home/" . 2>/dev/null | grep -v ".git" | grep -v "node_modules" | grep -v "example"; then
    echo "WARNING: Found Linux user paths (/home/)"
fi

# Check for ${CLAUDE_PLUGIN_ROOT} usage in hooks/MCP
if [[ -f .claude-plugin/plugin.json ]]; then
    if grep -q "hooks" .claude-plugin/plugin.json || grep -q "mcpServers" .claude-plugin/plugin.json; then
        if ! grep -q "\${CLAUDE_PLUGIN_ROOT}" .claude-plugin/plugin.json; then
            echo "WARNING: Consider using \${CLAUDE_PLUGIN_ROOT} for portable paths in hooks/MCP servers"
        fi
    fi
fi

echo "✓ Portability check passed"
```

### 5. Documentation Check

Verify README and documentation completeness:

```bash
if [[ ! -f README.md ]]; then
    echo "WARNING: README.md not found - highly recommended"
else
    # Check for essential sections
    if ! grep -q "Installation" README.md; then
        echo "WARNING: README.md missing Installation section"
    fi
    if ! grep -q "Usage" README.md; then
        echo "WARNING: README.md missing Usage section"
    fi
    echo "✓ README.md found"
fi

# Check for license
if [[ ! -f LICENSE ]] && [[ ! -f LICENSE.md ]]; then
    LICENSE_IN_JSON=$(cat .claude-plugin/plugin.json | jq -r '.license')
    if [[ "$LICENSE_IN_JSON" == "null" ]]; then
        echo "WARNING: No LICENSE file or license field in plugin.json"
    fi
fi
```

### 6. Marketplace Compatibility

If in marketplace repository, validate marketplace.json entry:

```bash
# Check if in marketplace repo
if [[ -f ../../.claude-plugin/marketplace.json ]]; then
    PLUGIN_NAME=$(cat .claude-plugin/plugin.json | jq -r '.name')

    # Check if plugin is registered in marketplace
    if ! cat ../../.claude-plugin/marketplace.json | jq -e ".plugins[] | select(.name == \"$PLUGIN_NAME\")" > /dev/null; then
        echo "ERROR: Plugin '$PLUGIN_NAME' not registered in marketplace.json"
        exit 1
    fi

    # Check version consistency
    PLUGIN_VERSION=$(cat .claude-plugin/plugin.json | jq -r '.version')
    MARKETPLACE_VERSION=$(cat ../../.claude-plugin/marketplace.json | jq -r ".plugins[] | select(.name == \"$PLUGIN_NAME\") | .version")

    if [[ "$PLUGIN_VERSION" != "$MARKETPLACE_VERSION" ]]; then
        echo "ERROR: Version mismatch between plugin.json ($PLUGIN_VERSION) and marketplace.json ($MARKETPLACE_VERSION)"
        exit 1
    fi

    echo "✓ Marketplace registration validated"
fi
```

## Complete Test Script

Run all checks with a single script:

```bash
#!/bin/bash

echo "=== Plugin Testing Suite ==="
echo ""

# Run all validation steps
echo "1. Structural Validation..."
# [Insert step 1 code]

echo ""
echo "2. Manifest Validation..."
# [Insert step 2 code]

echo ""
echo "3. Component Validation..."
# [Insert step 3 code]

echo ""
echo "4. Portability Check..."
# [Insert step 4 code]

echo ""
echo "5. Documentation Check..."
# [Insert step 5 code]

echo ""
echo "6. Marketplace Compatibility..."
# [Insert step 6 code]

echo ""
echo "=== All Tests Passed! ==="
echo "Plugin is ready for local testing or publishing"
```

## Local Testing

After validation, test the plugin locally:

### Mac/Linux
```bash
# Copy to plugins directory
cp -r . ~/.local/share/claude/plugins/$(basename $PWD)

# Or create symlink for development
ln -s $(pwd) ~/.local/share/claude/plugins/$(basename $PWD)

# Test in Claude Code
claude
/plugin list
/help
```

### Windows (via GitHub)
```bash
# Create test repository
# Upload plugin files
# Make repository public
/plugin marketplace add YOUR_USERNAME/YOUR_TEST_REPO
/plugin install your-plugin@YOUR_USERNAME
/help
```

## Cross-Platform Testing Checklist

- [ ] Test on Windows (via GitHub marketplace)
- [ ] Test on macOS (local or GitHub)
- [ ] Test on Linux (local or GitHub)
- [ ] Commands appear in /help
- [ ] Agents appear in /agents
- [ ] Skills load correctly
- [ ] Hooks execute as expected
- [ ] MCP servers start successfully
- [ ] No hardcoded paths
- [ ] README renders correctly
- [ ] No sensitive information exposed

## Continuous Integration

Add automated testing to your plugin CI/CD:

```yaml
name: Plugin Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Validate Plugin
        run: |
          cd plugins/your-plugin
          bash test-plugin.sh
```

## Best Practices

1. **Test Early**: Validate structure before investing time in content
2. **Automate**: Use the test script in CI/CD pipelines
3. **Cross-Platform**: Always test on target platforms
4. **Version Sync**: Ensure plugin.json and marketplace.json versions match
5. **Portability**: Use ${CLAUDE_PLUGIN_ROOT} for all internal paths
6. **Documentation**: Maintain comprehensive README with examples
7. **Security**: Never commit secrets or sensitive information

## Next Steps

After testing passes:
1. Increment version if needed
2. Update CHANGELOG if applicable
3. Test in real-world scenarios
4. Publish to marketplace or distribute to team
5. Monitor for issues and gather feedback
