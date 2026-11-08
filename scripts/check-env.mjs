#!/usr/bin/env node
/* Audits configuration names and formats without printing credential values. */
import nextEnv from '@next/env';
nextEnv.loadEnvConfig(process.cwd());

const errors = [];
const warnings = [];
const groups = {
  'Application origin': ['APP_URL', 'NEXT_PUBLIC_APP_URL'],
  'Supabase auth/database': ['NEXT_PUBLIC_SUPABASE_URL', 'NEXT_PUBLIC_SUPABASE_ANON_KEY', 'SUPABASE_SERVICE_ROLE_KEY'],
  'OpenRouter (optional until generation is enabled)': ['OPENROUTER_API_KEY'],
  'Cloudflare R2 (optional until storage is enabled)': ['R2_ACCOUNT_ID', 'R2_ACCESS_KEY_ID', 'R2_SECRET_ACCESS_KEY', 'R2_BUCKET'],
  'Dodo test billing (optional until checkout is enabled)': ['DODO_API_KEY', 'DODO_WEBHOOK_SECRET', 'DODO_PRODUCT_USD_ID'],
};
const configured = (name) => Boolean(process.env[name]?.trim());
const placeholder = (name) => /YOUR_PROJECT|PASTE_|PLACEHOLDER|CHANGE_ME/i.test(process.env[name] || '');

console.log('Orindle environment check — credential values are never displayed.');
for (const [group, names] of Object.entries(groups)) {
  const missing = names.filter((name) => !configured(name) || placeholder(name));
  console.log(`${missing.length ? 'INCOMPLETE' : 'READY'} ${group}${missing.length ? ` — missing/placeholder: ${missing.join(', ')}` : ''}`);
}

const requiredCore = ['APP_URL', 'NEXT_PUBLIC_APP_URL', 'NEXT_PUBLIC_SUPABASE_URL', 'NEXT_PUBLIC_SUPABASE_ANON_KEY', 'SUPABASE_SERVICE_ROLE_KEY'];
for (const name of requiredCore) {
  if (!configured(name) || placeholder(name)) errors.push(`${name} is required for a connected application environment.`);
}
for (const name of ['APP_URL', 'NEXT_PUBLIC_APP_URL', 'NEXT_PUBLIC_SUPABASE_URL', 'OPENROUTER_SITE_URL']) {
  if (!configured(name)) continue;
  try {
    const url = new URL(process.env[name]);
    if (!['https:', 'http:'].includes(url.protocol)) errors.push(`${name} must use http or https.`);
  } catch {
    errors.push(`${name} must be a valid absolute URL.`);
  }
}
if (configured('APP_URL') && configured('NEXT_PUBLIC_APP_URL')) {
  try {
    if (new URL(process.env.APP_URL).origin !== new URL(process.env.NEXT_PUBLIC_APP_URL).origin) {
      warnings.push('APP_URL and NEXT_PUBLIC_APP_URL have different origins; confirm this is intentional for this deployment scope.');
    }
  } catch { /* Absolute URL validation reports the error above. */ }
}
if (process.env.DODO_ENVIRONMENT && !['test_mode', 'live_mode'].includes(process.env.DODO_ENVIRONMENT)) {
  errors.push('DODO_ENVIRONMENT must be test_mode or live_mode.');
}
if (process.env.DODO_ENVIRONMENT === 'live_mode' && process.env.DODO_ENABLE_LIVE_BILLING !== 'true') {
  errors.push('DODO live_mode requires DODO_ENABLE_LIVE_BILLING=true; live transactions still require explicit owner approval.');
}
if (process.env.DODO_ENABLE_LIVE_BILLING === 'true') {
  warnings.push('DODO_ENABLE_LIVE_BILLING is true. Do not use live billing without explicit owner approval.');
}
for (const [product, amount, expected] of [
  ['DODO_PRODUCT_USD_ID', 'DODO_PRICE_USD_MINOR', '1499'],
  ['DODO_PRODUCT_INR_ID', 'DODO_PRICE_INR_MINOR', '139900'],
]) {
  if (configured(product) && process.env[amount] !== expected) errors.push(`${amount} must equal ${expected} when ${product} is configured.`);
}
if (configured('NEXT_PUBLIC_SUPABASE_SERVICE_ROLE_KEY') || configured('NEXT_PUBLIC_OPENROUTER_API_KEY') || configured('NEXT_PUBLIC_DODO_API_KEY') || configured('NEXT_PUBLIC_R2_SECRET_ACCESS_KEY')) {
  errors.push('A server-only secret appears to use a NEXT_PUBLIC_ name. Remove it from public configuration and rotate it if exposed.');
}
for (const warning of warnings) console.warn(`WARNING ${warning}`);
if (process.argv.includes('--all')) {
  for (const name of ['OPENROUTER_API_KEY', 'R2_ACCOUNT_ID', 'R2_ACCESS_KEY_ID', 'R2_SECRET_ACCESS_KEY', 'R2_BUCKET', 'DODO_API_KEY', 'DODO_WEBHOOK_SECRET', 'DODO_PRODUCT_USD_ID']) {
    if (!configured(name) || placeholder(name)) errors.push(`${name} is required by --all.`);
  }
}
if (errors.length) {
  for (const error of errors) console.error(`ERROR ${error}`);
  if (process.argv.includes('--strict') || process.argv.includes('--all')) process.exitCode = 1;
  else console.log('Configuration is incomplete; this is expected before providers are connected. Use --strict or --all to fail the command.');
} else {
  console.log('Core application configuration looks structurally valid. This does not verify credentials with providers.');
}
