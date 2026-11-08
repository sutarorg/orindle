# Security implementation notes

This describes code, not a penetration-test result. See [`SECURITY_AUDIT_REPORT.md`](SECURITY_AUDIT_REPORT.md) for findings/severity and required gates.

## Authentication and roles

- Supabase SSR client validates current user with `auth.getUser()`.
- Middleware gates `/app/*` and `/admin/*`; the server admin layout also calls `requireAdminPage()`.
- Admin APIs call `assertAdmin`/server role check. A role row is server-managed; authenticated clients have no role mutation grant in the migration.
- Auth callback accepts code/token-hash flows and constrains `next` to a local path (single-leading slash, no protocol-relative/backslash path).
- Browser config includes only public Supabase URL/key. Service role remains in server-only code.
- Actual auth, cookie security/expiration, email settings and role escalation tests are pending.

## Database and credit functions

- Draft migration enables RLS on application tables and scopes user-owned records.
- `reserve_credits` is intended to use `auth.uid()` and row lock; `settle_credit_reservation` and `flag_credit_reservation_review` were changed to service-role-only in this audit branch.
- Monthly grant and catalogue sync are service-only; grant is idempotent per period key.
- Service-role APIs must still apply explicit user predicates. Normal users cannot directly mutate balances, payment rows, subscriptions, model prices or roles.
- Migration and tests have not run against Postgres; never infer security from syntax parse alone.

## API, provider and input controls

- OpenRouter, Dodo and R2 modules are server-only and keys are read server-side.
- Zod schemas, bounded request fields and idempotency keys are used on major generation/payment paths.
- Files are size/purpose/type/magic-byte validated, stored under user-specific private R2 keys and delivered via short-lived owner-checked signed URLs. This is not malware scanning; no antivirus/quarantine service is configured. PDF uploads are not accepted by the current upload endpoint.
- AI provider errors are mapped to generalized codes and full input content is not intentionally logged.
- Durable request/IP/user rate limiting, captcha/abuse controls, provider spend alerts and concurrency ceilings are not implemented.

## Payment safety

- Dodo webhook SDK unwrap verifies signatures; event IDs are unique; subscription product/currency/amount/monthly interval are checked; checkout redirect does not grant credits.
- Live mode is behind a double gate and defaults to test mode.
- Provider schema, signature timestamp window, replay/retry handling and payment lifecycle must be verified in sandbox. Refund/chargeback handling is incomplete.

## Generated HTML isolation

- Preview is a `srcDoc` iframe with `sandbox="allow-scripts"`, without `allow-same-origin`, no-referrer, and in-document CSP restricting default sources, network connects, forms, base URLs, external resources.
- Do not add same-origin or top-navigation sandbox permissions. Do not serve generated HTML inline from the app origin.
- The HTML is user-generated code and may execute scripts in the isolated preview. Browser testing of cookie/local storage access, postMessage and navigation behavior remains a launch gate.

## Security response headers

`next.config.ts` adds `X-Content-Type-Options: nosniff`, `X-Frame-Options: SAMEORIGIN`, `Referrer-Policy: strict-origin-when-cross-origin`, and disables powered-by. `Permissions-Policy` disables camera, microphone and geolocation. Local production-server smoke test observed these headers. HSTS and a site-wide CSP are not configured; determine safe production edge policy after HTTPS/domain/browser verification.
