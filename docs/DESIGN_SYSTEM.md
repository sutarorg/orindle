# Orindle design system

> **Status note (2026-11-08):** This records design intent and source-level components. Browser screenshots, breakpoint review and WCAG verification have not been completed in the current audit. Some “local-only/demo” interaction notes below predate Prompt 2. See `DESIGN_FINAL_AUDIT.md` and `IMPLEMENTATION_STATUS.md` for current state.

## Foundations
- **Typography:** Poppins local font via `next/font/local`, weights 400, 500, 600, 700. Body 14px default; hero 56px desktop / 37px mobile; section title ~36px / 27px; cards 10–15px; supporting copy 8–12px. Compact tracking on display text, comfortable body line height.
- **Color tokens:** `--bg #fff`; `--soft #f8faf9`; `--soft-green #f3f8f5`; `--ink #111512`; `--muted #68736c`; `--quiet #98a29b`; `--line #e8ede9`; `--hair #f0f2f0`; `--green #16865b`; `--green-dark #07543b`; `--mint #ddf5e9`; `--cyan #ddf5f8`; `--forest #10271e`.
- **Shape:** cards 9–14px, hero container 18–23px, controls 6–10px, subtle 1px borders, low-opacity shadows. Avoid using pills for every element.
- **Layout:** content maximum 1220px; desktop gutters 40px (56px at medium sizes; 16px mobile); desktop 12-column intent; consistent spacing in sections. Responsive content reflows rather than scaling desktop screens down.
- **Iconography:** Lucide React, usually 14–20px with consistent stroke.

## Components implemented
Marketing header/mobile menu, hero and demo browser frame, provider names, model chip set, selectable capability tabs and four preview states, single-plan pricing card, use-case cards, feature cards, keyboard-operable FAQ accordion, final CTA with explicitly illustrative panel, footer. App sidebar with exactly five primary destinations, account-menu entry point, workspace topbar, chat composer, image/video control/result shells, HTML editor/preview tabs, library categories/search/gallery, account panels, admin foundation notice, authentication card, information/policy pages.

## Interaction states
- Primary, secondary, hover, active/selected, disabled/coming-soon, focus via native controls where present.
- Selected app item and capability tab use both background and text/icon color.
- FAQ `aria-expanded` tracks its open state.
- Local-only filters/tabs do not persist or connect to services.
- Static and illustrative values are marked demo in the surrounding interface.

## Responsive design targets
Designed to adapt across 1440, 1280, 1024, 768, 390 and 375 CSS-pixel viewports. At tablet, navigation collapses and grids reduce columns. At <=560px, product mockup is rebuilt as a vertically stacked editor/preview rather than shrunk; capability tabs stack; feature grid becomes two columns; app sidebar becomes a labeled bottom navigation; editor and tool controls become readable single-column layouts. Browser screenshots still need manual inspection at each reference width.

## Accessibility and constraints
Semantic links and buttons, labels, keyboard-friendly native selects/inputs, FAQ state, file input labels, reduced-motion rule. Contrast, full focus visibility, exact target sizing, screen-reader behavior, text zoom/reflow and axe scan remain validation tasks. Do not treat screenshot typography inside marketing mockups as live UI sizes.
