# Landing page specification

> **Status note (2026-11-08):** The following is the original design acceptance spec, not live visual sign-off. Backend pricing/catalogue APIs now exist, but live model data and provider integrations are unverified. The home page remains USD-default and must not claim a verified model count until live catalogue gates pass. Policy content requires owner/legal review. See `DESIGN_FINAL_AUDIT.md` for the actual visual QA limitation.

Route `/`. Current implementation sequence:
1. Sticky white header: brand, Features, AI Models, Pricing, FAQ, About, Contact; Login and Get Started. Mobile collapsible menu.
2. Centered pale mint-to-cyan hero; nonnumeric verified-safe eyebrow, title “One Powerful AI Workspace.”, explanation, Get Started / Explore Models, honest one-subscription note.
3. Original Orindle demo application window: five-tool rail, illustrative credits, code editor plus a fictional agency website preview. On narrow screens the sidebar is hidden and code/editor preview stack vertically. All sample UI is presented as demonstration.
4. Plain text provider names and qualification that availability depends on support/catalogue; not partnerships.
5. Pale-tinted model discovery section, featured examples currently placeholders for visual arrangement only and not claimed as a synchronized catalogue. Numeric model count must remain absent until catalogue verification.
6. Capability section: Chat, Images, Videos, Websites tabs; default Chat; each tab changes the right-hand preview. No excluded Compare/Consensus tools.
7. ORINDLE PRO pricing: USD-only default `$14.99 / month`, 1,500 credits and included benefit checklist. India localization not implemented yet. Taxes/checkout terms caveat.
8. “Made for your everyday AI workflow” use-case cards; no fictitious testimonials.
9. Five capability feature cards (Auto, Image Studio, Video Studio, HTML Website Builder, Library) in varied layout.
10. FAQ accordion.
11. Contrasting dark-green CTA with clearly labeled illustrative model/credit/activity panel.
12. Structured footer; resource placeholders are visibly marked; policy pages explicitly say they are not yet published.

## Visual intent
Premium white minimal, Poppins, strong editorial scale, restrained borders/shadow, centered readable widths, varied compositions. Main app preview is the proof point; not a generic abstract hero graphic.

## Unfinished gates
Sync model catalogue and replace placeholder model examples only after availability verification. Gate 100+ claim. Add trustworthy India server country detection and fixed INR checkout pairing. Replace draft policy pages, configure actual support and resource URLs. Inspect full-page captures at desktop and 375/390 mobile widths; no screenshot-based signoff has been performed yet.
