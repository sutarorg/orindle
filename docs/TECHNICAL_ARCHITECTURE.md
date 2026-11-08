# Technical architecture and verified implementation state

**Status:** source contains full-stack integration drafts. External services, database behavior and production operation are unverified. Read `IMPLEMENTATION_STATUS.md` and `FINAL_LAUNCH_STATUS.md` before treating any route as live.

## Runtime

- Next.js 15 App Router, React 19, strict TypeScript.
- Poppins self-hosted through `next/font/local`; Lucide icons; shared styling in `app/globals.css`.
- API handlers under `app/api`; protected page middleware under `middleware.ts`; server-side role checks in `lib/auth/server.ts`.
- Current UI has significant client-side composition in `components/app-shell.tsx`; bundle measurements are in `PERFORMANCE_AUDIT.md`.

## Data and auth

- Supabase Auth via `@supabase/ssr` with browser public key and server-only service-role admin client.
- PostgreSQL migration/RLS/RPC source in `supabase/migrations/202611080001_core.sql`.
- No production database URL or credentials are stored in the repo. Migration and RLS tests are not executed.
- API routes using the admin client must keep explicit user predicates; service-role calls bypass RLS.

## External service adapters

- OpenRouter chat, catalogue discovery/sync, image generation and asynchronous video endpoints in `lib/openrouter` and `/api` routes.
- Dodo Checkout Sessions, pricing selection, cancellation and verified webhook processing in `lib/billing` and `/api` routes. Defaults to test mode and uses fixed USD/eligible INR configuration.
- Cloudflare R2 S3-compatible operations in `lib/storage/r2.ts`; private bucket is expected.
- Resend is not directly integrated. Supabase Auth mail can use SMTP configured separately by an operator.

## Application paths

- Chat stores conversation/message history, validates uploads, performs model selection, streams provider response and settles credits.
- Image generation is synchronous provider work behind bounded route duration; outputs are validated and stored.
- Video submission is asynchronous (202 + persisted provider job ID); status route polls and finalizes output. There is no background worker; polling/resumption occurs through user requests.
- Website generation returns a standalone HTML file; editing/save and download are authenticated. Preview is a sandboxed `srcDoc` iframe with restrictive in-document CSP.
- Account and Library endpoints are owner-scoped. Admin page is guarded but dashboard remains a placeholder, not a production operations console.

## Rendering, caching and security

- Personalized API responses generally use `Cache-Control: private, no-store`.
- OpenRouter data is synchronized through an admin route; no scheduled refresh/freshness alert exists.
- R2 signed URLs currently expire after 300 seconds.
- Security headers are configured in Next response headers; HSTS/site-wide CSP are not yet configured or browser-verified.
- No distributed rate limiter, abuse/spend monitoring, backup worker, observability platform or automated credit-review worker exists.

## Deployment gates

- Verify commercial hosting terms and choose a plan that permits a paid SaaS; do not use Vercel Hobby for paid Orindle subscriptions.
- Apply/test schema and RLS on a disposable project before any user data.
- Set and test environment scopes; use test provider credentials and safe budgets.
- Complete external sandbox, browser/mobile/accessibility, rate-limit and backup/restore testing.
- Keep live billing disabled until explicit owner approval.
