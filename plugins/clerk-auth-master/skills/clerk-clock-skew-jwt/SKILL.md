---
name: clerk-clock-skew-jwt
description: |
  Use for Clerk JWT and session token clock-skew issues. PROACTIVELY activate for "token-not-active-yet", "JWT cannot be used prior to not before", token-expired, nbf/iat/exp claim failures, clockSkewInMs in verifyToken/authenticateRequest, local dev container/WSL2/Docker Desktop time drift, NTP misconfiguration, paused VM clock, serverless cold-start clock issues, custom JWT template verification leeway across Node/Python/Go/Ruby/Java/.NET/PHP, debugging iat vs server-time delta, and separating real expiry from clock skew. Provides nbf/iat/exp semantics, Clerk and library clock-tolerance defaults, container time fix recipes, multi-language leeway patterns, diagnostics, and gotchas.
---

# Clerk JWT and Clock Skew

## Overview

Clerk session tokens and custom JWT templates are signed JSON Web Tokens. The verifier always checks three time-based claims:

| Claim | Meaning | Failure error |
|---|---|---|
| `iat` (issued at) | When the token was minted | (rare) `invalid-iat` or `iat must be in the past` |
| `nbf` (not before) | Earliest moment the token is valid | `token-not-active-yet` (Clerk error `reason`) |
| `exp` (expiration) | Latest moment the token is valid | `token-expired` (Clerk error `reason`) |

Clock skew occurs when the verifier's wall clock is offset from the issuer's wall clock. If the verifier is behind, even freshly minted tokens fail `nbf`. If the verifier is ahead, long-lived tokens can fail `exp` early. Both directions break auth.

Clerk's own backend SDK applies a small tolerance (`clockSkewInMs` default `5000` ms) and the Dashboard exposes a session-level "Allowed Clock Skew" / `nbf` offset setting for JWT templates. Third-party libraries used to verify Clerk-issued JWTs have their own leeway settings; the safe defaults differ by library.

## Time Claims in Clerk Tokens

A decoded Clerk session token typically contains numeric epoch-second values for `iat`, `nbf`, and `exp`. Decode the JWT (without verification) at a tool like jwt.io to inspect them when diagnosing failures.

The verifier must check `nbf <= now + leeway` and `exp >= now - leeway`. A token that is "active" must satisfy both bounds. If `nbf > now` even by one second, the token is rejected with `token-not-active-yet`. If `exp < now`, the token is rejected with `token-expired`.

`iat` is informational; most libraries do not require it. Clerk's tokens do include `iat`, and some libraries (for example `golang-jwt/jwt v5`) require `WithIssuedAt()` to enable `iat` validation.

## Clerk SDK Clock Skew Configuration

Clerk's `verifyToken()` (in `@clerk/backend`, `@clerk/nextjs/server`, and equivalent) accepts a `clockSkewInMs` option. Documented default: `5000` (5 seconds). The same option is exposed to `authenticateRequest` for HTTP requests.

Conceptual shape (Node, TypeScript):

```ts
import { verifyToken } from '@clerk/backend'

const payload = await verifyToken(token, {
  secretKey: process.env.CLERK_SECRET_KEY!,
  clockSkewInMs: 5000,        // 5s tolerance for nbf/exp
  audience: 'my-api',
  authorizedParties: ['https://app.example.com'],
})
```

The Clerk Dashboard also exposes a session-token "Allowed Clock Skew" / `nbf` offset. Treat the Dashboard setting as the user-facing knob; treat `clockSkewInMs` in code as the same concept. Do not stack them to a large effective tolerance.

## Why Clock Skew Happens in Local Dev

Local development environments are the most common source of clock skew failures because clocks are sometimes virtualized, suspended, or never NTP-synced.

| Environment | Typical cause | Symptom |
|---|---|---|
| Bare-metal host | NTP disabled, firewall blocks UDP 123 | Host clock drifts seconds per day |
| WSL2 (Windows) | Hyper-V time sync not exposed; `hwclock` diverges from Windows host | Container time lags Windows time after sleep/resume |
| Docker Desktop (macOS/Windows) | VM clock paused while laptop sleeps | Containers wake with a stale clock |
| Linux container (Docker Engine) | No NTP inside the container; bind-mounts host time as a path | If host is wrong, container is wrong |
| Kubernetes pod | Some runtime images lack chrony/systemd-timesyncd | Drift after long-lived pods |
| CI runners (GitHub Actions, etc.) | Ephemeral VMs with no synced clock between jobs | `iat` may be milliseconds in the future |
| Serverless cold start (Lambda, Vercel, Cloudflare Workers) | Provider clock can differ slightly from yours; GC pauses cause skew | First request after cold start occasionally fails |
| Suspended/paused VM (VMware, VirtualBox, Hyper-V) | Wall clock stops on suspend, may jump on resume | Large skew after wake |
| Manual clock changes | Admin sets time forward or backward | Token issued at the new time is then re-verified against the old time |

Clerk mints tokens on its own servers (so its clock is NTP-disciplined). The local server verifying them is the variable side. Fix the verifying side's clock first; only adjust leeway as a secondary control.

## Fixing Container and Local Clocks

The remediation order matters. Always start with the clock; only add leeway after the clock is known-good.

### Verify the skew first

Capture the host time and the in-container time:

```bash
# Host
date -u +%s
date -u --iso-8601=seconds

# Inside a container
docker exec <container> date -u +%s
docker exec <container> date -u --iso-8601=seconds
```

If they differ by more than a few seconds, the container is the source of the problem. The same script works for `kubectl exec` against a pod.

### WSL2

WSL2 runs in a lightweight VM; its clock is independent of Windows unless explicitly synchronized. After the Windows host sleeps, WSL2 may resume with a stale clock.

```bash
# Inside WSL2
sudo hwclock -s                       # sync to hardware clock (may also be stale)
sudo chronyc tracking                 # check NTP sync state if chrony is installed
sudo ntpdate pool.ntp.org             # one-shot sync
sudo timedatectl status               # confirm NTP enabled
```

If `timedatectl` reports NTP inactive, enable it:

```bash
sudo timedatectl set-ntp true
```

If the underlying Windows clock is correct but WSL2 still drifts, restart the WSL2 VM from PowerShell:

```powershell
wsl --shutdown
wsl
```

### Docker Desktop

Docker Desktop on macOS and Windows runs an embedded Linux VM. Its clock is normally synced to the host, but pauses of the host (laptop sleep, suspended VM) leave the embedded VM with a stale time.

```bash
# Quick resync from inside the container
docker exec <container> date -s "$(date -u +%Y-%m-%dT%H:%M:%S)Z"

# Or restart Docker Desktop to fully reset the VM clock
# macOS: open the Docker Desktop UI and choose Troubleshoot -> Restart
# Windows: right-click tray icon -> Restart
```

The reliable fix is to keep the host awake (disable sleep) or restart Docker Desktop after long pauses.

### Linux containers without chrony

Many minimal images (`alpine`, `distroless`, `node:alpine`) lack a time-sync daemon. Bind-mount the host's `/etc/localtime` and ensure the host itself is NTP-synced:

```bash
# In the Dockerfile or docker run
-v /etc/localtime:/etc/localtime:ro
```

For deeper control, install a time-sync client inside the image:

```dockerfile
RUN apk add --no-cache tzdata chrony || apt-get update && apt-get install -y --no-install-recommends chrony
```

For Kubernetes, prefer a node-level `chrony` or `systemd-timesyncd`; do not try to NTP-sync inside every pod.

### CI runners

Ephemeral CI runners rarely have time-sync issues for short jobs, but multi-minute pauses (queued jobs, large checkout) can drift. Force a sync at job start:

```yaml
# GitHub Actions
- name: Sync clock
  run: sudo sntp -S time.cloudflare.com
```

If even after sync the test intermittently fails, capture `date -u +%s` at token-issue and token-verify time during the failing test; compare to the token's `nbf`/`iat`/`exp`. If the test environment cannot be fixed, gate test-only flows with a documented `clockSkewInMs` override.

### Serverless cold starts

Lambda, Vercel, and Cloudflare Workers generally have well-disciplined clocks. Skew is rare. If it occurs, capture the cold-start time and token `nbf` from a log line; if the difference is reproducible, raise an issue with the provider and use `clockSkewInMs` as a temporary buffer.

## Leeway Settings by Library

When verifying Clerk-issued tokens outside Clerk's own helpers, configure the library's leeway explicitly. Defaults are not consistent and not always large enough.

### Node.js: `jsonwebtoken`

`clockTolerance` is in seconds and applies to both `nbf` and `exp`. Default is `0`.

```js
import jwt from 'jsonwebtoken'

const claims = jwt.verify(token, publicKey, {
  algorithms: ['RS256'],
  clockTolerance: 30,           // 30 seconds
  issuer: 'https://clerk.<instance>.com',
  audience: 'my-api',
})
```

Pass a number, never a string. A string value causes silent concatenation bugs. Do not combine with `ignoreNotBefore: true` or `ignoreExpiration: true` in production.

### Node.js: `jose` (panva)

`clockTolerance` accepts a number of seconds or a string like `"30s"`, `"2m"`, `"1h"`. Use the string form for readability.

```ts
import { jwtVerify } from 'jose'
await jwtVerify(token, jwks, { clockTolerance: '30s' })
```

### Python: `PyJWT`

`leeway` is in seconds and applies to both `nbf` and `exp`. Default is `0`. Can also be a `timedelta`.

```python
import jwt
decoded = jwt.decode(
    token,
    key=public_key,
    algorithms=["RS256"],
    leeway=30,
    options={"require": ["exp", "iat"]},
    audience="my-api",
    issuer="https://clerk.<instance>.com",
)
```

Exceptions: `ExpiredSignatureError` (`exp`), `ImmatureSignatureError` (`nbf`), `InvalidIssuedAtError` (`iat`).

### Python: `python-jose`

`python-jose` accepts `leeway` (seconds) in its options. PyJWT is generally recommended for new code because python-jose is less actively maintained.

```python
from jose import jwt
decoded = jwt.decode(
    token,
    key=public_key,
    algorithms=["RS256"],
    options={"leeway": 30, "verify_exp": True, "verify_nbf": True},
    audience="my-api",
)
```

### Go: `golang-jwt/jwt/v5`

Use `jwt.WithLeeway(duration)` to add clock skew tolerance and `jwt.WithIssuedAt()` to enable `iat` validation. `WithExpirationRequired()` and `WithNotBeforeRequired()` enforce presence of the claims.

```go
token, err := jwt.ParseWithClaims(
    raw, &MyClaims{}, keyFunc,
    jwt.WithLeeway(30*time.Second),
    jwt.WithIssuedAt(),
    jwt.WithExpirationRequired(),
    jwt.WithIssuer("https://clerk.<instance>.com"),
    jwt.WithAudience("my-api"),
    jwt.WithValidMethods([]string{"RS256"}),
)
```

### Ruby: `jwt` gem

Use the `leeway` key (in seconds) in the options hash. The gem applies the same value to both `exp` and `nbf`. Despite older documentation references, prefer the single `:leeway` key.

```ruby
payload, _header = JWT.decode(
  token, public_key, true,
  algorithm: "RS256",
  leeway: 30,
  verify_iat: true,
  iss: "https://clerk.<instance>.com",
  aud: "my-api",
)
```

### Java: `Nimbus JOSE + JWT`

`DefaultJWTClaimsVerifier` exposes `setMaxClockSkew(int seconds)`. Default skew in Nimbus is `60` seconds. If you need to disable `iat` checks, set the verifier's required-claim set accordingly.

```java
JWTClaimsSet expected = new JWTClaimsSet.Builder()
    .issuer("https://clerk.<instance>.com")
    .audience("my-api")
    .build();

DefaultJWTClaimsVerifier<?> verifier =
    new DefaultJWTClaimsVerifier<>(expected, Set.of("sub", "exp", "iat"));
verifier.setMaxClockSkew(60); // 60 seconds

DefaultJWTProcessor<SecurityContext> processor = new DefaultJWTProcessor<>();
processor.setJWTClaimsSetVerifier(verifier);
```

### Java: `Auth0 java-jwt`

`JWTVerifier` exposes `acceptLeeway(long seconds)`.

```java
JWTVerifier verifier = JWT.require(Algorithm.RSA256(publicKey, null))
    .withIssuer("https://clerk.<instance>.com")
    .withAudience("my-api")
    .acceptLeeway(30)
    .build();
DecodedJWT decoded = verifier.verify(token);
```

### C# / .NET: `Microsoft.IdentityModel.Tokens`

`TokenValidationParameters.ClockSkew` is a `TimeSpan`. The Microsoft default is `5 minutes` (`TimeSpan.FromMinutes(5)`). For Clerk integrations this default is generous; reduce it to 30-60 seconds for tighter validation.

```csharp
var validationParams = new TokenValidationParameters
{
    ValidIssuer = "https://clerk.<instance>.com",
    ValidAudience = "my-api",
    IssuerSigningKeys = jwks,
    ValidateLifetime = true,
    ClockSkew = TimeSpan.FromSeconds(30),
    RequireExpirationTime = true,
};
```

### PHP: `firebase/php-jwt`

Set the static `JWT::$leeway` property in seconds. Applies to `exp` and `nbf` during `JWT::decode`.

```php
use Firebase\JWT\JWT;
use Firebase\JWT\Key;

JWT::$leeway = 30; // 30 seconds

$decoded = JWT::decode($jwt, new Key($publicKey, 'RS256'));
```

Avoid the deprecated `exp_leeway` / `nbf_leeway` keys.

## Diagnostics: Is It Really Clock Skew?

Clock skew and a legitimately expired token can both look like a 401 with a token error. Use this decision tree to separate them.

1. **Decode the token without verification** (a tool like jwt.io or your library's "decode only" call) and read `iat`, `nbf`, `exp`.
2. **Capture verifier time** at the moment of failure (`date +%s` or `Date.now()/1000`).
3. Compute deltas:
   - `nbf - now`: if greater than 0, the token is "not yet valid". A few seconds is clock skew; many minutes is wrong environment clock.
   - `now - exp`: if greater than 0, the token is expired. A few seconds is clock skew; a long positive value is a real expiry.
   - `now - iat`: if negative (token from the "future"), the issuer is ahead of the verifier.
4. Compare `nbf` to `iat`:
   - If `nbf == iat`, Clerk issued the token and made it immediately valid. A small `nbf > now` is purely verifier clock lag.
   - If `nbf > iat` by a configurable offset, the Dashboard "Allowed Clock Skew" / `nbf` offset is at play. Check the Dashboard.
5. **Check the local clock** on the verifier host and inside any containers (`date -u` and `docker exec <container> date -u`).
6. **Reproduce from a known-good machine**: open a shell on a server known to be NTP-synced and verify the same token. If it succeeds, the failing host's clock is the cause.
7. **Try a fresh token**: if a new `getToken()` call works, the old token's `exp` was crossed. If even a fresh token fails, the verifier clock is wrong.

The error reason is the single most useful piece of information. Look for:

- `token-not-active-yet` - `nbf` is in the future relative to verifier time.
- `token-expired` - `exp` is in the past relative to verifier time.
- `invalid-iat` - `iat` is in the future (rare; usually clock skew the other direction).
- `jwt-verification-failed` - signature, issuer, or audience mismatch; usually not clock skew.

## Security Tradeoffs of Leeway

A larger leeway window accepts tokens for a longer time after they should have expired, and accepts them earlier than the issuer intended. Pick the smallest leeway that absorbs real clock drift.

| Leeway | Acceptable for |
|---|---|
| 0-5 s | Tight production where clocks are NTP-disciplined (most cloud) |
| 30-60 s | Default for production with NTP and a small safety margin |
| 1-5 min | Local development, CI, or environments with known drift |
| > 5 min | Almost never acceptable; weakens security and complicates revocation |

The .NET `TokenValidationParameters.ClockSkew` default of 5 minutes is widely cited as too generous for production APIs. Set it to 30-60 seconds unless there is a documented reason for more.

A common anti-pattern is fixing only the leeway without fixing the underlying clock. The verifier remains incorrect for other consumers, future operators, and audit logs. Treat leeway as a safety net, not the fix.

## Gotchas

- `clerkMiddleware()` and `auth.protect()` do not allow callers to pass `clockSkewInMs` directly. If you need a custom value, use the underlying `verifyToken` helper or your own session-token verification.
- The Clerk Dashboard "Allowed Clock Skew" / "nbf Offset" setting affects newly issued tokens only; it does not retroactively fix tokens already in flight.
- WSL2 clock can be hours behind after a long-suspended host. `timedatectl set-ntp true` plus restarting the WSL VM is the reliable fix.
- Docker Desktop on macOS/Windows may not resync after sleep. Restart Docker Desktop as a quick fix; keep the host awake in the long term.
- CI runners sometimes issue tokens with `iat` milliseconds in the future; this is normal and Clerk's 5-second default absorbs it.
- Custom JWT template tokens use the same `nbf`/`iat`/`exp` claims as session tokens. The same leeway considerations apply to any service that verifies them.
- Webhook delivery uses Svix, which has its own timestamp tolerance (Svix `timestamp` header with a freshness window, typically 5 minutes) that is separate from JWT clock skew. Do not conflate the two. A webhook failing the Svix freshness check is a different failure mode than a JWT failing `nbf`.
- Cross-origin SPAs: the JWT is issued by Clerk, sent to your API, and verified there. Frontend and backend clocks do not both matter; only the backend's clock and Clerk's clock matter. Frontend clock drift (laptop with wrong time) does not break JWT verification.
- A token that works locally and fails in production usually means production has an un-NTP'd container or VM, not that production has different Clerk settings. Compare clocks first, leeway second.
- If you are not sure whether you are hitting clock skew or a real expiry, capture the token, decode it, and read the raw `nbf`/`exp` integers. Do not guess from error text alone.

## Production Checklist

- NTP enabled on every production host that verifies Clerk tokens (Linux: `timedatectl`; Windows: W32Time service; macOS: `sntp`).
- Container base images that run for long periods use `chrony` or an init system that syncs time.
- Host sleep settings reviewed for dev laptops and CI runners; restart Docker Desktop after long pauses.
- `clockSkewInMs` set explicitly to a small value (5-30 seconds) where Clerk's own helpers are used.
- Library leeway set explicitly in custom JWT verification code; do not rely on defaults.
- `.NET ClockSkew` reduced from 5 minutes to 30-60 seconds in production `TokenValidationParameters`.
- Monitoring on spike of `token-not-active-yet` / `token-expired` errors; sudden change usually indicates a clock problem.
- Token-decoding diagnostic tool available in test environments to read raw `nbf`/`iat`/`exp`.
- Webhook handlers continue to use Svix verification; do not relax Svix tolerance because of unrelated JWT issues.
