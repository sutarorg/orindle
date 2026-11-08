# Orindle database schema reference

**Source of truth:** `supabase/migrations/202611080001_core.sql` (draft). This inventory is not evidence the migration has run. SQL syntax parses; database behavior and RLS tests have not been executed.

## Identity and access

- `profiles`: user display name/avatar/country metadata; key references `auth.users`.
- `user_roles`: server-managed `user`/`admin` roles. No authenticated insert/update grant.
- `user_preferences`: user model/locale preferences.

## Catalogue and administration

- `model_catalog`: provider/model identity, canonical ID, active flag, context and modalities.
- `model_capabilities`: normalized capability rows.
- `model_pricing`: prompt/completion token rates, image unit and video per-second rate, USD source/sync time.
- `model_sync_logs`: model sync counts and status.
- `system_settings`: credits-per-USD, monthly grant and generation settings; admin-managed RLS.
- `admin_audit_logs`: admin action records.

## Conversations and files

- `conversations`: user-owned chat title, active model and soft deletion.
- `messages`: user/assistant content, status, token counts, provider cost and basis, idempotency key, reservation link.
- `message_attachments`: message-to-upload links with owner constraints.
- `uploaded_files`: private R2 object key, original filename, MIME/size/hash, purpose, validation state, expiry and soft deletion.
- `library_items`: exactly one generated asset, uploaded file or conversation reference; policies enforce owner match.

## Credits and billing

- `credit_wallets`: nonnegative available balance and reserved amount per user.
- `credit_reservations`: idempotency key, amount, actual usage/cost and state (`reserved`, `settled`, `released`, `needs_review`).
- `credit_transactions`: append-only ledger rows for grants, reservations, usage, refunds and adjustments.
- `credit_grants`: one-time period grant with unique provider event key and billing period.
- `subscriptions`: Dodo product/provider ID, currency/amount/status/period/cancellation state.
- `subscription_events`: unique event history per provider event ID.
- `payment_records`: user-owned provider payment ID, amount, currency and status.
- `webhook_events`: unique provider event receipt/processing/failed state.

## Generation and usage

- `generation_jobs`: user-owned image/video/website job, provider job/poll URL, prompt/request, idempotency/status, estimate/actual credits/cost and actual-vs-estimated cost basis.
- `generation_assets`: user-owned R2 key, MIME/size/hash and media metadata.
- `generation_usage`: one usage row per job or message, model, token counts, provider cost, cost basis and credits charged.

## Security model and caveats

- RLS is enabled on public tables. Customer rows use `auth.uid()` ownership; catalogue visibility is active-only; mutations for billing, credits, pricing, model sync and user roles are intentionally restricted.
- Server API routes use service-role clients for operations and must retain explicit ownership predicates. RLS does not protect service-role queries.
- `reserve_credits` is a SECURITY DEFINER user RPC intended to lock/decrement only the caller’s wallet, requiring a positive amount and idempotency key. Optional job ID must belong to caller.
- `settle_credit_reservation` and `flag_credit_reservation_review` are service-role-only after this audit change. Normal users cannot self-settle/refund.
- `grant_monthly_credits` is service-role-only, idempotent by provider period key and fixed to exactly 1,500 credits.
- Some admin/store cost fields and APIs are only partial; no complete reporting or scheduled reconciliation is present.
- No migration has been executed. If the initial migration is already applied in another environment, create a reviewed forward migration rather than rewriting applied history.
