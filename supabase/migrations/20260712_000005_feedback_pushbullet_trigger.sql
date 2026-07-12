-- Trigger function: notify admin via Pushbullet when feedback is submitted
create or replace function notify_admin_on_feedback()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  token text;
  user_email text;
begin
  select value into token from app_config where key = 'pushbullet_token';
  if token is null or token = '' then
    return new;
  end if;

  select email into user_email from profiles where id = new.user_id;

  begin
    perform net.http_post(
      url := 'https://api.pushbullet.com/v2/pushes',
      headers := jsonb_build_object(
        'Access-Token', token,
        'Content-Type', 'application/json'
      ),
      body := jsonb_build_object(
        'type', 'note',
        'title', 'Dogs Afield - Feedback',
        'body', format(E'From: %s\n\n%s', user_email, new.message)
      )
    );
  exception when others then
    null;
  end;
  return new;
end;
$$;

drop trigger if exists on_feedback_insert on feedback;
create trigger on_feedback_insert
  after insert on feedback
  for each row
  execute function notify_admin_on_feedback();
