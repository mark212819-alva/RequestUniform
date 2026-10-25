create or replace function public.current_user_profile() returns jsonb
language plpgsql stable security definer set search_path=public
as $$
declare r jsonb;
begin
  select jsonb_build_object('id',id,'role','student','name',full_name,'identifier',student_id,'email',phinma_email,'phone',phone,'program',program,'year',year_level)
  into r from student_profiles where id=auth.uid();
  if r is null then
    select jsonb_build_object('id',id,'role','marketing','name',full_name,'identifier',employee_id,'email',work_email)
    into r from staff_profiles where id=auth.uid() and active;
  end if;
  return r;
end;
$$;

create or replace function public.update_own_profile(
  p_full_name text,
  p_identifier text,
  p_contact_email text,
  p_phone text default '',
  p_program text default '',
  p_year_level text default ''
) returns jsonb
language plpgsql security definer set search_path=public
as $$
begin
  if coalesce(trim(p_full_name),'')='' or coalesce(trim(p_identifier),'')='' or coalesce(trim(p_contact_email),'')='' then
    raise exception 'Name, ID, and email are required';
  end if;
  if exists(select 1 from student_profiles where id=auth.uid()) then
    update student_profiles set full_name=trim(p_full_name),student_id=upper(trim(p_identifier)),phinma_email=lower(trim(p_contact_email)),phone=nullif(trim(p_phone),''),program=nullif(trim(p_program),''),year_level=nullif(trim(p_year_level),'') where id=auth.uid();
  elsif exists(select 1 from staff_profiles where id=auth.uid() and active) then
    update staff_profiles set full_name=trim(p_full_name),employee_id=upper(trim(p_identifier)),work_email=lower(trim(p_contact_email)) where id=auth.uid();
  else
    raise exception 'Profile not found';
  end if;
  insert into audit_logs(actor_id,action,entity_type,entity_id) values(auth.uid(),'profile.updated','profile',auth.uid()::text);
  return current_user_profile();
end;
$$;

grant execute on function public.update_own_profile(text,text,text,text,text,text) to authenticated;
