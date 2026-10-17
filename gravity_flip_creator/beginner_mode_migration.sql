-- Add an independent Beginner leaderboard. Classic scores stay in public.scores.
create table public.beginner_scores (
  id bigint generated always as identity primary key,
  username text not null unique check (char_length(username) between 2 and 16 and username ~ '^[A-Za-z0-9 _-]+$'),
  score integer not null check (score between 0 and 2000000000),
  created_at timestamptz not null default now(),
  player_id uuid not null default gen_random_uuid()
);
create unique index beginner_scores_username_lower_unique on public.beginner_scores (lower(username));
alter table public.beginner_scores enable row level security;
create policy "Beginner scores are publicly readable" on public.beginner_scores for select to anon, authenticated using (true);
create policy "Visitors can submit beginner scores" on public.beginner_scores for insert to anon, authenticated with check (char_length(username) between 2 and 16 and username ~ '^[A-Za-z0-9 _-]+$' and score between 0 and 2000000000);
create policy "Visitors can update beginner scores" on public.beginner_scores for update to anon, authenticated using (true) with check (char_length(username) between 2 and 16 and username ~ '^[A-Za-z0-9 _-]+$' and score between 0 and 2000000000);
grant select, insert, update on public.beginner_scores to anon, authenticated;
grant usage, select on sequence public.beginner_scores_id_seq to anon, authenticated;

-- Keep username changes and "Delete my record" consistent across both boards.
create or replace function public.rename_player_scores(p_player_id uuid, p_old_username text, p_new_username text)
returns void language plpgsql security definer set search_path to 'public'
as $function$
declare board_table text; target_owner uuid; old_score integer; target_score integer; old_row_id bigint; target_row_id bigint;
begin
  if p_player_id is null then raise exception 'Player ID is required'; end if;
  if p_new_username is null or char_length(trim(p_new_username)) not between 2 and 16 or trim(p_new_username) !~ '^[A-Za-z0-9 _-]+$' then raise exception 'Invalid username'; end if;
  foreach board_table in array array['scores','beginner_scores'] loop
    target_owner := null; target_row_id := null; target_score := null; old_row_id := null; old_score := null;
    execute format('select player_id,id,score from public.%I where lower(username)=lower(trim($1)) limit 1', board_table) into target_owner,target_row_id,target_score using p_new_username;
    if target_owner is not null and target_owner is distinct from p_player_id then raise exception 'Username already taken'; end if;
    execute format('select id,score from public.%I where player_id=$1 and lower(username)=lower(trim($2)) limit 1', board_table) into old_row_id,old_score using p_player_id,p_old_username;
    if old_row_id is null then continue; end if;
    if target_row_id is not null and target_row_id <> old_row_id then
      execute format('update public.%I set score=greatest($1,$2),player_id=$3,username=trim($4),created_at=least(created_at,now()) where id=$5', board_table) using target_score,old_score,p_player_id,p_new_username,target_row_id;
      execute format('delete from public.%I where id=$1', board_table) using old_row_id;
    else
      execute format('update public.%I set username=trim($1),player_id=$2 where id=$3', board_table) using p_new_username,p_player_id,old_row_id;
    end if;
  end loop;
end;
$function$;

create or replace function public.delete_player_scores(p_player_id uuid)
returns integer language plpgsql security definer set search_path to 'public'
as $function$
declare deleted_count integer; beginner_deleted integer;
begin
  if p_player_id is null then raise exception 'Player ID is required'; end if;
  delete from public.scores where player_id=p_player_id;
  get diagnostics deleted_count = row_count;
  delete from public.beginner_scores where player_id=p_player_id;
  get diagnostics beginner_deleted = row_count;
  return deleted_count + beginner_deleted;
end;
$function$;

