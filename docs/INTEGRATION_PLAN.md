# Integration plan and implementation status

The application now contains integration drafts for Supabase, OpenRouter, Dodo Payments, and private R2 storage. The implementation is not yet externally validated: secrets are not configured, SQL has not been applied, and no provider or payment calls have been made. Use [Setup and handoff](SETUP_AND_HANDOFF.md) for environment configuration and operator verification steps. The roadmap below records the remaining validation and release work.

## Model catalogue and chat — OpenRouter
- Create server-only credentials and fetch the live catalogue; normalize IDs/aliases and capabilities; store last verified state and pricing metadata.
- Prove that >=100 unique active chat-capable IDs are accessible before displaying “100+”. Refresh and remove stale/unavailable IDs.
- Confirm current provider usage rules, data handling and model licensing; clearly display provider/source and best-effort availability.
- Implement Auto routing only over compatible models and allow Manual selection. Show cost/credit estimates where stable; preserve model choice in history.

## Payments — Dodo Payments
- Research current Dodo fixed-price/localized pricing and supported India customer-location signals before deciding checkout design. No conclusion about availability is assumed in this milestone.
- Configure separate fixed USD $14.99/month and INR ₹1,399/month price/product configurations if supported and approved. Have server select exact price using trusted country data; use USD when unknown. Return the same server-selected display amount and currency used for checkout.
- Verify signed webhooks, deduplicate events, reconcile subscription/cancellation and monthly credit grants. Show renewal/cancellation terms before checkout. Test India, international and unknown country cases in sandbox.
- Never perform client-side exchange conversion or activate live payments in preview.

## Image/video providers
- Identify approved providers/models with image/video capability, supported prompt/reference formats, aspect/duration controls, moderation and pricing.
- Normalize asynchronous jobs, progress, cancellation, errors and artifact storage. Do not show controls a model does not support.

## Files and library
- Private object storage with signed short-lived upload/download links, size/MIME limits, malware scanning, retention/deletion and user ownership checks.
- Store artifact metadata and link only authorized content to Library. Consider safe HTML download and sandbox preview policies.

## Authentication and security
- Select hosted or managed auth, implement verification/recovery and server-side route protection. Protect admin separately with role and audit log. Test account deletion and session revocation.

## Rollout order
1. Product decisions and legal/privacy review.
2. Auth, persistence, ownership and data retention.
3. Catalogue sync + chat, model accuracy and credit ledger.
4. Dodo sandbox and webhook reconciliation.
5. Image/video asynchronous jobs and safe uploads.
6. Website HTML generation/download/sandbox preview.
7. Library/account, admin, observability, abuse and accessibility testing.
8. Commercial enablement only after release gates; no live payment configuration is included here.
