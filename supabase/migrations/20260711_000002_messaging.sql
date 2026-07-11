-- Messaging: conversations and messages tables with RLS and Realtime

create table if not exists conversations (
  id uuid primary key default gen_random_uuid(),
  user_a uuid not null references profiles(id) on delete cascade,
  user_b uuid not null references profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  last_message_at timestamptz not null default now(),
  last_message_content text,
  unique(user_a, user_b)
);

create table if not exists messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references conversations(id) on delete cascade,
  sender_id uuid not null references profiles(id) on delete cascade,
  content text not null,
  created_at timestamptz not null default now(),
  read_at timestamptz
);

create index if not exists idx_messages_conversation on messages(conversation_id, created_at);
create index if not exists idx_conversations_user_a on conversations(user_a, last_message_at desc);
create index if not exists idx_conversations_user_b on conversations(user_b, last_message_at desc);

alter table conversations enable row level security;
alter table messages enable row level security;

create policy "Users can view own conversations"
  on conversations for select
  using (auth.uid() = user_a or auth.uid() = user_b);

create policy "Users can insert conversations"
  on conversations for insert
  with check (auth.uid() = user_a or auth.uid() = user_b);

create policy "Participants can update conversations"
  on conversations for update
  using (auth.uid() = user_a or auth.uid() = user_b);

create policy "Participants can view messages"
  on messages for select
  using (
    exists (
      select 1 from conversations
      where conversations.id = messages.conversation_id
        and (auth.uid() = conversations.user_a or auth.uid() = conversations.user_b)
    )
  );

create policy "Participants can send messages"
  on messages for insert
  with check (
    auth.uid() = sender_id
    and exists (
      select 1 from conversations
      where conversations.id = messages.conversation_id
        and (auth.uid() = conversations.user_a or auth.uid() = conversations.user_b)
    )
  );

create policy "Participants can update own messages"
  on messages for update
  using (
    exists (
      select 1 from conversations
      where conversations.id = messages.conversation_id
        and (auth.uid() = conversations.user_a or auth.uid() = conversations.user_b)
    )
  );

-- Trigger to update conversation metadata on new message
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
