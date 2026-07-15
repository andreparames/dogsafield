-- Add regions table and PostGIS spatial support for events
-- Drops unused cities table

-- 1. Enable PostGIS (idempotent)
create extension if not exists postgis with schema extensions;

-- 2. Drop unused cities table and FK
alter table profiles drop constraint if exists profiles_founding_city_id_fkey;
alter table profiles drop column if exists founding_city_id;
drop table if exists cities;

-- 3. Regions table
create table if not exists regions (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  center_lat double precision not null,
  center_lng double precision not null,
  center geography(Point, 4326) generated always as (st_makepoint(center_lng, center_lat)) stored,
  radius_km double precision not null check (radius_km > 0),
  is_enabled boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 4. Generated location column on events (keeps existing lat/lng intact)
alter table events
  add column if not exists location geography(Point, 4326)
  generated always as (st_makepoint(longitude, latitude)) stored;

-- 5. Spatial index for distance queries on events
create index if not exists idx_events_location_geo on events using gist (location);

-- 6. Spatial index on regions center
create index if not exists idx_regions_center on regions using gist (center);

-- 7. RLS for regions
alter table regions enable row level security;

create policy "Regions are publicly readable"
  on regions for select using (true);

-- 8. Auto-update updated_at for regions
create trigger set_regions_updated_at before update on regions
  for each row execute function update_updated_at();
