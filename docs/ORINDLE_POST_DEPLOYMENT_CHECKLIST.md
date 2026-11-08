# Orindle post-deployment checklist

Use on a **test/Preview deployment first**. Record date, commit, URL, environment and operator. Mark PASS only when personally observed; do not turn “route exists” into a pass. Production Dodo remains in test mode until explicit owner approval.

## Release information

- [ ] Commit SHA and branch recorded.
- [ ] Hosting plan explicitly permits commercial SaaS use (not Vercel Hobby for paid launch).
- [ ] Target environment confirmed (Preview vs Production).
- [ ] Secrets are environment-specific, server-only where required, and not visible in browser source/logs.
- [ ] `APP_URL` and `NEXT_PUBLIC_APP_URL` match the exact deployment origin.
- [ ] Supabase project and auth callback URLs match the environment.
- [ ] Database migration version and backup captured; RLS SQL tests executed against this database.

## Public routes and navigation

- [ ] Home page loads over HTTPS.
- [ ] Header navigation, mobile menu and footer links work.
- [ ] `/models`, `/about`, `/contact`, `/privacy`, `/terms`, `/refund-policy` load and contain owner-approved truthful copy.
- [ ] No unverified “100+” model claim, invented testimonials, false service-health claim or unsupported plan/discount appears.
- [ ] Custom domain resolves to the approved deployment and presents valid HTTPS.

## Authentication and account isolation

- [ ] Signup with a dedicated test mailbox.
- [ ] Confirmation email arrives; link points at correct environment and completes callback.
- [ ] Login, logout, reload/session persistence and password reset work.
- [ ] Expired/revoked session redirects to login; unauthorized `/app/*` and `/admin` do not expose private content.
- [ ] A test non-admin is denied admin access; only approved role is admitted.
- [ ] Create two test accounts. Attempt to read/delete each other’s chat, attachments, files, generated image/video/site, Library item, wallet, subscription and payment history; all cross-user attempts fail.
- [ ] Confirm password change and session invalidation behavior matches the intended policy.

## Catalogue and chat

- [ ] Authorized catalogue sync succeeds; active models/modalities/prices are timestamped and current.
- [ ] Public model page shows only the real synchronized catalogue or a clear unavailable state; no stale fixture is shown as live.
- [ ] Auto selection, manual selection, search and provider filter work for a verified catalogue.
- [ ] One low-cost authorized chat request returns provider output (not a canned response), valid Markdown/code and a final stream completion marker.
- [ ] History persists after reload, earlier file attachment context works, and two-account isolation holds.
- [ ] Duplicate submit is rejected; provider timeout/truncated stream shows an error and holds uncertain credits for review rather than silently refunding/charging.
- [ ] Insufficient credit request never calls a provider.
- [ ] Credit ledger and recorded cost basis are checked against provider usage where available.

## Images, video and websites

- [ ] Image models are actually synchronized and have verified image price/capability.
- [ ] With owner-approved test spend, generate one small image; validate returned bytes/MIME, private R2 object, Library row, preview/download ownership and ledger/cost basis.
- [ ] With owner-approved test spend, submit one video job; receive 202, persist provider job ID/poll URL, refresh the browser, and confirm status recovery without a long-held submission request.
- [ ] Test completed and provider-failed video statuses; missing/ambiguous provider usage is routed to `needs_review`, not a false zero refund.
- [ ] Website Builder returns standalone HTML, saves/edits/downloads it, and preview iframe retains `sandbox="allow-scripts"` without `allow-same-origin`, no-referrer and restrictive in-document CSP.
- [ ] Downloaded HTML runs independently; security reviewer verifies it cannot read Orindle cookies/storage/private APIs.
- [ ] No user-generated HTML is served inline from the application origin.

## Files and Library

- [ ] Allowed format upload works and unsupported format/oversize file is rejected.
- [ ] Signed PUT succeeds only for expected type/size; R2 bucket remains private.
- [ ] Expired URL and wrong-user URL fail.
- [ ] Delete removes or archives the intended user item and does not remove another user’s object.
- [ ] Library search/history/download does not leak content; pagination is reviewed at realistic volume.
- [ ] R2 CORS includes only exact app origins and required methods/headers; anonymous object access is denied.

## Subscription, webhook and credits (test mode only)

- [ ] Quote displays one currency and fixed price consistent with checkout.
- [ ] USD test product is monthly $14.99 (1499 minor units).
- [ ] INR appears only with trusted Vercel country `IN` and a matching fixed ₹1,399 test product (139900 minor units); no FX conversion.
- [ ] Checkout uses the configured test Dodo product and completes using a test payment method only.
- [ ] Browser redirect alone creates no entitlement or credit grant.
- [ ] Valid signed subscription event activates correct user/subscription and grants 1,500 once for that period.
- [ ] Invalid signature gets rejected; replay is idempotent; delayed retry processes safely.
- [ ] Price/product/currency/interval mismatch is rejected and does not grant credits.
- [ ] Renewal grants exactly one additional period grant; failed/cancelled/expired events do not grant a new period.
- [ ] Cancellation synchronizes with provider and current period entitlement behavior is confirmed.
- [ ] Refund handling is explicitly tested/implemented before promising refunds; current application has no complete refund workflow.
- [ ] `DODO_ENVIRONMENT=test_mode`; `DODO_ENABLE_LIVE_BILLING=false`.

## Email, admin and observability

- [ ] Supabase Auth confirmation/reset mail arrives at a test mailbox; SPF/DKIM pass if custom SMTP used.
- [ ] If using Resend, SMTP is configured in Supabase and actual sender verified; app direct Resend API is not assumed.
- [ ] Admin route denies non-admins. Current admin dashboard is placeholder; do not treat its metrics as operational reporting.
- [ ] Webhook failures, generation `needs_review`, provider spend, failed uploads and auth issues have an owner/alert process.
- [ ] Logs redact keys, tokens, prompts, file contents, email addresses and payment-sensitive data unless a reviewed policy permits specific fields.
- [ ] Database and object-storage backup/restore procedures are tested.

## Responsive/accessibility/performance

- [ ] Rendered screenshots taken at 1440, 1280, 1024, 768, 390 and 375 CSS px; no horizontal overflow or clipped controls.
- [ ] Keyboard-only navigation, visible focus, labels, screen-reader names and reduced motion are checked.
- [ ] Contrast and text zoom/reflow meet WCAG 2.2 AA where applicable; document exceptions.
- [ ] Browser-based Lighthouse/equivalent scores and Core Web Vitals are recorded from actual URL/device/network profile.
- [ ] Mobile file upload, menus, dialogs, pricing and app navigation are tested on a real or emulated browser.

## Go/no-go

- [ ] No critical/high security, tenant isolation, authentication, payment integrity or credit balance failure remains.
- [ ] Supabase tests ran against a real test DB; sandbox Dodo webhook tests passed.
- [ ] Provider and storage integration tests passed with safe budget limits.
- [ ] Any unresolved medium/low risks have owner, severity, mitigation and deadline.
- [ ] Owner explicitly approves commercial host plan and live billing. Without approval, keep test mode and do not transact live.

**Only record “production launch approved” after every critical gate above is observed and the owner accepts remaining risks.**
