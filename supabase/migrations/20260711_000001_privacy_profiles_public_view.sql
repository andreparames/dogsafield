-- Privacy: create a security barrier view for public profile reads
-- that exposes only non-sensitive columns and filters out:
--   - Suspended profiles (unless viewer is the owner)
--   - Profiles of users who have blocked the current user

create or replace view profiles_public
with (security_barrier = true)
as
select
  id,
  display_name,
  photo_url,
  treat_policy,
  is_founding_pack,
  founding_city_id,
  created_at
from profiles
where (is_suspended = false or auth.uid() = id)
  and not exists (
    select 1 from connections
    where connections.block_tier > 0
      and connections.user_id_a = profiles.id
      and connections.user_id_b = auth.uid()
  );

grant select on profiles_public to authenticated, anon;

-- Update events RLS: exclude events hosted by users who blocked the current user
-- or whose host profile is suspended (unless viewer is the host)
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
        select 1 from profiles
        where profiles.id = events.host_id
          and profiles.is_suspended = true
      )
    )
  );

-- Update attendance RLS: exclude attendance of users who blocked the current user
drop policy if exists "Attendance is publicly readable" on attendance;
create policy "Attendance is publicly readable"
  on attendance for select
  using (
    user_id = auth.uid()
    or not exists (
      select 1 from connections
      where connections.block_tier > 0
        and connections.user_id_a = attendance.user_id
        and connections.user_id_b = auth.uid()
    )
  );
