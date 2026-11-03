-- ADR-168: remove the private sighting subsystem; public linked notices remain.
-- Explicit DROP RESTRICT: no cascading deletion of unrelated objects.

create or replace function public.read_case_timeline(p_source text,p_case uuid,p_before_time timestamptz default null,p_before_key text default null,p_limit integer default 20)
returns jsonb language plpgsql security definer set search_path='' as $$
declare v_status text;v_items jsonb;v_next jsonb;
begin
 v_status=public.authorized_timeline_case(p_source,p_case);
 if p_limit is null or p_limit not between 1 and 50 or (p_before_time is null)<>(p_before_key is null)
 or (p_before_time is not null and (not isfinite(p_before_time) or length(p_before_key)>80)) then
  raise exception using errcode='23514',message='timeline_invalid';end if;
 with events as (
  select e.event_type key,e.event_type kind,e.event_type id,e.created_at observed_at,e.created_at received_at,false is_late,'' comment,false has_photo,'unreviewed' review_state,0 revision
   from public.case_events e where p_source='lost' and e.case_id=p_case
  union all
  select e.event_type,e.event_type,e.event_type,e.created_at,e.created_at,false,'',false,'unreviewed',0
   from public.found_case_events e where p_source='found' and e.case_id=p_case
 ), page as (
  select * from events where p_before_time is null or (observed_at,key)<(p_before_time,p_before_key)
  order by observed_at desc,key desc limit p_limit+1
 ), numbered as (select *,row_number() over(order by observed_at desc,key desc) n from page)
 select coalesce(jsonb_agg(to_jsonb(numbered)-'n' order by observed_at desc,key desc) filter(where n<=p_limit),'[]'::jsonb),
  case when count(*)>p_limit then (select jsonb_build_object('time',observed_at,'key',key) from numbered where n=p_limit) end
 into v_items,v_next from numbered;
 return jsonb_build_object('case_status',v_status,'items',v_items,'next',v_next);
end $$;

create or replace function public.authorize_report_resource(p_kind text,p_resource uuid)
returns void language plpgsql security definer set search_path='' set lock_timeout='5s' as $$
declare v_visible boolean;
begin
 if auth.uid() is null then raise exception using errcode='42501',message='report_forbidden';end if;
 if p_kind='lost' then
  select exists(select 1 from public.read_recovery_pet_case(p_resource)) into v_visible;
 elsif p_kind='found' then
  select exists(select 1 from public.read_recovery_report(p_resource)) into v_visible;

 end if;
 if not coalesce(v_visible,false) then raise exception using errcode='42501',message='report_forbidden';end if;
end $$;

create or replace function public.is_moderation_hidden(p_kind text,p_resource uuid)
returns boolean language sql stable security definer set search_path='' as $$
 select exists(select 1 from public.content_visibility where resource_kind=p_kind and resource_id=p_resource and hidden)
 or (p_kind='found' and exists(select 1 from public.found_cases c join public.content_visibility v
 on (v.resource_kind='lost' and v.resource_id=c.target_lost_case_id) or (v.resource_kind='found' and v.resource_id=c.target_community_case_id)
 where c.id=p_resource and v.hidden));
$$;

create or replace function public.read_moderation_report(p_id uuid)
returns jsonb language plpgsql security definer set search_path='' as $$
declare v_actor uuid:=public.require_content_reviewer();r public.content_reports;v_resource jsonb;v_history jsonb;
begin
 select * into r from public.content_reports where id=p_id;
 if not found then raise exception using errcode='42501',message='moderation_forbidden';end if;
 insert into public.content_moderation_access(actor_id,report_id,action) values(v_actor,p_id,'detail');
 if r.resource_kind='lost' then
  select jsonb_build_object('title',pet_name,'text',traits,'status',status,'removed',deleted_at is not null,
  'has_photo',exists(select 1 from public.pet_photos ph where ph.id=any(c.photo_ids) and ph.status='published' and ph.processed_at is not null))
  into v_resource from public.lost_cases c where id=r.resource_id;
 elsif r.resource_kind='found' then
  select jsonb_build_object('title',case when report_kind='possible_loss' then 'Búsqueda comunitaria' else 'Aviso' end,'text',traits,'status',status,'removed',deleted_at is not null,
  'has_photo',exists(select 1 from public.found_case_photos ph where ph.id=any(c.photo_ids) and ph.status='ready' and ph.processed_at is not null))
  into v_resource from public.found_cases c where id=r.resource_id;
 end if;
 select coalesce(jsonb_agg(to_jsonb(d) order by report_version desc),'[]'::jsonb) into v_history
 from (select * from public.content_moderation_decisions where report_id=p_id order by report_version desc limit 20) d;
 return jsonb_build_object('report',to_jsonb(r),'resource',v_resource,
  'report_version',coalesce((select version from public.content_report_resolutions where report_id=p_id),0),
  'resource_version',coalesce((select version from public.content_visibility where resource_kind=r.resource_kind and resource_id=r.resource_id),0),
  'hidden',coalesce((select hidden from public.content_visibility where resource_kind=r.resource_kind and resource_id=r.resource_id),false),
  'effective_hidden',public.is_moderation_hidden(r.resource_kind,r.resource_id),'history',v_history);
end $$;

create or replace function public.read_moderation_evidence(p_id uuid)
returns jsonb language plpgsql security definer set search_path='' as $$
declare v_actor uuid:=public.require_content_reviewer();r public.content_reports;v_photo jsonb;
begin
 select * into r from public.content_reports where id=p_id;
 if not found then raise exception using errcode='42501',message='moderation_forbidden';end if;
 insert into public.content_moderation_access(actor_id,report_id,action) values(v_actor,p_id,'evidence');
 if r.resource_kind='lost' then
  select jsonb_build_object('bucket','pet-photo-renditions','path',ph.owner_id::text||'/'||ph.pet_id::text||'/'||ph.id::text||'.jpg') into v_photo
  from public.lost_cases c join public.pet_photos ph on ph.id=any(c.photo_ids) and ph.pet_id=c.pet_id and ph.owner_id=c.owner_id
  where c.id=r.resource_id and ph.status='published' and ph.processed_at is not null and ph.content_hash is not null order by ph.is_primary desc,ph.created_at,ph.id limit 1;
 else
  select jsonb_build_object('bucket','found-photo-renditions','path',ph.owner_id::text||'/'||ph.case_id::text||'/'||ph.id::text||'.jpg') into v_photo
  from public.found_cases c join public.found_case_photos ph on ph.id=any(c.photo_ids) and ph.case_id=c.id and ph.owner_id=c.owner_id
  where c.id=r.resource_id and ph.status='ready' and ph.processed_at is not null and ph.content_hash is not null order by ph.created_at,ph.id limit 1;
 end if;
 return v_photo;
end $$;

create or replace function public.notification_event_trigger()
returns trigger language plpgsql security definer set search_path='' as $$
declare src text;target uuid;k text;ek text;
begin
 if tg_table_name='case_events' then src='lost';target=new.case_id;k=case when new.event_type='resolved' then 'resolved' else 'published' end;ek='lost:'||target||':'||new.event_type;
 else
  select case when target_lost_case_id is not null then 'lost' else 'found' end,coalesce(target_lost_case_id,target_community_case_id)
   into src,target from public.found_cases where id=new.case_id and report_kind in ('sighting','with_reporter');
  if target is not null then k='update';ek='report:'||new.case_id;
  else src='found';target=new.case_id;k=case when new.event_type='resolved' then 'resolved' else 'published' end;ek='found:'||target||':'||new.event_type;end if;
 end if;
 perform public.enqueue_case_notification(src,target,ek,k);return new;
end $$;

create or replace function public.prepare_user_block(p_kind text,p_resource uuid)
returns jsonb language plpgsql security definer set search_path='' set lock_timeout='5s' set statement_timeout='10s' as $$
declare v_target uuid;v_label text;v_row public.user_blocks;
begin
 if auth.uid() is null then raise exception using errcode='42501',message='block_forbidden';end if;
 if p_resource is null or p_kind is null or p_kind not in ('lost','found') then
  raise exception using errcode='23514',message='block_invalid';end if;
 if p_kind='lost' then
  if not exists(select 1 from public.read_recovery_pet_case(p_resource)) then
   raise exception using errcode='42501',message='block_forbidden';end if;
  select owner_id,'Reportante de '||pet_name into v_target,v_label from public.lost_cases where id=p_resource;
 elsif p_kind='found' then
  if not exists(select 1 from public.read_recovery_report(p_resource)) then
   raise exception using errcode='42501',message='block_forbidden';end if;
  select owner_id,'Reportante del aviso' into v_target,v_label from public.found_cases where id=p_resource;
 end if;
 -- Anonymous QR reporters cannot be identified as accounts; own content has no action.
 if v_target is null or v_target=auth.uid() then return null;end if;
 perform public.lock_user_pair(auth.uid(),v_target);
 insert into public.user_blocks(owner_id,blocked_id,label)
 values(auth.uid(),v_target,left(v_label,120)) on conflict(owner_id,blocked_id) do nothing;
 select * into v_row from public.user_blocks where owner_id=auth.uid() and blocked_id=v_target;
 return public.user_block_json(v_row);
end $$;

create or replace function public.owns_moderated_resource(p_kind text,p_id uuid,p_actor uuid)
returns boolean language sql stable security definer set search_path='' as $$
 select p_actor is not null and (
 (p_kind='lost' and exists(select 1 from public.lost_cases where id=p_id and owner_id=p_actor)) or
 (p_kind='found' and exists(select 1 from public.found_cases where id=p_id and owner_id=p_actor)));
$$;

create or replace function public.read_pilot_statistics(p_from date,p_to date)
returns jsonb language plpgsql security definer set search_path=''
set lock_timeout='5s' set statement_timeout='10s' as $$
declare v_actor uuid:=public.require_platform_administrator();v_from timestamptz;v_until timestamptz;v_result jsonb;
begin
 if p_from is null or p_to is null or not isfinite(p_from) or not isfinite(p_to)
 or p_from<'2000-01-01'::date or p_to>'2099-12-31'::date or p_to<p_from or p_to-p_from>=366 then
  raise exception using errcode='23514',message='statistics_invalid';
 end if;
 v_from=p_from::timestamp at time zone 'America/Lima';
 v_until=(p_to+1)::timestamp at time zone 'America/Lima';
 -- One statement gives all aggregates the same database snapshot. Historical
 -- publications remain counted after removal/moderation; drafts never count.
 with withdrawals as (
  select 'lost'::text source,id,deleted_at from public.lost_cases where deleted_at>=v_from and deleted_at<v_until
  union all
  select 'found',id,deleted_at from public.found_cases where published_at is not null and deleted_at>=v_from and deleted_at<v_until
 ), classified as (
  select exists(select 1 from public.case_closures c where c.case_source=w.source and c.case_id=w.id and c.closed_at<=w.deleted_at) recovered
  from withdrawals w
 )
 select jsonb_build_object(
  'period',jsonb_build_object('from',to_char(p_from,'YYYY-MM-DD'),'to',to_char(p_to,'YYYY-MM-DD')),
  'timezone','America/Lima',
  'publishedLost',(select count(*) from public.lost_cases where created_at>=v_from and created_at<v_until),
  'publishedFound',(select count(*) from public.found_cases where published_at>=v_from and published_at<v_until),
  'sightings',(select count(*) from public.found_cases where report_kind='sighting' and published_at>=v_from and published_at<v_until),
  'recovered',(select count(*) from public.case_closures where closed_at>=v_from and closed_at<v_until),
  'cancelled',(select count(*) from classified where not recovered),
  'archived',(select count(*) from classified where recovered),
  'reports',(select count(*) from public.content_reports where submitted_at>=v_from and submitted_at<v_until)
 ) into v_result;
 return v_result;
end $$;

drop function if exists public.submit_public_sighting(text,jsonb,text,text,text);
drop function if exists public.submit_app_sighting(text,uuid,uuid,jsonb,text,text,text);
drop function if exists public.persist_sighting(text,uuid,jsonb,text,text,text,uuid);
drop function if exists public.read_sighting_review(uuid,integer);
drop function if exists public.read_sighting_evidence(uuid);
drop function if exists public.review_sighting(uuid,uuid,integer,text,text);
drop table if exists public.sighting_reviews;
drop table if exists public.public_sightings;
drop function if exists public.guard_blocked_app_sighting();
-- Reject deployment if any runtime function still queries the removed tables.
do $$ begin
 if exists(select 1 from pg_catalog.pg_proc p join pg_catalog.pg_namespace n on n.oid=p.pronamespace
 where n.nspname='public' and p.prosrc ~ '(public_sightings|sighting_reviews)') then
  raise exception 'Private sighting dependency remains';
 end if;
end $$;
