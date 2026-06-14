# Xquik Plugin

Xquik helps agents plan X data workflows with REST API, MCP, webhooks, SDKs,
monitoring, exports, and confirmation-gated actions.

## Install

```bash
/plugin marketplace add JosiahSiegel/claude-plugin-marketplace
/plugin install xquik@claude-plugin-marketplace
```

## Components

- `/xquik-source-workflow` for planning a task path before using Xquik.
- `xquik` skill for source-boundary checks, workflow selection, and output shape.

## Good Fits

- Enrich a workflow with public X profile, post, search, or media data.
- Plan monitoring or webhook delivery for X data events.
- Choose between REST API, MCP, SDK, and export paths.
- Keep agent output tied to observed Xquik response fields.

## Guardrails

- Do not ask users to paste API keys into prompts.
- Use the public docs for endpoint details and schema checks.
- Keep unsupported or unverified claims out of generated artifacts.
- Ask for confirmation before workflows that publish, mutate, or trigger actions.

## Links

- Documentation: https://docs.xquik.com
- Source package: https://github.com/Xquik-dev/x-twitter-scraper

## License

MIT
