-- Authenticated contribution destination; never returns private coordinates/evidence.
create or replace function public.read_qr_recovery_target(p_slug text)
returns table(id uuid,community boolean,name text,species text,species_detail text,size text,sex text)
language plpgsql stable security definer set search_path='' as $$
begin
 if auth.uid() is null then raise exception using errcode='42501',message='case_unauthorized'; end if;
 if p_slug is null or p_slug !~ '^[0-9a-f]{64}$' or public.read_qr_case(p_slug)->>'state' is distinct from 'active' then
  raise exception using errcode='42501',message='case_unavailable';
 end if;
 return query select s.* from public.case_public_links l
 join public.list_open_recovery_searches() s on s.id=l.case_id and s.community=(l.case_source='found')
 where l.public_slug=p_slug and l.revoked_at is null;
 if not found then raise exception using errcode='42501',message='case_unavailable'; end if;
end;
$$;
revoke all on function public.read_qr_recovery_target(text) from public,anon;
grant execute on function public.read_qr_recovery_target(text) to authenticated;

create or replace function public.read_qr_case_with_contributions(p_slug text)
returns jsonb language plpgsql stable security definer set search_path='' as $$
declare v_case jsonb; v_notices jsonb;
begin
 v_case=public.read_qr_case(p_slug);
 if v_case->>'state' is distinct from 'active' then return v_case; end if;
 select coalesce(jsonb_agg(jsonb_build_object('id',n.id,'kind',n.report_kind,
  'text',n.traits,'occurredAt',n.occurred_at) order by n.occurred_at desc,n.id),'[]'::jsonb)
 into v_notices from (
  select c.id,c.report_kind,c.traits,c.occurred_at from public.found_cases c
  join public.case_public_links l on
   (l.case_source='lost' and c.target_lost_case_id=l.case_id)
   or (l.case_source='found' and c.target_community_case_id=l.case_id)
  where l.public_slug=p_slug and l.revoked_at is null
   and c.report_kind in ('sighting','with_reporter') and c.status='active'
   and c.deleted_at is null and not public.is_moderation_hidden('found',c.id)
  order by c.occurred_at desc,c.id limit 100
 ) n;
 return v_case||jsonb_build_object('contributions',v_notices);
end;
$$;
revoke all on function public.read_qr_case_with_contributions(text) from public;
grant execute on function public.read_qr_case_with_contributions(text) to anon,authenticated;
