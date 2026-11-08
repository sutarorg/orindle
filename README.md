# Orindle

Orindle is a frontend foundation for a premium multi-model AI workspace. This branch contains a responsive Next.js App Router design system, a full marketing-page prototype, application workflow shells, and implementation/research handoff docs. It is not a connected or launched AI service.

## Run locally

```bash
npm install
npm run dev
```

The dev server binds to `0.0.0.0:3000` for preview. Useful checks:

```bash
npm run typecheck
npm run lint
npm run build
npm audit
```

## Start here
- [Product requirements](docs/PRODUCT_REQUIREMENTS.md)
- [Market research](docs/MARKET_RESEARCH.md)
- [Competitor research](docs/COMPETITOR_RESEARCH.md)
- [Psychology and UX research](docs/PSYCHOLOGY_AND_UX_RESEARCH.md)
- [Design system](docs/DESIGN_SYSTEM.md)
- [Prompt 2 handoff](docs/HANDOFF_TO_PROMPT_2.md)

All generation, authentication, payments, storage, model catalogue, user persistence and admin authorization are unconnected. Demo content is labeled in the interface. See the handoff document for release blockers and environment variable placeholders.
