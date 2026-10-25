create table if not exists public.registration_invitations(
  id uuid primary key default gen_random_uuid(),
  role text not null check(role in ('student','marketing')),
  token_hash text unique not null,
  expires_at timestamptz not null,
  revoked_at timestamptz,
  usage_count integer not null default 0 check(usage_count>=0),
  created_by uuid not null references auth.users,
  created_at timestamptz not null default now()
);
alter table public.registration_invitations enable row level security;
create policy "marketing manages registration invitations" on public.registration_invitations for select to authenticated using(public.is_marketing());

create or replace function public.create_registration_invitation(p_role text,p_expires_hours integer default 24)
returns jsonb language plpgsql security definer set search_path=public,extensions as $$
declare token text:=encode(extensions.gen_random_bytes(32),'hex'); invitation public.registration_invitations;
begin
  if not is_marketing() then raise exception 'Marketing Office authorization required'; end if;
  if p_role not in ('student','marketing') then raise exception 'Invalid invitation role'; end if;
  if p_expires_hours not between 1 and 720 then raise exception 'Expiry must be between 1 hour and 30 days'; end if;
  insert into registration_invitations(role,token_hash,expires_at,created_by)
  values(p_role,encode(extensions.digest(token,'sha256'),'hex'),now()+make_interval(hours=>p_expires_hours),auth.uid()) returning * into invitation;
  return jsonb_build_object('id',invitation.id,'token',token,'role',invitation.role,'expiresAt',invitation.expires_at);
end$$;

create or replace function public.revoke_registration_invitation(p_invitation_id uuid)
returns void language plpgsql security definer set search_path=public as $$ begin
  if not is_marketing() then raise exception 'Marketing Office authorization required'; end if;
  update registration_invitations set revoked_at=coalesce(revoked_at,now()) where id=p_invitation_id;
  if not found then raise exception 'Invitation not found'; end if;
end$$;

create or replace function public.delete_registration_invitation(p_invitation_id uuid)
returns void language plpgsql security definer set search_path=public as $$ begin
  if not is_marketing() then raise exception 'Marketing Office authorization required'; end if;
  delete from registration_invitations where id=p_invitation_id;
  if not found then raise exception 'Invitation not found'; end if;
end$$;

grant execute on function public.create_registration_invitation(text,integer) to authenticated;
grant execute on function public.revoke_registration_invitation(uuid) to authenticated;
grant execute on function public.delete_registration_invitation(uuid) to authenticated;
