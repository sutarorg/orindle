import 'server-only';
import { redirect } from 'next/navigation';
import type { User } from '@supabase/supabase-js';
import { createAdminClient, createClient } from '@/lib/supabase/server';

export class AuthRequiredError extends Error{constructor(){super('AUTH_REQUIRED');this.name='AuthRequiredError'}}
export class AdminRequiredError extends Error{constructor(){super('ADMIN_REQUIRED');this.name='AdminRequiredError'}}
export async function getAuthenticatedContext(){
  const supabase=await createClient();const {data:{user},error}=await supabase.auth.getUser();
  if(error||!user)throw new AuthRequiredError();return {supabase,user};
}
export async function getAuthenticatedUser():Promise<User>{return (await getAuthenticatedContext()).user}
export async function requireAdminPage(){
  let user:User;try{user=await getAuthenticatedUser()}catch{redirect('/login?error=auth_required')}
  const admin=createAdminClient();const {data,error}=await admin.from('user_roles').select('role').eq('user_id',user.id).eq('role','admin').maybeSingle();if(error||!data)redirect('/app/chat?notice=admin_required');return user;
}
export async function assertAdmin(userId:string){const admin=createAdminClient();const {data,error}=await admin.from('user_roles').select('role').eq('user_id',userId).eq('role','admin').maybeSingle();if(error||!data)throw new AdminRequiredError();return admin}
