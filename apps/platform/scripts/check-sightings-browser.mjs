// Local fixtures only; no production writes.
import assert from 'node:assert/strict';
import { mkdir } from 'node:fs/promises';
import { pathToFileURL, fileURLToPath } from 'node:url';
import { recoveryFixture } from '../tests/recovery_fixture.mjs';
import { slug, rawActive } from '../tests/fixtures.mjs';
const runtime = await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href);
const { chromium } = runtime.default || runtime;
const browser = await chromium.launch({ executablePath:process.env.CHROME_PATH,headless:true });
const server = await recoveryFixture();
const output = new URL('../../mobile/build/ui-preview/public-contributions/',import.meta.url);
await mkdir(output,{recursive:true});
try {
 const context=await browser.newContext({viewport:{width:390,height:844},reducedMotion:'reduce'});
 const page=await context.newPage();page.setDefaultTimeout(20000);
 server.set({...rawActive(),contributions:[{id:'11111111-1111-4111-8111-111111111111',kind:'sighting',text:'La vi junto al parque',occurredAt:'2026-10-29T12:00:00Z'}]});
 await page.goto(server.origin+'/c/'+slug);
 await page.getByText('La vi junto al parque').waitFor();
 await page.screenshot({path:fileURLToPath(new URL('qr-publico.png',output)),fullPage:true});
 await page.getByRole('link',{name:'La vi o la encontré',exact:true}).click();
 await page.waitForURL(/iniciar-sesion/);
 assert.equal(decodeURIComponent((await context.cookies()).find(c=>c.name==='eh_contribution_return')?.value || ''),'/ayudar/'+slug);
 await page.getByLabel('Correo',{exact:true}).fill('ordinario@example.test');
 await page.getByLabel('Contraseña',{exact:true}).fill('test-fixture-password');
 await page.getByRole('button',{name:/^Iniciar sesión$/i}).click();
 await page.waitForURL('**/ayudar/'+slug);
 await page.getByRole('heading',{name:'Ayudar en este caso',exact:true}).waitFor();
 await page.getByText('Tu aviso y sus fotos serán públicos dentro del caso.',{exact:false}).waitFor();
 await page.screenshot({path:fileURLToPath(new URL('formulario-publico.png',output)),fullPage:true});
 assert.equal(server.sightings(),0);
 await context.close();
 console.log('QR public notices, authenticated entry and return to fixed case passed with local fixtures.');
} finally {await browser.close();await server.close();}
