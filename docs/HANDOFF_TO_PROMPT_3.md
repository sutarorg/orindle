# Prompt 3 audit handoff

The Prompt 2 integration branch is merged on `main` at the audit baseline commit `7467475`. This handoff is rewritten from the current repository state; the previous `HANDOFF_TO_PROMPT_3.md` did not exist at audit start.

## Current session state

- Current work branch: `arena/60c50522-orindle` (active during this work).
- Audit began with a clean working tree at `7467475`.
- Read `AGENTS.md` and existing product, architecture, design, landing and app UI docs. Several expected schema/API/credit/provider/security/status documents were absent; current source and new reference docs were used instead.
- Static verification and local route smoke tests ran; see `QA_TEST_REPORT.md`.
- A critical service-only settlement RPC flaw in the draft SQL was found and fixed in this branch, and ambiguous provider outcomes now hold reservations for review. SQL syntax passed after change but no DB execution has occurred.
- Docs created include complete setup, QA/security/design/performance reports, env master/click-by-click, deployment/checklists and maintenance/recovery guides.

## Immediate next actions

1. Run `npm ci`, `npm run typecheck`, `npm run lint`, `npm run test`, `npm run build` and `git diff --check` after any further change.
2. Execute the migration and RLS tests only against a disposable test Supabase project; if initial migration is already applied in another DB, create a forward migration.
3. Add durable rate limits, integration test coverage, operational credit review and monitoring before launch.
4. Use test-only OpenRouter, Dodo and R2 credentials with explicit spend limits; do not run generation or payment tests without owner authorization.
5. Capture actual browser screenshots and accessibility/Lighthouse results; current audit had no browser binary/tooling.
6. Verify current provider dashboards/docs and eligibility with account owner. In particular, verify fixed INR Dodo support, webhook event/payload contract, R2 CORS, Supabase keys/SMTP and commercial Vercel plan.
7. Keep Dodo in `test_mode` and `DODO_ENABLE_LIVE_BILLING=false`. No live payment or commercial production launch without explicit approval.
8. Review generated docs for any account-specific dashboard labels and add screenshots only from current real accounts with all secret/customer data redacted.

## Important nonclaims

No integration call, database migration execution, payment, user test, provider generation, production deployment, screenshot, browser audit, Lighthouse score, formal security certification or production-readiness signoff has occurred.
