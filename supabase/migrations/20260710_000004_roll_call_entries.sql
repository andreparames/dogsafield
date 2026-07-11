create table if not exists roll_call_entries (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references events(id) on delete cascade,
  observer_id uuid not null references profiles(id) on delete cascade,
  observed_id uuid not null references profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(event_id, observer_id, observed_id)
);

alter table roll_call_entries enable row level security;

create policy "Users can insert own roll call entries"
  on roll_call_entries for insert with check (auth.uid() = observer_id);

create policy "Users can view roll call entries for events they attended"
  on roll_call_entries for select using (
    exists (
      select 1 from attendance
      where attendance.event_id = roll_call_entries.event_id
        and attendance.user_id = auth.uid()
    )
  );

create policy "Users can delete own roll call entries"
  on roll_call_entries for delete using (auth.uid() = observer_id);
