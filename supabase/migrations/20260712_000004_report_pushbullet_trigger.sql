-- App config table for server-side secrets (RLS-protected, no user access)
create table if not exists app_config (
  key text primary key,
  value text not null
);

alter table app_config enable row level security;

-- No select/insert policies — only SECURITY DEFINER functions can read this table

-- Trigger function: notify admin via Pushbullet when a new report is inserted
create or replace function notify_admin_on_report()
returns trigger
language plpgsql
security definer
as $$
declare
  token text;
  reporter_email text;
  reported_email text;
begin
  select value into token from app_config where key = 'pushbullet_token';
  if token is null or token = '' then
    return new;
  end if;

  select email into reporter_email from profiles where id = new.reporter_id;
  select email into reported_email from profiles where id = new.reported_id;

  perform net.http_post(
    url := 'https://api.pushbullet.com/v2/pushes',
    headers := jsonb_build_object(
      'Access-Token', token,
      'Content-Type', 'application/json'
    ),
    body := jsonb_build_object(
      'type', 'note',
      'title', 'Dogs Afield - Trust & Safety Report',
      'body', format(E'Reporter: %s\nReported: %s\nReason: %s', reporter_email, reported_email, new.reason)
    )
  );
  return new;
end;
$$;

drop trigger if exists on_report_insert on reports;
create trigger on_report_insert
  after insert on reports
  for each row
  execute function notify_admin_on_report();
