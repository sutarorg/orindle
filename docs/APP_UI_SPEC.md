# Application UI specification

> **Status note (2026-11-08):** The sections below document design intent from the frontend milestone. They predate Prompt 2: connected API/auth/account/generation flows and a server role guard are now present in source, but external integrations and admin operational data are still unverified. See `IMPLEMENTATION_STATUS.md` and `FINAL_LAUNCH_STATUS.md` for the actual current status. Do not treat older “demo” labels below as proof that every current route is still static.

## Primary destinations
Exactly: New Chat (`/app/chat`), Image Studio (`/app/images`), Video Studio (`/app/videos`), Websites (`/app/websites`), Library (`/app/library`). Settings/billing are from account menu (`/app/account`). Recent chat examples are subordinate visual history. No Slides, Experts, Projects, Compare, Consensus or Prompt Enhancer.

## Route-by-route
- **New Chat:** the current UI sends authenticated API requests, streams replies and can attach validated files. OpenRouter is unconfigured and no live provider response was verified in this audit.
- **Image Studio:** current source submits supported generation requests to the backend and displays returned assets. Provider configuration, pricing and storage delivery are unverified.
- **Video Studio:** current source submits asynchronous jobs and polls persisted status. Provider behavior, billing settlement and artifact delivery are unverified.
- **Websites:** current source submits generation requests and saves generated standalone HTML; it is not a production code-hosting/editor service. Provider and browser rendering behavior remain unverified.
- **Library:** current source reads persisted owner-scoped records and categories; records require configured Supabase/R2 and have not been tested against a database here.
- **Account:** current source reads authenticated profile, subscription and usage records and exposes billing/security actions. Real account/provider behavior is unverified.
- **Admin:** server-side role gating exists, but current panels are placeholders and are not connected to live operational data.

## Shell
Desktop 258px sidebar, subtle divider, compact topbar, centered work area. White/light backgrounds. Sidebar exposes only five primary choices; account management sits at bottom. Mobile replaces sidebar with a fixed labeled bottom navigation; a mobile menu includes all five destinations plus account settings.

## Interaction and real behavior boundaries
The preceding interaction description is historical frontend-milestone text. Current source has real API calls and persisted-data flows, but behavior depends on environment credentials and has not been verified with external services. Review `DESIGN_FINAL_AUDIT.md` for source-level findings and browser-visual limitations.
