# Hermes Tweet Plugin

Hermes Tweet guides Claude Code users through installing, configuring, and safely operating the Hermes Tweet plugin for Hermes Agent X/Twitter workflows through Xquik.

## Installation

Add this marketplace, then install the plugin:

```bash
/plugin marketplace add JosiahSiegel/claude-plugin-marketplace
/plugin install hermes-tweet@claude-plugin-marketplace
```

Install the Hermes Agent runtime package separately:

```bash
pipx install hermes-tweet
hermes plugin install hermes-tweet
```

Set the API key in your local shell or secret manager:

```bash
export XQUIK_API_KEY="your-key"
```

Enable action tools only when you intend to post or engage:

```bash
export HERMES_TWEET_ENABLE_ACTIONS=1
```

## Components

- `hermes-tweet-knowledge`: install, routing, safety, and troubleshooting guidance for Hermes Tweet.

## Workflow

1. Use `tweet_explore` first to inspect available operations and examples.
2. Use `tweet_read` for authenticated read workflows after `XQUIK_API_KEY` is set.
3. Use `tweet_action` only after confirming the target account, payload, and desired action.
4. Keep keys in local environment variables or a secret manager. Never commit credentials.

## Troubleshooting

- Missing key: set `XQUIK_API_KEY` before read or action tools.
- Action unavailable: set `HERMES_TWEET_ENABLE_ACTIONS=1` only for the session that needs it.
- Install drift: reinstall from PyPI with `pipx install --force hermes-tweet`.
- Public automation: avoid private tokens, unpublished plans, and account-specific secrets in prompts or logs.

## License

MIT
