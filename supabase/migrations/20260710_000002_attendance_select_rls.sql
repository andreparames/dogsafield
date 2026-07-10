alter table attendance enable row level security;

drop policy if exists "Hosts can view attendance for their events" on attendance;

create policy "Attendance is publicly readable"
  on attendance for select using (true);
