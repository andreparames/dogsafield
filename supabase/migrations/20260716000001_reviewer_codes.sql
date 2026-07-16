create table if not exists public.reviewer_codes (
  code text primary key,
  email text not null unique,
  created_at timestamptz not null default now(),
  active bool not null default true
);

alter table public.reviewer_codes enable row level security;

-- Only the function (SECURITY DEFINER) should access this
-- Block all direct table access
create policy "block_direct_access"
  on public.reviewer_codes
  for all
  using (false)
  with check (false);

create or replace function public.validate_reviewer_code(p_code text)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_email text;
begin
  select email into v_email
  from public.reviewer_codes
  where code = p_code and active = true;
  return v_email;
end;
$$;
