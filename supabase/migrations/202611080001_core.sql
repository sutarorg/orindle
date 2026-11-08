-- Orindle core schema, RLS and transactional credit primitives.
-- Apply via `supabase db push`; never expose the service-role key to clients.
create extension if not exists pgcrypto with schema extensions;
create schema if not exists private;

create or replace function public.set_updated_at()
returns trigger language plpgsql set search_path = '' as $$
begin new.updated_at = now(); return new; end; $$;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '',
  avatar_url text,
  country_code char(2),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table public.user_roles (
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'user' check (role in ('user','admin')),
  created_at timestamptz not null default now(),
  primary key (user_id, role)
);
create table public.user_preferences (
  user_id uuid primary key references auth.users(id) on delete cascade,
  model_mode text not null default 'auto' check (model_mode in ('auto','manual')),
  preferred_model_id uuid,
  locale text not null default 'en',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.model_catalog (
  id uuid primary key default gen_random_uuid(),
  provider text not null,
  model_id text not null,
  canonical_model_id text,
  display_name text not null,
  description text not null default '',
  context_length integer check (context_length is null or context_length > 0),
  input_modalities text[] not null default '{}',
  output_modalities text[] not null default '{}',
  supported_parameters text[] not null default '{}',
  metadata jsonb not null default '{}'::jsonb,
  active boolean not null default true,
  last_synced_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (provider, model_id)
);
alter table public.user_preferences add constraint user_preferences_model_fk foreign key (preferred_model_id) references public.model_catalog(id) on delete set null;
create index model_catalog_active_provider_idx on public.model_catalog(active, provider, display_name);
create index model_catalog_modalities_idx on public.model_catalog using gin(input_modalities, output_modalities);
create table public.model_capabilities (
  id uuid primary key default gen_random_uuid(),
  model_id uuid not null references public.model_catalog(id) on delete cascade,
  capability text not null check (capability in ('text','image','video','audio','speech','transcription','embeddings','reranking')),
  active boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  unique (model_id, capability)
);
create index model_capability_lookup_idx on public.model_capabilities(capability, active, model_id);
create table public.model_pricing (
  id uuid primary key default gen_random_uuid(),
  model_id uuid not null unique references public.model_catalog(id) on delete cascade,
  prompt_usd_per_token numeric(24,16) check (prompt_usd_per_token is null or prompt_usd_per_token >= 0),
  completion_usd_per_token numeric(24,16) check (completion_usd_per_token is null or completion_usd_per_token >= 0),
  image_usd numeric(18,8),
  video_usd_per_second numeric(18,8),
  currency char(3) not null default 'USD' check (currency = 'USD'),
  source text not null default 'openrouter',
  synced_at timestamptz not null default now()
);
create table public.model_sync_logs (
  id uuid primary key default gen_random_uuid(),
  provider text not null,
  status text not null check (status in ('running','succeeded','failed')),
  model_count integer not null default 0,
  unique_chat_count integer not null default 0,
  started_at timestamptz not null default now(),
  finished_at timestamptz,
  error_message text
);

create table public.conversations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null default 'New Chat' check (char_length(title) <= 160),
  active_model_id uuid references public.model_catalog(id) on delete set null,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);
create index conversations_user_recent_idx on public.conversations(user_id, updated_at desc) where deleted_at is null;
create table public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null check (role in ('user','assistant','system')),
  content text not null default '',
  model_id uuid references public.model_catalog(id) on delete set null,
  status text not null default 'complete' check (status in ('pending','streaming','complete','failed','cancelled')),
  prompt_tokens integer check (prompt_tokens is null or prompt_tokens >= 0),
  completion_tokens integer check (completion_tokens is null or completion_tokens >= 0),
  provider_cost_usd numeric(18,10) check (provider_cost_usd is null or provider_cost_usd >= 0),
  provider_cost_basis text check (provider_cost_basis in ('actual','estimated')),
  credit_reservation_id uuid,
  idempotency_key text,
  error_code text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (role <> 'system' or status = 'complete')
);
create index messages_conversation_idx on public.messages(conversation_id, created_at);
create unique index messages_user_idempotency_unique on public.messages(user_id,idempotency_key) where idempotency_key is not null;
create table public.message_attachments (
  id uuid primary key default gen_random_uuid(),
  message_id uuid not null references public.messages(id) on delete cascade,
  uploaded_file_id uuid not null,
  created_at timestamptz not null default now(),
  unique (message_id, uploaded_file_id)
);

create table public.credit_wallets (
  user_id uuid primary key references auth.users(id) on delete cascade,
  balance integer not null default 0 check (balance >= 0),
  reserved integer not null default 0 check (reserved >= 0),
  updated_at timestamptz not null default now()
);
create table public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  provider text not null default 'dodo' check (provider = 'dodo'),
  provider_subscription_id text unique,
  provider_customer_id text,
  product_id text not null,
  plan_code text not null default 'ORINDLE_PRO' check (plan_code = 'ORINDLE_PRO'),
  currency char(3) not null check (currency in ('USD','INR')),
  amount_minor bigint not null check (amount_minor > 0),
  status text not null check (status in ('pending','active','past_due','on_hold','cancelled','expired','failed')),
  period_start timestamptz,
  period_end timestamptz,
  cancel_at_period_end boolean not null default false,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index subscriptions_user_idx on public.subscriptions(user_id, created_at desc);
create unique index subscriptions_one_active_per_user on public.subscriptions(user_id) where status in ('pending','active','past_due','on_hold');
create table public.subscription_events (
  id uuid primary key default gen_random_uuid(),
  subscription_id uuid not null references public.subscriptions(id) on delete cascade,
  provider_event_id text not null unique,
  event_type text not null,
  payload jsonb not null default '{}'::jsonb,
  occurred_at timestamptz not null,
  received_at timestamptz not null default now()
);
create table public.payment_records (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  subscription_id uuid references public.subscriptions(id) on delete set null,
  provider text not null default 'dodo',
  provider_payment_id text not null unique,
  currency char(3) not null check (currency in ('USD','INR')),
  amount_minor bigint not null check (amount_minor >= 0),
  status text not null,
  occurred_at timestamptz not null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
create index payment_records_user_idx on public.payment_records(user_id, occurred_at desc);
create table public.webhook_events (
  id uuid primary key default gen_random_uuid(),
  provider text not null,
  provider_event_id text not null,
  event_type text not null,
  status text not null default 'received' check (status in ('received','processed','ignored','failed')),
  payload jsonb not null default '{}'::jsonb,
  error_message text,
  received_at timestamptz not null default now(),
  processed_at timestamptz,
  unique (provider, provider_event_id)
);

create table public.generation_jobs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  kind text not null check (kind in ('image','video','website')),
  model_id uuid references public.model_catalog(id) on delete set null,
  provider text not null default 'openrouter',
  provider_job_id text,
  provider_poll_url text,
  idempotency_key text,
  status text not null default 'queued' check (status in ('queued','submitted','processing','completed','failed','cancelled','expired','needs_review')),
  prompt text not null,
  request jsonb not null default '{}'::jsonb,
  result_metadata jsonb not null default '{}'::jsonb,
  credit_reservation_id uuid,
  estimated_credits integer not null default 0 check (estimated_credits >= 0),
  actual_credits integer check (actual_credits is null or actual_credits >= 0),
  estimated_cost_usd numeric(18,10) check (estimated_cost_usd is null or estimated_cost_usd >= 0),
  actual_cost_usd numeric(18,10) check (actual_cost_usd is null or actual_cost_usd >= 0),
  actual_cost_basis text check (actual_cost_basis in ('actual','estimated')),
  error_code text,
  submitted_at timestamptz,
  completed_at timestamptz,
  expires_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create unique index generation_provider_job_unique on public.generation_jobs(provider, provider_job_id) where provider_job_id is not null;
create unique index generation_user_idempotency_unique on public.generation_jobs(user_id,kind,idempotency_key) where idempotency_key is not null;
create index generation_jobs_user_recent_idx on public.generation_jobs(user_id, created_at desc);
create table public.generation_assets (
  id uuid primary key default gen_random_uuid(),
  job_id uuid not null references public.generation_jobs(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  storage_key text not null unique,
  mime_type text not null,
  byte_size bigint not null check (byte_size >= 0),
  width integer,
  height integer,
  duration_seconds numeric(8,3),
  sha256 text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
create table public.generation_usage (
  id uuid primary key default gen_random_uuid(),
  job_id uuid references public.generation_jobs(id) on delete set null,
  message_id uuid references public.messages(id) on delete set null,
  user_id uuid not null references auth.users(id) on delete cascade,
  model_id uuid references public.model_catalog(id) on delete set null,
  input_tokens integer not null default 0 check (input_tokens >= 0),
  output_tokens integer not null default 0 check (output_tokens >= 0),
  provider_cost_usd numeric(18,10) not null check (provider_cost_usd >= 0),
  cost_basis text not null check (cost_basis in ('actual','estimated')),
  credits_charged integer not null check (credits_charged >= 0),
  created_at timestamptz not null default now(),
  check (job_id is not null or message_id is not null)
);
create index generation_usage_user_idx on public.generation_usage(user_id, created_at desc);
create unique index generation_usage_job_unique on public.generation_usage(job_id) where job_id is not null;
create unique index library_asset_unique on public.library_items(user_id,generation_asset_id);

create table public.credit_reservations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  generation_job_id uuid references public.generation_jobs(id) on delete set null,
  idempotency_key text not null,
  reserved_credits integer not null check (reserved_credits > 0),
  actual_credits integer check (actual_credits is null or actual_credits >= 0),
  actual_cost_usd numeric(18,10) check (actual_cost_usd is null or actual_cost_usd >= 0),
  status text not null default 'reserved' check (status in ('reserved','settled','released','needs_review')),
  expires_at timestamptz not null default (now() + interval '30 minutes'),
  created_at timestamptz not null default now(),
  settled_at timestamptz,
  unique (user_id, idempotency_key)
);
create index credit_reservations_reconcile_idx on public.credit_reservations(status, expires_at) where status in ('reserved','needs_review');
alter table public.generation_jobs add constraint generation_credit_reservation_fk foreign key (credit_reservation_id) references public.credit_reservations(id) on delete set null;
alter table public.messages add constraint message_credit_reservation_fk foreign key (credit_reservation_id) references public.credit_reservations(id) on delete set null;
create table public.credit_transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  reservation_id uuid references public.credit_reservations(id) on delete set null,
  grant_id uuid,
  idempotency_key text not null,
  kind text not null check (kind in ('grant','reserve','usage','refund','adjustment','expiry')),
  amount integer not null check (amount <> 0),
  balance_after integer not null check (balance_after >= 0),
  provider_cost_usd numeric(18,10) check (provider_cost_usd is null or provider_cost_usd >= 0),
  description text not null default '',
  created_at timestamptz not null default now(),
  unique (user_id, idempotency_key)
);
create index credit_transactions_user_recent_idx on public.credit_transactions(user_id, created_at desc);
create table public.credit_grants (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  subscription_id uuid not null references public.subscriptions(id) on delete cascade,
  provider_event_id text not null unique,
  credits integer not null check (credits > 0),
  period_start timestamptz not null,
  period_end timestamptz not null,
  expires_at timestamptz,
  created_at timestamptz not null default now(),
  check (period_end > period_start)
);
alter table public.credit_transactions add constraint credit_transaction_grant_fk foreign key (grant_id) references public.credit_grants(id) on delete set null;

create table public.uploaded_files (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  storage_key text not null unique,
  original_name text not null,
  mime_type text not null,
  size_bytes bigint not null check (size_bytes between 1 and 26214400),
  sha256 text,
  purpose text not null check (purpose in ('chat','image_reference','video_reference','asset')),
  scan_status text not null default 'pending' check (scan_status in ('pending','validated','rejected','error')),
  expires_at timestamptz,
  created_at timestamptz not null default now(),
  deleted_at timestamptz
);
create index uploaded_files_user_idx on public.uploaded_files(user_id, created_at desc) where deleted_at is null;
alter table public.message_attachments add constraint message_attachment_file_fk foreign key (uploaded_file_id) references public.uploaded_files(id) on delete cascade;
create table public.library_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  category text not null check (category in ('image','video','website','chat','file')),
  title text not null,
  generation_asset_id uuid references public.generation_assets(id) on delete cascade,
  uploaded_file_id uuid references public.uploaded_files(id) on delete cascade,
  conversation_id uuid references public.conversations(id) on delete cascade,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  archived_at timestamptz,
  check (num_nonnulls(generation_asset_id, uploaded_file_id, conversation_id) = 1)
);
create index library_user_idx on public.library_items(user_id, created_at desc) where archived_at is null;
create unique index library_conversation_unique on public.library_items(user_id,conversation_id);
create table public.system_settings (
  key text primary key,
  value jsonb not null,
  public_readable boolean not null default false,
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users(id) on delete set null
);
insert into public.system_settings(key,value,public_readable) values
 ('credits_per_usd', '1000'::jsonb, false),
 ('monthly_credit_grant', '1500'::jsonb, false),
 ('max_chat_completion_tokens', '4096'::jsonb, false),
 ('country_inr_allowlist', '["IN"]'::jsonb, false)
on conflict(key) do nothing;
create table public.admin_audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_user_id uuid references auth.users(id) on delete set null,
  action text not null,
  target_type text not null,
  target_id text,
  request_id text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.user_roles r where r.user_id = auth.uid() and r.role = 'admin');
$$;
revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to authenticated;

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles(id,display_name) values(new.id, coalesce(new.raw_user_meta_data ->> 'display_name','')) on conflict(id) do nothing;
  insert into public.user_roles(user_id,role) values(new.id,'user') on conflict do nothing;
  insert into public.credit_wallets(user_id) values(new.id) on conflict(user_id) do nothing;
  insert into public.user_preferences(user_id) values(new.id) on conflict(user_id) do nothing;
  return new;
end; $$;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();

create or replace function public.reserve_credits(p_amount integer, p_idempotency_key text, p_generation_job_id uuid default null)
returns uuid language plpgsql security definer set search_path = '' as $$
declare v_user uuid := auth.uid(); v_wallet public.credit_wallets; v_id uuid;
begin
  if v_user is null or p_amount is null or p_amount <= 0 or length(p_idempotency_key) not between 1 and 160 then raise exception 'invalid_reservation'; end if;
  if p_generation_job_id is not null and not exists(select 1 from public.generation_jobs j where j.id=p_generation_job_id and j.user_id=v_user) then raise exception 'generation_job_not_found'; end if;
  select id into v_id from public.credit_reservations where user_id=v_user and idempotency_key=p_idempotency_key;
  if v_id is not null then return v_id; end if;
  select * into v_wallet from public.credit_wallets where user_id=v_user for update;
  if not found or v_wallet.balance < p_amount then raise exception 'insufficient_credits'; end if;
  update public.credit_wallets set balance=balance-p_amount, reserved=reserved+p_amount, updated_at=now() where user_id=v_user returning * into v_wallet;
  insert into public.credit_reservations(user_id,generation_job_id,idempotency_key,reserved_credits)
    values(v_user,p_generation_job_id,p_idempotency_key,p_amount) returning id into v_id;
  insert into public.credit_transactions(user_id,reservation_id,idempotency_key,kind,amount,balance_after,description)
    values(v_user,v_id,'reserve:'||p_idempotency_key,'reserve',-p_amount,v_wallet.balance,'Reserved for request');
  return v_id;
end; $$;

create or replace function public.settle_credit_reservation(p_reservation_id uuid,p_actual_credits integer,p_actual_cost_usd numeric default null)
returns text language plpgsql security definer set search_path = '' as $$
declare v_user uuid; v_r public.credit_reservations; v_wallet public.credit_wallets; v_delta integer;
begin
  if auth.role() <> 'service_role' then raise exception 'not_authorized'; end if;
  select user_id into v_user from public.credit_reservations where id=p_reservation_id;
  if v_user is null or p_actual_credits is null or p_actual_credits < 0 or (p_actual_cost_usd is not null and p_actual_cost_usd < 0) then raise exception 'invalid_settlement'; end if;
  select * into v_r from public.credit_reservations where id=p_reservation_id and user_id=v_user for update;
  if not found then raise exception 'reservation_not_found'; end if;
  if v_r.status in ('settled','released') then return v_r.status; end if;
  select * into v_wallet from public.credit_wallets where user_id=v_user for update;
  if v_r.status='needs_review' then raise exception 'reservation_needs_review'; end if;
  v_delta := v_r.reserved_credits - p_actual_credits;
  if v_delta < 0 and v_wallet.balance < -v_delta then
    update public.credit_reservations set status='needs_review',actual_credits=p_actual_credits,actual_cost_usd=p_actual_cost_usd where id=v_r.id;
    return 'needs_review';
  end if;
  update public.credit_wallets set balance=balance+v_delta,reserved=reserved-v_r.reserved_credits,updated_at=now() where user_id=v_user returning * into v_wallet;
  if v_delta > 0 then
    insert into public.credit_transactions(user_id,reservation_id,idempotency_key,kind,amount,balance_after,provider_cost_usd,description)
    values(v_user,v_r.id,'settle-refund:'||v_r.id::text,'refund',v_delta,v_wallet.balance,p_actual_cost_usd,'Unused reservation returned');
  elsif v_delta < 0 then
    insert into public.credit_transactions(user_id,reservation_id,idempotency_key,kind,amount,balance_after,provider_cost_usd,description)
    values(v_user,v_r.id,'settle-extra:'||v_r.id::text,'usage',v_delta,v_wallet.balance,p_actual_cost_usd,'Additional actual usage');
  end if;
  update public.credit_reservations set status=case when p_actual_credits=0 then 'released' else 'settled' end,actual_credits=p_actual_credits,actual_cost_usd=p_actual_cost_usd,settled_at=now() where id=v_r.id;
  return case when p_actual_credits=0 then 'released' else 'settled' end;
end; $$;

create or replace function public.flag_credit_reservation_review(p_reservation_id uuid)
returns boolean language plpgsql security definer set search_path = '' as $$
declare v_user uuid;
begin
  if auth.role() <> 'service_role' then raise exception 'not_authorized'; end if;
  update public.credit_reservations set status='needs_review'
    where id=p_reservation_id and status='reserved' returning user_id into v_user;
  return v_user is not null;
end; $$;

create or replace function public.grant_monthly_credits(p_user_id uuid,p_subscription_id uuid,p_provider_event_id text,p_period_start timestamptz,p_period_end timestamptz)
returns uuid language plpgsql security definer set search_path = '' as $$
declare v_grant uuid; v_credits integer;
begin
  if auth.role() <> 'service_role' and not public.is_admin() then raise exception 'not_authorized'; end if;
  if p_period_end <= p_period_start then raise exception 'invalid_billing_period'; end if;
  select (value #>> '{}')::integer into v_credits from public.system_settings where key='monthly_credit_grant';
  if v_credits is null or v_credits <> 1500 then raise exception 'invalid_credit_grant_setting'; end if;
  insert into public.credit_grants(user_id,subscription_id,provider_event_id,credits,period_start,period_end)
    values(p_user_id,p_subscription_id,p_provider_event_id,v_credits,p_period_start,p_period_end)
    on conflict(provider_event_id) do nothing returning id into v_grant;
  if v_grant is null then select id into v_grant from public.credit_grants where provider_event_id=p_provider_event_id; return v_grant; end if;
  insert into public.credit_wallets(user_id) values(p_user_id) on conflict(user_id) do nothing;
  update public.credit_wallets set balance=balance+v_credits,updated_at=now() where user_id=p_user_id;
  insert into public.credit_transactions(user_id,grant_id,idempotency_key,kind,amount,balance_after,description)
    select p_user_id,v_grant,'grant:'||p_provider_event_id,'grant',v_credits,w.balance,'Monthly ORINDLE PRO credits' from public.credit_wallets w where w.user_id=p_user_id;
  return v_grant;
end; $$;

create or replace function public.sync_model_catalogue(p_models jsonb,p_sync_id uuid)
returns integer language plpgsql security definer set search_path = '' as $$
declare v_count integer;
begin
  if auth.role() <> 'service_role' and not public.is_admin() then raise exception 'not_authorized'; end if;
  if jsonb_typeof(p_models) <> 'array' then raise exception 'invalid_model_payload'; end if;
  insert into public.model_catalog(provider,model_id,canonical_model_id,display_name,description,context_length,input_modalities,output_modalities,supported_parameters,metadata,active,last_synced_at)
  select 'openrouter', x->>'id', nullif(x->>'canonical_model_id',''), coalesce(nullif(x->>'name',''),x->>'id'), coalesce(x->>'description',''), nullif(x->>'context_length','')::integer,
    coalesce(array(select jsonb_array_elements_text(coalesce(x->'input_modalities','[]'::jsonb))),'{}'),
    coalesce(array(select jsonb_array_elements_text(coalesce(x->'output_modalities','[]'::jsonb))),'{}'),
    coalesce(array(select jsonb_array_elements_text(coalesce(x->'supported_parameters','[]'::jsonb))),'{}'), coalesce(x->'metadata','{}'::jsonb), true, now()
  from jsonb_array_elements(p_models) x where coalesce(x->>'id','') <> ''
  on conflict(provider,model_id) do update set canonical_model_id=excluded.canonical_model_id,display_name=excluded.display_name,description=excluded.description,context_length=excluded.context_length,input_modalities=excluded.input_modalities,output_modalities=excluded.output_modalities,supported_parameters=excluded.supported_parameters,metadata=excluded.metadata,active=true,last_synced_at=now();
  update public.model_catalog c set active=false,updated_at=now() where provider='openrouter' and active and not exists(select 1 from jsonb_array_elements(p_models) x where x->>'id'=c.model_id);
  insert into public.model_pricing(model_id,prompt_usd_per_token,completion_usd_per_token,image_usd,video_usd_per_second,source,synced_at)
    select c.id,nullif(x->'pricing'->>'prompt','')::numeric,nullif(x->'pricing'->>'completion','')::numeric,nullif(x->'pricing'->>'image','')::numeric,nullif(x->'pricing'->>'video','')::numeric,'openrouter',now()
    from jsonb_array_elements(p_models) x join public.model_catalog c on c.provider='openrouter' and c.model_id=x->>'id'
    on conflict(model_id) do update set prompt_usd_per_token=excluded.prompt_usd_per_token,completion_usd_per_token=excluded.completion_usd_per_token,image_usd=excluded.image_usd,video_usd_per_second=excluded.video_usd_per_second,source='openrouter',synced_at=now();
  delete from public.model_capabilities mc using public.model_catalog c where mc.model_id=c.id and c.provider='openrouter';
  insert into public.model_capabilities(model_id,capability)
    select c.id, m.cap from jsonb_array_elements(p_models) x join public.model_catalog c on c.provider='openrouter' and c.model_id=x->>'id'
    cross join lateral (select unnest(coalesce(array(select jsonb_array_elements_text(coalesce(x->'input_modalities','[]'::jsonb))),'{}')) cap union select unnest(coalesce(array(select jsonb_array_elements_text(coalesce(x->'output_modalities','[]'::jsonb))),'{}')) cap) m
    where m.cap in ('text','image','video','audio','speech','transcription','embeddings','reranking') on conflict(model_id,capability) do nothing;
  select count(*) into v_count from jsonb_array_elements(p_models);
  update public.model_sync_logs set status='succeeded',model_count=v_count,unique_chat_count=(select count(distinct coalesce(canonical_model_id,model_id)) from public.model_catalog where provider='openrouter' and active and 'text'=any(output_modalities)),finished_at=now() where id=p_sync_id;
  return v_count;
end; $$;

-- Automatic profile/ledger writes and all credit/catalogue mutation functions are server-only or transactional RPCs.
revoke all on function public.reserve_credits(integer,text,uuid) from public;
revoke all on function public.settle_credit_reservation(uuid,integer,numeric) from public;
revoke all on function public.flag_credit_reservation_review(uuid) from public;
revoke all on function public.grant_monthly_credits(uuid,uuid,text,timestamptz,timestamptz) from public;
revoke all on function public.sync_model_catalogue(jsonb,uuid) from public;
grant execute on function public.reserve_credits(integer,text,uuid) to authenticated;
grant execute on function public.settle_credit_reservation(uuid,integer,numeric) to service_role;
grant execute on function public.flag_credit_reservation_review(uuid) to service_role;
grant execute on function public.grant_monthly_credits(uuid,uuid,text,timestamptz,timestamptz) to service_role;
grant execute on function public.sync_model_catalogue(jsonb,uuid) to service_role;

-- RLS and intentionally narrow client permissions.
do $$ declare t text; begin
  foreach t in array array['profiles','user_roles','user_preferences','model_catalog','model_capabilities','model_pricing','model_sync_logs','conversations','messages','message_attachments','credit_wallets','credit_transactions','credit_reservations','credit_grants','subscriptions','subscription_events','payment_records','webhook_events','generation_jobs','generation_assets','generation_usage','uploaded_files','library_items','system_settings','admin_audit_logs'] loop
    execute format('alter table public.%I enable row level security',t);
  end loop;
end $$;

create policy profiles_select_own on public.profiles for select to authenticated using (id=auth.uid() or public.is_admin());
create policy profiles_update_own on public.profiles for update to authenticated using (id=auth.uid()) with check (id=auth.uid());
create policy profiles_admin_select on public.profiles for select to authenticated using (public.is_admin());
create policy roles_select_own on public.user_roles for select to authenticated using (user_id=auth.uid() or public.is_admin());
create policy preferences_own on public.user_preferences for all to authenticated using (user_id=auth.uid()) with check (user_id=auth.uid());
create policy models_read_active on public.model_catalog for select to authenticated using (active);
create policy capabilities_read_active on public.model_capabilities for select to authenticated using (active and exists(select 1 from public.model_catalog m where m.id=model_id and m.active));
create policy model_pricing_read_active on public.model_pricing for select to authenticated using (exists(select 1 from public.model_catalog m where m.id=model_id and m.active));
create policy model_sync_admin_read on public.model_sync_logs for select to authenticated using (public.is_admin());
create policy conversations_own_select on public.conversations for select to authenticated using (user_id=auth.uid() and deleted_at is null);
create policy conversations_own_insert on public.conversations for insert to authenticated with check (user_id=auth.uid());
create policy conversations_own_update on public.conversations for update to authenticated using (user_id=auth.uid()) with check (user_id=auth.uid());
create policy conversations_own_delete on public.conversations for delete to authenticated using (user_id=auth.uid());
create policy messages_own_select on public.messages for select to authenticated using (user_id=auth.uid() and exists(select 1 from public.conversations c where c.id=conversation_id and c.user_id=auth.uid()));
create policy messages_own_insert on public.messages for insert to authenticated with check (user_id=auth.uid() and role='user' and exists(select 1 from public.conversations c where c.id=conversation_id and c.user_id=auth.uid()));
create policy attachments_own_select on public.message_attachments for select to authenticated using (exists(select 1 from public.messages m where m.id=message_id and m.user_id=auth.uid()));
create policy attachments_own_insert on public.message_attachments for insert to authenticated with check (exists(select 1 from public.messages m where m.id=message_id and m.user_id=auth.uid()) and exists(select 1 from public.uploaded_files f where f.id=uploaded_file_id and f.user_id=auth.uid()));
create policy wallet_read_own on public.credit_wallets for select to authenticated using (user_id=auth.uid());
create policy credit_tx_read_own on public.credit_transactions for select to authenticated using (user_id=auth.uid());
create policy credit_reservation_read_own on public.credit_reservations for select to authenticated using (user_id=auth.uid());
create policy credit_grant_read_own on public.credit_grants for select to authenticated using (user_id=auth.uid());
create policy subscriptions_read_own on public.subscriptions for select to authenticated using (user_id=auth.uid());
create policy subscription_events_read_own on public.subscription_events for select to authenticated using (exists(select 1 from public.subscriptions s where s.id=subscription_id and s.user_id=auth.uid()));
create policy payments_read_own on public.payment_records for select to authenticated using (user_id=auth.uid());
create policy jobs_read_own on public.generation_jobs for select to authenticated using (user_id=auth.uid());
create policy assets_read_own on public.generation_assets for select to authenticated using (user_id=auth.uid());
create policy usage_read_own on public.generation_usage for select to authenticated using (user_id=auth.uid());
create policy uploaded_files_own_select on public.uploaded_files for select to authenticated using (user_id=auth.uid() and deleted_at is null);
create policy library_own_select on public.library_items for select to authenticated using (user_id=auth.uid());
create policy library_own_insert on public.library_items for insert to authenticated with check (user_id=auth.uid() and (generation_asset_id is null or exists(select 1 from public.generation_assets a where a.id=generation_asset_id and a.user_id=auth.uid())) and (uploaded_file_id is null or exists(select 1 from public.uploaded_files f where f.id=uploaded_file_id and f.user_id=auth.uid())) and (conversation_id is null or exists(select 1 from public.conversations c where c.id=conversation_id and c.user_id=auth.uid())));
create policy library_own_update on public.library_items for update to authenticated using (user_id=auth.uid()) with check (user_id=auth.uid() and (generation_asset_id is null or exists(select 1 from public.generation_assets a where a.id=generation_asset_id and a.user_id=auth.uid())) and (uploaded_file_id is null or exists(select 1 from public.uploaded_files f where f.id=uploaded_file_id and f.user_id=auth.uid())) and (conversation_id is null or exists(select 1 from public.conversations c where c.id=conversation_id and c.user_id=auth.uid())));
create policy library_own_delete on public.library_items for delete to authenticated using (user_id=auth.uid());
create policy settings_public_read on public.system_settings for select to authenticated using (public_readable);
create policy settings_admin_read on public.system_settings for select to authenticated using (public.is_admin());
create policy settings_admin_write on public.system_settings for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy audit_admin_read on public.admin_audit_logs for select to authenticated using (public.is_admin());
create policy audit_admin_insert on public.admin_audit_logs for insert to authenticated with check (public.is_admin());

-- No end-user mutation policies for roles, wallets/ledger/grants, subscriptions/payments, webhook events, catalogue sync/pricing, upload metadata or generation job state.
grant usage on schema public to anon, authenticated, service_role;
revoke all privileges on all tables in schema public from anon,authenticated;
grant all privileges on all tables in schema public to service_role;
grant select on public.model_catalog,public.model_capabilities,public.model_pricing to anon,authenticated;
grant select on public.profiles,public.user_roles,public.user_preferences,public.conversations,public.messages,public.message_attachments,public.credit_wallets,public.credit_transactions,public.credit_reservations,public.credit_grants,public.subscriptions,public.subscription_events,public.payment_records,public.generation_jobs,public.generation_assets,public.generation_usage,public.uploaded_files,public.library_items,public.model_sync_logs,public.system_settings,public.admin_audit_logs to authenticated;
grant insert,update,delete on public.conversations to authenticated;
grant insert on public.messages,public.message_attachments,public.library_items,public.admin_audit_logs to authenticated;
grant update,delete on public.library_items to authenticated;
grant update on public.user_preferences,public.profiles to authenticated;

create trigger profiles_updated_at before update on public.profiles for each row execute procedure public.set_updated_at();
create trigger preferences_updated_at before update on public.user_preferences for each row execute procedure public.set_updated_at();
create trigger catalogue_updated_at before update on public.model_catalog for each row execute procedure public.set_updated_at();
create trigger conversation_updated_at before update on public.conversations for each row execute procedure public.set_updated_at();
create trigger message_updated_at before update on public.messages for each row execute procedure public.set_updated_at();
create trigger subscription_updated_at before update on public.subscriptions for each row execute procedure public.set_updated_at();
create trigger job_updated_at before update on public.generation_jobs for each row execute procedure public.set_updated_at();
create trigger settings_updated_at before update on public.system_settings for each row execute procedure public.set_updated_at();
