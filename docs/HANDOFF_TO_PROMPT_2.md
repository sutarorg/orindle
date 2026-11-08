# Handoff to Prompt 2

## What exists
A new Next.js App Router frontend foundation with a premium white/mint Orindle visual direction. Root marketing page includes the complete long-form section sequence, responsive CSS composition, selectable Chat/Images/Videos/Websites capability previews, responsive navigation, interactive FAQ, USD-only ORINDLE PRO presentation and a clearly illustrative product/demo preview. The app has a coherent sidebar, tool layouts, account menu, demo states, auth form screens, account settings foundation, catalogue placeholder, admin foundation, and draft information pages.

## Routes implemented
- `/`
- `/models`
- `/about`, `/contact`, `/privacy`, `/terms`, `/refund-policy`
- `/login`, `/signup`, `/forgot-password`, `/reset-password`, `/verify-email`
- `/app/chat`, `/app/images`, `/app/videos`, `/app/websites`, `/app/library`, `/app/account`, `/admin`

## Reusable components
- `components/brand.tsx`: wordmark and provisional orbit mark.
- `components/marketing.tsx`: landing page, original CSS product mockup, capability tabs and FAQ.
- `components/app-shell.tsx`: shell, five-link nav, demo chat, image/video/website/library/models/account/admin views.
- `components/auth.tsx`: route-aware authentication presentation only.
- `components/info-page.tsx`: About/contact/policy disclosure pages.
- `components/ui/button.tsx`, `components/ui/card.tsx`: shadcn-style local primitives using Radix Slot and class-variance-authority.
- Shared global styles/tokens and responsive rules: `app/globals.css`.

## Implemented tokens and type
Poppins is self-hosted (400/500/600/700) and loaded via `next/font/local`. Palette is declared in CSS custom properties: white, soft neutral/mint, ink/muted, green, forest and pale cyan/mint. Layout targets max 1220px, subtle 1px borders, moderate radii, low-opacity shadows, responsive layouts and reduced-motion support.

## Temporary/demo data and non-functional UI
- Product preview (fictional design studio), use-case cards, task-category chips, recent chats, 1,240 credit balances, demo user, sample library cards, account details, billing values and illustrative generation previews are fixtures.
- Catalogue is not synchronized. No current model names/count are asserted; no `100+` numeric claim is shown. The 100+ tagline must remain gated until live verification.
- Forms do not submit; auth, password recovery and email verification are visual-only.
- Chat, model selection, file upload, image/video generation, website generation, downloads, library persistence, account/billing and subscription cancellation are not connected.
- Current prices are static USD preview only. No India location determination or Dodo product selection exists.
- Legal pages explicitly state they are not published; no verified support channel is configured.
- `/admin` is not protected. It is a blocker: implement server-side role checks or remove/redirect before deployment.

## Integration status
OpenRouter, Dodo Payments, database, auth, file storage, image/video provider(s), email, logging/analytics, social profiles and support remain unconnected. Do not enable live payment transactions as part of frontend prompt completion.

## Environment variables
`.env.example` lists placeholders: `OPENROUTER_API_KEY`, `OPENROUTER_BASE_URL`, `DATABASE_URL`, `AUTH_SECRET`, `DODO_PAYMENTS_API_KEY`, `DODO_PAYMENTS_WEBHOOK_SECRET`, `DODO_PRODUCT_ID_USD`, `DODO_PRODUCT_ID_INR`, `NEXT_PUBLIC_APP_URL`. None are currently required to render the design.

## Preserve during Prompt 2
- Five primary sidebar destinations and their exact order; account settings/billing accessible from account menu.
- Only ORINDLE PRO; prices $14.99/month international and ₹1,399/month India; 1,500 monthly credits. Never display both currencies in one pricing view; USD fallback.
- Server-verified 100+ threshold after alias deduplication; no invented/discontinued model IDs.
- Honest demonstration labels until integrations work; no false customer proof.
- Standalone HTML scope (not full-stack generation); no prohibited features.
- Preserve Poppins and existing CSS tokens and responsive patterns; do not replace with generic admin template styles.
- Keep privacy, security, cost/credit transparency and user-controlled cancellation as release requirements.

## Build and visual-review status
The project scripts are `npm run typecheck`, `npm run lint`, `npm run build`, `npm run dev`. Build/type/lint results must be recorded after running. No browser screenshots or full-page visual audit have yet been completed. Prompt 2 should use a browser preview at desktop and mobile reference sizes, fix visible regressions and document what was actually inspected.
