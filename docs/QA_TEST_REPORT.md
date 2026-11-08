# Orindle QA test report

**Run date:** 2026-11-08 (workspace UTC)
**Branch under audit:** `arena/60c50522-orindle`
**Commit at audit start:** `7467475` (merged Prompt 2 baseline)
**Disposition:** Not production-ready. Static checks pass after `npm ci`; authenticated/provider/database end-to-end scenarios remain blocked by missing credentials and test infrastructure.

## Tests actually executed

| Check | Result | Evidence / scope |
|---|---|---|
| `npm ci` | PASS | Installed 527 packages; npm reported 0 known vulnerabilities across 534 audited packages. |
| `npm run typecheck` | PASS | TypeScript completed without diagnostics. |
| `npm run lint` | PASS | ESLint completed without diagnostics. |
| `npm run test` | PASS, limited | 2 Vitest files, 8 unit tests: 5 file-validation and 3 model-normalization tests. |
| `npm run build` | PASS | Next.js production build completed; page and API route manifest generated. |
| `npm audit --json` | PASS at run time | 0 low/moderate/high/critical findings reported by registry audit. This is not a guarantee against undisclosed vulnerabilities. |
| SQL parser | PASS, syntax only | `pglast` parsed the updated 129 migration statements and 10 RLS-test statements. No database execution. |
| `npm run check:env` | PASS, expected incomplete | Reports missing core/provider variable names without exposing values. Strict mode correctly exits 1 with the unconfigured sandbox; a fully connected credential set was not available to verify. |
| Local documentation links | PASS | Relative links across `docs/*.md` resolve; external site links were not fetched/checked under network restrictions. |
| `git diff --check` | PASS | Final audit changes contain no whitespace errors. |
| HTTP route smoke test | PASS for tested local routes | Production Next server returned 200 on `/`, `/about`, `/models`, `/contact`, `/privacy`, `/terms`, `/refund-policy`, `/login`, `/signup`, `/forgot-password`, `/reset-password`, `/verify-email`; protected app/admin routes redirected to login without Supabase config. Security response headers were present. |
| Protected route smoke test without credentials | Expected block | `/app/*` and `/admin` redirected to `/login?error=auth_not_configured`; `/api/models` returned 503 `service_not_configured`. This verifies fail-closed behavior only, not working authentication. |

## Not executed / blocked

- Signup, sign-in, sign-out, email verification, password recovery, cookie refresh and expiry require a configured Supabase project and mail delivery. Not executed.
- Cross-user reads/writes, credit RPC behavior and the RLS test SQL require a running disposable Supabase/Postgres database. `psql`, Supabase CLI and Docker are absent. The SQL tests were syntax-parsed only.
- OpenRouter catalogue sync, chat, image, video and website generation require credentials and could incur spend. No provider call was made.
- Dodo checkout/webhook lifecycle requires a sandbox account, configured products and webhook secret. No checkout, event, refund or renewal was run.
- R2 uploads/downloads require a private bucket and credentials. No object was uploaded.
- No browser automation package or browser binary is present. No screenshots, rendered visual review, keyboard pass, axe scan, responsive browser pass or Lighthouse run was performed.
- No production-domain, DNS, HTTPS, email-delivery or Vercel deployment test was performed.

## Code-level findings and changes made in this audit

1. **Credit settlement RPC authorization (critical before the fix):** the baseline migration granted `settle_credit_reservation` to `authenticated`, allowing an authenticated client to release/settle its own reservation directly without server verification. The draft migration now restricts settlement to `service_role`, resolves the reservation owner server-side, and adds a service-only review flag RPC. Generation routes now use the admin server client for settlement. The RLS SQL test asserts authenticated cannot execute either RPC. This is not effective until the updated migration is safely applied and verified in a test database.
2. **Ambiguous provider outcomes:** image/video/chat/website flows could release reservations after a network timeout even though a provider may have accepted a paid request. Routes now hold/flag reservations for review when the outcome is uncertain; confirmed pre-submit failures still release. This behavior is statically checked only.
3. **Cost basis:** generation rows now distinguish provider-reported cost (`actual`) from catalogue/token-based fallback (`estimated`). There is no validated profitability report or reconciliation operator workflow yet.

## Functional feature coverage (static, not end-to-end)

- Real API routes exist for OpenRouter chat, model catalogue, image submission, asynchronous video submission/poll/content retrieval, standalone HTML generation/edit/download, uploads, Library, account, checkout and webhook events.
- The app does not return a hardcoded AI response from the chat route. Requests fail closed if service configuration/catalogue/pricing is missing.
- Repeated/duplicate request protection, user ownership predicates and no-store responses are present in many routes; provider behavior, RLS and race handling remain unverified externally.
- Video submission returns 202 and stores job metadata; the browser polls a user-scoped status route. The browser does not keep the initial submission open for the full generation duration.

## Test inventory still required before launch

1. Run the migration on a disposable Supabase instance and execute `supabase/tests/rls_invariants.sql` there; add real concurrent reservation/settlement tests.
2. Add mock-backed integration tests for Dodo signatures, duplicate/delayed events, subscription price matching, renewals, cancellation and 1,500-credit idempotency.
3. Add mocked OpenRouter route tests for chat SSE completion/truncation, timeout review holds, image MIME/base64 validation, video state recovery and actual-vs-estimated basis.
4. Add R2 signed upload/download, expiry, wrong-user and delete tests.
5. Add Playwright or equivalent E2E/browser tooling plus mobile breakpoints and keyboard/assistive-technology checks.
6. Run controlled test-mode provider jobs only after owner-authorized budgets and credentials are configured.

## Overall QA status

**Static build: pass. Product integration acceptance: not established. Commercial launch: blocked.** Do not describe the application as fully tested or production-ready based on this report.
