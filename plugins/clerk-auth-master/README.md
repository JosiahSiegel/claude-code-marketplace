# Clerk Auth Master Plugin

Comprehensive Clerk authentication plugin for Claude Code, covering Next.js, React and JavaScript frontends, multi-language backend APIs, sessions, JWT templates, organizations, webhooks, development and production environments, and production security.

## Features

### Agent

- **Clerk Auth Expert** - Specialized agent for designing, implementing, debugging, and reviewing Clerk authentication systems across frontend frameworks, backend frameworks, environments, and deployment targets.

### Skills

- **Clerk Next.js Auth** - App Router, `auth()`, `currentUser()`, `clerkMiddleware()`, `proxy.ts`, route matchers, protected routes, Route Handlers, Server Actions, `clerkClient`, custom domains, and Next.js deployment gotchas.
- **Clerk Frontend SDKs** - React, JavaScript, SPA, mobile/frontend SDK selection, provider setup, prebuilt components, hooks, multi-session UX, organization UX, custom flows, redirects, and cross-origin token fetches.
- **Clerk Backend APIs** - Express, Fastify, Node, Go, Ruby/Rails, Python/FastAPI/Django/Flask, Java/Spring, C#/.NET, PHP/Laravel, Bearer tokens, middleware, request state, Backend API client usage, proxies, CORS, and API auth debugging.
- **Clerk Sessions, Webhooks, and Security** - Session tokens, JWT templates, organizations, roles, permissions, features/plans, MFA, passkeys, bot protection, Svix webhook verification, idempotent user/org sync, secret rotation, monitoring, and production hardening.
- **Clerk Environments, Deployment, and Multi-Language Checklists** - Development vs production instances, key separation, local/preview/prod deployments, domains/DNS, redirects, OAuth credentials, custom domains/proxy, CSP, CORS/cookies, webhooks, monitoring, and language-portable backend implementation patterns.

## Usage

The plugin activates for Clerk-related auth tasks, including:

- "Add Clerk to my Next.js App Router app and protect dashboard routes."
- "Implement a Clerk-authenticated Express API for my React frontend."
- "Verify Clerk session tokens in a FastAPI service."
- "Review this Clerk webhook handler for security and idempotency."
- "Use Clerk organizations and roles to protect an admin route."
- "Debug why my cross-origin API call is unauthenticated."
- "Prepare my Clerk app for production with custom domains, OAuth, webhooks, and CSP."

## Installation

```bash
/plugin marketplace add JosiahSiegel/claude-plugin-marketplace
/plugin install clerk-auth-master@JosiahSiegel
```

For local development from this repository, install the plugin from the marketplace checkout using Claude Code's plugin commands.

## Compatibility

- Clerk Next.js SDK (`@clerk/nextjs`)
- Clerk React SDK and framework-specific frontend SDKs
- Clerk Express and Fastify SDKs
- Backend SDK/API/token verification patterns for Node, Go, Ruby, Python, Java, .NET, and PHP ecosystems
- Next.js App Router and supported Pages Router legacy patterns
- Svix-backed Clerk webhooks
- Development, preview/staging, and production Clerk instance workflows

## Notes

This plugin summarizes official Clerk documentation into implementation guidance and emphasizes production gotchas. For rapidly changing SDK APIs, token verification details, and framework-specific middleware behavior, the agent should consult current Clerk docs before generating version-sensitive code.

## License

MIT
