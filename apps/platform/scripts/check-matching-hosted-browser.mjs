// Uses an Auth-verified QA session and the existing server cookie serializer.
// This validates the hosted matching UI; password/OTP entry is outside this run.
import assert from 'node:assert/strict';
import { readFile, mkdir, writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { sealAccountSession } from '../server/infrastructure/account_session.ts';
const data=JSON.parse(await readFile(resolve('../../work/matching-hosted-flow/ui-session.local.json'),'utf8'));
process.loadEnvFile(resolve('.env.local'));
const {chromium}=await import(pathToFileURL(resolve('../../work/matching-validation/node_modules/playwright-core/index.mjs')).href);
const browser=await chromium.launch({executablePath:'C:/Program Files/Google/Chrome/Application/chrome.exe',headless:true});
const output=resolve('../mobile/build/ui-preview/matching-hosted-2026-11-05');await mkdir(output,{recursive:true});
const errors=[];const checks=[];
try{
 const context=await browser.newContext({viewport:{width:390,height:844}});
 await context.addCookies([{name:'eh_access',value:sealAccountSession({actor:data.session.user.id,token:data.session.access_token,expiresAt:Date.now()+3000000},process.env.MODERATION_SESSION_SECRET),url:data.origin,httpOnly:true,secure:true,sameSite:'Strict'}]);
 const page=await context.newPage();page.setDefaultTimeout(25000);page.on('pageerror',error=>errors.push(error.message));
 await page.goto(data.origin+'/coincidencias');assert.ok(page.url().endsWith('/coincidencias'),'Verified QA session must pass hosted access policy');
 await page.getByRole('button',{name:'Buscar coincidencias',exact:true}).click();await page.getByText('Posible coincidencia',{exact:true}).waitFor();
 const photo=page.getByAltText('Mascota de la publicación sugerida');await photo.scrollIntoViewIfNeeded();await photo.evaluate(async img=>{await img.decode();});
 assert.equal(await photo.evaluate(img=>img.naturalWidth>0),true);checks.push('hosted-search-and-authorized-photo');
 const confirm=page.getByRole('button',{name:'Coincide',exact:true});
 if(await confirm.isEnabled())await confirm.click();
 await page.getByText('Tu revisión: Coincidencia confirmada.',{exact:true}).waitFor();
 await page.getByRole('button',{name:'Descartar',exact:true}).click();await page.getByText('Tu revisión: Descartada.',{exact:true}).waitFor();checks.push('hosted-human-review-confirm-and-dismiss');
 await page.evaluate(()=>document.activeElement?.blur());
 await page.locator('.matching-screen').screenshot({path:resolve(output,'web-390-resultados.png')});
 await page.getByRole('link',{name:'Ver ficha',exact:true}).click();await page.waitForURL('**/casos/encontrados/'+data.candidate);
 await page.getByText(/VALIDACION AUTOMATIZADA QA/).waitFor();checks.push('hosted-live-candidate-detail');
 await page.getByRole('button',{name:'Volver',exact:true}).click();await page.waitForURL('**/coincidencias');
 await page.getByRole('button',{name:'Buscar coincidencias',exact:true}).click();await page.getByText('Posible coincidencia',{exact:true}).waitFor();
 await page.setViewportSize({width:320,height:844});await page.emulateMedia({reducedMotion:'reduce'});await page.evaluate(()=>{document.documentElement.style.fontSize='200%';});
 assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),true);
 await page.getByRole('button',{name:'Descartar',exact:true}).scrollIntoViewIfNeeded();await page.locator('.matching-screen').screenshot({path:resolve(output,'web-320-texto-200.png')});checks.push('hosted-320-text-200-reduced-motion-and-scroll');
 await page.evaluate(()=>{document.documentElement.style.fontSize='';});
 await page.route('**/api/matching/search',route=>route.abort('internetdisconnected'));
 await page.getByRole('button',{name:'Buscar coincidencias',exact:true}).click();await page.getByText('No pudimos comparar las publicaciones. Puedes reintentar.',{exact:true}).waitFor();
 await page.unroute('**/api/matching/search');await page.getByRole('button',{name:'Buscar coincidencias',exact:true}).click();await page.getByText('Posible coincidencia',{exact:true}).waitFor();checks.push('hosted-network-error-and-retry');
 assert.deepEqual(errors,[]);await writeFile(resolve(output,'browser-results.json'),JSON.stringify({passed:true,checks,errors,sessionSetup:'Existing verified QA Auth token serialized into the standard HttpOnly server cookie; no password/OTP UI claim.'},null,2));console.log(JSON.stringify({passed:true,checks,errors},null,2));
}finally{await browser.close();}
