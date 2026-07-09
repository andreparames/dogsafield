-- Add missing INSERT policy for profiles table (idempotent for PG14)
do $$
begin
  if not exists (
    select 1 from pg_policies
    where tablename = 'profiles' and policyname = 'Users can insert own profile'
  ) then
    create policy "Users can insert own profile"
      on profiles for insert with check (auth.uid() = id);
  end if;
end;
$$;
