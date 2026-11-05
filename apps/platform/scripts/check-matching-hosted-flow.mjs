// Explicit QA acceptance flow against the configured backend.
// Only UUIDs created by this run may be retired/cleaned. Never logs credentials.
import assert from 'node:assert/strict';
import { readFile, writeFile, mkdir, access, rm } from 'node:fs/promises';
import { resolve } from 'node:path';
import { randomUUID } from 'node:crypto';
import sharp from 'sharp';
import { RecoverySource } from '../server/features/recovery/data/recovery_source.ts';
import { ServerRecoveryRepository } from '../server/features/recovery/data/server_recovery_repository.ts';
import { PublishRecoveryReport } from '../shared/features/recovery/domain/recovery.ts';

if(!process.argv.includes('--run-qa'))throw new Error('Pass --run-qa to create and retire clearly marked temporary QA reports');
const configPath=resolve('../mobile/config/profile_test.local.json');
const config=JSON.parse(await readFile(configPath,'utf8'));
const release=JSON.parse(await readFile(resolve('../mobile/config/release.local.json'),'utf8'));
process.loadEnvFile(resolve('.env.local'));
assert.equal(new URL(config.SUPABASE_URL).origin,new URL(process.env.SUPABASE_URL).origin,'QA backend mismatch');
const root=resolve('../../work/matching-hosted-flow');await mkdir(root,{recursive:true});
if(process.argv.includes('--hold-for-ui'))await rm(resolve(root,'continue'),{force:true});
const admin={apikey:process.env.SUPABASE_SERVER_KEY,Authorization:'Bearer '+process.env.SUPABASE_SERVER_KEY};
const checks=[],fixtures=[],sessions={};let stage='setup',failed=false;
const resultPath=resolve(root,'flow-results.json');
const pass=name=>{checks.push({name,passed:true});console.log('MATCH_HOSTED_PASS '+name);};
async function request(url,{method='GET',headers={},body}={}){
 const response=await fetch(url,{method,headers,...(body===undefined?{}:{body:typeof body==='string'||body instanceof Uint8Array?body:JSON.stringify(body)}),redirect:'error',signal:AbortSignal.timeout(90000)});
 const value=await response.json().catch(()=>null);return{status:response.status,value};
}
async function rpc(session,name,params={}){
 const response=await request(config.SUPABASE_URL+'/rest/v1/rpc/'+name,{method:'POST',headers:{apikey:config.SUPABASE_PUBLISHABLE_KEY,Authorization:'Bearer '+session.access_token,'Content-Type':'application/json'},body:params});
 if(response.status>=300)throw Error('RPC '+name+' failed HTTP '+response.status+' code '+(response.value?.code||'unknown'));
 return response.value;
}
async function matching(session,operation,body={}){
 return request(release.PUBLIC_CASE_WEB_URL+'/api/app/matching/'+operation,{method:'POST',headers:{Authorization:'Bearer '+session.access_token,'Content-Type':'application/json'},body});
}
async function context(anchor){
 const response=await request(config.SUPABASE_URL+'/rest/v1/rpc/read_case_match_context',{method:'POST',headers:{...admin,'Content-Type':'application/json'},body:{p_actor:sessions.A.user.id,p_source:'found',p_case:anchor}});
 assert.equal(response.status,200,'QA index context must be authorized');return response.value;
}
try{
 stage='authenticate-qa-accounts';
 for(const label of ['A','B']){
  const refresh=config['PROFILE_TEST_REFRESH_TOKEN_'+label];assert.ok(refresh,'Existing QA session required');
  const response=await request(config.SUPABASE_URL+'/auth/v1/token?grant_type=refresh_token',{method:'POST',headers:{apikey:config.SUPABASE_PUBLISHABLE_KEY,'Content-Type':'application/json'},body:{refresh_token:refresh}});
  assert.equal(response.status,200,'QA '+label+' session refresh');sessions[label]=response.value;
  config['PROFILE_TEST_REFRESH_TOKEN_'+label]=response.value.refresh_token;
  await writeFile(configPath,JSON.stringify(config,null,2)+'\n');
 }
 assert.notEqual(sessions.A.user.id,sessions.B.user.id);pass('two-real-distinct-authenticated-accounts');
 stage='publication-isolation-precondition';
 // Interest-zone radius is at most50km. No nearby zones means no unrelated
 // publication alerts at this deliberately remote QA coordinate.
 const zones=await request(config.SUPABASE_URL+'/rest/v1/interest_zones?select=id&deleted_at=is.null&latitude=gte.-0.6&latitude=lte.0.6&longitude=gte.-0.6&longitude=lte.0.6&limit=1',{headers:admin});
 assert.equal(zones.status,200,'Verify QA zone isolation before publishing');assert.deepEqual(zones.value,[],'QA zone must not notify other users');
 pass('qa-publication-zone-has-no-nearby-interest-zones');
 const raw=await readFile(resolve('../mobile/assets/onboarding/dog_waving.png'));
 for(const [label,kind] of [['A','possible_loss'],['B','independent_found']]){
  stage='publish-qa-'+label;
  const session=sessions[label],id=randomUUID(),photo=randomUUID();
  const fixture={label,id,photo,owner:session.user.id,kind,prepared:false,published:false};fixtures.push(fixture);
  await writeFile(resolve(root,'fixtures.local.json'),JSON.stringify(fixtures,null,2));
  const bytes=await sharp(raw).resize(label==='A'?320:300).flatten({background:'#fff'}).jpeg({quality:85}).toBuffer();
  const source=new RecoverySource({url:config.SUPABASE_URL,key:config.SUPABASE_PUBLISHABLE_KEY},session.access_token);
  const repository=new ServerRecoveryRepository(source,session.user.id);
  const draft={id,kind,petId:null,petVersion:null,targetId:null,communityTarget:false,occurredAt:new Date(Date.now()-300000).toISOString(),latitude:0,longitude:0,place:'VALIDACION QA AUTOMATICA. NO ES UN CASO REAL.',species:'other',speciesDetail:'Prueba automatizada QA',size:'medium',sex:'',traits:'VALIDACION AUTOMATIZADA QA. NO ES UNA MASCOTA PERDIDA. Registro temporal de prueba de Coincidencias.',photoIds:[photo],custody:null};
  fixture.prepared=true;
  const receipt=await new PublishRecoveryReport(repository).execute(draft,[{id:photo,bytes}]);
  assert.equal(receipt.id,id);fixture.published=true;
  await writeFile(resolve(root,'fixtures.local.json'),JSON.stringify(fixtures,null,2));
  pass('qa-'+label+'-publication-through-real-domain-repository-photo-processor');
 }
 const [anchor,candidate]=fixtures;
 stage='matching-authorizations';
 const aList=await matching(sessions.A,'searches'),bList=await matching(sessions.B,'searches');
 assert.equal(aList.status,200);assert.equal(bList.status,200);
 assert.ok(aList.value.some(row=>row.ref.id===anchor.id));assert.ok(!bList.value.some(row=>row.ref.id===anchor.id));
 assert.equal((await matching(sessions.B,'search',{source:'found',id:anchor.id})).status,403);
 pass('search-list-isolation-and-cross-account-anchor-rejection');
 stage='real-model-index-and-retry';
 let response=await matching(sessions.A,'search',{source:'found',id:anchor.id});
 assert.equal(response.status,200,'Hosted comparison must execute the real model');let result=response.value;
 for(let n=0;!result.complete&&n<8;n++){response=await matching(sessions.A,'search',{source:'found',id:anchor.id});assert.equal(response.status,200);result=response.value;}
 assert.equal(result.complete,true);assert.equal(result.pendingPhotos,0);
 const suggested=result.candidates.find(item=>item.ref.id===candidate.id);assert.ok(suggested,'Other QA account independent find must be suggested');
 assert.doesNotMatch(JSON.stringify(result),/"(?:owner|embedding|path|photos|score|email)"/);
 const snapshot=await context(anchor.id);
 const vectors=[snapshot.anchor,...snapshot.candidates.filter(item=>item.id===candidate.id)].flatMap(item=>item.photos.map(photo=>photo.embedding));
 assert.equal(vectors.length,2);for(const vector of vectors){assert.equal(vector.length,512);assert.ok(Math.abs(Math.hypot(...vector)-1)<1e-5);}
 const retried=await matching(sessions.A,'search',{source:'found',id:anchor.id});assert.equal(retried.status,200);assert.equal(retried.value.pendingPhotos,0);
 pass('hosted-real-clip-indexes-two-processed-images-and-reuses-durable-vectors');
 stage='reviews-and-replay';
 const command={id:randomUUID(),anchor:result.anchor,anchorRevision:result.revision,candidate:suggested.ref,candidateRevision:suggested.revision,decision:'confirmed',model:result.model};
 assert.equal((await matching(sessions.B,'review',command)).status,403);
 assert.equal((await matching(sessions.A,'review',{...command,id:randomUUID(),candidateRevision:'0'.repeat(32)})).status,409);
 // Discard the first acknowledgement deliberately, then retry the same UUID.
 assert.equal((await matching(sessions.A,'review',command)).status,200);
 assert.equal((await matching(sessions.A,'review',command)).status,200);
 assert.equal((await matching(sessions.A,'search',{source:'found',id:anchor.id})).value.candidates.find(item=>item.ref.id===candidate.id).review,'confirmed');
 assert.equal((await matching(sessions.A,'review',{...command,id:randomUUID(),decision:'dismissed'})).status,200);
 assert.equal((await matching(sessions.A,'review',command)).status,200);
 assert.equal((await matching(sessions.A,'search',{source:'found',id:anchor.id})).value.candidates.find(item=>item.ref.id===candidate.id).review,'dismissed');
 const live=await rpc(sessions.A,'read_recovery_report',{p_id:anchor.id});assert.equal(live[0].status,'active');assert.equal(live[0].pet_id??null,null);
 pass('human-reviews-persist-authorize-conflict-retry-and-do-not-close-or-assign');
 stage='client-representation-grants';
 const forbidden=await request(config.SUPABASE_URL+'/rest/v1/rpc/read_case_match_context',{method:'POST',headers:{apikey:config.SUPABASE_PUBLISHABLE_KEY,Authorization:'Bearer '+sessions.A.access_token,'Content-Type':'application/json'},body:{p_actor:sessions.A.user.id,p_source:'found',p_case:anchor.id}});
 assert.ok([401,403,404].includes(forbidden.status));pass('server-only-matching-context-unavailable-to-client-token');
 if(process.argv.includes('--hold-for-ui')){
  stage='native-ui-check';
  await writeFile(resolve(root,'ui-session.local.json'),JSON.stringify({session:sessions.A,backend:config.SUPABASE_URL,anchor:anchor.id,candidate:candidate.id,origin:release.PUBLIC_CASE_WEB_URL}));
  console.log('MATCH_HOSTED_UI_READY');
  const deadline=Date.now()+600000;
  while(true){try{await access(resolve(root,'continue'));break;}catch{if(Date.now()>deadline)throw Error('Native UI check deadline expired');await new Promise(resolve=>setTimeout(resolve,1000));}}
  pass('native-ui-check-resumed');
 }
 stage='retirement-and-closure';
 await rpc(sessions.B,'delete_found_case',{p_id:candidate.id});
 const afterRetirement=await matching(sessions.A,'search',{source:'found',id:anchor.id});assert.equal(afterRetirement.status,200);assert.ok(!afterRetirement.value.candidates.some(item=>item.ref.id===candidate.id));
 await rpc(sessions.A,'close_recovery_case',{p_command:randomUUID(),p_source:'found',p_case:anchor.id,p_reason:'Fin de validacion automatizada QA. No hubo recuperacion real.',p_evidence_note:null});
 assert.equal((await matching(sessions.A,'search',{source:'found',id:anchor.id})).status,403);
 assert.ok(!(await matching(sessions.A,'searches')).value.some(item=>item.ref.id===anchor.id));
 pass('retired-candidate-and-closed-anchor-cannot-resurrect');
 stage='notification-isolation';
 const notifications=await request(config.SUPABASE_URL+'/rest/v1/notifications?select=owner_id&case_id=in.('+fixtures.map(item=>item.id).join(',')+')',{headers:admin});
 // These private inbox tables intentionally have no direct service-role grant.
 // Do not broaden permissions to inspect other accounts for a QA check.
 assert.equal(notifications.status,403);
 pass('private-notification-table-grants-preserved');
}catch(error){failed=true;checks.push({name:stage,passed:false,error:error instanceof Error?error.message:'validation-failed'});console.log('MATCH_HOSTED_FAIL '+stage+' '+(error instanceof Error?error.message:'validation-failed'));}
finally{
 for(const fixture of [...fixtures].reverse()){
  try{
   const session=sessions[fixture.label];
   if(fixture.published)await rpc(session,'delete_found_case',{p_id:fixture.id});
   else if(fixture.prepared)await rpc(session,'begin_found_case_discard',{p_id:fixture.id});
   for(const bucket of ['found-photo-renditions','found-photo-thumbnails']){
    const cleaned=await request(config.SUPABASE_URL+'/storage/v1/object/'+bucket,{method:'DELETE',headers:{...admin,'Content-Type':'application/json'},body:{prefixes:[fixture.owner+'/'+fixture.id+'/'+fixture.photo+'.jpg']}});
    assert.ok(cleaned.status<300,'QA Storage cleanup HTTP '+cleaned.status);
   }
   if(!fixture.published&&fixture.prepared)await rpc(session,'finish_found_case_discard',{p_id:fixture.id});
   pass('qa-'+fixture.label+'-retired-and-own-storage-removed');
  }catch(error){failed=true;checks.push({name:'cleanup-qa-'+fixture.label,passed:false,error:error instanceof Error?error.message:'cleanup-failed'});}
 }
 const report={date:'2026-11-05',origin:release.PUBLIC_CASE_WEB_URL,passed:!failed,checks,scope:'Real configured Auth, RPC/RLS, photo-processing/Storage and hosted Nuxt/CLIP. Clearly marked temporary QA reports at a verified alert-isolated coordinate; no password/account-role changes. Synthetic canary photos validate the flow, not animal identity quality. Soft-deleted QA history/review receipts remain according to the domain.'};
 await writeFile(resultPath,JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify(report,null,2));if(failed)process.exitCode=1;
}
