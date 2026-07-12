-- Event messages: structured message types with JSONB payloads

create type message_type as enum ('text', 'event_edited', 'event_left', 'account_suspended');

alter table messages
  add column message_type message_type not null default 'text',
  add column payload jsonb;

-- Update policy to also allow payload changes (for the same read_at only update)
drop policy if exists "Participants can update messages read_at" on messages;
create policy "Participants can update messages read_at"
  on messages for update
  using (
    exists (
      select 1 from conversations
      where conversations.id = messages.conversation_id
        and (auth.uid() = conversations.user_a or auth.uid() = conversations.user_b)
    )
  )
  with check (
    content = (select content from public.messages where id = messages.id)
    and message_type = (select message_type from public.messages where id = messages.id)
    and sender_id = (select sender_id from public.messages where id = messages.id)
    and conversation_id = (select conversation_id from public.messages where id = messages.id)
    and created_at = (select created_at from public.messages where id = messages.id)
  );

-- Update trigger to use content for last_message_content (works for all types)
drop trigger if exists on_message_insert on messages;
drop function if exists update_conversation_on_message;

create or replace function update_conversation_on_message()
returns trigger
set search_path = ''
as $$
begin
  update public.conversations
  set last_message_at = new.created_at,
      last_message_content = new.content
  where id = new.conversation_id;
  return new;
end;
$$ language plpgsql;

create trigger on_message_insert
  after insert on messages
  for each row execute function update_conversation_on_message();
