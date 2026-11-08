# Orindle credit engine

**Status:** SQL/application draft; database tests and race tests have not run. Treat as unverified until a disposable Supabase project executes the migration and tests.

## Business rules

- ORINDLE PRO is the only plan.
- Fixed monthly amounts: $14.99 USD (1499 minor units) and ₹1,399 INR (139900 minor units) only when trusted server-side India location and matching fixed INR product are configured. No FX conversion.
- A successful verified subscription billing period grants exactly 1,500 credits. Redirects never grant credits.
- `credits_per_usd` is seeded as 1000, i.e. one credit corresponds to $0.001 in the internal usage conversion. This is an application setting, not a profitability promise or guaranteed exchange value.

## Reservation flow

1. API validates user, request, model capability and current synchronized price.
2. API computes an estimated cost and estimated credit amount (`ceil(USD cost * credits_per_usd)`) to reserve before provider call.
3. User-authenticated `reserve_credits` RPC locks the caller’s wallet row, checks available balance, moves credits from `balance` to `reserved`, creates a uniquely keyed reservation and ledger transaction atomically.
4. The RPC rejects non-positive amounts, invalid idempotency keys and a generation-job ID not owned by the caller.
5. On a confirmed provider response, server obtains provider cost where available; otherwise computes an explicitly marked estimate from synchronized price/tokens/duration.
6. Service-role-only `settle_credit_reservation` compares actual credits with the reserved amount. Unused amount returns to balance; over-reservation is charged if enough balance remains; insufficient remainder moves the reservation to `needs_review`.
7. If the provider may have accepted a request but response/usage is unknown, the route flags the reservation for review rather than refunding blindly.

## Grant flow

- The Dodo webhook endpoint verifies the signature using the endpoint secret and persists unique provider event ID.
- Subscription events are checked against the local subscription, product, currency, fixed minor amount and monthly interval.
- For `subscription.active` or `subscription.renewed` with valid billing period, `grant_monthly_credits` inserts a unique period grant key (`dodo:<subscription-id>:<period-start>`), adds 1,500 to wallet and records a ledger row atomically.
- Replayed event/period key does not double grant.
- No browser redirect or client-side call can grant credits.

## Failure and concurrency controls

- Wallet updates in reserve/settle functions use row locks and nonnegative constraints; idempotency constraints protect duplicate request keys.
- Credit settlement and uncertainty-review RPCs are now service-role-only; normal users cannot call them directly. This fix is in the current draft migration and has not been tested against Postgres.
- A reservation can remain held in `needs_review` after provider uncertainty or inability to settle. There is no automated expiry/refund worker or admin reconciliation UI. An operator must reconcile provider evidence; do not clear by setting zero.
- An app failure after settlement may leave the ledger settled while a result/job record is incomplete; the review/repair process is manual and must be tested before launch.

## Cost measurement and profitability

- `generation_usage.cost_basis='actual'` means provider returned a cost value.
- `cost_basis='estimated'` means the app computed cost using current synchronized model pricing and fallback token/output/duration assumptions.
- Estimated values must not be presented as provider-billed actuals.
- The current project does not record all payment processing fees, storage/infrastructure per-user costs or other variable costs, and does not provide a validated gross-margin report. Therefore gross margin cannot currently be calculated accurately from the app database.
- The 80% gross-margin figure is a target only, not a promise or measured value.
- Image prices vary by model/output; video estimates vary by model, duration and configuration. Store actual provider usage whenever returned; otherwise mark estimate.

## Required tests before use

1. Two simultaneous reservations against one wallet cannot overspend.
2. Duplicate reservation key creates only one debit.
3. Authenticated user cannot execute settlement/review/grant/catalogue mutation RPCs.
4. Service role can settle only an existing reservation and gets same result on repeated settlement.
5. Refund/settlement replay cannot produce a second balance change.
6. Actual usage below/above reservation adjusts balance correctly; overage beyond wallet becomes `needs_review` without negative balance.
7. Dodo signature failure/replay/period retry produces zero or one grant as appropriate.
8. Missing actual cost holds uncertain provider actions for review.

These tests have not been executed against a database in this workspace.
