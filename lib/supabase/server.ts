import 'server-only';
import { createServerClient } from '@supabase/ssr';
import { cookies } from 'next/headers';
import { createClient as createSupabaseClient } from '@supabase/supabase-js';
import { serviceRoleKey, supabaseConfig } from './env';

export async function createClient(){
  const {url,anon}=supabaseConfig();const cookieStore=await cookies();
  return createServerClient(url,anon,{cookies:{getAll(){return cookieStore.getAll()},setAll(items){try{for(const {name,value,options} of items)cookieStore.set(name,value,options)}catch{/* Server Components cannot mutate response cookies; middleware refreshes them. */}}}});
}
export function createAdminClient(){
  const {url}=supabaseConfig();return createSupabaseClient(url,serviceRoleKey(),{auth:{autoRefreshToken:false,persistSession:false,detectSessionInUrl:false}});
}
