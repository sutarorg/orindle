# Orindle troubleshooting

Start with the user-facing error, deployment/environment name and time. Never include secret values, full auth tokens, prompts, uploaded files or payment details in shared logs.

## Local app does not start

- **`tsc: not found` / command missing:** run `npm ci` from the repository root, then rerun the command.
- **Build errors after changing `.env.local`:** restart the dev server. Check variable spelling against `.env.example` and the master guide.
- **Port already used:** stop the prior dev server or choose an available port. Update local `APP_URL` and `NEXT_PUBLIC_APP_URL` if changing the app origin.
- **`npm ci` registry/network failure:** verify access to npm registry and retry without deleting `package-lock.json`.

## Protected pages redirect to login / APIs say service not configured

- Confirm `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` are set for the correct project.
- Confirm server routes also have `SUPABASE_SERVICE_ROLE_KEY` in the server environment. Never put it in a `NEXT_PUBLIC_` variable.
- Restart/redeploy after changes.
- Verify Supabase Auth Site URL and exact `/auth/callback` redirect allowlist.
- If an API returns 503 while local auth is not configured, this is fail-closed behavior; it does not mean an external service is healthy.

## Confirmation/password reset email not arriving

- Check spam/junk and the recipient address.
- In Supabase Auth, inspect email provider/SMTP settings and event logs.
- If using Resend, verify the domain in your own Resend account and copy that account’s SPF/DKIM records exactly to DNS. Never reuse sample DNS values.
- Confirm `NEXT_PUBLIC_APP_URL` uses the correct origin and allowed callback path.
- Orindle currently calls Supabase Auth, not Resend directly; adding `RESEND_API_KEY` alone will not change mail behavior.

## Model catalogue empty / stale / sync fails

- Confirm `OPENROUTER_API_KEY` is valid for the current environment and not spend-limited to zero.
- Confirm the authorized user has the `admin` role in Supabase; ordinary users must not access model sync.
- Check provider status/usage and OpenRouter base URL. Default is `https://openrouter.ai/api/v1`.
- Inspect `model_sync_logs` with a restricted DB account; sync errors are deliberately generalized in app logs.
- Image/video selectors require synchronized capability and verified price. No priced models should be displayed as available generation choices. Do not add a hardcoded replacement list.

## Chat fails / request interrupted

- Check the API response and exact error code; the UI deliberately avoids exposing provider payloads.
- If `catalogue_unavailable` or `model_pricing_unavailable`, sync/verify catalogue pricing first.
- If `insufficient_credits`, inspect the user wallet and reservation ledger; never edit balances in the browser.
- If stream fails or gets interrupted, reload the conversation. History is server-persisted only after completion; an uncertain provider outcome can place the reservation in `needs_review`.
- A `needs_review` balance is intentionally held until provider usage is reconciled. Do not clear it by settling zero.

## Image/video generation failures

- Confirm the model output modality, supported parameters and price in the synchronized database catalogue.
- Check ownership and validation state of any reference upload.
- Verify OpenRouter test credentials, budget and endpoint status.
- For video, submit should return 202 quickly and the UI polls status. If a generation is still pending, reopen its history/query URL rather than submitting again.
- `needs_review` means provider acceptance, output storage or usage settlement is uncertain. Check the provider job and reservation before retrying or refunding.
- Ensure R2 credentials, private bucket, CORS origins and signed upload headers are correct.

## File upload/download fails

- Confirm all four variables: `R2_ACCOUNT_ID`, `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`, `R2_BUCKET`.
- Verify the bucket exists, is private, and credential permissions include required object read/write/delete/head operations.
- Browser CORS must allow the exact application origin and signed `PUT` request headers; inspect the browser network request and Cloudflare CORS error. Do not use a wildcard production origin.
- File content type, magic bytes, purpose and byte limit are validated. An unsupported type or oversized file is expected to fail.
- Signed URLs expire after 300 seconds; request a new one rather than reusing a copied URL.

## Website preview looks blank or blocked

- Verify the HTML contains a doctype, `<html>` and `<body>`; generated output is standalone.
- Preview intentionally blocks network connections/forms and has a sandboxed opaque origin. External fonts/images/scripts will not load. Use embedded CSS, inline SVG and permitted data/blob assets.
- Do not add `allow-same-origin`, remove the CSP, or serve generated HTML inline from Orindle’s app origin to “fix” preview.
- Downloaded HTML is an attachment; open it independently in a browser for offline rendering.

## Checkout unavailable or wrong currency

- Quote/checkout requires matching Dodo product ID and exact amount guard: USD product + `DODO_PRICE_USD_MINOR=1499`; INR product + `DODO_PRICE_INR_MINOR=139900`.
- INR is used only when Vercel identifies trusted country `IN` and the fixed INR product is configured. Local/unknown location falls back to USD. There is no FX conversion.
- Make `APP_URL` match the deployment origin. Check Dodo test product interval/currency/amount and `DODO_ENVIRONMENT=test_mode`.
- Checkout redirect is not a payment event. Wait for a valid signed webhook and inspect event/subscription/credit grant state.
- Never enable live Dodo or accept real charges as a troubleshooting shortcut.

## Dodo webhook not processing

- Confirm test/live API key, webhook URL and `DODO_WEBHOOK_SECRET` all belong to the same Dodo environment/endpoint.
- Check Dodo delivery response and webhook headers. Invalid signature should be rejected.
- Inspect `webhook_events` by provider event ID. A processed/ignored duplicate is expected to be idempotent; a failed event needs payload/schema review.
- Check exact event type names and payload fields against current Dodo docs/account. This workspace has not verified current live/test payloads.
- Check for matching metadata `orindle_subscription_id`, product, currency, amount and monthly interval. Mismatch must not grant credits.

## Deployment/domain errors

- Read the full Vercel build log, not only the status icon. Re-run `npm run build` locally on the same commit.
- Verify environment variable scope and redeploy after changes.
- Confirm custom DNS values from Vercel’s current project UI and domain registrar; never use guessed DNS examples.
- Confirm HTTPS certificate/domain verification and Supabase allowed redirects use the exact production host.
- If a release is broken, use the last known-good deployment/commit following `BACKUP_AND_RECOVERY.md`; do not reverse database migrations manually.

## Where to get help

Contact the owner/provider support for account-specific IDs, secret rotation, payment eligibility, DNS or production backup questions. Do not send secrets, customer prompts, private files or full payment payloads in support tickets unless the provider explicitly requests a securely redacted diagnostic.
