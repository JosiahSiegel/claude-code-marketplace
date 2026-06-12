---
name: hermes-tweet-knowledge
description: |
  This skill should be used when users ask to install, configure, or operate Hermes Tweet, the Hermes Agent plugin for X/Twitter automation through Xquik. PROACTIVELY activate for Hermes Agent X/Twitter workflows, tweet_explore, tweet_read, tweet_action, XQUIK_API_KEY setup, social monitoring, public-safe research, and action-gated posting or engagement.
  Provides: install commands, capability routing, environment setup, action-safety guardrails, and troubleshooting checks.
---

# Hermes Tweet Knowledge

Use this skill for Hermes Tweet setup and safe X/Twitter automation through Hermes Agent. For generic Claude Code plugin development, use `plugin-master`.

## Quick setup

1. Install the runtime package:

   ```bash
   pipx install hermes-tweet
   hermes plugin install hermes-tweet
   ```

2. Configure authenticated reads and actions:

   ```bash
   export XQUIK_API_KEY="your-key"
   ```

3. Enable actions only for sessions that need posting or engagement:

   ```bash
   export HERMES_TWEET_ENABLE_ACTIONS=1
   ```

## Capability routing

- `tweet_explore`: inspect supported operations, examples, and setup requirements first.
- `tweet_read`: use for authenticated X/Twitter read workflows after `XQUIK_API_KEY` is available.
- `tweet_action`: use for posting or engagement only after `XQUIK_API_KEY` and `HERMES_TWEET_ENABLE_ACTIONS=1` are set.

## Safety checklist

1. Confirm the account, target URL or handle, and exact payload before actions.
2. Keep credentials in the local shell or a secret manager. Never paste or commit keys.
3. Treat public prompts, logs, README files, issue comments, and PR bodies as public communication.
4. Use read-only workflows for research unless the user explicitly asks for posting or engagement.
5. Re-run `tweet_explore` after upgrades to confirm current operation names and requirements.

## Troubleshooting

- `XQUIK_API_KEY` missing: set it before `tweet_read` or `tweet_action`.
- Actions disabled: set `HERMES_TWEET_ENABLE_ACTIONS=1` only in the active shell session.
- Runtime not found: reinstall with `pipx install --force hermes-tweet`.
- Plugin missing from Hermes Agent: run `hermes plugin install hermes-tweet` again and restart the agent session.
