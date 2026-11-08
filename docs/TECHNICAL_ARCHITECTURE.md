# Technical architecture

## Current frontend
- Next.js 15 App Router, React 19, strict TypeScript.
- Local Poppins weights 400/500/600/700 through `next/font/local`; self-hosted in `public/fonts`.
- Tailwind v4 installed and available, with an explicit CSS-token/design implementation in `app/globals.css` to preserve intentional art direction.
- Lucide React icon set; CSS-built demo UI assets avoid externally hosted images.
- Marketing page is mostly a client component because mobile navigation, capability previews and FAQ need local interaction. App shell and tool content are client components for local tabs, menu and filters. Later split server-rendered static copy/data from small client islands.

## Suggested full-stack boundaries for Prompt 2
1. Marketing/public server routes: localized, verified pricing and server catalogue data.
2. Auth boundary: provider/session-backed server auth; protected route groups/layouts, role-based admin access.
3. Application domain APIs: chat, model catalogue, image/video jobs, website artifacts, library, account/billing.
4. Service adapters: OpenRouter catalog/chat; image/video vendor adapters; Dodo Payments and verified webhooks; object storage for user files/artifacts.
5. Persistence: PostgreSQL with tenant/user scoping; encrypted secrets; object storage private by default; durable job/credit events.
6. Background job system: provider tasks with idempotency, status transitions, retries and cancellation.

## Rendering/caching
Catalogues should be refreshed server-side on a controlled cadence and cached with a timestamp; do not expose upstream secrets. Treat catalogue invalidation and stale availability explicitly. Public model claims should be derived from verified data. Dynamic location/pricing decisions must be made server-side, with USD fallback. Do not cache personalized billing responses across users.

## Failure and observability
Define typed provider errors, rate limiting, timeouts, retry budgets, request IDs, redacted logs, audit events and dead-letter handling. Do not log prompt/file contents by default. Add health checks and alerts for catalogue sync, payment webhooks, generation failures and credit reconciliation.

## Current limitations
No backend, database, auth, integration, server route or data persistence was present at repository start. This milestone is frontend-only. UI routes and form controls are not proof that underlying features work. `app/admin` currently has no guard and must not be deployed as-is.
