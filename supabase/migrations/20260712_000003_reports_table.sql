-- Create dedicated reports table for Trust & Safety queue
-- Each row represents a Tier 3 report (block + hide + report)

create table if not exists reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references profiles(id) on delete cascade,
  reported_id uuid not null references profiles(id) on delete cascade,
  reason text not null,
  created_at timestamptz not null default now()
);

-- Row-level security
alter table reports enable row level security;

-- Users can insert their own reports
create policy "Users can insert own reports"
  on reports for insert
  with check (auth.uid() = reporter_id);

-- No select policy by default — only owners/admins via future admin role

create index if not exists idx_reports_reporter on reports(reporter_id);
create index if not exists idx_reports_reported on reports(reported_id);
create index if not exists idx_reports_created on reports(created_at desc);
