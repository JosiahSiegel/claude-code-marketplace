---
name: Xquik Source Workflow
description: Plan an Xquik-backed X data workflow with source checks, output shape, and confirmation boundaries
argument-hint: "[goal or workflow]"
---

# Xquik Source Workflow

Use the `xquik` skill to plan the workflow.

## Inputs

- User goal or automation task
- Required X data type: profile, post, search, media, monitor, export, or action
- Desired output: JSON, file export, webhook event, agent summary, or SDK call

## Process

1. Identify whether REST API, MCP, SDK, export, or webhook fits best.
2. Check the public docs for endpoint shape and required fields.
3. Keep the plan bound to observed response fields.
4. Separate read-only lookups from workflows that publish, mutate, or trigger actions.
5. Ask for explicit confirmation before any non-read-only step.

## Output

Return a concise plan with:

- Recommended Xquik surface
- Required inputs
- Expected output shape
- Confirmation boundary
- Validation step
