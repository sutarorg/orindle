# Database schema proposal (not implemented)

Use PostgreSQL; use UUID primary keys; UTC timestamps; tenant/user scoped access; immutable audit/ledger events where appropriate. Encrypt secrets and minimize personal data. Exact ORM/migrations remain for Prompt 2.

## Core entities
- `users`: id, email_normalized, email_verified_at, name, auth_provider_id, created_at, disabled_at.
- `sessions`: id, user_id, hashed_token/session provider reference, expires_at, revoked_at, metadata minimized.
- `subscriptions`: id, user_id, provider, provider_subscription_id, plan_code (`ORINDLE_PRO`), currency, fixed_amount_minor, status, period_start/end, cancel_at_period_end, timestamps. Enforce one active plan; never store raw payment credentials.
- `credit_ledger`: id, user_id, subscription_id, delta, event_type, idempotency_key, provider_job_id, occurred_at, metadata; append-only. Balance derived or transactionally maintained; reconcile monthly grant and job debit.
- `model_catalogue`: provider, canonical_model_id, aliases, display_name, capabilities, limits, pricing metadata, active, last_verified_at, sync_source. Unique canonical ID; aliases deduplicated for counts.
- `conversations`: id, user_id, title, created_at, updated_at, deleted_at.
- `messages`: id, conversation_id, user_id, role, content reference/body (with retention policy), model_id, status, usage metadata, timestamps. Apply access control and retention policies.
- `files`: id, user_id, object_key, safe_name, mime_type, size, checksum, scan_status, created_at, deleted_at. Private object storage; do not expose raw bucket keys.
- `generation_jobs`: id, user_id, type (`image`/`video`/`website`), provider/model, prompt reference, status, progress, credit reservation/debit, error code, timestamps.
- `artifacts`: id, user_id, job_id, type, object_key, metadata, created_at, deleted_at. Website artifact stores standalone HTML output; sanitize/serve downloaded HTML safely.
- `library_items`: id, user_id, artifact/message/file reference, category, title, created_at, archived_at.
- `admin_audit_events`: actor_id, action, target, timestamp, request_id, redacted metadata.

## Data invariants
- Every user-owned row is scoped to the authenticated user in all queries; ownership must never rely on a client-supplied user ID.
- Credit grant/debit operations are transactional and idempotent; reserved credits reconcile with job outcomes.
- Keep currency and immutable amount from the actual checkout price on the subscription record.
- Do not store passwords when delegated auth is used. Otherwise use a reviewed password-hashing mechanism and rotation/recovery design.
- Prompt/file retention, deletion, backups, data residency and provider-sharing rules must be decided and documented before launch.
