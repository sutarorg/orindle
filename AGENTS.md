# Orindle repository guide

## Product constraints (preserve)
- Orindle is a single-subscription multi-model AI workspace; only ORINDLE PRO is defined ($14.99/month international, ₹1,399/month India, 1,500 credits/billing month).
- Display only one currency in a pricing view. USD is the safe default; use INR only from trusted server-side country identification and the matching fixed checkout product. Never infer India from browser locale or an IP guess in client code.
- Do not promote a 100+ model count until a synchronized live catalogue has at least 100 unique, currently available, chat-capable model IDs after alias de-duplication.
- Customer application primary navigation is exactly New Chat, Image Studio, Video Studio, Websites, Library, in that order. Settings and billing belong in the account menu.
- Excluded: Slides, Experts, Projects, Compare, Consensus, Prompt Enhancer, and additional plans.
- Website Builder output is standalone HTML (embedded CSS and client JS where appropriate), not full-stack application generation.
- Never add fabricated testimonials, customer metrics, paid-plan discounts, fake scarcity, or non-functional live-service claims.

## Engineering
- Next.js App Router + strict TypeScript + React, Poppins via `next/font/local`, Tailwind v4 available, Lucide icons.
- Keep shared product styling in `app/globals.css`; reusable marketing/application pieces live in `components/`.
- Prefer server components for route shells/content and client components only for interaction. This milestone has intentionally client-heavy demo components where local tabs, accordions and filters need state; split these during backend work if useful.
- Use semantic elements, visible focus, keyboard-operable controls, labels, and reduced-motion support.
- Use `npm run typecheck`, `npm run lint`, and `npm run build` before handoff.

## Preview honesty
This branch is a frontend design foundation. Forms, model generation, subscriptions, files, persistence, account security, catalogue sync, and authorization are not connected. Label static data and UI as demonstrations. Never turn illustrative counts or fixture records into production claims.
