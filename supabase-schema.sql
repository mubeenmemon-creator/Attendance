create table if not exists public.attendance_data (
  user_id uuid primary key references auth.users (id) on delete cascade,
  roster jsonb not null default '[]'::jsonb
    check (jsonb_typeof(roster) = 'array' and jsonb_array_length(roster) = 50),
  attendance jsonb not null default '{}'::jsonb
    check (jsonb_typeof(attendance) = 'object')
);

alter table public.attendance_data enable row level security;

drop policy if exists "Users can read their own attendance" on public.attendance_data;
create policy "Users can read their own attendance"
  on public.attendance_data for select to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "Users can create their own attendance" on public.attendance_data;
create policy "Users can create their own attendance"
  on public.attendance_data for insert to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "Users can update their own attendance" on public.attendance_data;
create policy "Users can update their own attendance"
  on public.attendance_data for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

revoke all on public.attendance_data from anon;
grant select, insert, update on public.attendance_data to authenticated;
