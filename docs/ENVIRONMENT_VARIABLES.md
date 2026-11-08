# Environment variables

Use [`ENVIRONMENT_VARIABLES_MASTER_GUIDE.md`](ENVIRONMENT_VARIABLES_MASTER_GUIDE.md) as the exact source-audited list. Use [`ENVIRONMENT_VARIABLES_CLICK_BY_CLICK.md`](ENVIRONMENT_VARIABLES_CLICK_BY_CLICK.md) for local/Vercel entry instructions. `.env.example` contains placeholder values only.

Important: Supabase URL/public anon or publishable key can be exposed; `SUPABASE_SERVICE_ROLE_KEY`, OpenRouter, Dodo, webhook and R2 credentials are server-only secrets. The application does not currently read Resend variables or a custom R2 endpoint variable. Dodo configuration uses product IDs and amount guards, not price-ID variables. Dodo live mode is disabled pending explicit approval.
