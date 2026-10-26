-- Execute uma vez no SQL Editor do projeto Supabase.
create table if not exists public.app_state (
  id text primary key default 'shared',
  payload jsonb not null default '{"routers":[],"sources":[],"queue":[],"moves":[],"minStock":3}'::jsonb,
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users(id)
);

alter table public.app_state enable row level security;

drop policy if exists "team can read shared inventory" on public.app_state;
create policy "team can read shared inventory"
  on public.app_state for select to authenticated using (id = 'shared');

drop policy if exists "team can create shared inventory" on public.app_state;
create policy "team can create shared inventory"
  on public.app_state for insert to authenticated with check (id = 'shared');

drop policy if exists "team can update shared inventory" on public.app_state;
create policy "team can update shared inventory"
  on public.app_state for update to authenticated using (id = 'shared') with check (id = 'shared');

grant select, insert, update on public.app_state to authenticated;

-- Ativa notificações em tempo real para as telas já conectadas.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'app_state'
  ) then
    alter publication supabase_realtime add table public.app_state;
  end if;
end;
$$;
