# Application UI specification

## Primary destinations
Exactly: New Chat (`/app/chat`), Image Studio (`/app/images`), Video Studio (`/app/videos`), Websites (`/app/websites`), Library (`/app/library`). Settings/billing are from account menu (`/app/account`). Recent chat examples are subordinate visual history. No Slides, Experts, Projects, Compare, Consensus or Prompt Enhancer.

## Route-by-route
- **New Chat:** centered welcome and broad prompt composer; attachment; Auto/Manual selector; send affordance; quick links only to Images, Videos, Websites. Demo notice; no provider response.
- **Image Studio:** left model/prompt/reference/aspect/output controls; right empty result and Download/Save affordances; no generation connection.
- **Video Studio:** video model/prompt/reference/duration/aspect controls; result job area; status and output actions; no generation connection.
- **Websites:** standalone HTML description, Code Editor/Preview tabs, Download HTML affordance and explicit demo notice; no full-stack generation or live editor connection.
- **Library:** All, Images, Videos, Websites, Chats, Files filters; local search field; sample fixture cards clearly marked; no persisted data.
- **Account:** profile, subscription, credit usage, billing history, security tabs; static values are demonstration only.
- **Admin:** separate conceptual foundation with visible warning; real server authorization is not implemented and this route must be protected before deployment.

## Shell
Desktop 258px sidebar, subtle divider, compact topbar, centered work area. White/light backgrounds. Sidebar exposes only five primary choices; account management sits at bottom. Mobile replaces sidebar with a fixed labeled bottom navigation; a mobile menu includes all five destinations plus account settings.

## Interaction and real behavior boundaries
Local UI only: capability tabs, FAQ, local library filters, account tabs, model mode toggle, navigation. Forms prevent submit; buttons do not invoke providers or payments. File controls are decorative input points, no files are uploaded. Values 1,240/1,500, profile “Demo user,” history and library items are fixtures. Any backend implementation must replace these with authorized records and robust loading/empty/error states.
