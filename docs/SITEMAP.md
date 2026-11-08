# Sitemap and route inventory

## Public
- `/` marketing landing page.
- `/models` model catalogue preview; currently fixture/placeholder content.
- `/about`, `/contact`.
- `/privacy`, `/terms`, `/refund-policy` — draft/launch-blocking information pages, not final legal advice.
- `/login`, `/signup`, `/forgot-password`, `/reset-password`, `/verify-email` — visual-only auth form states.

## Customer workspace (requires auth in production)
- `/app/chat` — New Chat.
- `/app/images` — Image Studio.
- `/app/videos` — Video Studio.
- `/app/websites` — Websites / standalone HTML builder.
- `/app/library` — Library.
- `/app/account` — profile, subscription, credit usage, billing history, security. Billing/account entry is via account menu.

## Internal
- `/admin` — admin UI foundation; currently not authorization-protected. Treat as a release-blocking security defect and protect/remove before deployment.

## Primary navigation invariant
Exactly five destinations in the customer sidebar and mobile navigation: New Chat, Image Studio, Video Studio, Websites, Library. Account settings and billing are in account menu. No extra primary destinations.
