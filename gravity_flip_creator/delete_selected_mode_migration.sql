-- Replace the all-boards delete RPC with a mode-scoped version.
drop function public.delete_player_scores(uuid);
create function public.delete_player_scores(p_player_id uuid, p_mode text)
returns integer
language plpgsql
security definer
set search_path to 'public'
as $function$
declare deleted_count integer;
begin
  if p_player_id is null then raise exception 'Player ID is required'; end if;
  if p_mode = 'classic' then
    delete from public.scores where player_id=p_player_id;
  elsif p_mode = 'beginner' then
    delete from public.beginner_scores where player_id=p_player_id;
  else
    raise exception 'Invalid leaderboard mode';
  end if;
  get diagnostics deleted_count = row_count;
  return deleted_count;
end;
$function$;
grant execute on function public.delete_player_scores(uuid,text) to anon, authenticated;

