# Psychology and human-centred UX research

## Research basis
The design decisions synthesize established usability principles and these references:
- NN/g, [5 Principles of Visual Design in UX](https://www.nngroup.com/articles/principles-visual-design/) — scale, hierarchy, balance, contrast and Gestalt principles guide interpretation.
- NN/g, [Visual Hierarchy in UX](https://www.nngroup.com/articles/visual-hierarchy-ux-definition/) — hierarchy directs attention using scale, contrast, placement and grouping.
- NN/g, [Recognition Rather Than Recall](https://www.nngroup.com/articles/recognition-and-recall/) — visible choices reduce memory burden.
- NN/g, [Gestalt Similarity](https://www.nngroup.com/articles/gestalt-similarity/) — consistent visual properties communicate relatedness.
- NN/g, [Gestalt Proximity](https://www.nngroup.com/articles/gestalt-proximity/) — spatial closeness and whitespace communicate groups.
- [Baymard Institute research](https://www.baymard.com/blog/) — checkout and form usability research is a reference for reducing uncertainty and avoidable friction; exact findings should be consulted in a later evidence review.
- W3C, [Web Content Accessibility Guidelines 2.2](https://www.w3.org/TR/WCAG22/) — accessibility is a product requirement, not a polish pass.

## Applied principles and decisions

### Visual hierarchy, scale and attention
**Principle:** users should not need to search for the primary message/action. Scale, contrast, spacing and placement form a readable order.
**Applied:** restrained 56px desktop hero, secondary 36px section titles and compact body copy. The hero copy is centered and constrained; action buttons directly follow the proposition. Pricing uses one large price and a single primary CTA. Green is reserved for action/selected state rather than used as decoration everywhere.

### Balance, whitespace and Gestalt grouping
**Principle:** proximity and common region help people infer what belongs together; too much density increases scanning cost.
**Applied:** model chips share a compact common container; composer actions stay grouped; filters are separated from results; pricing benefits are arranged in two columns inside one plan card. Alternating full-width soft sections and constrained content areas produces rhythm without repeating the same grid each time.

### Similarity and consistent mental models
**Principle:** similar controls should signal similar behavior; platform conventions lower the learning burden.
**Applied:** all tool pages share title, controls, result region, buttons and status notice patterns. The five application destinations use the same icon size and row geometry. Green selected states carry between marketing tabs and app navigation. Download/Library actions are positioned consistently.

### Hick’s Law and decision fatigue
**Principle:** more equally weighted choices can increase decision time; this is a directional design lens, not a literal timing guarantee.
**Applied:** a single Auto/Manual selector is offered, with Auto as an understandable starting route. Five primary app destinations remain fixed; model inventory is not a dense first screen. No plan comparison or extra add-on decision exists. Avoid making users choose among an unverified catalogue.

### Fitts’s Law and responsive control size
**Principle:** larger, closer targets are easier to acquire, especially on touch screens.
**Applied:** navigation rows and CTA controls have generous desktop and mobile hit regions. Mobile nav uses visible labels; menus remain touch-friendly. Further viewport/device testing is needed to verify exact WCAG target-size requirements and pointer handling.

### Cognitive load, progressive disclosure and recognition
**Principle:** keep routine tasks understandable, reveal advanced options in context, and show choices instead of requiring recall.
**Applied:** Image/Video controls are grouped under a dedicated tool rather than in the global chat view. Account billing/security stays behind account menu; model capability details can expand with a live catalogue. Composer offers shortcuts to only the three other creation destinations. Library categories label the types of saved work.

### Feedback, control and trust formation
**Principle:** users need understandable state, control, and credible evidence to trust an interface.
**Applied:** demo-only controls are explicitly labeled as unconnected; blank generation states explain what is needed; billing page states no payment is active; admin page warns it needs server authorization. Provider names have a no-endorsement qualifier. Testimonial placeholders are replaced with use cases. Prices have clear cadence and a note that taxes may apply.

### Ethical persuasion and conversion
**Principle:** conversion should come from relevance and clarity, not false urgency or reduced autonomy.
**Applied:** one visible plan, no strikethrough anchor or countdown, no fabricated reviews or customer counts, no preselected purchase extras. “Get Started” does not claim a free tier. Cancellation is named and account management is part of the application design. Checkout and policy states remain explicit implementation gates.

## Accessibility criteria
- Semantic headings, landmarks, links and buttons; labels for prompt, search and account fields.
- Keyboard-operable mobile nav, tabs and accordion; expanded state announced on FAQ buttons.
- Focus indicators and sufficient color contrast to be audited against WCAG 2.2 AA in a browser.
- Do not rely on color alone to show selection or status.
- Reduced-motion media query disables animated transitions.
- Responsive reflow and readable single-column product demo at narrow widths.

## Limitations and validation
The UI has not been tested with assistive technologies or participants. The compact website demo has intentionally tiny text as a product screenshot; ensure no actual app control/text inherits screenshot sizing. Run automated axe checks plus keyboard and screen-reader testing, contrast measurements, and 5–8 moderated task sessions before launch. Apply Hick/Fitts as useful principles rather than universal predictive laws.
