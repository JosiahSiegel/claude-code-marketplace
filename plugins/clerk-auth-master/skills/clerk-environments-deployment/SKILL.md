---
name: clerk-environments-deployment
description: |
  Use for Clerk dev/prod readiness, deployment, and multi-language implementation planning. PROACTIVELY activate for environment variables, pk_test/sk_test vs pk_live/sk_live, local dev, preview/staging/prod instances, domains/DNS, redirects, OAuth credentials, custom domains/proxy, authorizedParties, CSP, CORS/cookies, webhooks/tunnels, Vercel/Netlify/Cloudflare/API gateways, monitoring/troubleshooting, and backends in Node/Express/Fastify, Python/FastAPI/Django/Flask, Go, Ruby/Rails, Java/Spring, .NET, PHP/Laravel. Provides checklists, rollout plans, and language-portable patterns.
---

# Clerk Environments, Deployment, and Multi-Language Checklists

## Overview

Use this skill when the task is broader than a single framework: development vs production setup, deployment readiness, custom domains, DNS, redirects, CORS/cookies, webhooks, CSP, monitoring, incident response, or multi-language backend architecture.

Clerk integrations often work locally and fail in production because keys, domains, redirects, OAuth credentials, webhook secrets, proxy headers, or CSP are environment-specific. Treat environment design as part of the auth implementation, not a deployment afterthought.

## Environment Model

Use separate Clerk instances for development and production. For staging/preview, decide explicitly whether to use a separate staging Clerk instance or a constrained development instance. Avoid sharing a production instance with untrusted preview URLs unless there is a strong reason and hardened allowlists.

Key prefixes are a fast sanity check:

| Key type | Development | Production | Exposure |
|---|---|---|---|
| Publishable key | `pk_test_...` | `pk_live_...` | Client-safe |
| Secret key | `sk_test_...` | `sk_live_...` | Server-only |
| Webhook signing secret | `whsec_...` | `whsec_...` per endpoint/instance | Server-only |
| Encryption key | random secret | random secret | Server-only |

Never mix `pk_test_` with `sk_live_`, `pk_live_` with `sk_test_`, or webhook secrets from another endpoint/instance.

## Local Development Checklist

- Use `.env.local`/local secret storage for dev keys only.
- Confirm framework variable names: e.g. `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` for Next.js client exposure and `CLERK_SECRET_KEY` for server-only use.
- Configure local sign-in/sign-up routes and fallback redirects.
- Use the Clerk CLI where useful: setup/init, env pull, and deploy status checks.
- For webhooks, expose the local app with a tunnel and create a development webhook endpoint using the tunnel URL.
- Keep local webhook signing secrets separate from production secrets.
- Test signed-out, signed-in, wrong-role, wrong-org, and webhook replay flows locally.
- Do not commit `.env` files, logs with tokens, or tunnel URLs that imply private infrastructure.
- Confirm NTP is enabled on the dev host and inside any Docker/WSL2 containers; clock drift causes spurious `token-not-active-yet`/`token-expired` errors. For container time resync recipes (WSL2 `timedatectl`, Docker Desktop restart, `docker exec date -s`), load the `clerk-clock-skew-jwt` skill.

## Preview and Staging Checklist

Preview deployments introduce dynamic hosts. Decide how those hosts map to Clerk settings.

- Use non-production keys for untrusted preview branches.
- Configure allowed origins/redirect URLs for the preview host pattern where the platform and Clerk support it.
- Avoid giving every preview URL production OAuth credentials or production webhook access.
- Confirm cross-origin APIs accept the preview origin in CORS.
- Confirm cookies and SameSite behavior match the preview domain topology.
- If previews call a shared backend, ensure the backend accepts only the intended Clerk instance(s) and token issuers.
- Keep preview webhook endpoints separate, or route them to isolated test queues/databases.

## Production Launch Checklist

Before going live:

1. Create or select a production Clerk instance.
2. Set production environment variables in the hosting platform; do not deploy with development keys.
3. Configure production domains in Clerk Dashboard.
4. Add required DNS records for session management and domain-verified emails.
5. Replace development/shared OAuth credentials with provider-owned production credentials.
6. Configure sign-in/sign-up URLs, after-auth fallback/force redirects, and allowed redirect origins.
7. Configure production webhook endpoints and use the production endpoint's signing secret.
8. Configure custom domain/proxy settings if the app cannot use Clerk's Frontend API CNAME.
9. Add CSP directives for Clerk scripts, frames, connections, images, and styles if CSP is enabled.
10. Configure subdomain allowlists and `authorizedParties` for cross-subdomain safety.
11. Verify reverse proxies/CDNs forward auth-relevant headers.
12. Run direct API tests with and without Bearer tokens.
13. Run a webhook delivery/replay test.
14. Verify logs redact tokens, cookies, session IDs, webhook signatures, and secret keys.
15. Document rollback steps and secret-rotation steps.

Clerk production keys use `pk_live_` and `sk_live_`. DNS propagation can take time, so schedule domain validation before launch.

## Domains, DNS, Custom Domains, and Proxying

Production Clerk domains require DNS access. Clerk uses DNS records for session management and domain-verified emails. If using Cloudflare, certain Clerk validation records may need DNS-only mode so validation can complete.

When a Frontend API CNAME cannot be added, use Clerk's documented proxy option. Validate:

- Frontend SDK points at the correct proxy/custom domain.
- Next.js middleware/proxy matchers include `/__clerk/(.*)` or the custom proxy path.
- Reverse proxy preserves `Host`, `Origin`, `Referer`, `Authorization`, `User-Agent`, `X-Forwarded-Host`, and `X-Forwarded-Proto`/`CloudFront-Forwarded-Proto`.
- HTTPS terminates consistently and forwarded proto is correct.
- The app does not cache Clerk auth/proxy responses incorrectly.

For subdomains, setting a root domain can enable sessions across subdomains. Configure a subdomain allowlist and `authorizedParties` to reduce cross-subdomain risk.

## Redirects and OAuth

Redirects are an auth security boundary. Validate:

- Sign-in/sign-up routes exist in the app.
- Fallback redirect URLs are safe and expected.
- Force redirect URLs are used only when product flow requires them.
- Return-back behavior cannot be abused as an open redirect.
- OAuth provider redirect/callback URLs match the production Clerk instance and production domain.
- Production OAuth apps use the product's own provider credentials, not development/shared Clerk credentials.
- SSO/SAML/OIDC connections are configured separately for production tenants where applicable.

## CORS, Cookies, and API Topology

Choose one request model per API surface:

### Same-origin app/API

- Use Clerk framework integration and cookies.
- Protect route handlers/API routes server-side.
- Do not manually pass session tokens unless needed.

### Cross-origin browser-to-API

- Frontend calls `await getToken()`.
- Send `Authorization: Bearer <token>`.
- API CORS allows exact frontend origin and `Authorization` header.
- API verifies token with Clerk SDK/helper or documented JWT validation.
- Proxy/CDN forwards `Authorization`.

### Server-to-server

- Prefer M2M/API-key/OAuth token type where Clerk supports it.
- Do not reuse human session tokens for service identity.
- Validate token type, audience/scope, and issuer.
- Audit privileged service calls.

## CSP Checklist

If the app uses Content Security Policy, update it for Clerk features in use:

- Script sources for Clerk frontend scripts.
- Connect sources for Clerk APIs and proxied endpoints.
- Frame sources for embedded auth UI or OAuth flows when needed.
- Image sources for avatars/profile assets.
- Style/font directives if prebuilt components require them.

Keep CSP as narrow as possible and verify in report-only mode before enforcing in production.

## Multi-Language Backend Implementation Matrix

Use official SDKs/middleware where available. For unsupported framework combinations, follow Clerk's documented token verification rules and the same server-side trust boundary.

| Runtime | Recommended shape | Common failure |
|---|---|---|
| Node/Express | `@clerk/express` `clerkMiddleware()`, `getAuth(req)`, `requireAuth()` | Middleware registered after routes |
| Node/Fastify | Clerk Fastify `clerkPlugin()`, `request.auth`, `getAuth(request)` | Assuming Express APIs exist in Fastify |
| Next.js | `@clerk/nextjs` `auth()`, `currentUser()`, `auth.protect()` | `clerkMiddleware()` installed but no protection logic |
| Python/FastAPI | Dependency verifies token and returns auth context | Decoding JWT without verification or missing CORS Authorization header |
| Python/Django/Flask | Middleware/decorator verifies token and attaches auth state | Trusting user ID from request body |
| Go | HTTP middleware verifies token and stores auth in `context.Context` | Ignoring issuer/audience/key rotation |
| Ruby/Rails | Rack/controller concern verifies token and sets current auth | Leaking server secrets to assets/frontend env |
| Java/Spring | Servlet filter/Spring Security provider populates SecurityContext | Treating any valid JWT as a Clerk token without issuer/audience checks |
| C#/.NET | JWT bearer/custom auth handler populates ClaimsPrincipal and policies | Missing token-type/org authorization policies |
| PHP/Laravel | HTTP middleware verifies token; policies/gates enforce resource access | Using client-submitted org/user IDs for authorization |

Manual verification must validate signature, issuer, audience/authorized party as applicable, expiration, not-before, token type, and key rotation behavior. Claims are untrusted until all checks pass.

## Authorization Readiness Checklist

For each protected resource, define:

- Who can access it: user, organization member, admin, machine client, OAuth client.
- Which token types are accepted.
- Whether an active organization is required.
- Which role/custom permission/plan/feature is required.
- Whether system permissions require role checks instead of `has()`.
- Whether cached app database fields are authoritative or denormalized only.
- What response is returned for signed-out vs unauthorized requests.
- What audit logs are written for privileged changes.

Default-deny unknown roles, absent org context, wrong token type, pending sessions, stale memberships, and missing entitlements.

## Webhook Deployment Checklist

- Use the production instance's webhook endpoint URL and signing secret in production.
- Exempt webhook route from user-session protection but verify Svix signature.
- Subscribe only to needed event types.
- Store processed event IDs or deterministic checkpoints for idempotency.
- Queue slow work.
- Return `2xx` only after durable accept/queue.
- Test retry and replay from the Dashboard.
- Monitor failure/retry counts.
- Optionally restrict source IPs to Svix's published webhook IP ranges.

## Monitoring and Troubleshooting Runbook

When auth breaks after deployment:

1. Check key prefixes and instance IDs: dev vs prod mismatch is common.
2. Check domain/DNS status in Clerk Dashboard.
3. Check redirect URL and OAuth provider callback mismatch.
4. Inspect network requests for cookies or `Authorization: Bearer`.
5. Inspect CORS preflight response for origin and allowed headers.
6. Confirm reverse proxy/CDN forwards `Authorization` and forwarded host/proto headers.
7. Confirm middleware/proxy matcher includes the failing route.
8. Confirm webhook endpoint uses the correct signing secret.
9. Confirm CSP is not blocking Clerk scripts/connect/frame requests.
10. Confirm unauthorized `404` is not being mistaken for missing route.
11. Test with a direct HTTP client and a freshly retrieved token.
12. Temporarily enable Clerk middleware debug only in a safe non-production or controlled diagnostic window.

Log route, environment, Clerk instance ID, user/org IDs only after verification, token type, status, and correlation ID. Redact tokens, cookies, session IDs, secret keys, and webhook signatures.

## Rollback and Secret Incident Checklist

If a Clerk secret or token leaks:

1. Remove the leaked value from code/logs/artifacts where possible.
2. Rotate the affected secret in Clerk Dashboard or secret manager.
3. Update all deployments and workers.
4. Redeploy/restart consumers.
5. Validate sign-in, API auth, Backend API calls, and webhooks.
6. Revoke the old secret.
7. Review access logs for suspicious use.
8. Add tests or scanner rules to prevent recurrence.

If a production deploy breaks auth:

- Roll back the application deploy if code/matcher/CSP caused it.
- Revert environment variables only if you know the previous values are not compromised.
- Prefer fixing DNS/redirect/OAuth settings in Clerk/provider dashboards when the app build is correct.
- Keep webhook endpoints returning safe retryable failures rather than accepting unverified events.