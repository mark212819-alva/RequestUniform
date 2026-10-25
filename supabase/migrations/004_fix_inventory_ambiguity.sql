-- Replaces the original inventory RPC whose local product_id variable collided
-- with the product_sizes.product_id column inside ON CONFLICT.
create or replace function public.create_inventory_item(
  p_product_id uuid,
  p_name text,
  p_category text,
  p_description text,
  p_price numeric,
  p_size_label text,
  p_initial_stock integer
) returns uuid
language plpgsql
security definer
set search_path=public
as $$
declare
  v_product_id uuid;
  v_size_id uuid;
begin
  if not is_marketing() then raise exception 'Marketing Office authorization required'; end if;
  if coalesce(trim(p_size_label),'')='' then raise exception 'Size is required'; end if;
  if p_initial_stock<0 then raise exception 'Initial stock cannot be negative'; end if;

  if p_product_id is null then
    if coalesce(trim(p_name),'')='' or coalesce(trim(p_category),'')='' then raise exception 'Uniform name and category are required'; end if;
    if p_price<0 then raise exception 'Price cannot be negative'; end if;
    insert into uniform_products(name,category,description,price,active)
    values(trim(p_name),trim(p_category),nullif(trim(p_description),''),p_price,true)
    returning id into v_product_id;
  else
    select up.id into v_product_id
    from uniform_products up
    where up.id=p_product_id and up.active
    for update;
    if v_product_id is null then raise exception 'Uniform not found'; end if;
  end if;

  insert into product_sizes(product_id,label)
  values(v_product_id,upper(trim(p_size_label)))
  on conflict on constraint product_sizes_product_id_label_key
  do update set label=excluded.label
  returning id into v_size_id;

  insert into inventory(size_id,quantity_available)
  values(v_size_id,p_initial_stock)
  on conflict(size_id) do update
  set quantity_available=inventory.quantity_available+excluded.quantity_available,
      updated_at=now();

  insert into inventory_adjustments(size_id,delta,reason,performed_by)
  values(v_size_id,p_initial_stock,'Initial stock / size entry',auth.uid());

  insert into audit_logs(actor_id,action,entity_type,entity_id,metadata)
  values(auth.uid(),'inventory.item_created','product_size',v_size_id::text,
    jsonb_build_object('product_id',v_product_id,'size',upper(trim(p_size_label)),'stock',p_initial_stock));

  return v_size_id;
end;
$$;

grant execute on function public.create_inventory_item(uuid,text,text,text,numeric,text,integer) to authenticated;
