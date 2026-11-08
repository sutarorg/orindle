# API architecture proposal (historical)

> This proposal predates the implemented API routes. Use `API_ENDPOINTS.md` for the current route inventory. Routes and providers have not been exercised against configured external services in this audit.

All customer endpoints must authenticate, authorize ownership, validate input, rate limit and return an opaque request/job ID. Use typed schemas and stable error codes. Do not proxy arbitrary user-supplied provider URLs.

## Suggested routes
- `GET /api/models` — filtered compatible catalogue, capability filters, cursor pagination, verified timestamp; no secrets. Numeric marketing claim computed from deduplicated verified chat-capable IDs.
- `POST /api/chat` — create user message and provider response/job; accepts model selection `auto|manual` and authorized file IDs; server resolves provider and credit estimate/reservation.
- `GET /api/conversations`, `GET/PATCH/DELETE /api/conversations/:id`; `GET /api/conversations/:id/messages`.
- `POST /api/files` (signed upload intent), `POST /api/files/:id/complete`, `DELETE /api/files/:id`; enforce MIME/size, scan and expiry.
- `POST /api/generations/images`, `POST /api/generations/videos`; return job ID, never hold request open for long-running generation.
- `GET /api/generations/:id`; authorized polling/SSE with rate limits.
- `POST /api/websites` and `GET /api/websites/:id`; HTML-only artifact, safe downloadable attachment, constrained preview sandbox.
- `GET /api/library`, `POST /api/library/:id/save`, `DELETE /api/library/:id`.
- `GET /api/account`, `GET /api/account/credits`, `GET /api/account/subscription`, `POST /api/account/cancel`.
- `POST /api/billing/checkout` — server selects a fixed price/product from trusted location and explicitly returns the same display currency/amount; `POST /api/webhooks/dodo` verifies signature and idempotency.
- Admin routes isolated behind server-side role checks and audit events.

## API controls
Zod/JSON schema validation, CSRF defense for cookie sessions, secure SameSite cookies, origin checks, idempotency keys, request correlation IDs, per-user concurrency/quotas, provider timeouts, prompt-size limits, output-size limits, HTML sandboxing, webhook signature verification, no secret values returned to browser, safe error messages and redacted observability.
