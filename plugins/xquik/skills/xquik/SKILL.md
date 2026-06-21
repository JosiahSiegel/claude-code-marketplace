---
name: xquik
description: |
  Xquik X data workflow skill. PROACTIVELY activate for: (1) X profile, post, search, media, monitoring, export, or webhook tasks, (2) agent workflows that need X data through Xquik, (3) choosing between REST API, MCP, SDK, and export paths, (4) planning confirmation-gated actions. Provides: source-boundary checks, workflow routing, public docs validation, output-shape planning, and confirmation boundaries.
---

# Xquik

Use this skill when a task needs X data through Xquik.

## Workflow

1. Classify the task.
   - Profile or account lookup
   - Post or thread lookup
   - Search or trend collection
   - Media handling
   - Monitor or webhook delivery
   - SDK, MCP, or REST integration
   - Confirmation-gated action
2. Pick the Xquik surface.
   - REST API for direct application integration.
   - MCP for agent tool access.
   - SDKs when the host app already has a matching language runtime.
   - Webhooks for async delivery.
   - Exports for offline review or downstream analysis.
3. Check source truth.
   - Use https://docs.xquik.com for endpoint names, required inputs, and response fields.
   - Do not invent fields, limits, pricing, or private routing details.
   - Keep generated artifacts tied to observed response contracts.
4. Plan credentials safely.
   - Never ask users to paste API keys into prompts.
   - Refer to environment variables or the host application's credential store.
   - Keep example values synthetic.
5. Separate read-only and action steps.
   - Treat lookups, searches, exports, and monitoring setup as distinct steps.
   - Ask for explicit confirmation before any workflow that publishes, mutates, or triggers an action.

## Output Shape

Return a short implementation plan:

- Goal
- Recommended Xquik surface
- Required inputs
- Expected response or event shape
- Confirmation boundary
- Validation step

## Validation

Before presenting code or instructions:

- Confirm the cited Xquik docs page exists.
- Confirm the workflow does not rely on unsupported claims.
- Confirm no credential values or private implementation details appear.
- Confirm write-like steps are opt-in and confirmation-gated.
