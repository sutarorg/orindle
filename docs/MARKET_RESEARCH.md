# Market research and product framing

**Research status:** desk research and design synthesis for a frontend foundation, 2026-11-08. This sandbox has limited outbound access; the referenced commercial websites were not live-crawled or usability-tested in a browser during this milestone. Competitor statements below are positioning/IA hypotheses to validate against current public product pages, not audited current feature claims. Do not treat them as endorsements or as verified pricing/model catalogues.

## Market shape
The multi-model workspace category competes on reducing context switching, offering choice without making users learn provider infrastructure, and combining general chat with specialist creation tools. The product burden is not simply access to many models: users need to understand which model is suitable, what a generation costs, whether it can accept their file, and where output will be found afterward. Catalogue churn and provider restrictions make “100+” a maintenance claim, not evergreen decorative copy.

## Positioning hypothesis
**Orindle:** one coherent paid workspace for chat, image/video generation, standalone HTML websites, files and a searchable library. Differentiation to test: accessible model choice plus dedicated creation workflows rather than a directory of bots. Message should focus on reduced tool-hopping and clear control, not unsubstantiated “best”, “unlimited”, performance or market-leadership claims.

## Competitive landscape to validate
| Product | Category lens | Research question for next pass |
|---|---|---|
| AI Fiesta | Multi-model consumer workspace and campaign-led landing-page reference | How does its long-form page pace product proof, model choice, plans, FAQs and final CTA? Which parts are general IA patterns vs distinct brand assets? |
| Poe | Model/bot discovery and multi-model conversation | How does model discovery and user-created bot ecosystem affect choice load? What is presented as included vs usage-limited? |
| ChatGPT | Broad general-purpose assistant with multimodal capability | How are the core composer, conversation history, plan details and first-use experience kept legible? |
| Monica AI | Assistant surfaced across workflows/extensions | What is the cost of communicating broad utility across website sections and app navigation? |
| OpenRouter | Model catalogue/routing/API-oriented infrastructure | How do provider and model metadata, availability, pricing and routing affect informed choice? |
| Perplexity / similar answer engines | Search-grounded assistant | How are source provenance and trust presented? |
| Midjourney / Runway / dedicated creative tools | Specialist generation workflows | Which controls, status and output management patterns should specialist Orindle tools inherit without claiming parity? |

The URL list supplied in the brief should be the starting source list for a live audit. Before using any claim about a competitor’s current plan, models or product, date-stamp it and check the official pricing/product page.

## Market implications
1. **Catalogue is infrastructure.** Store provider model IDs, aliases, capability flags, limits, cost metadata, availability timestamps and display names. Show only verified synchronized entries. Numeric count requires >=100 unique active chat-capable IDs after alias de-duplication.
2. **Choice needs scaffolding.** Default to Auto but make Manual visible; explain task/capability and cost signals. Avoid exposing a giant undifferentiated list on first use.
3. **Specialist tools need explicit scope.** Image and Video have their own controls/job status. Websites explicitly means downloadable standalone HTML, not an implied full-stack IDE.
4. **Unify outputs.** Library and history bridge chat, generations, files and HTML. Consistent save/download actions avoid users having to remember where work went.
5. **Price is a trust contract.** One plan, one localized fixed amount, transparent billing and credits. Never put $14.99 and ₹1,399 in a single localized pricing view.
6. **Proof must be product-led.** Real screenshots, realistic but clearly marked demo states, accurate provider language and a working self-serve account path are stronger than invented usage statistics.

## Experience strategy applied here
The marketing page follows a high-level long-form sequence requested in the brief: navbar → centered hero → large product window → provider list → model discovery → capability selector → pricing → use cases → feature grid → FAQ → high-contrast CTA → footer. This borrows a familiar SaaS narrative cadence, not a competitor’s text, artwork or code. The product demo is original CSS UI, uses a fictional studio site, and is labeled demonstration. The design alternates editorial, product-led and comparison-light sections to prevent a repetitive card wall.

## Follow-up research plan
- Conduct a date-stamped heuristic review of the six named products at 1440×900 and 390×844; capture screenshots and public plan details without copying assets.
- Test users’ understanding of Auto vs Manual, credits and standalone HTML with 5–8 target customers.
- Run a task-based usability session: start chat, switch model, attach file, save output, find it in Library, cancel subscription.
- Audit mobile nav/hero/product demo and checkout; confirm sticky header does not cover section destinations.
- Track activation and task success with privacy-preserving, consent-aware analytics; do not invent benchmark numbers.
