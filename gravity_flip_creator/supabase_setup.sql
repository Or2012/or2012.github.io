-- Gravity Flip global leaderboard (Supabase)
-- Run this whole file in Supabase Dashboard -> SQL Editor -> New query -> Run.

create table if not exists public.scores (
  id bigint generated always as identity primary key,
  username text not null check (char_length(username) between 2 and 16),
  score integer not null check (score between 0 and 10000000),
  created_at timestamptz not null default now()
);

alter table public.scores enable row level security;

-- Anyone can read scores so every visitor sees the same global leaderboard.
create policy "Scores are publicly readable"
on public.scores for select
to anon, authenticated
using (true);

-- Anyone can submit a score. Input is constrained, but scores are NOT cheat-proof.
create policy "Visitors can submit scores"
on public.scores for insert
to anon, authenticated
with check (
  char_length(username) between 2 and 16
  and username ~ '^[A-Za-z0-9 _-]+$'
  and score between 0 and 10000000
);

grant select, insert on public.scores to anon, authenticated;
grant usage, select on sequence public.scores_id_seq to anon, authenticated;

-- Permanent username reservations (names remain taken while the player is offline).
-- The browser's random player_id lets the same browser keep using its reserved name
-- without an email or login. A different browser cannot claim that name.
create table if not exists public.username_reservations (
  normalized_username text primary key,
  username text not null,
  player_id uuid not null,
  reserved_at timestamptz not null default now(),
  constraint username_reservations_name_check check (
    char_length(username) between 2 and 16
    and username ~ '^[A-Za-z0-9 _-]+$'
  )
);
alter table public.username_reservations enable row level security;
revoke all on public.username_reservations from anon, authenticated;

create or replace function public.claim_username(p_username text, p_player_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_norm text := lower(btrim(p_username));
  v_owner uuid;
begin
  if p_username is null or btrim(p_username) !~ '^[A-Za-z0-9 _-]{2,16}$' then
    raise exception 'Username must be 2–16 letters, numbers, spaces, _ or -.';
  end if;
  insert into public.username_reservations(normalized_username, username, player_id)
  values (v_norm, btrim(p_username), p_player_id)
  on conflict (normalized_username) do nothing;
  select player_id into v_owner
  from public.username_reservations
  where normalized_username = v_norm;
  return v_owner = p_player_id;
end;
$$;
revoke all on function public.claim_username(text, uuid) from public;
grant execute on function public.claim_username(text, uuid) to anon, authenticated;

-- Preserve names already present on the leaderboard when this setup is run later.
insert into public.username_reservations(normalized_username, username, player_id)
select lower(btrim(username)), btrim(username), coalesce(player_id, gen_random_uuid())
from public.scores
where char_length(btrim(username)) between 2 and 16
  and btrim(username) ~ '^[A-Za-z0-9 _-]+$'
on conflict (normalized_username) do nothing;
