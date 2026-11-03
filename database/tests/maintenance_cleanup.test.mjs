import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {test} from 'node:test';
import {PGlite} from '@electric-sql/pglite';
import {postgis} from '@electric-sql/pglite-postgis';
import {historicalBundle} from './historical_bundle.mjs';

const cleanup = await readFile(new URL('../maintenance/001_clear_pets_and_cases.sql', import.meta.url), 'utf8');
const inventory = await readFile(new URL('../maintenance/002_list_pet_and_case_storage.sql', import.meta.url), 'utf8');
const current = await readFile(new URL('../run_all.sql', import.meta.url), 'utf8');
const id = n => `cccccccc-cccc-4ccc-8ccc-${String(n).padStart(12, '0')}`;
const cleared = ['pets', 'pet_photos', 'pet_deletions', 'pet_photo_deletions', 'lost_cases', 'case_events',
  'found_cases', 'found_case_photos', 'found_case_events', 'saved_cases', 'case_public_links', 'case_contacts',
  'case_closures', 'notifications', 'notification_deliveries', 'content_reports', 'content_visibility',
  'content_report_resolutions', 'content_moderation_decisions', 'content_moderation_access', 'moderation_appeals',
  'moderation_appeal_answers', 'moderation_appeal_access', 'case_match_embeddings', 'case_match_reviews'];

async function setup(t, legacy) {
  const db = await PGlite.create({extensions: {postgis}});
  t.after(() => db.close());
  await db.exec(`create role anon; create role authenticated; create role service_role bypassrls;
    create schema auth; create schema storage;
    create table auth.users(id uuid primary key, aud text, role text, email text, raw_user_meta_data jsonb);
    create function auth.uid() returns uuid language sql stable as
    $$select(nullif(current_setting('request.jwt.claims',true),'')::jsonb->>'sub')::uuid$$;
    grant usage on schema auth to authenticated;
    create table storage.buckets(id text primary key,name text,public boolean,file_size_limit bigint,allowed_mime_types text[]);
    create table storage.objects(id uuid primary key,bucket_id text references storage.buckets(id),name text,metadata jsonb,unique(bucket_id,name));
    alter table storage.objects enable row level security;
    grant usage on schema storage to authenticated,anon;
    grant select,insert,update,delete on storage.objects to authenticated;
    grant select on storage.objects to anon;`);
  await db.exec(legacy ? await historicalBundle() : current);
  await db.exec(`insert into auth.users(id) values('${id(1)}'),('${id(2)}');
    update public.profiles set display_name='Cuenta conservada',city='Lima';
    insert into public.content_report_reviewers values('${id(1)}');
    insert into public.platform_administrators values('${id(2)}');
    insert into public.interest_zones(id,owner_id,name,latitude,longitude,radius_meters)
      values('${id(3)}','${id(1)}','Casa',-12,-77,1000);
    insert into public.alert_preferences(owner_id,enabled,push) values('${id(1)}',true,true);
    insert into public.push_devices(token,owner_id) values(repeat('x',30),'${id(1)}');
    insert into public.user_blocks(owner_id,blocked_id,label,enabled,version) values('${id(1)}','${id(2)}','Cuenta',true,1);`);
  for (const [n, owner] of [[10, id(1)], [20, id(2)]]) {
    await db.exec(`insert into public.pets(id,owner_id,name,species,size,age_months,traits,case_history_at,active_case_count)
      values('${id(n)}','${owner}','Luna','dog','small',12,'Blanca',now(),1);
      insert into public.pet_photos(id,pet_id,owner_id,status) values('${id(n)}','${id(n)}','${owner}','published');
      insert into public.pet_deletions(id,owner_id) values('${id(n)}','${owner}');
      insert into public.pet_photo_deletions(id,pet_id,owner_id) values('${id(n)}','${id(n)}','${owner}');`);
    for (const [offset, status] of [[1, 'active'], [2, 'resolved']]) {
      await db.exec(`insert into public.lost_cases(id,owner_id,pet_id,pet_version,status,occurred_at,latitude,longitude,
        place_reference,public_latitude,public_longitude,pet_name,species,size,age_months,traits,photo_ids)
        values('${id(n+offset)}','${owner}','${id(n)}',1,'${status}',now(),-12,-77,'Casa',-12,-77,
        'Luna','dog','small',12,'Blanca',array['${id(n)}']::uuid[]);
        insert into public.case_events(case_id,actor_id,event_type) values('${id(n+offset)}','${owner}','published');`);
    }
    for (const [offset, status] of [[3,'draft'],[4,'active'],[5,'resolved'],[6,'discarded']]) {
      await db.exec(`insert into public.found_cases(id,owner_id,status,occurred_at,latitude,longitude,place_reference,
        public_latitude,public_longitude,species,traits,photo_ids,published_at,report_kind)
        values('${id(n+offset)}','${owner}','${status}',now(),-12,-77,'Casa',-12,-77,'cat','Negra',
        array['${id(n)}']::uuid[],now(),'possible_loss');`);
    }
    await db.exec(`insert into public.found_case_photos(id,case_id,owner_id,content_hash) values('${id(n)}','${id(n+4)}','${owner}',repeat('a',64));
      insert into public.found_case_events(case_id,actor_id,event_type) values('${id(n+4)}','${owner}','published');
      insert into public.saved_cases(owner_id,case_source,case_id,saved) values('${owner}','lost','${id(n+1)}',true);
      insert into public.case_public_links(case_source,case_id,owner_id) values('lost','${id(n+1)}','${owner}');
      insert into public.case_contacts(case_source,case_id,owner_id) values('lost','${id(n+1)}','${owner}');
      insert into public.case_closures(command_id,case_source,case_id,actor_id,reason) values('${id(n)}','lost','${id(n+2)}','${owner}','Recuperada');
      insert into public.notifications(owner_id,event_key,case_source,case_id,kind,title) values('${owner}','fixture','lost','${id(n+1)}','update','Aviso');
      insert into public.alert_subscriptions values('${owner}','lost','${id(n+1)}',true,1);
      insert into public.alert_subscription_commands values('${id(n)}','${owner}','lost','${id(n+1)}',true,0,'{}');`);
  }
  await db.exec(`insert into public.notification_deliveries(notification_id) select id from public.notifications;
    insert into public.alert_subscriptions values('${id(1)}','zone','${id(3)}',true,1);
    insert into public.alert_subscription_commands values('${id(3)}','${id(1)}','zone','${id(3)}',true,0,'{}');
    insert into public.content_reports(id,reporter_id,resource_kind,resource_id,reason) values('${id(30)}','${id(2)}','lost','${id(11)}','Revisar');
    insert into public.content_visibility values('lost','${id(11)}',true,1);
    insert into public.content_report_resolutions(report_id,version) values('${id(30)}',1);
    insert into public.content_moderation_decisions(command_id,report_id,actor_id,action,reason,report_version,resource_version,hidden)
      values('${id(31)}','${id(30)}','${id(1)}','hide','Revisar',1,1,true);
    insert into public.content_moderation_access(actor_id,report_id,action) values('${id(1)}','${id(30)}','detail');
    insert into public.moderation_appeals(id,decision_id,appellant_id,reason) values('${id(32)}','${id(31)}','${id(1)}','Revisión');
    insert into public.moderation_appeal_answers(id,appeal_id,actor_id,reason) values('${id(33)}','${id(32)}','${id(1)}','Confirmado');
    insert into public.moderation_appeal_access(actor_id,decision_id) values('${id(1)}','${id(31)}');
    insert into public.case_match_embeddings values('lost','${id(11)}','${id(10)}',repeat('a',64),repeat('b',32),
      'clip-vit-b32-d15189d-q8-v1',array_fill(0.1::real,array[512]),now());
    insert into public.case_match_reviews(command_id,actor_id,anchor_source,anchor_id,anchor_revision,candidate_source,
      candidate_id,candidate_revision,model_version,decision)
      values('${id(34)}','${id(1)}','lost','${id(11)}',repeat('b',32),'found','${id(24)}',repeat('c',32),'clip-vit-b32-d15189d-q8-v1','dismissed');
    insert into storage.objects values('${id(40)}','pet-photos','pet.jpg','{}'),
      ('${id(41)}','found-photo-renditions','case.jpg','{}'),('${id(42)}','profile-avatars','avatar.jpg','{}');`);
  if (legacy) {
    await db.exec(`insert into public.public_sightings(id,case_source,case_id,request_hash,actor_hash,observed_at,latitude,longitude,location_source,comment,is_late)
      values('${id(50)}','lost','${id(11)}',repeat('a',64),repeat('b',64),now(),-12,-77,'manual','Vista',false);
      insert into public.sighting_reviews(command_id,sighting_id,revision,previous_state,state,reason,actor_id)
      values('${id(51)}','${id(50)}',1,'unreviewed','useful','Útil','${id(1)}');`);
  }
  return db;
}

const count = async (db, table) => (await db.query(`select count(*)::int n from ${table}`)).rows[0].n;
async function snapshot(db, tables) {
  return Promise.all(tables.map(async table => [table, (await db.query(`select to_jsonb(t) v from ${table} t order by to_jsonb(t)::text`)).rows]));
}

for (const legacy of [false, true]) {
  test(`Global cleanup preserves accounts/settings, removes every related table and resets identities (${legacy ? 'pre-042' : 'current'})`, async t => {
    const db = await setup(t, legacy);
    const targets = legacy ? [...cleared, 'public_sightings', 'sighting_reviews'] : cleared;
    for (const table of targets) assert.ok(await count(db, `public.${table}`) > 0, `${table} fixture`);
    const keep = ['auth.users', 'public.profiles', 'public.content_report_reviewers', 'public.platform_administrators',
      'public.interest_zones', 'public.alert_preferences', 'public.push_devices', 'public.user_blocks', 'storage.buckets', 'storage.objects'];
    const before = await snapshot(db, keep);
    const zoneBefore = await db.query("select * from public.alert_subscriptions where target_kind='zone'");
    const zoneCommandsBefore = await db.query("select * from public.alert_subscription_commands where target_kind='zone'");
    const sequenceNames = (await db.query(`select pg_get_serial_sequence('public.'||table_name,column_name) name
      from information_schema.columns where table_schema='public' and is_identity='YES'`)).rows.map(r => r.name);
    for (const name of sequenceNames) await db.query('select setval($1,50,true)', [name]);

    // A new unrelated FK must abort the entire operation, including earlier DELETEs.
    await db.exec(`create table public.unrelated_fixture(pet_id uuid references public.pets(id));
      insert into public.unrelated_fixture values('${id(10)}');`);
    await assert.rejects(db.exec(cleanup), /foreign key|cannot truncate/i);
    await db.exec('rollback');
    assert.equal(await count(db, 'public.pets'), 2);
    assert.equal(await count(db, 'public.alert_subscriptions'), 3);
    assert.equal(await count(db, 'public.alert_subscription_commands'), 3);
    assert.equal(await count(db, 'public.unrelated_fixture'), 1);
    for (const name of sequenceNames) assert.deepEqual((await db.query(`select last_value::int, is_called from ${name}`)).rows, [{last_value: 50, is_called: true}]);
    await db.exec('drop table public.unrelated_fixture');

    // Normal application roles cannot run the administrative cleanup.
    await db.exec('set role authenticated');
    await assert.rejects(db.exec(cleanup), /permission denied|must be owner/i);
    await db.exec('rollback; reset role');
    await db.exec(cleanup);
    for (const table of targets) assert.equal(await count(db, `public.${table}`), 0, table);
    assert.deepEqual(await snapshot(db, keep), before);
    assert.deepEqual(await db.query('select * from public.alert_subscriptions'), zoneBefore);
    assert.deepEqual(await db.query('select * from public.alert_subscription_commands'), zoneCommandsBefore);
    for (const name of sequenceNames) assert.equal((await db.query('select nextval($1)::int n', [name])).rows[0].n, 1, name);
    await db.exec(cleanup); // Also works on an already empty database.
    assert.deepEqual(await snapshot(db, keep), before);
    const listed = await db.exec(inventory);
    assert.deepEqual(listed[1].rows.map(r => r.name).sort(), ['case.jpg', 'pet.jpg']);
    assert.deepEqual(await snapshot(db, keep), before);
  });
}
