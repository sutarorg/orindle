# Click-by-click account setup for Orindle

**Reader:** beginner. **Status:** provider accounts have not been accessed by this agent. Dashboard labels can change, and no secrets or IDs are supplied here. This guide gives verified code-side names and safe navigation routes; when an exact live dashboard label cannot be confirmed, it says so rather than inventing a button name. Use each provider’s current official help/search if the menu differs.

## Before you begin

- Create accounts in your own name/business and retain account recovery access.
- Keep a password manager open. Save API secrets there, not in email/chat/screenshots.
- Start with test/development projects and credentials. Do not enable Dodo live billing.
- The current code reads exact environment names from [`ENVIRONMENT_VARIABLES_MASTER_GUIDE.md`](ENVIRONMENT_VARIABLES_MASTER_GUIDE.md).
- The repository history available in this workspace says the GitHub repository is `sutarorg/orindle`. Provider accounts and project IDs were not supplied.

## A. GitHub and Arena

Official links: [GitHub](https://github.com/), [Arena Agent Mode](https://arena.ai/agent), [Arena connection guidance](https://help.arena.ai/articles/1655691990-how-to-use-coding-in-agent-mode).

### Create or confirm a private repository

1. Sign in to GitHub.
2. Open the **+** menu near your profile and choose the repository creation action. If the label differs, open [GitHub’s new repository page](https://github.com/new).
3. Enter repository name `orindle` and select **Private**.
4. Do not initialize with an unrelated README/license if you plan to push this existing app. Create the empty repository only if you have permission to create it in the correct owner account.
5. Confirm the repository owner/name and visibility on its main page. The currently connected upstream in the audit metadata was `sutarorg/orindle` and reported public; changing ownership/visibility is an owner decision. Do not silently assume this sandbox is private.
6. Connect GitHub to Arena using Arena’s documented GitHub connection flow. Approve only the intended account/repository if fine-grained selection is offered. Never paste a token into chat.
7. In Arena Agent Mode, select the intended repository and open the workspace. Verify the displayed repository and branch before edits.
8. Review changes with the changed-file list and diff; review the branch, commits, automated checks and PR base/head before merging.
9. For main-branch protection, open the repository **Settings** and find **Rules** / branch rules (GitHub may present rulesets instead of classic branch protection). Select `main`; require pull requests and required checks, block force pushes/deletion, and choose whether administrators may bypass. Save and verify the rule is active.
10. Understand: a branch is a parallel line of work; a commit is a saved change set; a pull request proposes merging a branch into `main`; merging updates the destination branch. Do not force-push or delete branches with unmerged work.

### Safely continue in Arena

1. Visit [Arena Agent Mode](https://arena.ai/agent) and ensure GitHub connection is enabled.
2. Select the repository that should receive the final application, not a similarly named copy.
3. Open the session workspace and confirm `git branch --show-current` matches the requested branch.
4. Inspect `git status`, the diff and test output before asking the agent to commit/push/open a PR.
5. Review the pull request on GitHub, its base/head, file changes and checks; merge only after you approve.
6. Arena works in its own sandbox clone and can manage Git commits and pull requests. Keep completed work merged or safely pushed before starting another stage. Follow the Arena help link above for current UI wording.

## B. Supabase

Official dashboard: [Supabase Dashboard](https://supabase.com/dashboard). The menu wording can vary by project and the dashboard was not opened during this audit.

### Create a test project and obtain client settings

1. Sign in or create a Supabase account.
2. Create/select an organization if the dashboard requests one. Choose an organization you control.
3. Select **New project** (or the equivalent project-creation button).
4. Choose a clear project name such as `orindle-test`, select an available region near the intended users/provider, and generate a strong unique database password. Store it in your password manager; it is not an app environment variable in this code.
5. Wait until provisioning reports the project is ready.
6. Open that project’s **Project Settings** and locate the API/project connection section. Copy the project URL into `NEXT_PUBLIC_SUPABASE_URL`.
7. In the same API/keys section, select the browser-safe **publishable** key (or legacy **anon/public** key). Paste into `NEXT_PUBLIC_SUPABASE_ANON_KEY`. Do not use a secret/service-role key in this variable.
8. Locate the server-side **secret** key (or legacy `service_role` key) and paste only into `SUPABASE_SERVICE_ROLE_KEY`. It bypasses RLS. Never put it in a browser, screenshot, `NEXT_PUBLIC_` variable or chat.
9. In **Authentication** settings, open the URL/site configuration. Set the Site URL to the local app origin during local testing, and add the exact local callback URL `http://localhost:3000/auth/callback` to allowed redirect URLs. Add each exact Vercel preview/production callback after those domains exist. Do not use a wildcard redirect for production unless Supabase explicitly documents and you understand the risk.
10. Email confirmation and password recovery use Supabase Auth. Configure a supported custom SMTP provider (Resend is not currently wired as a direct API integration; see section F). Set From identity only after its domain is verified.

### Apply and verify the database draft

1. Confirm the target is a **disposable test project**. The migration has never been applied in this workspace; it changes core tables and functions.
2. Open **SQL Editor** in the project and create a new query. Paste the reviewed contents of `supabase/migrations/202611080001_core.sql`. Run once only after a backup/empty test project check. Do not run it in production merely to see what happens.
3. Inspect the result for errors. Open **Table Editor** and check for the expected tables (profiles, conversations, messages, wallets/reservations, subscriptions, generation jobs/assets, uploaded files and Library). Open the table’s RLS/policies view and confirm row-level security is enabled.
4. Important: the RLS invariant test is a separate transaction-based test script and is not guaranteed to work by pasting into a production SQL editor. Run `supabase/tests/rls_invariants.sql` using the project’s approved local/test Supabase database workflow. This workspace lacks Supabase CLI/Postgres, so the author did not execute it.
5. Verify account creation creates a profile, role, preference and zero-credit wallet. Verify a normal user cannot execute settlement or modify wallet/role/pricing tables.
6. Do not turn on public app access until the updated service-only settlement functions and all cross-user tests pass.

## C. OpenRouter

Official site: [OpenRouter](https://openrouter.ai/). The API key management URL/menu was not accessed; use the account’s current Settings/API Keys navigation.

1. Create/sign in to an account at OpenRouter.
2. Open account settings and choose its API key management section.
3. Create a new key dedicated to Orindle development. Give it a descriptive name. Apply a spend/credit limit if offered; keep a deliberately small test budget.
4. Copy the key once and save it in a password manager. Put it in `OPENROUTER_API_KEY` in local `.env.local` or the matching Vercel Preview environment.
5. Add test credits/payment method only if required by your account and after reviewing provider pricing. Do not add a high/unlimited budget for QA.
6. In Orindle, sign in with an authorized admin, run `POST /api/admin/models/sync`, and check the result and synchronized database catalogue. Model count, modalities and prices must be verified from the live catalogue; the app must not assert “100+” unless the alias-deduplicated current chat model count meets that gate.
7. Test chat with a low-cost selected model first. Confirm response stream, persisted history, actual usage or explicitly estimated cost basis, and credit settlement.
8. Test image and video only with owner authorization. Generation prices vary by model, image count/output parameters, video model, duration, resolution and provider response. Video generation is asynchronous; one test job is enough to verify the flow. Monitor OpenRouter spend immediately.
9. Do not expose the key through browser devtools, client environment variables, logs, screenshots or chat.

## D. Cloudflare R2

Official dashboard: [Cloudflare Dashboard](https://dash.cloudflare.com/). Use Cloudflare’s current R2 docs and in-dashboard guidance; this audit did not sign in or inspect current labels.

1. Sign in to Cloudflare and select the account that will own Orindle storage.
2. Open **R2 Object Storage** from the account dashboard navigation/search.
3. Create a bucket named for the environment (for example, a test-only Orindle bucket). Keep it private; do not enable public object access/custom domain for user uploads.
4. Copy the account identifier shown in R2/account details to `R2_ACCOUNT_ID`.
5. In R2 API tokens/credentials, create a token scoped to only the required bucket and minimum operations used by code: object read (`GetObject`), write (`PutObject`), delete (`DeleteObject`) and metadata/head checks (`HeadObject`). Do not grant account-wide administration or public access if bucket-scoped permissions are available.
6. Copy the generated Access Key ID to `R2_ACCESS_KEY_ID` and Secret Access Key to `R2_SECRET_ACCESS_KEY`. The secret is usually shown only once; save securely.
7. Set `R2_BUCKET` to the exact bucket name. The app builds the S3 endpoint as `https://<R2_ACCOUNT_ID>.r2.cloudflarestorage.com`; there is no `R2_ENDPOINT` variable.
8. For browser-to-bucket signed uploads, configure CORS only for exact local and production app origins. Match the actual browser request method (`PUT`) and signed request headers (currently `Content-Type`; verify any signed headers from the generated upload URL). Expose response headers only if the browser needs them. Do not use `*` origins for production. Cloudflare’s current CORS editor/JSON shape may vary; follow its official R2 CORS docs rather than copying a guessed UI screenshot.
9. Test a small allowed file upload, then a signed download. Try a different user and an expired URL; both must be denied. Confirm a public anonymous bucket URL does not work.
10. Set expiration/lifecycle rules only after confirming retention and legal policy. No R2 retention policy is configured by this app.

## E. Dodo Payments (test mode only)

Official pages: [Dodo Payments](https://dodopayments.com/) and [Dodo documentation](https://docs.dodopayments.com/). Current product labels/features/eligibility have not been inspected from an authenticated account. Confirm availability before relying on these instructions.

1. Create/sign in to a merchant account and complete the onboarding/eligibility requests Dodo currently requires. Do not enter live credentials into local development.
2. Enable/select Dodo’s test/sandbox environment first.
3. Open the product/catalog management area and create ORINDLE PRO as a recurring monthly product.
4. Configure the fixed USD amount to exactly $14.99 monthly. Verify the product’s currency, monthly interval, amount, and tax/checkout display in the provider’s test preview.
5. If India fixed localization is available and approved for the account, create/configure a distinct matching fixed INR product at exactly ₹1,399/month. Confirm product-level/localized checkout behaves as INR. Do not use automatic FX conversion. If Dodo cannot provide this supported fixed INR configuration, leave `DODO_PRODUCT_INR_ID` blank; the app intentionally falls back to USD for that currency path.
6. Copy the exact test USD product ID to `DODO_PRODUCT_USD_ID`; copy the matching India product ID to `DODO_PRODUCT_INR_ID` only after verifying it. Set `DODO_PRICE_USD_MINOR=1499` and `DODO_PRICE_INR_MINOR=139900`. The latter variables are code-side amount guards, **not Dodo price IDs**. Current code does not read price identifier variables; check Dodo’s product-cart model before creating additional configuration.
7. In the account’s test API credentials section, create/copy a test API key to `DODO_API_KEY`. Keep `DODO_ENVIRONMENT=test_mode` and `DODO_ENABLE_LIVE_BILLING=false`.
8. In webhook settings, add the test endpoint `https://<your-preview-host>/api/webhooks/dodo`. Select event types matching the implementation (`payment.succeeded`, `subscription.active`, `subscription.renewed`, `subscription.cancelled`, `subscription.expired`, `subscription.past_due`, `subscription.on_hold`, `subscription.failed`, `subscription.paused`, `subscription.unpaused`, `subscription.updated`). Confirm the current dashboard actually provides these exact event names; do not subscribe based on assumptions.
9. Copy that endpoint’s **test signing secret** to `DODO_WEBHOOK_SECRET`. Test an invalid signature, valid activation, renewal replay, delayed webhook, cancellation and product/currency/amount mismatch.
10. Complete one test checkout. A browser return/redirect proves only that the browser returned; it is not payment proof. Verify `subscriptions`, signed `webhook_events`, `payment_records`, and the unique monthly `credit_grants` record. Only a verified successful billing-period event should grant 1,500 credits.
11. Test cancellation at period end and confirm entitlement/credits follow verified provider state. A refund workflow is not implemented; do not promise automated refunds.
12. Do not enable live mode or live Dodo credentials without explicit owner approval and a separate launch review.

## F. Resend / email

Official site: [Resend](https://resend.com/). **Current Orindle code does not directly use the Resend SDK or read a Resend API key.** Signup, verification and recovery mail are initiated through Supabase Auth.

1. If you want Resend as the Supabase Auth SMTP provider, create a Resend account and follow its current official domain/SMTP setup docs.
2. Add your sending domain in the Resend Domains area. Copy the exact SPF/DKIM DNS records that your own account displays. DNS record names/values are unique to the account; do not use example records from this guide.
3. Add each record to the domain’s DNS provider exactly as supplied. Wait for Resend’s domain verification to pass.
4. Configure the Resend SMTP integration in Supabase Auth email/SMTP settings using the SMTP credentials and verified sender address from the current Resend instructions.
5. Send Supabase’s test email and verify inbox delivery, spam folder, SPF/DKIM alignment and recovery redirect.
6. Do not add `RESEND_API_KEY` to Orindle’s environment until a direct Resend integration is implemented. It is not currently read by code.

## G. Arena AI

Official links: [Arena Agent Mode](https://arena.ai/agent), [Arena connection guidance](https://help.arena.ai/articles/1655691990-how-to-use-coding-in-agent-mode).

1. Open Agent Mode and sign in.
2. Use the GitHub connection action to connect the account/repository. Approve only the repository you intend to work on.
3. Select the correct Orindle repo, then start or resume the relevant coding session.
4. Open the workspace and verify the branch name before edits.
5. Review changed files, test output, commits and `git status`.
6. Push only the session branch; inspect the pull request base/head and CI checks on GitHub.
7. Merge only when you approve. Ensure prior work is merged or safely preserved before starting a new session/branch.

Arena’s Agent Mode uses a repository sandbox and can manage Git commits and pull requests; UI labels can change. Use the help article for current navigation.

## H. Vercel

Official dashboard: [Vercel Dashboard](https://vercel.com/dashboard). Exact menus were not inspected from an account.

1. Create/sign in to a Vercel account.
2. Connect the GitHub account that owns the deployment repository.
3. Use **Add New Project** / import flow and choose the exact Orindle repository. Confirm framework detection is Next.js.
4. Keep the default Next.js build settings unless the build output identifies a specific issue. Current app commands are in `package.json`; build is `npm run build`.
5. Before deploying, open project settings and environment variables. Add exact values using [`ENVIRONMENT_VARIABLES_CLICK_BY_CLICK.md`](ENVIRONMENT_VARIABLES_CLICK_BY_CLICK.md). Use test Supabase/OpenRouter/R2/Dodo credentials for Preview. Set scopes deliberately.
6. Deploy a Preview. Read the complete build log; fix missing variables and redirect settings before sharing.
7. Connect a custom domain only after selecting a commercial-appropriate hosting plan. Add the domain in Vercel’s domain settings and copy the DNS instructions Vercel displays into your DNS provider exactly. Do not invent A/CNAME values; they vary by domain/provider.
8. Verify Vercel indicates domain ownership/SSL is valid and the site opens via HTTPS.
9. Add the exact production origin and `/auth/callback` redirect to Supabase; use separate Preview origins for preview deployments.
10. Verify test checkout, webhook delivery, storage CORS, auth email and uploads on Preview.
11. **Commercial hosting warning:** do not launch a paid Orindle subscription on Vercel Hobby. Orindle is a commercial subscription SaaS. Use Vercel Pro or another hosting plan/provider that explicitly permits commercial use, and confirm current official terms and pricing before purchase. This account’s plan was not checked by the agent.
12. Do not deploy production billing or switch Dodo to live without owner approval.
