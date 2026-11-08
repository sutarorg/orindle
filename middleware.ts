import { createServerClient } from '@supabase/ssr';
import { NextResponse, type NextRequest } from 'next/server';

export async function middleware(request:NextRequest){
  if(!process.env.NEXT_PUBLIC_SUPABASE_URL||!process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY){const url=request.nextUrl.clone();url.pathname='/login';url.searchParams.set('error','auth_not_configured');return NextResponse.redirect(url)}
  const url=process.env.NEXT_PUBLIC_SUPABASE_URL!,anon=process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;
  let response=NextResponse.next({request});
  const supabase=createServerClient(url,anon,{cookies:{getAll(){return request.cookies.getAll()},setAll(items){items.forEach(({name,value})=>request.cookies.set(name,value));response=NextResponse.next({request});items.forEach(({name,value,options})=>response.cookies.set(name,value,options))}}});
  const {data:{user}}=await supabase.auth.getUser();
  if(!user){const target=request.nextUrl.clone();target.pathname='/login';target.searchParams.set('next',request.nextUrl.pathname);return NextResponse.redirect(target)}
  return response;
}
export const config={matcher:['/app/:path*','/admin/:path*']};
