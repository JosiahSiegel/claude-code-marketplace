---
name: clerk-nextjs-auth
description: |
  Use for Clerk in Next.js. PROACTIVELY activate for @clerk/nextjs setup, App Router auth()/currentUser(), clerkMiddleware(), proxy.ts/middleware.ts, createRouteMatcher(), protected pages/layouts/Route Handlers/Server Actions/API routes/tRPC, auth.protect() role/permission/token checks, ClerkProvider placement, server-only clerkClient, Link prefetch, redirects, 401/404 auth failures, custom domains, __clerk proxy paths, and deployment gotchas. Provides file patterns, server/client boundary rules, matcher templates, and production checks.
---

# Clerk Next.js Auth

## Overview

Use this skill for Clerk integrations in Next.js projects, especially App Router projects using `@clerk/nextjs`. Focus on correct file placement, protected-route coverage, server/client boundaries, and modern Clerk middleware behavior.

## Quick Reference

| Need | Preferred Clerk primitive |
|---|---|
| Wrap app with auth context and prebuilt components | `ClerkProvider` |
| Read auth state in App Router server code | `auth()` from `@clerk/nextjs/server` |
| Read current user object in App Router server code | `currentUser()` from `@clerk/nextjs/server` |
| Protect routes before rendering | `clerkMiddleware()` + `auth.protect()` |
| Group protected/public routes | `createRouteMatcher()` |
| Pages Router API auth | `getAuth(req)` |
| Administrative Backend API calls | `clerkClient` from server-only code |
| Client UI state | `useUser()`, `useAuth()`, `useClerk()` |

## Setup Pattern

Install the official package and wire environment variables from the Clerk Dashboard. Clerk recommends CLI setup with `npx clerk@latest init --framework next` when scaffolding from scratch, but always verify the resulting files against the project's Next.js version and repo conventions.

Place `ClerkProvider` in the root layout for App Router apps. Keep it near the top of the React tree so prebuilt components and hooks can access Clerk context. Use client hooks only inside client components.

Use `proxy.ts` at the project root or `src/proxy.ts` for current Next.js projects. Use `middleware.ts` for Next.js 15 and older projects that still require middleware naming. The implementation is otherwise the same. Do not blindly create both files.

## Middleware and Route Protection

Start with the rule that surprises most teams: `clerkMiddleware()` does not protect any route by default. Add explicit protection logic.

Use `createRouteMatcher()` to declare route groups. Prefer positive matchers for high-risk surfaces, such as dashboard pages and mutating APIs. Use an inverted public-route matcher only after confirming every public route is listed.

Common matcher coverage:

- Skip Next.js internals and common static files.
- Always include API/TRPC surfaces when API auth is required, such as `/(api|trpc)(.*)`.
- Include Clerk frontend API proxy paths such as `/__clerk/(.*)` when using Clerk proxying.
- Include any custom Clerk proxy path.
- Include route groups that look public but call Server Actions or Route Handlers with private side effects.

Use `await auth.protect()` when default Clerk behavior is acceptable. Use `const { isAuthenticated, redirectToSignIn } = await auth()` when custom JSON responses, logging, or redirects are required.

## Auth and Authorization Behavior

`auth()` is App Router server-only and requires `clerkMiddleware()`. Use it in Server Components, Route Handlers, and Server Actions. It returns the request's Auth object and `redirectToSignIn()`.

`auth.protect()` can enforce:

- Signed-in access.
- Roles, permissions, and custom `has()` authorization logic.
- Feature and plan checks where enabled.
- Accepted token types such as `session_token`, `oauth_token`, `api_key`, `m2m_token`, or `any`.

Failure behavior matters in tests:

- Authenticated and authorized returns auth state.
- Authenticated but unauthorized returns `404` by default.
- Unauthenticated document requests redirect to sign-in.
- Unauthenticated non-document/API requests with session token defaults can return `404`.
- Unauthenticated machine-token requests can return `401`.

Use `unauthenticatedUrl` and `unauthorizedUrl` only when the resulting behavior is intentional for both browser navigation and API callers.

## App Router Server APIs

Use `auth()` when only IDs, session state, active organization, token retrieval, or authorization checks are needed. Use `currentUser()` only when the full user object is needed because it can add Backend API work.

For token retrieval, use `getToken()` from the Auth object and always await it. Use a custom JWT template only when an external service requires it; otherwise prefer the default session token or server-side Clerk auth state.

In Route Handlers, call `auth()` or `auth.protect()` at the top. Authenticate and authorize before input parsing that can trigger costly work or side effects. For organization-scoped resources, compare the active organization ID to the resource's organization owner before mutating.

In Server Actions, call `auth()` or `auth.protect()` inside the action, not only in the page that renders the form. Server Actions can be invoked independently from the original UI state.

When a page needs auth-only rendering, protect at the page/layout level or in middleware. Use middleware when the app should avoid rendering work for signed-out users.

## Server/Client Boundary Rules

Keep these boundaries strict:

- Use `auth()`, `currentUser()`, `clerkClient`, Backend API operations, and secret keys only on the server.
- Use `useUser()`, `useAuth()`, `useSignIn()`, `useSignUp()`, and prebuilt UI components in client components.
- Treat client hooks as UI state, not final authorization.
- Avoid passing full user records into client components unless every field is intentionally exposed.
- Keep `CLERK_SECRET_KEY`, `CLERK_WEBHOOK_SIGNING_SECRET`, and `CLERK_ENCRYPTION_KEY` server-only. Client code should use publishable keys only.

## Environment Variables

Common Next.js Clerk variables:

- `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY`: browser-safe publishable key.
- `CLERK_SECRET_KEY`: server-only Backend API credential.
- `NEXT_PUBLIC_CLERK_SIGN_IN_URL`, `NEXT_PUBLIC_CLERK_SIGN_UP_URL`: app route paths for auth UI.
- `NEXT_PUBLIC_CLERK_SIGN_IN_FALLBACK_REDIRECT_URL`, `NEXT_PUBLIC_CLERK_SIGN_UP_FALLBACK_REDIRECT_URL`: post-auth fallback destinations.
- `NEXT_PUBLIC_CLERK_SIGN_IN_FORCE_REDIRECT_URL`, `NEXT_PUBLIC_CLERK_SIGN_UP_FORCE_REDIRECT_URL`: force destinations when product flow requires it.
- `CLERK_WEBHOOK_SIGNING_SECRET`: endpoint-specific webhook secret for API route handlers.
- `CLERK_ENCRYPTION_KEY`: required when middleware options include a `secretKey`.

Production keys use `pk_live_` and `sk_live_`; development keys use `pk_test_` and `sk_test_`. Never mix them.

## Organizations and Permissions

Use Clerk organization context deliberately. Check the active organization ID when protecting organization resources. For authorization, prefer explicit role/permission checks that match Clerk's semantics.

Important nuance: server-side `has()` works for Custom Permissions. System Permissions are not available in session token claims, so check roles where Clerk requires it. Do not assume every Dashboard permission string is valid in every server-side check.

Default-deny unknown roles, missing active organization, pending sessions, and absent permissions. Avoid fallback logic that treats “no organization selected” as organization access unless that is an intentional product rule.

## Custom Domains, Proxying, and CSP

When using a custom Clerk Frontend API domain or proxy:

- Ensure the middleware matcher includes `/__clerk/(.*)` or the configured custom proxy path.
- In App Router, a literal `__clerk` route folder must be named `%5F%5Fclerk`.
- If using route handlers for proxying, do not assume `proxyUrl` is automatically derived; configure it as Clerk documents for the selected approach.
- Test production host headers and forwarded proto/host headers, not just localhost.
- If the app uses CSP, add Clerk script/connect/frame/img/style directives according to Clerk's current CSP guide and the SDK components used.

## Production Gotchas

- Add `prefetch={false}` on public-page `Link`s pointing to protected pages if prefetching causes failed auth requests or noisy console errors.
- Enable Clerk middleware `{ debug: true }` only in development or temporary diagnostics.
- For custom domains, proxy URLs, and multi-tenant dynamic keys, test in an environment that matches production host headers.
- Dynamic keys such as `signUpUrl`, `signInUrl`, `secretKey`, and `publishableKey` supplied through middleware are not client-accessible through middleware.
- If passing `secretKey` through middleware options, configure `CLERK_ENCRYPTION_KEY` as Clerk requires.
- Do not use a dev Clerk instance for production preview of OAuth, DNS, custom domains, or webhooks when behavior depends on production instance settings.

## Troubleshooting Matrix

| Symptom | Likely check |
|---|---|
| Protected route is public | `clerkMiddleware()` present but no `auth.protect()` or route matcher |
| API returns `404` instead of `401` | Clerk authorization failure behavior or session-token API failure semantics |
| `auth()` unavailable or empty | Missing `clerkMiddleware()`/proxy, wrong file name for Next version, matcher excluded route |
| Client hook crashes | Component is not wrapped in `ClerkProvider` or hook runs before loaded state |
| Production sign-in loops | Mixed keys, redirect URL mismatch, missing forwarded headers, domain/DNS misconfiguration |
| Protected link logs fetch errors | Next `Link` prefetch to protected route; use `prefetch={false}` |
| System permission check fails | Server-side `has()` cannot see system permission claims; check roles |

## Validation Checklist

- Confirm every protected page, layout, Server Action, Route Handler, API route, and tRPC route is covered by middleware or in-route guard.
- Test signed-out, signed-in unauthorized, signed-in authorized, wrong organization, pending session, and wrong token type.
- Test direct API calls, not only browser navigation.
- Verify production environment variables, DNS, domain, OAuth, webhook, and redirect settings.
- Confirm no server-only imports appear in client components.
- Confirm no secret keys or webhook signing secrets appear in bundled client code or public environment variables.
- Inspect production request headers for `Authorization`, `Host`, `Origin`, `Referer`, `User-Agent`, `X-Forwarded-Host`, and `X-Forwarded-Proto`/`CloudFront-Forwarded-Proto` when auth state differs from local.