# Orindle complete deployment guide

**Audience:** beginner owner/operator. **State:** documentation only; no provider accounts, migrations, test events or deployment were performed. Follow in order and stop at a failed gate. Do not enable live payments until you explicitly approve.

## Before setup: know what exists

- Application code and a draft Supabase migration/RLS test exist in this repository.
- Static TypeScript/lint/unit/build checks pass in this audit branch.
- Supabase schema has not been applied or tested; provider credentials and external service behavior are unverified.
- Resend is not directly called by this code. Supabase Auth sends account email; configure SMTP separately if you choose Resend.
- Dodo uses product IDs and fixed amount guards in the code; there are no `DODO_PRICE_*_ID` variables.
- Use the exact environment names in [`ENVIRONMENT_VARIABLES_MASTER_GUIDE.md`](ENVIRONMENT_VARIABLES_MASTER_GUIDE.md).

## 1. Accounts and preparation

1. Create/verify owner-controlled GitHub, Supabase, OpenRouter, Cloudflare, Dodo, Arena, and Vercel accounts. Use [Resend](https://resend.com/) only if you intend to configure SMTP for Supabase Auth.
2. Turn on MFA wherever offered, especially GitHub, cloud storage, payments, DNS and hosting.
3. Use a password manager for database passwords and API secrets. Never paste secrets into a pull request, issue, log, screenshot or chat.
4. Keep a test/development account/project separate from production.
5. Decide the company/legal entity, support email, domain, privacy/retention policy, tax treatment, cancellation/refund policy, budget limits and incident owner before accepting customers.
6. Record your expected business domain and intended region. Select regions consistent with latency, data-residency and vendor terms.

## 2. GitHub repository

1. Open [GitHub](https://github.com/) and sign in.
2. Confirm the repository owner, name and visibility. Create a private repo called `orindle` only if you control the owner account and want a new private destination. The repository metadata seen in this audit referred to `sutarorg/orindle`; confirm its current visibility and ownership yourself before using it commercially.
3. If creating a new repository, use [github.com/new](https://github.com/new), choose **Private**, and do not upload secrets.
4. Connect the intended repo to Arena following [Arena’s Agent Mode guide](https://help.arena.ai/articles/1655691990-how-to-use-coding-in-agent-mode).
5. Review diffs and pull requests on GitHub; protect `main` with pull-request and check requirements. Never force push shared history to “fix” a deployment.

## 3. Supabase project

1. Open [Supabase Dashboard](https://supabase.com/dashboard) and sign in.
2. Create a test project under an owner-controlled organization, choose an available region, and store the generated database password securely.
3. Wait for the project to provision. Open project settings/API credentials. Copy the project URL and public publishable/anon key to `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY`.
4. Copy the server-only secret/service-role credential to `SUPABASE_SERVICE_ROLE_KEY`. This credential bypasses RLS; never expose it in browser code.
5. Set `APP_URL` and `NEXT_PUBLIC_APP_URL` to `http://localhost:3000` for local tests. Configure Auth’s Site URL to local and add exact `/auth/callback` redirect URLs.
6. Inspect `supabase/migrations/202611080001_core.sql` before applying. The current migration file has not been run against any database.
7. For a new disposable project, apply through the approved Supabase migration workflow. If using SQL Editor, paste the entire reviewed migration into a new query and run it only against an empty test project. Back up first; if this migration was already applied, do not edit history—write a new forward migration.
8. Inspect tables and RLS policy flags. Run `supabase/tests/rls_invariants.sql` using the database test workflow against a disposable local/test database. This workspace could only syntax-parse the tests.
9. Create normal test users and test ownership, profile/wallet creation, password recovery and auth redirects before moving to production.

## 4. Authentication and email

1. In Supabase Auth settings, set the local Site URL and allow `http://localhost:3000/auth/callback`.
2. When Preview exists, add its exact HTTPS callback URL. Add the production `https://your-domain/auth/callback` only after the domain is verified.
3. Do not allow arbitrary redirect origins. The callback constrains `next` to local paths.
4. Supabase Auth owns signup confirmation and password-recovery messages in current code. If using Resend, configure Resend as SMTP in Supabase Auth after domain authentication; no direct Resend key is used by the app.
5. Test a new mailbox: sign up, open the confirmation email, verify redirect, sign out/in, request password recovery and complete it. Check spam and avoid using staff personal mailboxes as customer test accounts.

## 5. OpenRouter

1. Open [OpenRouter](https://openrouter.ai/) and create a dedicated test API key with the smallest available spend limit.
2. Add `OPENROUTER_API_KEY` to local or Preview environment. Optional base/site values are listed in the master guide.
3. Sign in as an authorized admin in Orindle and call `POST /api/admin/models/sync` using the application’s protected admin route.
4. Inspect the stored active catalogue, modality metadata and price timestamps. Do not advertise a model as available unless its current synchronized record is active and supports that operation.
5. Run one low-cost chat call. Check streaming completion, history and cost basis. Only then, with explicit spend authorization, run one image and one video generation. Use provider dashboard spend to reconcile actual charges.

## 6. Cloudflare R2

1. Open [Cloudflare Dashboard](https://dash.cloudflare.com/) and create a separate private test bucket in R2 Object Storage.
2. Create a bucket-scoped credential with the minimum object read, write, delete and metadata-check permissions the application uses. Save key values securely.
3. Add `R2_ACCOUNT_ID`, `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`, and `R2_BUCKET` to the test environment. The S3 endpoint is constructed in code; there is no public-base-url setting.
4. Set CORS only for exact local/Preview origins and the signed upload method/headers. Verify the exact required headers from a browser network trace; no CORS policy was verified in this run.
5. Test an allowed small image/text upload, completed upload validation, download, expired signed link, deletion, and cross-user denial. Confirm public anonymous object access is disabled.
6. Select retention/backups/lifecycle only after approving data retention and privacy policy.

## 7. Dodo Payments — test mode

1. Create/verify your Dodo merchant account and confirm business eligibility, supported countries, recurring checkout, fixed INR localization, tax handling and settlement requirements directly with Dodo.
2. Use Dodo test mode. Create ORINDLE PRO monthly USD at exactly $14.99. If supported and approved, create fixed INR at exactly ₹1,399/month. Do not use FX conversion.
3. Copy test product IDs into `DODO_PRODUCT_USD_ID` and, only after verified fixed INR setup, `DODO_PRODUCT_INR_ID`. Keep code-side minor-unit guards exactly `1499` and `139900`.
4. Set `DODO_API_KEY` and `DODO_WEBHOOK_SECRET` from the matching test environment. Leave `DODO_ENVIRONMENT=test_mode` and `DODO_ENABLE_LIVE_BILLING=false`.
5. Configure Dodo test webhook at `https://<preview-host>/api/webhooks/dodo` with the event names supported by the current webhook handler. Verify current event names from Dodo docs/dashboard; do not assume an event name.
6. Use signed test events to verify signature rejection, duplicate delivery, delayed retries, amount/product/currency mismatch, initial successful billing, renewal and cancellation. Check one 1,500-credit grant per verified successful period.
7. A redirect to `/app/account?...checkout=return` is not proof of payment. Confirm signed event, subscription state and ledger grant.
8. Refund automation and full gross-margin reporting are not implemented. Do not promise them.
9. Do not change to live mode or enable live billing without the owner’s explicit approval.

## 8. Resend (optional SMTP for Supabase)

1. If selected, create a Resend account and add the sending domain in the current Resend dashboard.
2. Copy the exact SPF/DKIM DNS records shown for your account and add them to your DNS provider. Records differ by domain and account; never copy values from a sample.
3. Wait for the provider to report verified. Configure the current Resend SMTP credentials and From address in Supabase Auth SMTP settings.
4. Send a test email and verify inbox delivery and SPF/DKIM alignment. The app currently has no direct Resend SDK API integration or Resend environment variable.

## 9. Local `.env.local`

1. In the repository root (same folder as `package.json`), copy `.env.example` to `.env.local`.
2. Fill only test credentials and exact values. Keep `.env.local` out of Git.
3. Start with required Supabase/app origin settings. Then add provider values one at a time.
4. Keep Dodo test settings. Keep live billing disabled.
5. Restart `npm run dev` after every change. Verify protected routes fail closed when values are missing and work only after Supabase is configured.
6. Run `npm run typecheck`, `npm run lint`, `npm run test`, `npm run build`.

## 10. Vercel project and variables

1. Open [Vercel Dashboard](https://vercel.com/dashboard), connect GitHub, and import the exact intended repository.
2. Confirm Next.js detection and build command `npm run build`.
3. Open project Settings → Environment Variables (dashboard labels can change). Use [`ENVIRONMENT_VARIABLES_CLICK_BY_CLICK.md`](ENVIRONMENT_VARIABLES_CLICK_BY_CLICK.md).
4. Add Supabase/OpenRouter/R2/Dodo test settings to Preview only as needed. Use distinct credentials and origins for Development, Preview and Production.
5. Keep `DODO_ENVIRONMENT=test_mode` and `DODO_ENABLE_LIVE_BILLING=false` everywhere in this stage.
6. Save values and deploy a Preview. Read build logs. A new deployment is required after environment changes.
7. Commercial hosting: do not sell subscriptions on Vercel Hobby. Choose Vercel Pro or a provider/plan whose current terms expressly permit commercial SaaS. Verify pricing/terms in Vercel’s current plan documentation before buying; the agent cannot inspect your plan.

## 11. Preview and custom domain

1. Review successful Vercel deployment status and open its HTTPS preview URL.
2. Test public pages and auth route. Verify no console/network errors and no secret is present in browser bundles.
3. Add a custom domain in Vercel project settings. Copy the exact DNS records Vercel displays for that domain into your registrar/DNS provider. Do not reuse another user’s A/CNAME record.
4. Wait for domain verification and HTTPS certificate status. Test HTTP redirects to HTTPS and the exact canonical host.
5. Set `APP_URL` and `NEXT_PUBLIC_APP_URL` for the production origin in the Production scope; redeploy.
6. Add the exact production `/auth/callback` URL to Supabase’s allowed redirects; verify password reset and confirmation use the production host.
7. Update R2 CORS to exact production origin. Add Dodo webhook only for test until approved.

## 12. Test checkout and controlled validation

1. Confirm Dodo test credentials, product/price/currency and webhook secret match the same test account/environment.
2. Check the quote endpoint and visible account price. USD must show $14.99; INR can show ₹1,399 only with trusted India country and configured fixed INR product. Unknown/local location uses USD.
3. Complete a test checkout with provider test payment method, then confirm the webhook and database state. Do not use a real card.
4. Test duplicate webhooks; confirm one monthly grant per period. Test failed/expired/cancelled statuses and confirm they do not create an unauthorized new grant.
5. Test upload, private download, Website Builder preview, one image and one video job only after provider spend is authorized.
6. Review reservations/jobs marked `needs_review`; current recovery process is manual. Do not ignore a held balance or label it as a refund.

## 13. Final production configuration (approval required)

1. Finish all staging gates in `ORINDLE_POST_DEPLOYMENT_CHECKLIST.md`.
2. Review privacy, legal, subscription terms, refunds, taxes, rate limits, support, backups, monitoring and incident plans with responsible specialists.
3. Obtain owner approval for commercial host plan, production provider accounts, production Dodo products, DNS, production domain and any budget/spend limits.
4. Only after explicit payment approval, create production Dodo credentials/webhook/products, scope them to Production, and review every amount and currency. Never copy test credentials into production.
5. Use a separate approval to enable `DODO_ENVIRONMENT=live_mode` and `DODO_ENABLE_LIVE_BILLING=true`; redeploy only with that approval. This guide does not authorize live transactions.
6. Deploy the reviewed commit to Production. Keep the prior known-good deployment available for rollback.

## 14. Post-deployment verification and maintenance

Follow [`ORINDLE_POST_DEPLOYMENT_CHECKLIST.md`](ORINDLE_POST_DEPLOYMENT_CHECKLIST.md), [`MAINTENANCE_GUIDE.md`](MAINTENANCE_GUIDE.md), [`BACKUP_AND_RECOVERY.md`](BACKUP_AND_RECOVERY.md), and [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md). Record real outcomes, dates and operator. If any auth, tenant isolation, credit settlement, webhook, currency, private storage or TLS check fails, stop launch and restore the previous safe deployment.
