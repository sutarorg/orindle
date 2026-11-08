# Orindle backup and recovery

## Current status and limitations

- The application does not implement its own database backup scheduler, R2 object replication, recovery console or point-in-time restore workflow.
- Supabase backup/PITR availability depends on the current project plan and must be confirmed in your account. This agent did not access the project or run a restore.
- Generated images, videos, websites and uploads live in a private R2 bucket. The code does not make a second copy. Do not assume a database backup also contains object bytes.
- Do not deploy commercial traffic until the owner has selected retention, backup frequency, recovery objectives (RPO/RTO) and tested restoration in a separate project/bucket.

## Before production

1. Open the Supabase dashboard for the correct project and inspect its current backup/PITR options, retention duration and restore procedure. Record plan limits and timezone.
2. Enable the approved database backup feature or schedule encrypted exports using the provider’s current documented process. Store exports in a separate access-controlled location, not the same database account.
3. Ensure backups include schema/migration history and user-owned data that the business is required to retain. Keep secrets out of SQL dumps.
4. Decide how to protect R2 objects: use provider-supported versioning/replication/backup if available for the chosen plan, or a documented separate-copy process. Verify object metadata and ACL/privacy semantics on restore.
5. Store credentials for restores in a password manager with least privilege. Restrict backup access to named operators; record audit events.
6. Set an explicit retention policy and deletion process consistent with privacy/legal obligations. Backups may retain deleted objects until their expiration; document that honestly.

## Safe database export (operator-run)

Use the exact command/provider mechanism currently documented by Supabase for your plan. If `pg_dump` is the approved method, run it from a trusted operator workstation against the correct database using a protected connection string. Avoid putting passwords directly in shell history or command-line arguments; use the provider’s recommended secure connection/credential method. Encrypt the output and verify file checksum and restoreability. This repository does not require a `DATABASE_URL` at runtime and the command must not be added as an app env var by assumption.

## Restore drill (test environment)

1. Create/choose an isolated recovery project. Never overwrite production for a drill.
2. Restore the latest encrypted backup using Supabase’s documented steps for your exact plan/database version.
3. Apply later migrations in order using the approved migration workflow. Do not replay an edited migration that is already recorded as applied.
4. Restore/copy required R2 objects using the chosen backup process and verify object metadata, ownership keys and privacy.
5. Configure only test provider credentials in the restored environment. Keep Dodo in test mode.
6. Run RLS tests, check schema/table counts, sign in with two test users, and verify ownership boundaries and generated-asset reads.
7. Record restore time, missing data, issues, and actual recovery point. Fix the process before launch.

## Recovery from a bad application deploy

1. In Vercel, open the Orindle project’s deployments and identify the last known-good deployment/commit.
2. Use the current dashboard’s **Promote/Rollback** action for that deployment, or redeploy the known-good commit. Confirm the exact environment and domain before action.
3. Check whether environment variables changed after that deployment; rollback code does not necessarily roll back environment configuration.
4. Smoke-test public pages, auth and API health. Keep Dodo live mode disabled until payment state has been reconciled.
5. Do not roll back database schema by deleting columns/tables. Use a forward corrective migration after a backup and review.

## Recovery from accidental secret exposure

1. Revoke or rotate the secret immediately in its provider dashboard.
2. Update only the affected Vercel scopes/local secret store, redeploy/restart, and verify service behavior.
3. Review provider access logs/spend and database audit logs for unauthorized use.
4. Remove the secret from tracked files and Git history using a reviewed repository procedure; deleting the latest line does not invalidate a leaked key.
5. Document impact and notify the security owner. Never paste the value into an incident ticket or chat.

## Recovery from credit or payment discrepancy

1. Pause generation/checkout if financial integrity is uncertain.
2. Preserve signed webhook evidence and event IDs; compare Dodo subscription/payment details and OpenRouter usage with app rows.
3. Inspect reservation, ledger, period grant, cost basis, and job/message states. Do not make a blind SQL balance adjustment.
4. Use a reviewed transactional repair with an idempotency key and separate audit record. Have a second operator verify before reopening traffic.
5. If no reconciliable provider record exists, leave the case held for review and contact the provider/owner rather than asserting a refund.
