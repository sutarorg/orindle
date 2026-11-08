# Dodo Payments integration

**Status:** Dodo SDK adapter and webhook/checkout draft present; no Dodo account, test keys, products, checkout, webhook or payment were accessed. Test mode only; live billing remains disabled pending explicit approval.

## Fixed plan invariants

- Only ORINDLE PRO exists.
- USD is $14.99 monthly (`DODO_PRICE_USD_MINOR=1499`).
- INR is ₹1,399 monthly (`DODO_PRICE_INR_MINOR=139900`) only when trusted Vercel country is `IN` and the matching fixed INR product ID is configured.
- Unknown/local location uses USD. No browser locale or FX conversion is used.
- 1,500 credits are granted only on a verified successful subscription period event, not a redirect.

## Checkout implementation

`POST /api/billing/checkout` requires authenticated user and UUID `Idempotency-Key`, chooses currency server-side, validates exact configured amount/product, prevents another pending/active subscription, inserts a pending subscription record and creates a Dodo Checkout Session with a product cart and metadata. Return/cancel URLs use server `APP_URL`. Dodo uses `DODO_ENVIRONMENT` defaulting to `test_mode`; `live_mode` requires `DODO_ENABLE_LIVE_BILLING=true` as well.

The current code reads `DODO_PRODUCT_USD_ID` / `DODO_PRODUCT_INR_ID` (product IDs) and fixed minor-unit guard variables. It does **not** read `DODO_PRICE_USD_ID` or `DODO_PRICE_INR_ID`. Verify the current Dodo product recurring-price model and account eligibility before setup; do not invent IDs.

## Webhook implementation

`POST /api/webhooks/dodo` validates required webhook headers, calls the installed Dodo SDK’s signature unwrap, records unique provider event IDs, marks duplicates idempotently, processes `payment.succeeded` and subscription lifecycle event types, checks local product/currency/amount/monthly interval, updates local subscription/payment state and invokes a service-role-only monthly grant for valid active/renewed period events.

A signed event is stronger evidence than the browser redirect, but actual payload fields/event names and provider retrieval behavior have not been tested against an account. Before relying on this integration, compare the implementation with current Dodo docs/account and run sandbox events. Ensure the configured event endpoint/secret correspond to the same environment.

## Cancellation

Customer cancellation route requests cancellation at period end and updates local cancellation state. Provider event reconciliation remains authoritative. Refund/chargeback handling and customer self-service reactivation are not complete.

## Known operational gaps

- No provider API retrieval is performed to independently confirm every subscription/payment detail beyond signed event payload fields.
- No automated refund/chargeback or support workflow.
- No admin subscription reconciliation screen or gross margin dashboard.
- No live/sandbox webhook contract test or Dodo account call was performed.
- Webhook event failure replay/operations must be manually supervised.

## Safe operator test matrix

1. USD quote and checkout display match USD 14.99 product.
2. Trusted Vercel India request with configured fixed India product displays and checks out at ₹1,399; unknown/local defaults USD.
3. Checkout redirect without webhook leaves pending state and zero grant.
4. Valid signed initial period grants exactly 1,500 once.
5. Duplicate event and repeated same period grant do not double credit.
6. Renewal extends period and grants exactly once for the new period.
7. Failed, past due, on-hold, cancelled, expired events do not mint a new successful period grant.
8. Invalid signature, wrong product, wrong amount/currency, non-monthly interval and mismatched metadata fail safely.
9. Cancellation at period end matches provider state and account display.
10. All tests use Dodo test credentials/test payment methods. Never use a real charge for QA.
