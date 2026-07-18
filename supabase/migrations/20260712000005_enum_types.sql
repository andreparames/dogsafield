-- Convert text columns with CHECK constraints to proper PostgreSQL enum types
-- Enables type-safe reads/writes from the database layer.

do $$ begin
  if not exists (select 1 from pg_type where typname = 'event_type') then
    create type event_type as enum ('packWalk', 'dogPicnic', 'fieldGames');
  end if;
end $$;
do $$ begin
  if not exists (select 1 from pg_type where typname = 'social_vibe') then
    create type social_vibe as enum ('loungeLizard', 'zoomieKing', 'socialLearner');
  end if;
end $$;
do $$ begin
  if not exists (select 1 from pg_type where typname = 'treat_policy') then
    create type treat_policy as enum ('okToShare', 'askBeforeFeeding');
  end if;
end $$;
do $$ begin
  if not exists (select 1 from pg_type where typname = 'attendance_status') then
    create type attendance_status as enum ('confirmed', 'attended', 'noShow');
  end if;
end $$;

alter table events alter column type drop default;
alter table events drop constraint if exists events_type_check;
alter table events alter column type type event_type using type::event_type;
alter table events alter column type set default 'packWalk';

alter table dogs drop constraint if exists dogs_vibe_check;
alter table dogs
  alter column vibe type social_vibe using vibe::social_vibe;

drop view if exists profiles_public cascade;
alter table profiles drop constraint if exists profiles_treat_policy_check;
alter table profiles
  alter column treat_policy type treat_policy using treat_policy::treat_policy;

alter table attendance drop constraint if exists attendance_status_check;
alter table attendance alter column status drop default;
alter table attendance
  alter column status type attendance_status
    using (case status when 'no_show' then 'noShow'::attendance_status else status::attendance_status end);
alter table attendance alter column status set default 'confirmed';
update attendance set status = 'confirmed' where status is null;
alter table attendance alter column status set not null;
