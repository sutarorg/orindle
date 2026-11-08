# Setup and integration handoff

This is a developer handoff for the current integration draft. It is not a claim of production readiness. Credentials are not present in this repository, no live provider requests have been made, and the Supabase SQL has only been syntax-parsed—not applied or exercised against a database.

## 1. Local configuration

1. Use a supported Node.js release compatible with the repository's Next.js version; install with `npm ci`.
2. Copy `.env.example` to `.env.local` and set `APP_URL` and `NEXT_PUBLIC_APP_URL` to the same origin.
3. Keep all secrets server-side. Never prefix `SUPABASE_SERVICE_ROLE_KEY`, `OPENROUTER_API_KEY`, Dodo credentials, or R2 credentials with `NEXT_PUBLIC_`, and do not commit `.env.local`.
4. For development, use Supabase, OpenRouter, Dodo, and R2 test/development credentials only. Missing integrations should remain unconfigured rather than replaced with production credentials.

## 2. Supabase Auth, schema, and RLS

1. Create a Supabase project and set `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, and the server-only `SUPABASE_SERVICE_ROLE_KEY`.
2. Configure the Supabase Auth site URL and redirect allowlist for the local origin and each approved deployment origin. Auth callbacks and recovery links depend on the app origin.
3. Review `supabase/migrations/202611080001_core.sql` against the target project's schema/extensions and role configuration. Back up any non-disposable database first. Apply the migration through the project's approved migration path (for example, the Supabase CLI or SQL editor) only after review; it has **not** been applied by this agent.
4. Run `supabase/tests/rls_invariants.sql` against a disposable local/test Supabase database using the project's supported database test workflow. It has **not** been executed against a database. Confirm cross-user reads/writes, credit ledger RPC privileges, admin role protections, and asset ownership checks before any real user data is used.
5. Keep the service-role key on server-only code paths. Re-check RLS for every new table, RPC, storage key and Library linkage. Do not grant authenticated users direct mutation rights to balances, verified prices, billing records, or privileged roles.

## 3. OpenRouter model catalogue and generation

1. Set `OPENROUTER_API_KEY`; optionally configure `OPENROUTER_BASE_URL` and `OPENROUTER_SITE_URL`.
2. Grant the appropriate administrator role, then invoke the protected model-sync route (`POST /api/admin/models/sync`) from an authorized environment. Check the sync response and database catalogue for active status, capability/modalities and verified pricing before exposing a model.
3. Chat uses the synchronized catalogue for compatibility/routing. Image and video generation require synchronized capabilities and verified image/video prices; unpriced models must remain unavailable for paid generation.
4. Test model listing and normalization independently first. Only submit provider generation requests when the project owner explicitly authorizes paid/test usage and has set a suitable provider budget. The agent has not called OpenRouter or verified live model metadata.

## 4. Private Cloudflare R2 storage

1. Create a private bucket and a scoped access key with the minimum necessary object read/write permissions. Set `R2_ACCOUNT_ID`, `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`, and `R2_BUCKET`.
2. Keep the bucket private; application uploads and downloads use short-lived signed URLs. Do not expose bucket credentials or public object URLs.
3. Exercise upload validation, ownership checks, expiry, deletion/retention, and generated-asset delivery using test objects. Confirm the selected bucket lifecycle and backup/retention policy with the operator.
4. R2 has not been configured or tested in this workspace.

## 5. Dodo Payments (test mode only)

1. Keep `DODO_ENVIRONMENT=test_mode` and `DODO_ENABLE_LIVE_BILLING=false`. Provide a Dodo sandbox API key and webhook signing secret only in a protected test environment.
2. Configure a fixed USD product at exactly 1499 minor units per month. Configure the fixed INR product at exactly 139900 minor units per month only if India pricing is approved and the matching fixed INR product is available. Set the product IDs and matching minor-unit variables in `.env.local`; the server rejects amounts that do not match these values.
3. The INR branch is selected only when running on Vercel and its trusted edge-country header is `IN`. Local development and unknown locations fall back to USD. There is no FX conversion and no client-supplied country/amount is trusted.
4. Register the test webhook endpoint at `/api/webhooks/dodo` and subscribe to the exact subscription/payment lifecycle events supported by the configured Dodo account. Use Dodo's signed test events to verify signature rejection, event deduplication, subscription state reconciliation, retry behavior, and the success-period credit grant. Ensure checkout redirects alone never grant credits.
5. Exercise checkout cancellation, webhook replay, renewal, failure, cancellation and product/currency mismatch cases. Review webhook payload event names/fields against the implementation and the installed Dodo SDK before relying on it; no live or sandbox Dodo calls have been made here.
6. ORINDLE PRO remains $14.99/month USD and ₹1,399/month INR only under the trusted/configured conditions above. A verified successful subscription period grants 1,500 credits. **Do not set live mode or `DODO_ENABLE_LIVE_BILLING=true` without explicit approval and a separate release review.**

## 6. Verification and deployment checklist

Local static checks currently pass:

```bash
npm run typecheck
npm run lint
npm run test
npm run build
```

Before deploying, additionally require:

- Approved and executed migration plus database-backed RLS/RPC tests in a non-production environment.
- Verified Supabase auth/recovery/callback behavior and account/session controls.
- OpenRouter catalogue sync, price provenance/freshness, chat streaming failure recovery, and authorized low-budget generation tests.
- R2 upload/download/ownership/deletion tests and appropriate monitoring.
- Dodo sandbox checkout and signed webhook lifecycle tests, including dedupe and period-credit idempotency.
- Privacy, retention, abuse/rate limiting, accessibility, observability, support, legal and incident-response review.
- A separate explicit approval before any live billing enablement.

No production-readiness or integration-verification claim should be made until these gates are completed by an operator with access to the corresponding services.
