# Environment variables: click-by-click guide

**Use with:** [`ENVIRONMENT_VARIABLES_MASTER_GUIDE.md`](ENVIRONMENT_VARIABLES_MASTER_GUIDE.md) and [account setup](CLICK_BY_CLICK_ACCOUNT_SETUP.md).

The master guide is derived from source. This workspace cannot sign in to your provider dashboards or verify the current appearance of their menus. Dashboard labels may change or vary by account. Use the official links below and confirm the credential purpose before copying anything; do not paste secrets into this conversation.

## A. Local development: create `.env.local`

1. Open the Orindle repository folder on your computer. The folder is the one containing `package.json`, `app/`, and `supabase/`.
2. In that top-level folder, create a new plain-text file named **`.env.local`** (the leading dot is part of the filename). Do not create it inside `app/` or `docs/`.
3. Copy the variable names from the repository’s `.env.example` into `.env.local`. The example contains placeholders only.
4. Replace each empty value with the value from the matching provider account. Keep `NAME=value` on one line. Do not add quotes unless a provider value actually contains spaces; keys usually do not need quotes.
5. Keep `APP_URL` and `NEXT_PUBLIC_APP_URL` equal to `http://localhost:3000` while running locally.
6. Keep `DODO_ENVIRONMENT=test_mode` and `DODO_ENABLE_LIVE_BILLING=false`. Leave live credentials out of this file.
7. Save the file. Confirm Git still ignores it: run `git status --short` and verify `.env.local` is not listed. Never `git add -f` it.
8. Start or restart the local app: from the repository folder run `npm run dev`. Next.js reads environment variables at startup/build time; restart after edits.
9. Verify in order: open `/login`; set up a test Supabase session; run an admin-authorized model sync only after an OpenRouter key is configured; test a small provider call only with owner approval and budget limits; upload a test file only after R2 is private and configured.
10. If a value is missing, use the exact variable name and error information in the master guide. Do not copy a similarly named publishable/secret value into the wrong field.

### Placeholder example only

```dotenv
APP_URL=http://localhost:3000
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXT_PUBLIC_SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=PASTE_PUBLIC_PUBLISHABLE_OR_ANON_KEY_HERE
SUPABASE_SERVICE_ROLE_KEY=PASTE_SERVER_ONLY_SECRET_HERE
OPENROUTER_API_KEY=PASTE_TEST_KEY_HERE
R2_ACCOUNT_ID=PASTE_ACCOUNT_ID_HERE
R2_ACCESS_KEY_ID=PASTE_ACCESS_KEY_ID_HERE
R2_SECRET_ACCESS_KEY=PASTE_SECRET_ACCESS_KEY_HERE
R2_BUCKET=PASTE_PRIVATE_BUCKET_NAME_HERE
DODO_ENVIRONMENT=test_mode
DODO_ENABLE_LIVE_BILLING=false
DODO_API_KEY=PASTE_TEST_KEY_HERE
DODO_WEBHOOK_SECRET=PASTE_TEST_WEBHOOK_SECRET_HERE
DODO_PRODUCT_USD_ID=PASTE_TEST_USD_PRODUCT_ID_HERE
DODO_PRICE_USD_MINOR=1499
DODO_PRODUCT_INR_ID=
DODO_PRICE_INR_MINOR=139900
```

The strings beginning `PASTE_` are placeholders and will not work. Never paste actual values into documentation.

## B. Vercel: set variables on the Orindle project

1. Open [Vercel Dashboard](https://vercel.com/dashboard) and sign in.
2. Select the Orindle project (do not choose a similarly named unrelated project).
3. Open the project’s **Settings** and select **Environment Variables**. Vercel may adjust menu labels; use its settings search/help if the label differs.
4. For each row in `ENVIRONMENT_VARIABLES_MASTER_GUIDE.md`, enter the exact **Name** (for example, `OPENROUTER_API_KEY`) and its matching value. Check the name character-for-character.
5. Choose the environment scope deliberately:
   - **Development:** local `vercel dev` only, if used. Ordinary `npm run dev` reads `.env.local`.
   - **Preview:** sandbox/branch deployments; use Supabase/Dodo test credentials and a Preview callback origin.
   - **Production:** production origin; use production credentials only after explicit approval. Keep Dodo in test mode and the live switch false until the owner authorizes otherwise.
6. Save the entry. Repeat. Do not put server secrets under names beginning `NEXT_PUBLIC_`.
7. Set `APP_URL` and `NEXT_PUBLIC_APP_URL` to the exact site origin for that deployment. Preview and Production may require different values; one project-wide value may not safely represent both, so scope them appropriately.
8. Add `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, and the server-only `SUPABASE_SERVICE_ROLE_KEY` for the matching Supabase project/environment.
9. Add OpenRouter and R2 test credentials only to the environments where you plan to test them. Dodo preview must use test API and webhook credentials, fixed test product IDs, `test_mode`, and `DODO_ENABLE_LIVE_BILLING=false`.
10. Save all entries. Trigger a new deployment (open **Deployments**, select the appropriate deployment action to redeploy the latest commit). Existing server functions do not pick up changed values until redeployed.
11. Open the build/deployment logs and inspect for missing-variable or configuration errors. Do not print environment values to logs or use a diagnostic page that returns secrets.
12. Verify public routes first, then protected auth/API behavior. A missing key should fail closed, not silently swap to a live/demo provider.

## C. Scope and redeploy reminders

- Vercel’s labels and available scopes can vary by plan and account. Confirm each environment checkbox before saving.
- A Preview deployment needs an origin that is also allowed in Supabase Auth redirects. Production needs its own exact HTTPS origin.
- Never copy Preview secrets into Production automatically. Separate keys and databases reduce accidental real payments/provider spend.
- Changing a variable requires a new deployment. Roll back or redeploy only after the prior deployment’s configured values are understood.
- Do not enable `DODO_ENVIRONMENT=live_mode` or `DODO_ENABLE_LIVE_BILLING=true` during setup or testing.
