-- Add pack walk columns to events table
alter table events add column if not exists min_threshold int not null default 8;
alter table events add column if not exists waitlist_status text not null default 'forming' check (waitlist_status in ('forming', 'unlocked', 'full'));
alter table events add column if not exists scheduled_date timestamptz;

-- Waitlist table for pack walks
create table if not exists waitlist (
  id uuid primary key default gen_random_uuid(),
  walk_id uuid not null references events(id) on delete cascade,
  user_id uuid not null references profiles(id) on delete cascade,
  status text not null default 'waiting' check (status in ('waiting', 'confirmed', 'released', 'declined')),
  confirmed_at timestamptz,
  created_at timestamptz not null default now(),
  unique(walk_id, user_id)
);

-- Indexes
create index if not exists idx_waitlist_walk on waitlist(walk_id);
create index if not exists idx_waitlist_user on waitlist(user_id);
create index if not exists idx_events_waitlist_status on events(waitlist_status);

-- RLS
alter table waitlist enable row level security;

-- Users can view only their own waitlist rows
create policy "Users can view own waitlist entries"
  on waitlist for select using (auth.uid() = user_id);

-- Hosts can view waitlist for their events
create policy "Hosts can view waitlist for their events"
  on waitlist for select using (
    exists (select 1 from events where events.id = waitlist.walk_id and events.host_id = auth.uid())
  );

-- Users can delete their own waitlist entries (leaving)
create policy "Users can delete own waitlist entries"
  on waitlist for delete using (auth.uid() = user_id);

-- NOTE: INSERT and UPDATE are NOT allowed directly.
-- All mutations go through SECURITY DEFINER RPCs below
-- that enforce state transitions, capacity, and event validation.

-- RPC: get aggregate waitlist counts for a walk (any authenticated user)
create or replace function get_waitlist_counts(p_walk_id uuid)
returns table(waiting int, confirmed int, released int)
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
begin
  return query
  select
    count(*) filter (where status = 'waiting')::int,
    count(*) filter (where status = 'confirmed')::int,
    count(*) filter (where status = 'released')::int
  from waitlist
  where walk_id = p_walk_id;
end;
$$;

-- RPC: join (or rejoin) the waitlist for a pack walk
create or replace function join_waitlist(p_walk_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  rec events%rowtype;
  existing_status text;
  new_row waitlist;
begin
  -- Lock the event row to serialize concurrent joins
  select * into rec
  from events
  where id = p_walk_id
  for update;

  if not found then
    raise exception 'Event not found' using errcode = 'P0002';
  end if;

  if rec.type != 'packWalk' then
    raise exception 'Cannot join waitlist: not a pack walk' using errcode = 'P0003';
  end if;

  if rec.is_cancelled then
    raise exception 'Cannot join waitlist: event is cancelled' using errcode = 'P0004';
  end if;

  if rec.waitlist_status = 'full' then
    raise exception 'Cannot join waitlist: walk is at full capacity' using errcode = 'P0005';
  end if;

  -- Check for existing entry
  select status into existing_status
  from waitlist
  where walk_id = p_walk_id and user_id = auth.uid();

  if found then
    if existing_status in ('waiting', 'confirmed') then
      raise exception 'Already on the waitlist' using errcode = 'P0006';
    end if;
    -- released/declined: update back to waiting
    update waitlist
    set status = 'waiting', confirmed_at = null
    where walk_id = p_walk_id and user_id = auth.uid()
    returning * into new_row;
  else
    insert into waitlist (walk_id, user_id, status)
    values (p_walk_id, auth.uid(), 'waiting')
    returning * into new_row;
  end if;

  return row_to_json(new_row)::jsonb;
end;
$$;

-- RPC: confirm a waiting spot
create or replace function confirm_waitlist_spot(p_walk_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  new_row waitlist;
begin
  update waitlist
  set status = 'confirmed',
      confirmed_at = now()
  where walk_id = p_walk_id
    and user_id = auth.uid()
    and status = 'waiting'
  returning * into new_row;

  if not found then
    raise exception 'No waiting entry found to confirm' using errcode = 'P0007';
  end if;

  return row_to_json(new_row)::jsonb;
end;
$$;

-- RPC: leave the waitlist (delete own entry)
create or replace function leave_waitlist(p_walk_id uuid)
returns void
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
begin
  delete from waitlist
  where walk_id = p_walk_id and user_id = auth.uid();

  if not found then
    raise exception 'No waitlist entry found' using errcode = 'P0008';
  end if;
end;
$$;

-- Trigger function: recalculate event state from waitlist counts
-- Uses FOR UPDATE to serialize concurrent threshold checks
create or replace function recalc_waitlist_state()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  current_count int;
  min_req int;
  max_cap int;
  e_id uuid;
begin
  e_id := coalesce(new.walk_id, old.walk_id);

  -- Lock the event row to prevent race conditions
  select min_threshold, max_attendees into min_req, max_cap
  from events where id = e_id
  for update;

  select count(*) into current_count
  from waitlist
  where walk_id = e_id
    and status in ('waiting', 'confirmed');

  -- Unlock if threshold met
  if current_count >= min_req then
    update events
    set waitlist_status = 'unlocked',
        scheduled_date =
          case
            when extract(dow from now()) between 1 and 5 then
              date_trunc('week', now()) + interval '5 days' + interval '10 hours'
            else
              date_trunc('week', now()) + interval '12 days' + interval '10 hours'
          end
    where id = e_id
      and waitlist_status = 'forming';
  end if;

  -- Mark full if at capacity
  if current_count >= max_cap then
    update events
    set waitlist_status = 'full'
    where id = e_id
      and waitlist_status in ('forming', 'unlocked');
  end if;

  -- Revert to forming if below threshold
  if current_count < min_req then
    update events
    set waitlist_status = 'forming',
        scheduled_date = null
    where id = e_id
      and waitlist_status in ('unlocked', 'full');
  end if;

  return coalesce(new, old);
end;
$$;

drop trigger if exists on_waitlist_insert on waitlist;
create trigger on_waitlist_insert
  after insert on waitlist
  for each row
  execute function recalc_waitlist_state();

drop trigger if exists on_waitlist_update on waitlist;
create trigger on_waitlist_update
  after update of status on waitlist
  for each row
  when (old.status is distinct from new.status)
  execute function recalc_waitlist_state();

drop trigger if exists on_waitlist_delete on waitlist;
create trigger on_waitlist_delete
  after delete on waitlist
  for each row
  execute function recalc_waitlist_state();

-- Auto-release unconfirmed spots (callable via pg_cron or manual)
create or replace function release_unconfirmed_spots()
returns void
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
begin
  -- Release unconfirmed spots for walks where scheduled_date is within 24h
  update waitlist w
  set status = 'released'
  from events e
  where w.walk_id = e.id
    and e.waitlist_status in ('unlocked', 'full')
    and e.scheduled_date is not null
    and e.scheduled_date - interval '24 hours' <= now()
    and w.status = 'waiting';

  -- Revert to forming if not enough confirmed remain after releases
  update events e
  set waitlist_status = 'forming',
      scheduled_date = null
  where e.waitlist_status in ('unlocked', 'full')
    and e.scheduled_date is not null
    and e.scheduled_date - interval '24 hours' <= now()
    and (
      select count(*) from waitlist w
      where w.walk_id = e.id and w.status = 'confirmed'
    ) < e.min_threshold;
end;
$$;
