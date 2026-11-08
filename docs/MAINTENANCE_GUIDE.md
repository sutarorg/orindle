# Orindle maintenance guide

This guide describes the current draft implementation and operator tasks. It is not evidence that an external integration is connected.

## Routine checks (weekly or before a release)

1. Review the latest GitHub pull request, CI/check results and deployed commit. Do not merge unreviewed changes to `main`.
2. Run `npm ci`, `npm run typecheck`, `npm run lint`, `npm run test`, and `npm run build` from a clean checkout.
3. Check Supabase Auth, database availability, backup status and failed migrations in the provider dashboard. Do not run arbitrary SQL on production.
4. Review OpenRouter spend/limits directly in the provider account. Orindle currently has no cost alerting dashboard; configure provider-side budgets/alerts where available.
5. Inspect model catalogue sync logs and timestamps. Use the authorized admin sync route; confirm model availability and price values before exposing generation controls. Never advertise a numeric model count unless the live, alias-deduplicated set meets the gate.
6. Review Dodo webhook deliveries and the application’s `webhook_events` records. Investigate failed/retried events and reconcile against provider subscription records before changing entitlement.
7. Review `generation_jobs` with `needs_review`, `credit_reservations` with `needs_review`/expired reserved state, and usage rows whose cost basis is `estimated`. This is currently a manual operator task; there is no admin reconciliation UI or automated dead-letter worker.
8. Check R2 bucket access, object lifecycle/retention and recent storage cost using Cloudflare’s current account tools.
9. Send verification/recovery mail to a controlled mailbox after any Supabase SMTP/DNS change. Direct Resend API integration is not present.
10. Review customer support/privacy requests and retention/deletion queue. The app does not provide a complete data-retention scheduler yet.

## Updating AI models

1. Confirm OpenRouter key and spend limit are correct for the environment.
2. Sign in as an authorized Orindle administrator.
3. Run `POST /api/admin/models/sync` from an approved client or admin tooling.
4. Inspect sync result and `model_sync_logs`; if failure, do not substitute a hardcoded catalogue.
5. Check `model_catalog.active`, modalities, supported parameters, `model_pricing` and `synced_at` in a secure DB console.
6. Verify at least one current chat/image/video model with provider APIs only under approved budget.
7. Roll back/disable unpriced or unsupported models via the approved admin DB procedure; do not directly mutate catalogue using a customer credential.

## Spend, failed generations and credits

- OpenRouter’s provider dashboard is the source for provider-billed spend. `generation_usage` records a cost and `cost_basis` (`actual` when provider returns cost; `estimated` when calculated from synchronized price/token counts).
- Reservations and the ledger are the app-side credit source. Do not modify balances manually in a table.
- A `needs_review` reservation means provider acceptance/cost or settlement is uncertain. Compare OpenRouter job/event evidence with the job row before resolving. Current code has no operator UI; restrict database access and document each manual adjustment in an external incident/audit record.
- Never settle a customer request to zero simply to clear a stuck reservation. Confirm provider cost and whether content completed first.
- Failed/cancelled video terminal events without usage cost are held for review rather than assumed free.

## Subscriptions and webhook delivery

1. Check Dodo’s current environment (test/live) and the exact test/live product IDs before troubleshooting.
2. Inspect Dodo webhook delivery result, signature timestamp and provider event ID in its dashboard.
3. Find the matching `webhook_events` record. `processed` and `ignored` duplicates are idempotently acknowledged; `failed` records need payload/schema review and a safe retry.
4. Verify subscription `provider_subscription_id`, fixed `product_id`, `currency`, `amount_minor`, interval, `period_start` and `period_end` against Dodo.
5. Verify `credit_grants.provider_event_id` for the period before reprocessing. Never hand-create an additional grant without a documented approved recovery.
6. Cancellation, refunds, chargebacks and account credit recovery need a reviewed operator playbook; complete automated refund handling is not present.

## Environment variables and key rotation

- Use [`ENVIRONMENT_VARIABLES_MASTER_GUIDE.md`](ENVIRONMENT_VARIABLES_MASTER_GUIDE.md) as the source inventory.
- Scope test and production values separately. Change secrets in the provider, update the matching Vercel environment scope, then redeploy and verify.
- Rotate Supabase secret/service-role, OpenRouter, Dodo, webhook and R2 credentials immediately if exposed. Update all dependent environments; revoke the old credential after confirming new deployment.
- Do not log or screenshot credential values. Restart local Next.js after `.env.local` changes.

## Incident response

1. Stop additional provider spend: disable generation by removing/revoking provider credentials or limiting provider budgets; preserve evidence.
2. For payment events, keep Dodo live mode disabled where possible; do not delete webhook records.
3. For suspected cross-user data exposure, revoke affected credentials and signed URL access, restrict the route, preserve timestamps/request IDs without retaining unnecessary customer content, and notify the privacy/security owner.
4. For incorrect balances, stop settlements and reconcile provider records, reservation, wallet and transaction ledger. Do not edit production rows manually without a reviewed transactional recovery.
5. Restore the prior known-good Vercel deployment if the release caused an outage, but remember environment variables are project-scoped and may have changed separately.
6. Record cause, impact, data affected, mitigation, customer communication and follow-up actions.
