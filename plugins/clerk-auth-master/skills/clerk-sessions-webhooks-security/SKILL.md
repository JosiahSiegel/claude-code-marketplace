---
name: clerk-sessions-webhooks-security
description: |
  Use for Clerk sessions, tokens, webhooks, orgs, and security. PROACTIVELY activate for session tokens, JWT templates, getToken(), custom claims, pending sessions, multi-session UX, organizations, roles, permissions, system vs custom permissions, features/plans, MFA/passkeys/password policy/bot protection, Clerk webhooks, Svix signatures, verifyWebhook(), user/org sync, retries/replays, environment variables, custom domains, secret rotation, logs, and auth security reviews. Provides token semantics, webhook idempotency, authorization defaults, and hardening checklist.
---

# Clerk Sessions, Webhooks, and Security

## Overview

Use this skill for Clerk's security-sensitive surfaces: sessions, JWTs, token retrieval, organizations and authorization, webhook synchronization, environment separation, and production hardening. Prioritize trust boundaries and replay-safe design.

## Sessions and Tokens

Distinguish the token or session type before writing code:

| Surface | Use |
|---|---|
| Session token | Authenticates a signed-in user session |
| Custom JWT template | Supplies custom claims for an external service integration |
| API key | Authenticates an application/user-created key where Clerk supports API keys |
| OAuth token | Authenticates OAuth access flows where enabled |
| Machine-to-machine token | Authenticates service-to-service requests |

Use `getToken()` from the relevant Clerk auth object or hook to retrieve a session token or custom JWT template where supported. Always await it. Do not store tokens in localStorage, log them, embed them in URLs, or send them to origins that do not need them.

Treat pending sessions deliberately. Some Clerk APIs treat pending sessions as signed out by default (`treatPendingAsSignedOut` defaults to true in relevant server APIs). If a flow includes session tasks, MFA, verification, or other pending states, design UI and server behavior for “not fully signed in yet.”

## Custom JWT Templates

Use custom JWT templates when an external service needs a token with particular claims, audience, or shape. Keep templates minimal. Include only claims the recipient needs, and avoid duplicating sensitive profile fields.

On the consuming service, validate according to Clerk's current docs and the service's expectations:

- Signature/JWKS.
- Issuer.
- Audience.
- Expiration/nbf.
- Token type/template.
- Organization context where relevant.

When a custom JWT contains organization or role context, ensure the active organization at token issuance matches the resource being accessed. Avoid long-lived authorization decisions based solely on stale claims when roles, memberships, plans, or permissions can change.

## Token Time Claims and Clock Skew

Clerk session tokens and custom JWT templates include `iat`, `nbf`, and `exp`. Verifiers reject tokens with reason `token-not-active-yet` when `nbf` is in the future, and `token-expired` when `exp` has passed. These failures are usually clock skew on the verifier, not real token problems. For full coverage (nbf/iat/exp semantics, Clerk's `clockSkewInMs` default of 5000 ms in `verifyToken`/`authenticateRequest`, multi-language leeway settings, container/WSL2/Docker Desktop time fix recipes, and a clock-skew-vs-real-expiry decision tree) load the dedicated `clerk-clock-skew-jwt` skill.

## Organizations, Roles, Permissions, Features, and Plans

Authorization must be explicit and organization-scoped where relevant. A signed-in user is not automatically authorized for every organization resource.

Recommended defaults:

- Require an active organization for organization resources.
- Check resource organization ownership against authenticated org context.
- Use roles or custom permissions for admin actions.
- Use plan/feature checks only where product entitlements are configured and enforce them server-side.
- Default-deny missing roles, unknown permissions, inactive memberships, unsupported plans, and absent organization context.
- Treat client-rendered role/plan/metadata data as advisory; enforce on the server.

Important nuance: server-side `has()` works for Custom Permissions. Clerk System Permissions are not in session token claims, so check the user's Role where Clerk requires it. Do not assume every Dashboard permission string is valid in every server-side check.

## Metadata Trust Boundaries

Clerk user data can include multiple metadata categories. Define source of truth before syncing or authorizing:

- Public metadata: visible to the frontend; do not store secrets.
- Private metadata: server-side privileged metadata; still avoid using it as the only source for high-risk authorization when freshness matters.
- Unsafe metadata: user-writable; treat as untrusted input.
- Application database fields: often best for app-specific profiles, audit state, and denormalized search/indexing.

Do not grant admin access from user-controlled metadata. For role and org authorization, use Clerk organization membership/role/permission state or trusted application records.

## Webhook Verification

Clerk webhooks are delivered through Svix. Treat every incoming webhook as forged until verification succeeds. Use Clerk's `verifyWebhook()` helper or Svix verification libraries as documented for the runtime.

Webhook rules:

1. Make the webhook route public with respect to user-session middleware; webhooks do not carry a user session.
2. Preserve the signed request payload in the form required by the verification helper/library.
3. Verify the Svix signature before parsing or trusting event data.
4. Reject missing or invalid signature headers.
5. Process only subscribed/expected event types.
6. Make handlers idempotent because retries and dashboard replays are normal.
7. Return `2xx` only after the event has been safely accepted or durably queued; `4xx`, `5xx`, or no response can trigger retries.
8. Return quickly; move slow work to queues where possible.
9. Consider restricting source IPs to Svix's published webhook IP ranges as defense in depth.

The event payload includes fields such as `type`, `data`, `object`, `timestamp`, and `instance_id`. For `user.*` events, `data` represents the Clerk User object. Billing events have their own docs and should be handled with the same verification and idempotency rules.

## Webhook Idempotency and Sync

Use webhooks for asynchronous synchronization, not synchronous onboarding gates. Clerk documents webhooks as asynchronous and eventually consistent; delivery can fail, retry, or be replayed. A user should not be unable to proceed solely because a webhook has not populated an application database row yet.

Persist a durable processed-event record or deterministic checkpoint before side effects. Common patterns:

- `clerk_webhook_events(event_id unique, type, instance_id, received_at, processed_at, status)` for event deduplication.
- Upsert users by Clerk user ID for `user.created` and `user.updated`.
- Soft-delete, tombstone, or mark inactive on `user.deleted` instead of destructive cascades unless explicitly required and recoverable.
- Upsert organizations by Clerk organization ID for organization events.
- Upsert organization memberships by Clerk membership ID or `(org_id, user_id)` depending on payload guarantees.
- Store the Clerk `instance_id` when multiple Clerk instances or environments can hit the same infrastructure.
- Queue slow downstream work after verification and dedupe.

Design for out-of-order updates by storing Clerk `updated_at`/event timestamp checkpoints when available. Do not let an older replay overwrite newer application state.

## User and Organization Sync Scope

Only sync data the application needs. Avoid cloning the entire Clerk user object into the database by default. Common useful fields:

- Clerk user ID.
- Primary email ID/address if needed.
- Display name/avatar if needed.
- Created/updated/deleted timestamps.
- Instance/environment ID.
- Organization ID, name, slug, membership role for org-scoped apps.

Never sync secrets or tokens. Treat emails and profile data as personal data subject to deletion/export obligations.

## Environment Variables and Secret Rotation

Common Clerk environment categories:

- Publishable key: safe for client bundle (`pk_test_` or `pk_live_`).
- Secret key: server-only Backend API credential (`sk_test_` or `sk_live_`).
- Webhook signing secret: server-only, endpoint-specific (`whsec_...`).
- Encryption key: server-only when required by dynamic middleware secret-key usage.
- Sign-in/sign-up URLs and redirect URLs: must align with framework routes and Clerk Dashboard.
- Proxy/custom domain settings: must align with production hosts and forwarded headers.

Keep development, staging, preview, and production instances separate when the risk profile requires it. Never mix a production secret key with a development publishable key. Rotate secrets after accidental exposure and review logs for token leakage.

Rotation checklist:

1. Identify every deployment and secret store using the old value.
2. Add the new secret in the platform/secret manager.
3. Deploy/restart all consumers.
4. Validate auth, webhooks, and Backend API calls.
5. Revoke/remove the old secret.
6. Search logs/artifacts for accidental leakage.

## Account Security Features

Choose account security controls based on product risk:

- MFA for admin, billing, organization-owner, or high-risk users.
- Passkeys where supported for phishing-resistant sign-in.
- Strong password policy when password auth is enabled.
- Bot protection or abuse controls on public sign-up and sign-in surfaces.
- Email/phone verification where account trust requires it.
- SSO/SAML/OIDC for enterprise customers where applicable.
- Session lifetime and reauthentication policies appropriate to sensitive actions.

Apply the strongest checks to endpoints that change roles, memberships, secrets, billing, API keys, or organization settings.

## Monitoring and Incident Response

Monitor:

- Spike in sign-in/sign-up failures.
- Webhook failure/retry counts.
- 401/403/404 auth failures by route and environment.
- Backend API rate-limit/error responses.
- CORS preflight failures.
- Secret/key mismatch errors after deploys.
- Organization role/membership change audit trails.

Log enough request context to debug without leaking secrets: route, environment, Clerk instance ID, user ID/org ID when verified, token type, status code, and correlation ID. Redact tokens, session IDs, cookies, webhook signatures, and secret keys.

## Security Hardening Checklist

- Enforce MFA/passkeys/password policy according to risk level.
- Enable bot protection or abuse controls on public sign-up surfaces when appropriate.
- Protect role/member management endpoints with the strongest checks.
- Treat all user-controlled metadata as untrusted unless written only by trusted server code.
- Do not use webhooks as authorization enforcement for the live request path.
- Do not grant access from cached plan/role fields without validating current user/org context where risk is high.
- Redact tokens, secrets, session IDs, cookies, and webhook signatures from logs.
- Add replay-safe tests for webhooks and unauthorized-access tests for APIs.
- Test secret rotation and webhook replay in non-production before relying on the runbook.

## Review Procedure

For a Clerk security review:

1. Inventory auth entry points: middleware/proxy, route handlers, APIs, server actions, backend services, webhooks, workers, and cron jobs.
2. List token types accepted by each endpoint.
3. Verify route protection coverage and authorization logic.
4. Check environment variables, key prefixes, domains, DNS, redirects, and CSP settings.
5. Inspect webhook verification, dedupe, and replay handling.
6. Confirm server-only secrets are not imported into client bundles.
7. Confirm backend language integrations verify tokens with official helpers or full JWT validation.
8. Test signed-out, wrong-org, wrong-role, pending-session, wrong-token-type, replayed-webhook, expired-token, and mixed-environment scenarios.