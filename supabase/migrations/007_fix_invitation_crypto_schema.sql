create or replace function public.create_registration_invitation(p_role text,p_expires_hours integer default 24)
returns jsonb
language plpgsql
security definer
set search_path=public,extensions
as $$
declare
  token text:=encode(extensions.gen_random_bytes(32),'hex');
  invitation public.registration_invitations;
begin
  if not is_marketing() then raise exception 'Marketing Office authorization required'; end if;
  if p_role not in ('student','marketing') then raise exception 'Invalid invitation role'; end if;
  if p_expires_hours not between 1 and 720 then raise exception 'Expiry must be between 1 hour and 30 days'; end if;

  insert into registration_invitations(role,token_hash,expires_at,created_by)
  values(
    p_role,
    encode(extensions.digest(token,'sha256'),'hex'),
    now()+make_interval(hours=>p_expires_hours),
    auth.uid()
  )
  returning * into invitation;

  return jsonb_build_object(
    'id',invitation.id,
    'token',token,
    'role',invitation.role,
    'expiresAt',invitation.expires_at
  );
end;
$$;

grant execute on function public.create_registration_invitation(text,integer) to authenticated;
