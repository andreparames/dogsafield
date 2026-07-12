drop policy if exists "Users can delete own attendance" on attendance;

create policy "Users can delete own attendance"
  on attendance for delete using (auth.uid() = user_id);
