---
name: clerk-frontend-sdks
description: |
  Use for Clerk frontend auth flows. PROACTIVELY activate for React, JavaScript, Vue, Nuxt, Astro, Expo, React Router, TanStack React Start, or SPA setup; ClerkProvider and publishable-key wiring; SignIn/SignUp/UserButton/UserProfile/OrganizationSwitcher; custom useUser/useAuth/useClerk/useSignIn/useSignUp/useSession/useOrganization flows; multi-session UX; cross-origin getToken() fetches; loading states, redirects, routing, CORS/cookies, or hydration bugs. Provides SDK selection, UI patterns, token-fetch templates, and frontend gotchas.
---

# Clerk Frontend SDKs

## Overview

Use this skill for client-side Clerk integration across React and other frontend frameworks. The main job is choosing the correct framework SDK, wiring provider context, selecting prebuilt UI vs custom flows, handling environment-specific redirects, and avoiding the mistake of treating client auth state as server authorization.

## SDK Selection

Prefer the dedicated framework SDK when one exists:

| App type | Preferred package/pattern |
|---|---|
| Next.js | `@clerk/nextjs` |
| React app without a stronger integration | `@clerk/react` |
| React Router framework | Clerk React Router SDK/patterns |
| TanStack React Start | Clerk TanStack integration |
| Astro | Clerk Astro integration |
| Nuxt/Vue | Clerk Nuxt/Vue integration |
| Expo/mobile | Clerk Expo/mobile integration |
| Plain JavaScript/non-React | ClerkJS |

Selecting the wrong SDK causes routing, SSR, hydration, and token propagation bugs. Check the package already installed before adding another package.

## Provider and Environment Setup

Wire the frontend provider near the root of the app. The provider should receive a publishable key or use the framework SDK's environment-variable convention. Never pass a secret key, webhook signing secret, or Backend API credential to browser code.

Use development and production Clerk instances deliberately. Auth bugs often come from mixing a development publishable key with production domains, production redirect URLs, production Backend API secrets, or production webhooks.

Provider-level options and environment variables must align with Clerk Dashboard URLs:

- Sign-in route/path.
- Sign-up route/path.
- After-sign-in and after-sign-up fallback/force redirects.
- Allowed origins/domains.
- OAuth redirect and callback settings for production providers.
- Custom domain/proxy settings when used.

## Prebuilt Components vs Custom Flows

Prefer Clerk prebuilt components for standard auth UX:

- Sign in and sign up pages or modals.
- User button and account management.
- User profile and organization profile.
- Organization switcher and organization list flows.
- Multi-session account switching when supported by the chosen UI.

Use custom flows when the product requires bespoke screens, progressive onboarding, embedded verification, or custom routing. For custom flows, use the specific sign-in/sign-up hooks and handle intermediate states explicitly. Do not assume a single submit call completes every flow; verification steps, MFA, passkeys, SSO, email codes, phone codes, OAuth, and pending session tasks can add state transitions.

## Hook Selection

Use hooks by purpose:

| Need | Hook |
|---|---|
| Current user object and loading state | `useUser()` |
| Auth status, user ID, session ID, token retrieval | `useAuth()` |
| Open modals, sign out, client methods | `useClerk()` |
| Custom sign-in flow | `useSignIn()` |
| Custom sign-up flow | `useSignUp()` |
| Active session details | `useSession()` |
| Multiple sessions | `useSessionList()` |
| Active organization | `useOrganization()` |
| Organization list/switching/creation | `useOrganizationList()` |

Always handle loading and unavailable states. Many frontend bugs are null-reference bugs caused by reading `user`, `session`, or `organization` before Clerk finishes loading.

## Cross-Origin API Calls

Same-origin requests in supported framework integrations can often rely on Clerk-managed cookies. Cross-origin requests require a session token sent as a Bearer token.

Use this pattern in client code:

```js
const { getToken } = useAuth()
const token = await getToken()

const res = await fetch('https://api.example.com/resource', {
  headers: {
    Authorization: `Bearer ${token}`,
  },
})

if (!res.ok) {
  throw new Error(`Request failed: ${res.status}`)
}
```

Plain JavaScript with ClerkJS uses the active session, conceptually:

```js
const token = await Clerk.session.getToken()
```

Keep the gotchas attached to the code:

- `getToken()` returns a Promise; always `await` it.
- `fetch()` does not throw for non-2xx responses; check `res.ok`.
- Do not log tokens or store them in localStorage/sessionStorage.
- Do not put tokens in URLs.
- Do not send tokens to origins that do not need them.
- Do not use a client token to perform privileged Backend API operations in the browser.
- Ensure the backend CORS policy allows the frontend origin and the `Authorization` header.

## CORS, Cookies, and Same-Origin Assumptions

For same-origin app/API routes, Clerk-managed cookies usually provide the session token automatically. For a separate API origin, browsers do not automatically send a useful Clerk session to that API unless the architecture and cookie settings explicitly support it. Prefer Bearer-token authorization for cross-origin APIs.

When cross-origin requests fail:

- Verify the request includes `Origin` and `Authorization`.
- Verify the API responds with `Access-Control-Allow-Origin` for the exact frontend origin, not `*` when credentials are used.
- Verify `Access-Control-Allow-Headers` includes `Authorization` and `Content-Type`.
- Verify any CDN or API gateway forwards `Authorization`.
- Verify frontend and backend use the same Clerk instance/environment.

## Routing and Redirects

Configure sign-in and sign-up URLs consistently across the SDK, environment variables, routes, and Clerk Dashboard. When implementing protected client-side routes, use client checks for UX only; enforce access on the server/API too.

For SPAs, guard route rendering with loading-aware logic:

- Loading: show a skeleton/spinner, not protected data.
- Signed out: redirect or render sign-in UI.
- Signed in but no active organization: show organization selection if the route requires an org.
- Signed in but unauthorized: show a non-sensitive access-denied UI and ensure the API also returns denial.

Avoid flashes where protected content renders before auth status is known. For SSR frameworks, prefer server-side or middleware protection where available.

## Organizations and Multi-Session UX

When organization features are enabled, design for active organization selection. UI may have a signed-in user but no active organization. Organization switching can change authorization for the same route, so fetch organization-scoped data after the active organization is known and cancel/refetch stale requests on org changes.

For applications that allow multiple sessions, use session-list APIs deliberately. Make active-session switching visible and test sign-out behavior for one session vs all sessions.

## Custom Sign-In/Sign-Up Flow Guardrails

For custom flows:

- Model sign-in/sign-up as a state machine, not one form submit.
- Handle verification strategies, MFA, passkeys, SSO redirects, first-factor and second-factor requirements, and pending sessions.
- Avoid storing password or OTP values longer than the current request.
- Handle rate limiting and bot/abuse responses gracefully.
- Do not bypass Clerk's recommended verification steps to simplify UI.
- Redirect only to allowlisted return URLs; do not create open redirects.

## Frontend Security Boundaries

Treat frontend Clerk state as presentation state. Any operation that reads private data, mutates data, changes billing, changes roles, changes organization membership, or performs admin work needs server-side authorization.

Do not embed sensitive authorization logic solely in hidden buttons, disabled UI, or client route guards. Users can call APIs directly.

Do not expose:

- `CLERK_SECRET_KEY` or equivalent Backend API secret.
- Webhook signing secrets.
- M2M credentials or API-key management secrets.
- Server-only `clerkClient` operations.
- Private metadata that should not be visible to the user.

## Development and Preview Environments

Use environment-specific publishable keys and redirect URLs. Preview deployments often have different hostnames; verify they are allowed by the correct Clerk instance and do not accidentally use production secrets. For OAuth in production, configure provider-owned credentials rather than relying on development/shared Clerk credentials.

## Troubleshooting Checklist

- Confirm the app uses the framework-specific Clerk SDK.
- Confirm provider placement wraps all components that call Clerk hooks.
- Confirm publishable key and allowed domains match the environment.
- Check loading states before reading user/session/org objects.
- For cross-origin calls, inspect the request for `Authorization: Bearer <token>`.
- Confirm CORS allows the origin and `Authorization` header.
- Confirm client redirects match routes, environment variables, and Clerk Dashboard settings.
- Confirm organization-scoped views refetch on active organization changes.
- Confirm production OAuth providers and redirect URLs are configured in the provider and Clerk Dashboard.
- Confirm CSP permits Clerk scripts, frames, connections, images, and styles required by the chosen components.