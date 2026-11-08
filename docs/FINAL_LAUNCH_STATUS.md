# Orindle final launch status

**Audit date:** 2026-11-08 UTC
**Branch:** `arena/60c50522-orindle`
**Base:** `main` at `7467475` (merged Prompt 2 baseline)
**Status:** **NOT APPROVED FOR COMMERCIAL PRODUCTION.** The code is a connected integration draft with static verification; external services and live workflows remain unverified. This is not a formal security certification.

## Completed in this audit branch

- Read `AGENTS.md` and the available product, architecture, design, landing and app UI specs. The requested Prompt 3 history docs (`FINAL_DATABASE_SCHEMA`, `API_ENDPOINTS`, `IMPLEMENTATION_STATUS`, `CREDIT_ENGINE`, `OPENROUTER_INTEGRATION`, `DODO_PAYMENTS`, `VIDEO_STUDIO`, `SECURITY_IMPLEMENTATION`, `ENVIRONMENT_VARIABLES`, `HANDOFF_TO_PROMPT_3`) were absent at audit start; the actual source and existing Prompt 2 handoff/setup docs were used instead.
- Installed lockfile dependencies with `npm ci` and ran typecheck, lint, unit tests and production build; see `QA_TEST_REPORT.md` for exact scope.
- Smoke-requested public and auth pages from local Next.js, and verified protected routes fail closed with missing Supabase settings.
- Syntax-parsed migration and RLS test SQL (129 and 10 statements); no database was available for execution.
- Fixed a confirmed settlement permission flaw in the draft migration: ordinary authenticated users may no longer call the credit settlement/review RPCs. Service routes now settle using server-only service role. Added a test assertion.
- Held credit reservations for ambiguous provider outcomes and added explicit `actual` vs `estimated` cost basis tracking to generation records.
- Added baseline response security headers (nosniff, same-origin frame restriction, referrer policy, camera/microphone/geolocation restriction).
- Created the QA, security, design, performance, environment, setup, deployment, post-deployment, maintenance, backup/recovery and troubleshooting documents.

## Not completed / cannot be claimed

- No Supabase account/database was configured; migration and RLS tests were not executed against Postgres.
- No OpenRouter, Dodo, R2 or email-provider test/live API request was performed. No signup, real model response, image/video generation, checkout, webhook, email delivery, upload or cross-user test was run.
- No screenshots, browser automation, six viewport render review, accessibility scan or Lighthouse score was captured. The environment had no browser binary/Playwright/Puppeteer.
- Current admin UI is a restricted placeholder, not a users/models/credits/subscriptions/payments/generations dashboard or profitability report.
- Admin gross margin is not calculable from current data: payment processing fees, storage/infrastructure allocations and other variable costs are not comprehensively recorded; only model cost has actual/estimated basis. The 80% target is not a measured result or guarantee.
- No refunds/chargebacks workflow, durable rate-limit/abuse system, automated credit review/reconciliation worker, privacy retention scheduler, tested backup/restore, monitoring/alerting, or customer-support workflow is complete.
- Current integration/operations dashboard click paths could not be checked against live authenticated current dashboards. The manual contains explicit caveats and official links; operators must verify current UI/provider eligibility and webhook/API payloads directly.

## Severity summary

- **Critical — addressed in source draft; database deployment gate:** authenticated client execution of settlement RPC was possible in baseline SQL. Updated migration blocks this; it must be applied as a forward migration and tested before serving user traffic.
- **High — launch blockers:** no executed tenant-isolation/RLS tests; no provider/payment/storage E2E validation; no durable request rate limits/abuse controls; no operational reconciliation/alert process; no production browser/accessibility review.
- **Medium — launch blockers for a commercial release:** no reporting of true gross margin/fees; no automated refunds; no validated retention/backup/restore; no direct Resend integration; global HSTS/CSP not yet configured and browser-tested.
- **Low — follow-up:** design typography/contrast/target-size inspection at actual reference widths and optimize client bundle only after profiling.

## Exact verification outcomes

- `npm ci`: pass, 527 packages added; 0 known vulnerabilities reported at run time.
- `npm run typecheck`: pass.
- `npm run lint`: pass.
- `npm run test`: pass, 8 tests in 2 files.
- `npm run build`: pass, Next.js 15.5.29.
- `npm run check:env`: default reports missing/placeholder names without values and exits successfully; strict mode correctly exits 1 because this workspace has no app credentials.
- Local relative links in `docs/*.md`: pass. External documentation links were not fetched/verified under network restrictions.
- `npm audit`: 0 reported known vulnerabilities at audit time.
- SQL syntax parse: 126 migration statements and 10 RLS test statements parse; syntax only.
- HTTP smoke: public/auth pages returned 200; `/app/*` and `/admin` redirected to login because Supabase is unconfigured; `/api/models` returned 503 `service_not_configured`.
- Browser screenshots, E2E, database tests, external provider tests, live payment test: not run.

## Go/no-go

**NO-GO for production commercial launch now.** A staged private Preview can be prepared by the owner with test credentials after completing the documented Supabase migration/RLS gate. Live payments must remain disabled. A production launch requires a separate owner approval after all critical/high gates in `ORINDLE_POST_DEPLOYMENT_CHECKLIST.md` pass.

---

# YOUR COMPLETE ORINDLE LAUNCH GUIDE

You do not need to share passwords or keys with Arena. Keep every secret in your password manager, `.env.local`, or the correct private Vercel environment scope. Never paste a key into this chat.

## Things the development work has prepared

- Application routes and service adapters for Supabase, OpenRouter, Dodo and private R2.
- Example environment names, migration draft, RLS test draft, and detailed checklists.
- Static checks and a local route smoke test.
- Dodo is still gated to test mode; no live payment setup was performed.

## Actions you personally must take

1. **GitHub — confirm the repository.** Open [GitHub](https://github.com/), sign in, and confirm the Orindle repository owner, visibility and `main` branch. The repository metadata observed in this audit referred to `sutarorg/orindle`; confirm it is the repository you intend to own/use. If your commercial project needs a private repository, create/transfer to an owner-controlled private repo using [github.com/new](https://github.com/new) and review access before connecting it. Follow the [Arena GitHub connection guide](https://help.arena.ai/articles/1655691990-how-to-use-coding-in-agent-mode).
2. **Supabase — create a test project.** Open [Supabase Dashboard](https://supabase.com/dashboard), create a project in an appropriate region, and save the database password securely. Wait for the project to show ready.
3. **Supabase — copy the URL and public key.** In the project’s settings/API credentials, copy the Project URL to `NEXT_PUBLIC_SUPABASE_URL`, then copy the publishable/anon public key to `NEXT_PUBLIC_SUPABASE_ANON_KEY`. These are the only Supabase values intended for browser use.
4. **Supabase — copy the secret key.** In the same project key area, copy the server-only secret/service-role key to `SUPABASE_SERVICE_ROLE_KEY`. Never use a `NEXT_PUBLIC_` prefix for it and never share it in chat.
5. **Supabase — configure Auth and database.** Add the exact local/Preview/production `/auth/callback` URLs under Auth redirects. Review then apply the SQL migration to a disposable test project only; run the RLS test workflow against a test database. This has not been done yet. Do not run the draft against production without review/backup.
6. **OpenRouter — create a capped test key.** Open [OpenRouter](https://openrouter.ai/), use the account’s API key section, create a dedicated key, set the smallest useful spend limit and save it privately as `OPENROUTER_API_KEY`. Add credits only after reviewing model pricing and testing budget.
7. **Cloudflare R2 — create a private test bucket.** Open [Cloudflare Dashboard](https://dash.cloudflare.com/), find R2 Object Storage, create a private bucket, copy its account ID/name, then create a bucket-scoped access token with the minimum required read/write/delete permissions. Store values as `R2_ACCOUNT_ID`, `R2_BUCKET`, `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`. Configure CORS for exact app origins/method/headers and test signed upload/download; never make the bucket public.
8. **Dodo — create test product(s).** Open [Dodo](https://dodopayments.com/) and its [official docs](https://docs.dodopayments.com/). Confirm your account supports recurring checkout and fixed INR localization. Create ORINDLE PRO at $14.99/month USD. Create fixed ₹1,399/month INR only if supported/approved; otherwise leave INR product blank. Never use FX conversion.
9. **Dodo — add test keys/webhook.** Create test API credentials and a test webhook at `https://<your-preview-origin>/api/webhooks/dodo`. Copy test API/webhook secrets to `DODO_API_KEY` and `DODO_WEBHOOK_SECRET`; copy product IDs to `DODO_PRODUCT_USD_ID` and optional `DODO_PRODUCT_INR_ID`. Keep `DODO_PRICE_USD_MINOR=1499`, `DODO_PRICE_INR_MINOR=139900`, `DODO_ENVIRONMENT=test_mode`, `DODO_ENABLE_LIVE_BILLING=false`. Verify signed webhook events. A browser redirect alone is not proof of payment.
10. **Resend — only if configuring Supabase SMTP.** Open [Resend](https://resend.com/), add your domain, copy the exact SPF/DKIM records shown in your account to your DNS provider, wait for verification, then configure SMTP in Supabase Auth. The current app does not read a Resend API key.
11. **Create local `.env.local`.** In the root Orindle project folder (same folder as `package.json`), copy `.env.example` to `.env.local`. Fill test values following [`ENVIRONMENT_VARIABLES_MASTER_GUIDE.md`](ENVIRONMENT_VARIABLES_MASTER_GUIDE.md). Save, confirm `.env.local` is ignored by Git, then restart the dev server. Do not send values here.
12. **Run locally.** Install with `npm ci`; run `npm run dev`. Verify login, protected-route behavior and public routes. Then run typecheck, lint, tests and build. Do not attempt generation until you deliberately authorize provider spend.
13. **Connect Vercel to GitHub.** Open [Vercel Dashboard](https://vercel.com/dashboard), connect GitHub and import the intended Orindle repository. Confirm Next.js build settings. Do not use the Hobby plan for a paid commercial subscription SaaS; select Vercel Pro or another plan/provider that explicitly permits commercial use, after checking current terms/pricing.
14. **Add Vercel Preview variables.** Under the Orindle project Settings → Environment Variables, set the exact names in `ENVIRONMENT_VARIABLES_MASTER_GUIDE.md` for Preview with test credentials. Keep Development/Preview/Production values separated. Save and redeploy after changes.
15. **Deploy a Preview.** Open the preview URL and inspect build logs. Complete `ORINDLE_POST_DEPLOYMENT_CHECKLIST.md` on test credentials. Verify actual provider calls only with owner-approved budgets; verify two-user data boundaries and RLS in the test DB.
16. **Configure the production domain.** Add the domain in Vercel, copy only the DNS records Vercel displays, and add them at your domain registrar. Wait for domain verification and HTTPS. Never use a guessed A/CNAME value.
17. **Set production origins.** Set Production `APP_URL` and `NEXT_PUBLIC_APP_URL` to the exact HTTPS origin. Add production `/auth/callback` in Supabase Auth redirect settings. Update R2 CORS for that exact origin. Redeploy and verify email links and HTTPS.
18. **Approve live payments only after gates pass.** Review Dodo production eligibility, products, USD/INR amounts, taxes, cancellation/refund terms, webhook delivery and owner budget. Live billing is not approved by this guide. You must explicitly authorize it before anyone sets `DODO_ENVIRONMENT=live_mode` and `DODO_ENABLE_LIVE_BILLING=true`.
19. **Deploy the approved release.** Review the GitHub PR, required checks and exact commit. Deploy only after your approval. Keep the prior deployment available for rollback.
20. **Verify production without guessing.** Follow every applicable item in `ORINDLE_POST_DEPLOYMENT_CHECKLIST.md`. Record evidence and outcomes. If auth, cross-user privacy, payment integrity, credits, private storage, domain or TLS checks fail, stop and roll back/disable the affected integration.

For step-by-step provider environment entry, see [`ENVIRONMENT_VARIABLES_CLICK_BY_CLICK.md`](ENVIRONMENT_VARIABLES_CLICK_BY_CLICK.md). For operations after launch, use maintenance, backup and troubleshooting guides. No secrets are requested here.
