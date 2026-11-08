# Orindle performance audit

**Date:** 2026-11-08 UTC · **Measurement type:** Next.js production build report and source-level review only. No Lighthouse, WebPageTest, browser trace, Core Web Vitals or mobile network emulation was run. No performance score is claimed.

## Measured build outputs

`npm run build` succeeded with Next.js 15.5.29. Its reported first-load JavaScript summary:

- Shared JS: 103 kB (46.6 kB + 54.2 kB + 1.93 kB other shared chunks).
- Home route: 9.26 kB route size; 115 kB first load.
- Main workspace route entries: approximately 172–174 B route size and 236 kB first load (shared app-shell bundle dominates).
- Middleware bundle: 95.3 kB.

These are build analyzer figures, not downloaded transfer size or runtime performance scores. The dev server emitted Webpack cache warnings that serializing 115 kB and 272 kB strings may affect cache deserialization; no build failure resulted.

## Dependency and route notes

- `npm ci` installed 527 packages; 534 packages were audited and `npm audit` found 0 known vulnerabilities at the time of the run.
- Main app UI is concentrated in a large client component and shared bundle. Consider server/client boundary splitting only after profiling and without changing approved behavior.
- Chat history, account history and generation history use finite limits (commonly 20–100). Library query is debounced client-side; verify server pagination/filter behavior under real data volume.
- Video content retrieval is capped at 160 MiB and bounded by a request timeout. It occurs after asynchronous job completion; the initial submit returns 202. Validate platform execution duration and memory for large video downloads before selecting a host.
- R2 upload/download uses short-lived signed URLs; actual transfer speed and CORS are unmeasured.
- No custom image CDN, cache headers for personalized data, database query plans, long-session memory profile or mobile CPU/network tests were run.

## Required browser measurements

On a deployed preview with a test project, run Lighthouse (or equivalent) at mobile and desktop for `/`, `/models`, `/login`, and signed-in `/app/chat`, `/app/images`, `/app/videos`, `/app/websites`, `/app/library`, `/app/account`. Record performance, accessibility, best-practices and SEO scores, run date, URL, device profile, throttling, and warnings. Capture LCP, INP, CLS, TTFB and transfer size. Do not infer these metrics from build output.

## Performance follow-up priorities

1. Profile the shared workspace bundle; split large feature interactions into route-level/client islands if profiling shows material benefit.
2. Verify the synchronized catalogue is cached server-side with freshness timestamps and bounded sync concurrency.
3. Inspect Supabase query plans/indexes against seeded scale data; retain explicit page limits and add cursor pagination where needed.
4. Measure 100–160 MiB video storage/finalization memory and hosting duration limits; consider background workers/object streaming for production-scale output.
5. Measure signed R2 transfer throughput, CORS preflight, cache behavior and mobile upload reliability.
6. Repeat Lighthouse and accessibility checks after actual visual QA; report raw scores rather than a target claim.

**Performance readiness:** build passes; user-perceived speed and Core Web Vitals remain unmeasured.
