ALTER TABLE profiles ADD COLUMN is_suspended boolean not null default false;

DROP POLICY IF EXISTS "Profiles are publicly readable" ON profiles;
CREATE POLICY "Profiles are publicly readable"
  ON profiles FOR SELECT
  USING (is_suspended = false OR auth.uid() = id);

CREATE OR REPLACE FUNCTION delete_my_account()
RETURNS void
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  DELETE FROM auth.users WHERE id = auth.uid();
END;
$$ LANGUAGE plpgsql;

REVOKE EXECUTE ON FUNCTION delete_my_account FROM PUBLIC;
GRANT EXECUTE ON FUNCTION delete_my_account TO authenticated;
