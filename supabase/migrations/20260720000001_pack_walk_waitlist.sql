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

create policy "Users can view own waitlist entries"
  on waitlist for select using (auth.uid() = user_id);

create policy "Hosts can view waitlist for their events"
  on waitlist for select using (
    exists (select 1 from events where events.id = waitlist.walk_id and events.host_id = auth.uid())
  );

create policy "Users can insert own waitlist entries"
  on waitlist for insert with check (auth.uid() = user_id);

create policy "Users can update own waitlist entries"
  on waitlist for update using (auth.uid() = user_id);

-- Trigger function: on waitlist insert, check threshold and capacity
create or replace function check_waitlist_threshold()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  current_count int;
  min_req int;
  max_cap int;
begin
  select min_threshold, max_attendees into min_req, max_cap
  from events where id = new.walk_id;
  
  select count(*) into current_count
  from waitlist
  where walk_id = new.walk_id
    and status in ('waiting', 'confirmed');
  
  -- Unlock if threshold met
  if current_count >= min_req then
    update events
    set waitlist_status = 'unlocked',
        scheduled_date =
          case
            when extract(dow from now()) between 2 and 4 then
              date_trunc('week', now()) + interval '5 days' + interval '10 hours'
            else
              date_trunc('week', now()) + interval '12 days' + interval '10 hours'
          end
    where id = new.walk_id
      and waitlist_status = 'forming';
  end if;
  
  -- Mark full if at capacity
  if current_count >= max_cap then
    update events
    set waitlist_status = 'full'
    where id = new.walk_id
      and waitlist_status in ('forming', 'unlocked');
  end if;
  
  return new;
end;
$$;

drop trigger if exists on_waitlist_insert on waitlist;
create trigger on_waitlist_insert
  after insert on waitlist
  for each row
  execute function check_waitlist_threshold();

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
    and e.waitlist_status = 'unlocked'
    and e.scheduled_date is not null
    and e.scheduled_date - interval '24 hours' <= now()
    and w.status = 'waiting';
  
  -- Revert to forming if not enough confirmed remain after releases
  update events e
  set waitlist_status = 'forming',
      scheduled_date = null
  where e.waitlist_status = 'unlocked'
    and e.scheduled_date is not null
    and e.scheduled_date - interval '24 hours' <= now()
    and (
      select count(*) from waitlist w
      where w.walk_id = e.id and w.status = 'confirmed'
    ) < e.min_threshold;
end;
$$;
