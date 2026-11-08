# Orindle

Orindle is a Next.js multi-model AI workspace. This branch contains the application UI and draft integrations for Supabase Auth/Postgres, OpenRouter, Dodo Payments, and private Cloudflare R2 storage. Provider-backed features require credentials and configured external services; no live provider calls, database migration, billing, or production deployment have been performed from this workspace.

## Run locally

```bash
npm install
cp .env.example .env.local
# Fill in the required sandbox/development values before using connected features.
npm run dev
```

The development and start scripts bind to `0.0.0.0:3000`. Run the local checks with:

```bash
npm run typecheck
npm run lint
npm run test
npm run build
npm run check:env
```

## Integration setup and release gates

See [docs/SETUP_AND_HANDOFF.md](docs/SETUP_AND_HANDOFF.md) before configuring external services. It covers Supabase migration/RLS review, auth URLs, OpenRouter model sync, private R2 setup, and Dodo sandbox products/webhooks. **Dodo must stay in `test_mode`; do not enable live billing without explicit approval.**

Current billing rules are fixed: ORINDLE PRO is $14.99/month (USD); ₹1,399/month is available only when Vercel reports trusted country `IN` and the fixed INR product/price is configured. No foreign-exchange conversion is used. The 1,500-credit grant is tied to a verified successful subscription-period webhook, never to the checkout return redirect.

## Product and design references

- [Product requirements](docs/PRODUCT_REQUIREMENTS.md)
- [Architecture](docs/TECHNICAL_ARCHITECTURE.md)
- [Security requirements](docs/SECURITY_REQUIREMENTS.md)
- [Prompt 2 handoff](docs/HANDOFF_TO_PROMPT_2.md)
