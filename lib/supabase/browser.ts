'use client';
import { createBrowserClient } from '@supabase/ssr';
let browserClient:ReturnType<typeof createBrowserClient>|undefined;
export function createClient(){const url=process.env.NEXT_PUBLIC_SUPABASE_URL,anon=process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;if(!url||!anon)throw new Error('Authentication is not configured.');browserClient??=createBrowserClient(url,anon);return browserClient}
