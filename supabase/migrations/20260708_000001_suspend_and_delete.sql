ALTER TABLE profiles ADD COLUMN is_suspended boolean not null default false;

CREATE POLICY "Users can delete own profile"
  ON profiles FOR DELETE
  USING (auth.uid() = id);

CREATE OR REPLACE FUNCTION delete_my_account()
RETURNS void
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  DELETE FROM auth.users WHERE id = auth.uid();
END;
$$ LANGUAGE plpgsql;
