# Orindle API endpoints (source inventory)

Audit date 2026-11-08. Methods are based on current route exports. This is a code inventory, not proof of deployment or external service availability. Most authenticated routes require a Supabase session; admin routes require server-side `user_roles` authorization; Dodo webhook requires a valid signature.

| Route | Method | Purpose / controls |
|---|---|---|
| `/api/account/profile` | GET/PATCH | Current user profile; update is schema validated and user scoped. |
| `/api/account/summary` | GET | Current user profile, wallet and subscription summary; no-store. |
| `/api/account/usage` | GET | Bounded credit transaction or billing history for the authenticated user. |
| `/api/admin/models/sync` | POST | Admin-gated OpenRouter catalogue refresh and audit entry; may make external provider requests. |
| `/api/assets/[id]` | GET | Authenticated owner-only signed asset delivery; inline MIME allowlist for image/video. |
| `/api/billing/quote` | GET | Server-selected fixed price quote. INR only with Vercel country `IN` and matching fixed product config; otherwise USD. |
| `/api/billing/checkout` | POST | Authenticated Dodo Checkout Session; requires idempotency key and matching fixed server product/amount. No redirect-based credit grant. |
| `/api/billing/cancel` | POST | Schedules current user’s active Dodo subscription cancellation at period end. |
| `/api/webhooks/dodo` | POST | Dodo signed event unwrap, event dedupe/status, subscription/payment state and verified period grant logic. Payload/event contract remains untested against a Dodo account. |
| `/api/chat` | POST | Authenticated SSE chat, history/attachments, model routing, credit reserve/settle, idempotency. |
| `/api/conversations` | GET/POST | Current user’s recent conversations and creation. |
| `/api/conversations/[id]` | GET/PATCH/DELETE | Owner-scoped conversation read/rename/soft-delete or delete according to route implementation. |
| `/api/files/upload-url` | POST | Authenticated upload metadata + short-lived signed R2 upload URL; format/size/purpose validation. |
| `/api/files/complete` | POST | Validate completed object metadata/bytes and mark file validated. |
| `/api/files/[id]` | DELETE | User-scoped uploaded-file delete flow. |
| `/api/library` | GET/POST | List/search current user’s Library and add allowed user-owned item links. |
| `/api/library/[id]` | DELETE | Remove/archive the current user’s Library item or uploaded file according to source parameter. |
| `/api/files/[id]/download` | GET | Owner-only short-lived signed attachment download. |
| `/api/models` | GET | Synchronized active catalogue, capability filters and bounded result count. No live upstream call is guaranteed on request. |
| `/api/images` | GET/POST | Authenticated image history/generation; verified catalogue price, credits, byte validation, private R2 and Library save. POST can incur provider cost. |
| `/api/images/[id]` | GET | Owner-scoped image job/status information. |
| `/api/videos` | GET/POST | Authenticated video history and asynchronous submit; POST returns accepted/pending status, persists job ID/poll URL, reserves credits. |
| `/api/videos/[id]` | GET | Owner-scoped polling/status and, on provider completion, bounded content download, R2 storage, Library and settlement. Polling route contacts provider only after a cooldown. |
| `/api/websites` | GET/POST | Authenticated Website history and standalone HTML generation. POST may incur provider cost and stores output to private R2/Library. |
| `/api/websites/[id]` | GET/PATCH | Owner-scoped HTML retrieval/edit save. Preview client runs code in sandbox; API returns content in authenticated JSON. |
| `/api/websites/[id]/download` | GET | Owner-scoped signed attachment URL for standalone HTML. |
| `/auth/callback` | GET | Supabase code/token exchange with constrained local-path `next` redirect. |

## Operational notes

- Most application routes use the Supabase service-role client for selected reads/writes, so RLS tests alone are not sufficient; verify explicit user predicates and cross-user behavior.
- Chat, website, image and video generation can spend OpenRouter credits. A real API response is not expected without an API key, synchronized model catalogue, verified pricing and user credits.
- Use `Idempotency-Key` for generation/checkout routes where required. Do not retry non-idempotent external operations blindly.
- Dodo webhook and generation `needs_review` cases currently require operator reconciliation. Do not clear held reservations without provider evidence.
- R2 URL expiry is currently 300 seconds. The bucket must remain private and CORS must match deployed origins.
- Server returns generalized error codes; inspect secure server/provider logs without recording secrets or user content.
