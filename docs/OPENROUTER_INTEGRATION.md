# OpenRouter integration

**Status:** adapter code present; no live credentials/catalogue or generation requests were used in this audit.

## Code path

- `lib/openrouter/client.ts`: server-only API key, API base default, optional site attribution header, timeouts and provider error mapping.
- `lib/openrouter/normalize.ts`: normalized IDs, modalities, supported parameters and price values.
- `lib/openrouter/catalogue.ts`: concurrent discovery of text/image/video model sets, merges modality lists, fetches image endpoint price details and maps pricing to DB fields.
- `lib/openrouter/router.ts`: chat selection from active synchronized catalog, filters input/output modalities and context limit, estimates cost from token prices, ranks Auto candidates.
- `lib/openrouter/generation.ts`: requires active model capability and verified unit price, validates model-supported parameters.
- `app/api/admin/models/sync/route.ts`: server-side admin-gated sync to the Supabase catalogue.

## Chat

`POST /api/chat` validates user, content, attachment ownership/type and idempotency key; loads the latest 40 complete messages in chronological order including prior validated attachments; selects a compatible priced model; reserves credits; calls OpenRouter chat completions with SSE; persists assistant output and usage; settles or holds credits. Incomplete streams and ambiguous provider outcomes are not treated as a clean success/refund. Provider calls require `OPENROUTER_API_KEY`, current catalogue rows and user credits.

## Images

`POST /api/images` selects a current image-capable priced model, validates parameter metadata and reference image ownership, reserves credits, posts an image request, validates base64/media bytes, stores artifacts in private R2 and links them to Library. Uses provider cost when returned; otherwise records a marked estimate using the synchronized per-image price. No generation call was made during audit.

## Video

`POST /api/videos` submits an asynchronous video request and returns 202 after saving the provider job ID/poll URL. `GET /api/videos/[id]` polls after a cooldown; once complete it retrieves bounded content, validates MP4/WebM signatures, stores it in R2, adds Library and settles usage. If reported usage is missing, the app uses a synchronized per-second rate times requested duration and records `estimated`; unknown terminal cost is held for review. Provider schema, timeout, billing and output format behavior are not verified against credentials.

## Website Builder

`POST /api/websites` uses a text-capable priced model to generate standalone HTML. It stores a private R2 asset and Library record, exposes a sandboxed `srcDoc` preview, supports owner-scoped edit/save/download, and records actual/estimated cost basis. HTML generation is not full-stack hosting. Provider output has basic standalone checks, but is untrusted executable HTML; the preview isolation must remain.

## Catalogue, pricing and availability caveats

- Models are only as current as the last successful admin sync. No automatic scheduled sync/health alert exists.
- Alias/canonical de-duplication, output modalities and prices must be reviewed after real sync.
- Chat cost estimates depend on model prompt/completion prices and token estimates when provider usage/cost is omitted.
- Image uses provider-reported cost if present, otherwise synchronized output-image price per unit times quantity.
- Video uses provider-reported usage if present, otherwise synchronized video USD/second times requested duration.
- Do not represent estimates as actual charges. The `generation_usage.cost_basis` field records this distinction.
- Provider cost/pricing can change; set budget caps and verify before each controlled test.

## Safe test sequence

1. Create a dedicated OpenRouter test key with small budget.
2. Configure only on local/Preview server side.
3. Run admin sync; inspect `model_sync_logs`, active IDs, capability and price rows.
4. Send one small-cost chat, compare provider usage with persisted cost basis and credit settlement.
5. Only after owner approval run one image/video job; monitor spend and storage.
6. Stop if a cost is missing, provider request outcome is ambiguous, or reservation enters review.

No current OpenRouter dashboard labels or pricing for a particular model are asserted here.
