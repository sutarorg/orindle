# Orindle product requirements and implementation status

**Status:** implementation draft with backend/API code present; integrations and launch gates remain unverified. Not a launched or production-approved service. Last updated 2026-11-08.

## Product definition
Orindle is a subscription-based workspace concept for compatible AI chat models, image and video generation, file uploads, standalone HTML website generation, history and a library. Brand tagline requested: **One Workspace. 100+ AI Models.** The numeric claim is gated: the current interface does not assert a verified count because no synchronized live catalogue is connected. Use a nonnumeric public line until the gate is met.

## Commercial model
One plan: ORINDLE PRO. International: USD $14.99 monthly. India: INR ₹1,399 monthly. 1,500 credits per billing month. No trial, discount, free plan, or additional plan has been specified. USD is the default, including unknown location. Only show INR when trusted server-side country data confirms India and checkout selects the exact India fixed-price product. Never combine currencies in one pricing view and never calculate INR from exchange rates. Current preview displays USD only; Dodo Payments localized fixed-price configuration remains unverified/unconnected.

## Included capabilities
- Auto and manual model selection.
- Compatible model catalogue (100+ marketing assertion only after verified unique live IDs; alias de-duplication; compatible chat capability).
- Chat, file upload, chat history.
- Image Studio; Video Studio.
- Website Builder producing standalone HTML.
- Library, generation history, monthly credit renewal.

## Navigation and exclusions
Primary customer nav, exact order: New Chat; Image Studio; Video Studio; Websites; Library. Recent conversations may be visually nested under New Chat. Settings and billing are reachable from the account menu. Exclude Slides, Experts, Projects, Compare, Consensus, Prompt Enhancer and multiple subscription tiers from copy, nav, previews and implementation.

## Human-centred product rules
- Keep one salient next action per workflow. Explain model choice and credit consequences before generation where reliable cost estimates are available.
- Auto is a convenience, not a hidden lock-in; expose manual selection.
- Preserve user control over uploads, generated content, account settings and cancellation.
- Make loading, queued, failed and completed states distinguishable; do not imply a generation occurred in a static fixture.
- Keep the app’s five-tool navigation stable and keep settings/billing in the account menu.
- Distinguish demo fixtures from account/customer data.

## Acceptance / release gates
1. Live catalogue is synchronized, deduplicated and availability checked before displaying numeric model count or live names.
2. India location is trusted server-side, and the displayed fixed price matches the checkout SKU. Unknown location uses USD.
3. Prices, renewal timing, taxes, credit rules, usage estimates and cancellation terms are confirmed and visible before checkout.
4. Privacy, terms, refund and data-retention policies are approved and published before commercial use.
5. Authentication, authorization, secure file handling, rate/credit limits, provider integrations, payment webhook verification, observability and support processes are implemented and tested.
