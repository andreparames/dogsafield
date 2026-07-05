-- Create tables for Dogs Afield
-- Run this in your Supabase SQL editor or via `supabase db push`

-- 1. Cities (for Founding Pack geographic waiver)
create table if not exists cities (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  latitude double precision not null,
  longitude double precision not null,
  radius_km double precision not null default 50,
  launched_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

-- 2. Profiles (extends auth.users)
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  display_name text,
  photo_url text,
  is_verified boolean not null default false,
  treat_policy text check (treat_policy in ('okToShare', 'askBeforeFeeding')),
  trial_rsvps_used int not null default 0,
  is_founding_pack boolean not null default false,
  founding_city_id uuid references cities(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 3. Dogs
create table if not exists dogs (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references profiles(id) on delete cascade,
  name text not null,
  age int,
  breed text,
  vibe text check (vibe in ('loungeLizard', 'zoomieKing', 'socialLearner')),
  icebreaker_answer text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 4. Events
create table if not exists events (
  id uuid primary key default gen_random_uuid(),
  host_id uuid not null references profiles(id) on delete cascade,
  type text not null check (type in ('packWalk', 'dogPicnic', 'fieldGames')),
  title text not null,
  description text,
  location_name text not null,
  latitude double precision not null,
  longitude double precision not null,
  date_time timestamptz not null,
  max_attendees int not null default 20,
  what_to_bring text[] default '{}',
  amenity_tags text[] default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 5. Attendance (RSVPs + roll-call tracking)
create table if not exists attendance (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references events(id) on delete cascade,
  user_id uuid not null references profiles(id) on delete cascade,
  status text not null default 'confirmed' check (status in ('confirmed', 'attended', 'no_show')),
  roll_call_submitted boolean not null default false,
  created_at timestamptz not null default now(),
  unique(event_id, user_id)
);

-- 6. Connections (packmate & block state)
create table if not exists connections (
  id uuid primary key default gen_random_uuid(),
  user_id_a uuid not null references profiles(id) on delete cascade,
  user_id_b uuid not null references profiles(id) on delete cascade,
  are_packmates boolean not null default false,
  block_tier int not null default 0 check (block_tier in (0, 1, 2, 3)),
  report_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(user_id_a, user_id_b)
);

-- Indexes
create index if not exists idx_dogs_owner on dogs(owner_id);
create index if not exists idx_events_host on events(host_id);
create index if not exists idx_events_location on events(latitude, longitude);
create index if not exists idx_events_date on events(date_time);
create index if not exists idx_attendance_event on attendance(event_id);
create index if not exists idx_attendance_user on attendance(user_id);
create index if not exists idx_connections_users on connections(user_id_a, user_id_b);

-- Row Level Security
alter table profiles enable row level security;
alter table dogs enable row level security;
alter table events enable row level security;
alter table attendance enable row level security;
alter table connections enable row level security;
alter table cities enable row level security;

-- RLS: profiles — users can read all profiles, update only their own
create policy "Profiles are publicly readable"
  on profiles for select using (true);

create policy "Users can update own profile"
  on profiles for update using (auth.uid() = id);

-- RLS: dogs — users can read all dogs, manage their own
create policy "Dogs are publicly readable"
  on dogs for select using (true);

create policy "Users can insert own dogs"
  on dogs for insert with check (auth.uid() = owner_id);

create policy "Users can update own dogs"
  on dogs for update using (auth.uid() = owner_id);

create policy "Users can delete own dogs"
  on dogs for delete using (auth.uid() = owner_id);

-- RLS: events — publicly readable, host manages
create policy "Events are publicly readable"
  on events for select using (true);

create policy "Host can insert events"
  on events for insert with check (auth.uid() = host_id);

create policy "Host can update own events"
  on events for update using (auth.uid() = host_id);

create policy "Host can delete own events"
  on events for delete using (auth.uid() = host_id);

-- RLS: attendance — users see their own, host sees all for their events
create policy "Users can view own attendance"
  on attendance for select using (auth.uid() = user_id);

create policy "Hosts can view attendance for their events"
  on attendance for select using (
    exists (select 1 from events where events.id = attendance.event_id and events.host_id = auth.uid())
  );

create policy "Users can insert own attendance"
  on attendance for insert with check (auth.uid() = user_id);

create policy "Users can update own attendance"
  on attendance for update using (auth.uid() = user_id);

-- RLS: connections — users see connections involving them
create policy "Users can view own connections"
  on connections for select using (auth.uid() = user_id_a or auth.uid() = user_id_b);

create policy "Users can insert connections they initiate"
  on connections for insert with check (auth.uid() = user_id_a);

create policy "Users can update connections they are part of"
  on connections for update using (auth.uid() = user_id_a or auth.uid() = user_id_b);

-- RLS: cities — publicly readable
create policy "Cities are publicly readable"
  on cities for select using (true);

-- Auto-update updated_at trigger
create or replace function update_updated_at()
returns trigger
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

do $$
begin
  if not exists (select 1 from pg_trigger where tgname = 'set_profiles_updated_at') then
    create trigger set_profiles_updated_at before update on profiles for each row execute function update_updated_at();
  end if;
  if not exists (select 1 from pg_trigger where tgname = 'set_dogs_updated_at') then
    create trigger set_dogs_updated_at before update on dogs for each row execute function update_updated_at();
  end if;
  if not exists (select 1 from pg_trigger where tgname = 'set_events_updated_at') then
    create trigger set_events_updated_at before update on events for each row execute function update_updated_at();
  end if;
  if not exists (select 1 from pg_trigger where tgname = 'set_connections_updated_at') then
    create trigger set_connections_updated_at before update on connections for each row execute function update_updated_at();
  end if;
end;
$$;
