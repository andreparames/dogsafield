-- Block visibility in both directions: if the viewer blocked the row owner, the
-- row should also be hidden (not just when the row owner blocked the viewer).

drop policy if exists "Events are publicly readable" on events;
create policy "Events are publicly readable"
  on events for select
  using (
    host_id = auth.uid()
    or (
      not exists (
        select 1 from connections
        where connections.block_tier > 0
          and connections.user_id_a = events.host_id
          and connections.user_id_b = auth.uid()
      )
      and not exists (
        select 1 from connections
        where connections.block_tier > 0
          and connections.user_id_a = auth.uid()
          and connections.user_id_b = events.host_id
      )
      and not exists (
        select 1 from profiles
        where profiles.id = events.host_id
          and profiles.is_suspended = true
      )
    )
  );

drop policy if exists "Attendance is publicly readable" on attendance;
create policy "Attendance is publicly readable"
  on attendance for select
  using (
    user_id = auth.uid()
    or (
      not exists (
        select 1 from connections
        where connections.block_tier > 0
          and connections.user_id_a = attendance.user_id
          and connections.user_id_b = auth.uid()
      )
      and not exists (
        select 1 from connections
        where connections.block_tier > 0
          and connections.user_id_a = auth.uid()
          and connections.user_id_b = attendance.user_id
      )
    )
  );
