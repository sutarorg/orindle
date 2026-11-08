import { NextRequest,NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';
const localPath=(value:string|null)=>value&&value.startsWith('/')&&!value.startsWith('//')&&!value.includes('\\')?value:'/app/chat';
export async function GET(request:NextRequest){
  const url=request.nextUrl.clone();const code=url.searchParams.get('code');const tokenHash=url.searchParams.get('token_hash');const type=url.searchParams.get('type');const destination=localPath(url.searchParams.get('next'));
  try{const supabase=await createClient();let error;
    if(code){({error}=await supabase.auth.exchangeCodeForSession(code))}
    else if(tokenHash&&(type==='signup'||type==='recovery'||type==='email'||type==='email_change')){({error}=await supabase.auth.verifyOtp({token_hash:tokenHash,type}))}
    else return NextResponse.redirect(new URL('/login?error=invalid_callback',request.url));
    if(error)return NextResponse.redirect(new URL(`/login?error=auth_callback_failed`,request.url));
    return NextResponse.redirect(new URL(destination,request.url));
  }catch{return NextResponse.redirect(new URL('/login?error=service_unavailable',request.url))}
}
