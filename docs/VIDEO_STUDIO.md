# Video Studio implementation

**Status:** asynchronous route flow exists; no OpenRouter video request was submitted and no output was retrieved during audit.

## Flow

1. UI loads synchronized `/api/models?capability=video` results and shows models with verified video pricing.
2. User selects model, prompt, duration and supported aspect/resolution/reference options.
3. `POST /api/videos` validates signed-in user, model capability/pricing, parameter values, uploaded reference ownership and idempotency key; estimates and reserves credits.
4. Server submits provider request with a bounded timeout. It stores provider job ID and polling URL and returns HTTP 202 with the Orindle job ID. It does not hold the submit request open for the full generation time.
5. UI polls `GET /api/videos/[id]` periodically and can reopen from history/query ID after navigating away.
6. Status route contacts provider after a minimum update interval. On completion, it fetches bounded video bytes, validates MP4/WebM signatures, uploads to private R2, creates asset and Library links, records usage and settles credits.
7. If provider returns terminal failure with actual usage cost, the app settles that cost. If cost is missing or a provider request/finalization is uncertain, job/reservation goes to `needs_review` rather than assuming zero cost.

## State / recovery

Job states include `queued`, `submitted`, `processing`, `completed`, `failed`, `cancelled`, `expired`, `needs_review`. The browser is not the job queue: job ID/provider ID/status are persisted. However, there is no background poller; progress resumes when a user reopens or polls the job. Provider stale-job expiry, automated retries and cancellation API are not established. Repeated status GET calls are throttled by persisted update timestamps, but no distributed provider rate limit exists.

## Limits observed in source

- API submission timeout: 25 seconds; route `maxDuration=30`.
- Poll request timeout: 15 seconds; minimum poll cooldown: 12 seconds; UI interval: 15 seconds.
- Content retrieval timeout: 100 seconds; byte limit: 160 MiB. Verify target host max duration/memory for the real output size.
- Request duration range: 1–120 seconds, further constrained by model metadata.
- Reference uploads must belong to user and be validated with `video_reference` purpose.
- R2 storage, provider job ID persistence, library insertion and settlement were not externally exercised.

## Required tests

- One approved low-cost submit; verify 202 and persisted job ID/poll URL.
- Reload/reopen before completion; ensure same job resumes, no duplicate submission.
- Poll processing/completion and fetch a small authorized output.
- Provider failure/cancel/expiry with and without usage cost.
- Provider acceptance followed by timeout, job-ID persistence failure, R2 failure and settlement failure; confirm reservation review behavior.
- Verify wrong-user status and asset endpoints reject access.
- Validate timeouts, concurrency, memory and provider billing in the actual hosting plan.
