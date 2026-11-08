# Security requirements

**Current status:** security controls are not implemented. UI authentication and admin routes are demonstrations. Do not deploy as a customer service.

## Identity and access
- Require server-side auth for `/app/*`; verify ownership on each data operation.
- Keep admin authorization separate; least privilege, MFA for privileged users, audit sensitive actions, secure session expiry/revocation.
- Prevent user/tenant ID substitution and insecure direct-object references.

## Secrets and payments
- Keep provider/payment/database credentials server-side; never commit `.env` files or expose keys in client bundles.
- Verify payment-webhook signatures and idempotency; reconcile credit grants against provider events. Never store raw card data.
- Sanitize/redact logs, analytics and error reporting; do not log prompts/file contents by default.

## Uploads, generation and generated HTML
- Limit upload types and size, scan files, use private storage and short-lived signed URLs, authorize every access and support deletion/retention.
- Protect against malicious prompt abuse, resource exhaustion, provider cost abuse, SSRF and unsafe URL fetching.
- Preview generated HTML in a separate restrictive sandbox origin/iframe with scripts sandboxed and no ambient app credentials; deliver as attachment with safe content disposition. Define CSP and download handling.
- Apply provider policy/moderation and user reporting controls where required.

## Web and application controls
- TLS, secure HttpOnly SameSite cookies, CSRF defenses, strict validation, output encoding, CSP, clickjacking protection, CORS/origin allowlists, rate limiting, abuse monitoring, dependency scanning and patch process.
- Use secure, environment-specific secrets; rotate and audit access.
- Enforce credit accounting transactionally and atomically; prevent replay/double debit and quota race conditions.
- Backups, recovery, data residency, retention/deletion schedule and incident response playbook.

## Privacy/release gates
Before launch publish accurate privacy, terms and refund policies, retention and provider disclosure, subprocessors, user controls and verified support channel. Complete threat modeling, dependency/license review, pen test or equivalent, accessibility/privacy reviews, incident and breach response readiness. Current app `/admin` is not protected and must be gated before any deployment.
