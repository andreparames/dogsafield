-- Convert text columns with CHECK constraints to proper PostgreSQL enum types
-- Enables type-safe reads/writes from the database layer.

create type event_type as enum ('packWalk', 'dogPicnic', 'fieldGames');
create type social_vibe as enum ('loungeLizard', 'zoomieKing', 'socialLearner');
create type treat_policy as enum ('okToShare', 'askBeforeFeeding');
create type attendance_status as enum ('confirmed', 'attended', 'noShow');

alter table events alter column type set default 'packWalk';
update events set type = 'packWalk' where type is null;
alter table events alter column type type event_type using type::event_type;
alter table events alter column type set not null;

alter table dogs
  alter column vibe type social_vibe using vibe::social_vibe;

alter table profiles
  alter column treat_policy type treat_policy using treat_policy::treat_policy;

alter table attendance
  alter column status type attendance_status
    using (case status when 'no_show' then 'noShow'::attendance_status else status::attendance_status end);
alter table attendance alter column status set default 'confirmed';
update attendance set status = 'confirmed' where status is null;
alter table attendance alter column status set not null;
