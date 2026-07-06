-- Add missing INSERT policy for profiles table
create policy "Users can insert own profile"
  on profiles for insert with check (auth.uid() = id);
