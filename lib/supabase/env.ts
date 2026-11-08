import 'server-only';
export function supabaseConfig(){const url=process.env.NEXT_PUBLIC_SUPABASE_URL;const anon=process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;if(!url||!anon)throw new Error('SUPABASE_NOT_CONFIGURED');return {url,anon}}
export function serviceRoleKey(){const key=process.env.SUPABASE_SERVICE_ROLE_KEY;if(!key)throw new Error('SUPABASE_NOT_CONFIGURED');return key}
export function isSupabaseConfigured(){return Boolean(process.env.NEXT_PUBLIC_SUPABASE_URL&&process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY)}
