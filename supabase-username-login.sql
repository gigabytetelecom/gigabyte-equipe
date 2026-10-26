-- Execute este script no Editor SQL depois de criar o projeto.
-- Ele permite login com usuário/senha, sem conta de e-mail no Supabase Auth.

create extension if not exists pgcrypto with schema extensions;

create table if not exists public.app_state (
  id text primary key default 'shared',
  payload jsonb not null default '{"routers":[],"sources":[],"queue":[],"moves":[],"minStock":3}'::jsonb,
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users(id)
);

alter table public.app_state enable row level security;
revoke all on public.app_state from anon, authenticated;

create table if not exists public.app_credentials (
  username text primary key,
  password_hash text not null
);
alter table public.app_credentials enable row level security;
revoke all on public.app_credentials from anon, authenticated;

insert into public.app_credentials(username, password_hash)
values ('bruno', extensions.crypt('bruno', extensions.gen_salt('bf')))
on conflict (username) do nothing;

create or replace function public.get_shared_inventory(p_username text, p_password text)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_hash text;
  v_payload jsonb;
begin
  select password_hash into v_hash
  from public.app_credentials
  where username = p_username;

  if v_hash is null or p_password is null or extensions.crypt(p_password, v_hash) <> v_hash then
    raise exception 'Acesso negado' using errcode = '28000';
  end if;

  select payload into v_payload from public.app_state where id = 'shared';
  return coalesce(v_payload, '{"routers":[],"sources":[],"queue":[],"moves":[],"minStock":3}'::jsonb);
end;
$$;

create or replace function public.save_shared_inventory(p_username text, p_password text, p_payload jsonb)
returns void
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_hash text;
begin
  select password_hash into v_hash
  from public.app_credentials
  where username = p_username;

  if v_hash is null or p_password is null or extensions.crypt(p_password, v_hash) <> v_hash then
    raise exception 'Acesso negado' using errcode = '28000';
  end if;
  if p_payload is null or jsonb_typeof(p_payload) <> 'object' then
    raise exception 'Dados inválidos' using errcode = '22023';
  end if;

  insert into public.app_state(id, payload, updated_by, updated_at)
  values ('shared', p_payload, null, now())
  on conflict (id) do update
    set payload = excluded.payload, updated_by = null, updated_at = now();
end;
$$;

revoke all on function public.get_shared_inventory(text, text) from public;
revoke all on function public.save_shared_inventory(text, text, jsonb) from public;
grant execute on function public.get_shared_inventory(text, text) to anon, authenticated;
grant execute on function public.save_shared_inventory(text, text, jsonb) to anon, authenticated;
