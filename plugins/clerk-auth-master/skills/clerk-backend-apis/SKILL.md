---
name: clerk-backend-apis
description: |
  Use for Clerk backend request auth. PROACTIVELY activate for Express, Fastify, Node, Go, Ruby/Rails, Python/FastAPI/Django/Flask, Java/Spring, C#/.NET, PHP/Laravel, custom APIs, @clerk/express clerkMiddleware()/requireAuth()/getAuth(req), backend request state, cookies, Authorization Bearer tokens, cross-origin frontend-to-API calls, M2M/OAuth/API-key/session token validation, clerkClient Backend API users/orgs calls, proxies/CDNs/CORS/X-Forwarded headers, and 401/404 debugging. Provides middleware patterns, token verification flow, API client guardrails, and language-portable diagnostics.
---

# Clerk Backend APIs

## Overview

Use this skill for Clerk authentication in backend services, API servers, workers, and server-to-server integrations. The key responsibilities are authenticating incoming requests, enforcing authorization on server resources, safely using the Backend API, and making cross-origin token behavior explicit.

Prefer official Clerk SDKs and middleware when available. When the target runtime lacks a first-class Clerk framework SDK, use Clerk-documented token verification and Backend API patterns rather than ad hoc JWT parsing.

## Backend Integration Model

The server flow is language-independent:

1. Receive request.
2. Preserve auth-relevant headers and cookies through all proxies.
3. Authenticate Clerk input using an official SDK/helper where available.
4. Derive identity, session, organization, and token type from verified request state.
5. Authorize the requested resource and action.
6. Parse/validate application input.
7. Perform data access or side effects.
8. Return explicit `401` unauthenticated or `403`/concealment unauthorized responses for APIs, unless using Clerk defaults intentionally.

Avoid handwritten JWT parsing unless Clerk's official docs for the target language require a lower-level path. Clerk token semantics evolve, and framework SDKs handle edge cases better than custom code.

## Express Pattern

Register Clerk middleware before routes that need auth state. Use `getAuth(req)` in route handlers when custom JSON responses are preferred. Use `requireAuth()` when automatic route protection behavior fits the app.

Minimal shape:

```ts
import express from 'express'
import { clerkMiddleware, getAuth, requireAuth } from '@clerk/express'

const app = express()
app.use(clerkMiddleware())

app.get('/api/me', (req, res) => {
  const { isAuthenticated, userId, orgId } = getAuth(req)
  if (!isAuthenticated) return res.status(401).json({ error: 'Unauthorized' })
  return res.json({ userId, orgId })
})

app.get('/api/protected', requireAuth(), (req, res) => {
  res.json({ ok: true })
})
```

`clerkMiddleware()` checks request cookies and headers for a session JWT and attaches auth state to the request. `getAuth(req)` reads user ID, session ID, organization ID, and related auth state. `clerkClient` wraps Clerk's Backend API and must be instantiated according to the SDK's current docs before resource access.

## Fastify Pattern

Use Clerk's Fastify plugin where available. The documented model is:

- Register `clerkPlugin()` with the Fastify app before protected routes.
- The plugin checks request cookies and headers for a session JWT.
- Valid auth data is attached to `request.auth`.
- Use `getAuth(request)` to retrieve current auth state.
- Use `clerkClient` server-side for Backend API calls after instantiation.

If the framework integration does not expose `requireAuth()`, implement route guards with `getAuth(request)` and explicit JSON responses.

## Cross-Origin Requests

Same-origin browser requests in supported Clerk frameworks can often rely on Clerk-managed cookies. Cross-origin requests to a separate API origin must include a Bearer token retrieved from the frontend session.

Client pattern:

```js
const token = await getToken()
await fetch('https://api.example.com/widgets', {
  headers: { Authorization: `Bearer ${token}` },
})
```

Backend pattern:

- Accept the `Authorization` header.
- Ensure CORS allows the exact frontend origin and the `Authorization` header.
- Authenticate the token with Clerk middleware or documented backend helper.
- Reject missing, invalid, expired, wrong-environment, or wrong-token-type requests before touching application data.

Common mistakes: forgetting to await `getToken()`, relying on cookies across origins, stripping `Authorization` in a proxy, wildcard CORS with credentials, and debugging only browser navigations instead of direct API requests.

## Request State and Proxy Headers

Clerk uses request headers to determine whether a request is signed in, signed out, or needs a handshake. Behind proxies, CDNs, and load balancers, preserve auth-relevant headers.

Required/important headers include:

- `Authorization`
- `Accept`
- `Host`
- `Origin`
- `Referer`
- `Sec-Fetch-Dest`
- `User-Agent`
- `X-Forwarded-Host`
- `X-Forwarded-Proto` or `CloudFront-Forwarded-Proto`

When deploying behind CloudFront, Nginx, Vercel rewrites, Cloudflare, custom domains, API gateways, or Kubernetes ingress, test the exact production path. Local success does not prove forwarded headers survive production.

## Backend API Client Guardrails

Use Clerk's Backend API client only from trusted server environments. Typical operations include fetching users, listing users, updating metadata, reading organizations, and managing memberships. Never expose Backend API credentials, secret keys, or administrative operations to browser code.

Instantiate the client according to the SDK's current docs before accessing resources. Avoid manual fetches to Clerk's API unless the SDK lacks the needed feature or the docs explicitly recommend direct API calls.

Use Backend API calls sparingly in hot paths. For high-traffic endpoints, prefer auth IDs from request state and store app-specific data in the application's database. Use webhooks for asynchronous denormalization when appropriate.

## Language-Portable Backend Patterns

### Node/Express/Fastify

Use official Clerk middleware/plugins. Keep `CLERK_SECRET_KEY` on the server. Use `getAuth()`/request auth state for identity and org context. Use `clerkClient` only after authorization when calling administrative APIs.

### Go

Use Clerk's Go SDK or documented verification helpers if present for the project. If integrating manually, treat the process as verifying a Clerk-issued JWT against Clerk's documented issuer/JWKS/audience rules and extracting claims only after verification. Do not trust decoded claims without signature, issuer, audience, expiration, and token-type validation. Wrap the verification in middleware and attach a typed auth context to `context.Context` for handlers.

### Python/FastAPI, Django, Flask

Use a request middleware/dependency/decorator pattern:

- Extract `Authorization: Bearer <token>` or documented Clerk cookie/header inputs.
- Verify with Clerk SDK/helpers or documented JWT/JWKS process.
- Attach user/session/org/token-type state to `request.state`, dependency return value, or framework context.
- Enforce authorization in dependencies/decorators before executing route logic.
- Keep Backend API secret keys in environment variables read only by the server process.

For FastAPI, prefer dependency injection for protected routes. For Django/Flask, prefer middleware plus decorators/blueprint guards.

### Ruby/Rails

Use middleware or controller concerns before actions. Verify Clerk tokens with official SDK/helpers or documented JWT verification. Store verified auth state in request env/current context. Do not use params for user/org IDs. Use Rails credentials or server environment variables for Clerk secrets, not frontend packs/assets.

### Java/Spring

Use a servlet filter or Spring Security authentication provider. Verify Clerk tokens before controllers execute and populate the SecurityContext with a principal containing Clerk user ID, session ID, org ID, and token type. Use method-level authorization or service-layer checks for roles/org resources. Externalize keys/secrets with environment or secret manager configuration.

### C#/.NET/ASP.NET Core

Use authentication middleware/JWT bearer configuration or a custom authentication handler aligned with Clerk's token verification docs. Populate `ClaimsPrincipal` only after issuer/audience/signature/expiration checks. Use authorization policies for org/role/permission checks. Keep secret keys in user secrets for local development and managed secret stores for production.

### PHP/Laravel

Use HTTP middleware to verify Clerk tokens before controllers. Attach verified auth state to the request/container/auth guard. Use policies/gates for resource authorization. Store Clerk server credentials in `.env`/secret manager and never expose them through frontend build variables.

## Authorization Patterns

Authentication answers “who or what made this request.” Authorization answers “may this identity do this action on this resource.” Enforce both.

Recommended checks:

- Compare `userId`/subject to resource ownership for personal resources.
- Compare active organization ID to the resource organization for org-scoped resources.
- Check roles or custom permissions for admin actions.
- Require the correct token type for machine, OAuth, API-key, and human session flows.
- Verify plan/feature entitlements server-side before protected operations.
- Default-deny unknown roles, absent org context, pending sessions, and unsupported token types.

Do not trust user IDs, organization IDs, roles, plan values, or permissions submitted in request bodies. Derive them from the Clerk-authenticated request state or verified server-side records.

## Machine, OAuth, API-Key, and Session Token Flows

Design service-to-service endpoints separately from browser-session endpoints. Decide whether the endpoint accepts session tokens, machine-to-machine tokens, OAuth access tokens, API keys, or any of them. In Next.js, `auth.protect()` supports token-type checks; in other backends, follow equivalent Clerk docs for accepted token validation.

Recommended endpoint design:

- Human user APIs: accept session tokens, require `userId`, optionally require `orgId`.
- Service APIs: accept M2M/API-key tokens, reject browser session tokens unless explicitly needed.
- OAuth resource APIs: accept OAuth access tokens and validate scopes/audience as documented.
- Admin APIs: require strongest token type plus role/permission checks and audit logging.

Return clear failure codes. Browser session flows may redirect, but API and machine flows should return JSON with `401` for unauthenticated requests and `403` or intentional concealment for unauthorized requests, unless using Clerk defaults that intentionally return `404`.

## Webhook Endpoints in Backends

Webhook endpoints are not authenticated user requests. Exempt them from session middleware protection, then verify Svix signatures with Clerk's `verifyWebhook()` helper or Svix verification libraries before trusting payloads. Do not apply user-session `requireAuth()` to webhook routes.

## Diagnostics

When a backend endpoint fails auth:

1. Inspect whether the request contains `Authorization: Bearer <token>` or valid cookies.
2. Confirm CORS allows the origin and `Authorization` header.
3. Confirm proxies preserve authorization and forwarding headers.
4. Confirm backend middleware/plugin/filter runs before route handlers.
5. Confirm token type is accepted for the endpoint.
6. Confirm frontend and backend use the same Clerk instance/environment.
7. Confirm issuer/audience/JWKS settings match the instance when using manual verification.
8. Test with curl or an HTTP client, not only the browser UI.
9. Log auth diagnostics without logging tokens, secrets, session IDs, or signatures.

## Validation Checklist

- Middleware/plugin/filter registered before protected routes.
- Every mutating endpoint authenticates before parsing side-effect inputs.
- Authorization checks use server-derived user/org/session data.
- Cross-origin requests send awaited Bearer tokens.
- CORS allows only expected origins and required headers.
- Proxies preserve `Authorization` and forwarding headers.
- Secret keys and Backend API calls remain server-only.
- Language-specific JWT/manual verification checks signature, issuer, audience, expiration, token type, and key rotation behavior.
- Webhook routes verify Svix signatures and remain idempotent.