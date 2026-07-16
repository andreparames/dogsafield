-- Fix SECURITY DEFINER lint warning on profiles_public
-- Switch to security_invoker so the view respects the querying user's
-- permissions and RLS policies on the underlying profiles table.

create or replace view profiles_public
with (security_barrier = true, security_invoker = true)
as
select
  id,
  display_name,
  photo_url,
  treat_policy,
  is_founding_pack,
  created_at
from profiles
where (is_suspended = false or auth.uid() = id)
  and not exists (
    select 1 from connections
    where connections.block_tier > 0
      and connections.user_id_a = profiles.id
      and connections.user_id_b = auth.uid()
  );
