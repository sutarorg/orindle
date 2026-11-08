-- Run with `supabase test db`. All changes are rolled back.
begin;
do $$
begin
  insert into auth.users(id,aud,role,email,encrypted_password,email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
  values
    ('00000000-0000-4000-8000-000000000101','authenticated','authenticated','rls-a@example.invalid','',now(),'{}','{}',now(),now()),
    ('00000000-0000-4000-8000-000000000102','authenticated','authenticated','rls-b@example.invalid','',now(),'{}','{}',now(),now())
  on conflict(id) do nothing;
  insert into public.conversations(id,user_id,title) values
    ('00000000-0000-4000-8000-000000000201','00000000-0000-4000-8000-000000000101','A only'),
    ('00000000-0000-4000-8000-000000000202','00000000-0000-4000-8000-000000000102','B only')
  on conflict(id) do nothing;
  insert into public.uploaded_files(id,user_id,storage_key,original_name,mime_type,size_bytes,purpose)
  values ('00000000-0000-4000-8000-000000000301','00000000-0000-4000-8000-000000000102','test/rls-file','other-user.txt','text/plain',1,'asset')
  on conflict(id) do nothing;
end $$;
set local role authenticated;
select set_config('request.jwt.claim.sub','00000000-0000-4000-8000-000000000101',true);
do $$ begin
  if (select count(*) from public.conversations) <> 1 then raise exception 'RLS: user A should see exactly their conversation'; end if;
  if (select count(*) from public.conversations where id='00000000-0000-4000-8000-000000000202') <> 0 then raise exception 'RLS: user A read another user conversation'; end if;
  if (select count(*) from public.credit_wallets where user_id='00000000-0000-4000-8000-000000000102') <> 0 then raise exception 'RLS: user A read another user wallet'; end if;
  if has_function_privilege('authenticated','public.settle_credit_reservation(uuid,integer,numeric)','EXECUTE') then raise exception 'RLS: authenticated users can settle their own reservations without server verification'; end if;
  if has_function_privilege('authenticated','public.flag_credit_reservation_review(uuid)','EXECUTE') then raise exception 'RLS: authenticated users can manipulate reservation review state'; end if;
  begin
    insert into public.library_items(user_id,category,title,uploaded_file_id) values(auth.uid(),'file','forged link','00000000-0000-4000-8000-000000000301');
    raise exception 'RLS: user A linked another user file into their Library';
  exception when insufficient_privilege then null; end;
end $$;
select set_config('request.jwt.claim.sub','00000000-0000-4000-8000-000000000102',true);
do $$ begin
  if (select count(*) from public.conversations) <> 1 then raise exception 'RLS: user B should see exactly their conversation'; end if;
  if (select count(*) from public.messages m join public.conversations c on c.id=m.conversation_id where c.user_id <> auth.uid()) <> 0 then raise exception 'RLS: cross-user message read'; end if;
end $$;
do $$ begin
  begin update public.credit_wallets set balance=999999 where user_id=auth.uid(); raise exception 'RLS: user modified credit balance'; exception when insufficient_privilege then null; end;
  begin insert into public.user_roles(user_id,role) values(auth.uid(),'admin'); raise exception 'RLS: user assigned admin role'; exception when insufficient_privilege then null; end;
  begin update public.model_pricing set prompt_usd_per_token=0 where true; raise exception 'RLS: user modified model price'; exception when insufficient_privilege then null; end;
  begin update public.payment_records set amount_minor=0 where user_id=auth.uid(); raise exception 'RLS: user modified payment record'; exception when insufficient_privilege then null; end;
end $$;
reset role;
rollback;
