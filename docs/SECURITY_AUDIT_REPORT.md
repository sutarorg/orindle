# Orindle security audit report

**Date:** 2026-11-08 UTC · **Scope:** source/configuration review of the current merged repository plus dependency audit. No formal penetration test or certification was performed.

## Executive result

**Not cleared for commercial production.** No live secrets or service access were available. The updated credit settlement permission fix is a draft migration change and has not been applied to a database. Database isolation, authentication flows, provider requests, webhook signatures, storage permissions and deployment headers therefore remain unverified in the actual service environment.

## Findings

### Critical — credit settlement callable by end users (fixed in draft, deployment gate remains)

**Baseline issue:** `settle_credit_reservation` was a `SECURITY DEFINER` function executable by `authenticated`. A user could call the RPC directly to release a reservation without a provider response, defeating the server-side charging decision. This is an economic-control flaw.

**Change in this branch:** the function now rejects non-`service_role`, finds the owner from the reservation, and only grants execute to `service_role`. Generation endpoints settle through the server-only admin client. A server-only RPC flags ambiguous outcomes as `needs_review`; the RLS SQL test asserts authenticated cannot execute either RPC.

**Residual gate:** the migration has not run against Postgres. Do not deploy generation/payment traffic until the updated migration is applied to a test project and function ACLs plus credit race tests pass. Existing database migration history must be checked before deciding how to apply this edited initial migration; do not edit an already-applied migration in place in a real environment—create a new forward migration.

### High — service integrations and authorization not exercised

- Middleware protects `/app/*` and `/admin/*` and fail-closed behavior was seen locally with no Supabase env. No real identity provider session, callback, cookie, expiry, account recovery or role behavior was exercised.
- Server APIs often use Supabase service-role queries. Source review finds user predicates on many queried resources, but the service key bypasses RLS; every route must be tested with two users. No cross-tenant integration test has run.
- Webhooks verify Dodo signatures with the SDK and persist event IDs, but the actual SDK payload shapes, timestamp/replay behavior and provider retries were not checked against a Dodo sandbox account.
- There is no distributed per-user/IP rate limit or abuse quota for signup, upload signing, catalogue sync or generation. Credit reservation constrains paid generation only when balances and database enforcement are correctly configured. Add a durable rate limit/abuse control before public launch.
- No production alerting, audit operator workflow, privacy-safe request tracing or webhook dead-letter/replay console exists.

### High — no executed RLS tests / actual secrets configuration

The RLS tests parse but are not executed. Until they pass against the exact target Postgres/Supabase project, the project must be treated as unverified. Service-role credentials must remain server-only and be rotated if exposed.

### Medium — ambiguous provider outcome and cost classification

The audit found that transport timeouts could be mistaken for a definite pre-generation failure and credit reservations released. Routes now hold reservations for review when a provider may have accepted a request but no response was received. The review process is manual; no admin reconciliation screen or automated recovery job exists. Usage cost fields now distinguish `actual` provider-reported cost from `estimated` catalogue/token-derived cost, but no aggregate gross-margin report exists.

### Medium — HTML preview and download require operational checks

The preview uses `iframe sandbox="allow-scripts"` without `allow-same-origin`, a strict in-document CSP (`connect-src 'none'`, `form-action 'none'`, no external image/font/script sources), and no-referrer policy. This prevents same-origin access to the Orindle app from the preview context and disallows forms/network fetches. It still intentionally runs generated inline JavaScript in an opaque origin. No browser test verified behavior; do not remove the sandbox flags or CSP. Downloaded HTML is user-generated executable content and must be downloaded as an attachment, not served from the application origin as an active page.

### Medium — security headers and abuse controls

This audit branch adds `X-Content-Type-Options: nosniff`, `X-Frame-Options: SAMEORIGIN`, `Referrer-Policy: strict-origin-when-cross-origin` and a restrictive `Permissions-Policy`, while keeping the powered-by header disabled. These headers have not yet been verified in a browser/hosting deployment. HSTS and a site-wide CSP are not configured; set/validate edge policy after HTTPS domain setup. CSP must be tested carefully with Next.js, Supabase auth redirects, and the sandboxed `srcDoc` preview. Do not deploy a copied CSP without browser testing.

### Low — account enumeration / auth UX review pending

Auth action errors are generally generalized, but Supabase signup/reset behavior and mail delivery configuration have not been exercised. Review project settings to avoid exposing whether an email exists; ensure email confirmation and abuse protections are configured.

## Positive controls observed in source

- Provider keys and the Supabase service-role key are accessed only in server-only modules; only Supabase URL and anon/publishable key use `NEXT_PUBLIC_`.
- User-scoped routes commonly add `.eq('user_id', user.id)` before reading/deleting assets, jobs, billing and Library rows; RLS is enabled throughout the draft migration.
- Upload validation checks expected formats and magic bytes, sets private R2 object keys and signs operations briefly (300 seconds). Object store credentials are not browser-facing.
- Video/image output delivery requires authenticated ownership checks and restricts inline asset MIME types.
- Checkout values and product choice are server-side; the UI does not grant credits on redirect. Webhook event IDs are unique and successful period grants use an idempotency key.
- `npm audit` reported zero known vulnerabilities at the audit timestamp. This is registry data, not a security certification.

## Required before live launch

1. Apply a forward migration to a disposable database and run all RLS tests under authenticated roles.
2. Add a test proving a normal user cannot execute settlement/review/grant/catalogue RPCs and cannot alter balances/roles/prices.
3. Test two accounts against conversations, attachments, uploads, generated assets, Library, payment records and signed URLs.
4. Run signed Dodo sandbox webhook tests, including invalid signature, replay, delayed delivery, amount/product mismatch and renewal deduplication.
5. Add durable rate limiting and generation abuse controls; define request size, token/duration, concurrency and spend caps.
6. Add a documented manual reconciliation path and alerts for `needs_review` reservations/jobs.
7. Set and verify CDN/security headers, private R2 access/CORS, HTTPS, allowed auth redirects, backups and secret rotation.
8. Complete browser XSS/iframe isolation, CSRF, session fixation, content-disposition and dependency/provenance review.

**No formal security certification is claimed.**
