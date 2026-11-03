import assert from 'node:assert/strict';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { fileURLToPath } from 'node:url';
import { test } from 'node:test';
import { productionFixture } from './server_fixture.mjs';
import { slug, photo } from './fixtures.mjs';
import sharp from 'sharp';

test('Retired anonymous sightings reject writes and QR points to account contribution',async t=>{
 const server=await productionFixture();t.after(server.close);
 const response=await fetch(server.origin+'/api/c/'+slug+'/sightings',{method:'POST',headers:{Origin:server.origin}});
 assert.ok([404,405].includes(response.status));assert.equal(server.sightings(),0);
 const html=await (await fetch(server.origin+'/c/'+slug)).text();assert.ok(html.includes('/ayudar/'+slug));
 const protectedPage=await fetch(server.origin+'/ayudar/'+slug,{redirect:'manual'});assert.equal(protectedPage.status,302);assert.ok(protectedPage.headers.get('set-cookie').includes('eh_contribution_return'));
});

test('Landing SSR is public, works without product requests and keeps crawler policy separate from QR', async t => {
  const server = await productionFixture(); t.after(server.close);
  const response = await fetch(server.origin + '/'); const html = await response.text();
  assert.equal(response.status, 200); assert.equal(response.headers.get('x-robots-tag'), 'index, follow');
  assert.match(html, /Más huellas juntas/); assert.match(html, /<title>Entre Huellas/); assert.match(html, /name="description"/);
  assert.equal((html.match(/<details[\s>]/g) || []).length, 4);
  assert.match(html, /rel="canonical" href="https:\/\/entrehuellas.app\/"/);
  assert.match(html, /<title>Entre Huellas \| Mascotas perdidas y encontradas<\/title>/);
  assert.match(html, /property="og:site_name" content="Entre Huellas"/);
  assert.match(html, /property="og:url" content="https:\/\/entrehuellas.app\/"/);
  assert.match(html, /name="twitter:card" content="summary_large_image"/);
  assert.equal((html.match(/<h1[\s>]/g) || []).length, 1);
  const schemaTag = html.match(/<script\b([^>]*type="application\/ld\+json"[^>]*)>([\s\S]*?)<\/script>/);
  assert.ok(schemaTag); const schema = JSON.parse(schemaTag[2]);
  assert.deepEqual(schema['@graph'].map(item => item['@type']), ['Organization', 'WebSite', 'WebPage']);
  const nonce = /nonce-([^']+)/.exec(response.headers.get('content-security-policy'))?.[1];
  assert.ok(nonce); assert.ok(schemaTag[1].includes(`nonce="${nonce}"`));
  const socialImage = html.match(/property="og:image" content="([^"]+)"/)[1];
  const imageResponse = await fetch(server.origin + new URL(socialImage).pathname);
  assert.equal(imageResponse.status, 200); assert.match(imageResponse.headers.get('content-type'), /image\/jpeg/);
  const imageMetadata = await sharp(Buffer.from(await imageResponse.arrayBuffer())).metadata();
  assert.equal(imageMetadata.width, 1200); assert.equal(imageMetadata.height, 630);
  assert.equal(server.reads(), 0, 'Landing must not query cases or Supabase');
  assert.doesNotMatch(html, /sb_secret_test-private-canary|photo_objects|v-html|noindex/);
  const robots = await (await fetch(server.origin + '/robots.txt')).text(); assert.match(robots, /Disallow: \/c\//); assert.match(robots, /Disallow: \/admin\//);
  const sitemap = await (await fetch(server.origin + '/sitemap.xml')).text(); assert.equal((sitemap.match(/<loc>/g) || []).length, 1); assert.doesNotMatch(sitemap, /\/c\/|\/admin\/|\/api\//);
  const qr = await fetch(`${server.origin}/c/unknown`); assert.match(qr.headers.get('x-robots-tag'), /noindex/);
});

test('SEO domain changes at runtime consistently and ignores request Host overrides', async t => {
  const origin = 'https://public.example.org';
  const server = await productionFixture(undefined, { env: { NUXT_PUBLIC_SITE_URL: origin } }); t.after(server.close);
  const html = await (await fetch(server.origin + '/?utm_source=community', { headers: { 'X-Forwarded-Host': 'attacker.example' } })).text();
  assert.match(html, /rel="canonical" href="https:\/\/public.example.org\/"/);
  assert.match(html, /property="og:url" content="https:\/\/public.example.org\/"/);
  assert.match(html, /property="og:image" content="https:\/\/public.example.org\/images\/landing\/social-reunion.jpg"/);
  const schema = JSON.parse(html.match(/<script\b[^>]*type="application\/ld\+json"[^>]*>([\s\S]*?)<\/script>/)[1]);
  for (const item of schema['@graph']) assert.equal(item.url, origin + '/');
  const robots = await (await fetch(server.origin + '/robots.txt')).text();
  const sitemap = await (await fetch(server.origin + '/sitemap.xml')).text();
  assert.ok(robots.includes(`Sitemap: ${origin}/sitemap.xml`));
  assert.ok(sitemap.includes(`<loc>${origin}/</loc>`));
  assert.doesNotMatch(html + robots + sitemap, /entrehuellas\.app|entrehuellas\.kormind\.com|attacker\.example/);
  for (const path of ['/iniciar-sesion', '/privacidad', '/terminos', '/c/unknown']) {
    assert.match((await fetch(server.origin + path)).headers.get('x-robots-tag'), /noindex/);
  }
  assert.equal(server.reads(), 0);
});
test('Built Nuxt SSR, API and photo proxy preserve public contracts and never expose server credentials/paths', async t => {
  const server = await productionFixture(); t.after(server.close);
  const health = await fetch(`${server.origin}/health`); assert.deepEqual(await health.json(), { status: 'ok' });
  await promisify(execFile)(process.execPath, ['scripts/healthcheck.mjs'], { cwd: fileURLToPath(new URL('../', import.meta.url)), env: server.env });
  let response = await fetch(`${server.origin}/c/${slug}`); assert.equal(response.status, 200);
  const html = await response.text(); assert.match(html, /<h1>Luna<\/h1>/); assert.match(html, /Pelaje blanco/);
  for (const secret of [photo.path, photo.bucket, 'sb_secret_test-private-canary', 'photo_objects', 'PRIVATE SDK FAILURE']) assert.equal(html.includes(secret), false);
  assert.equal(response.headers.get('cache-control'), 'no-store'); assert.equal(response.headers.get('referrer-policy'), 'no-referrer');
  const nonce = /nonce-([^']+)/.exec(response.headers.get('content-security-policy'))?.[1]; assert.ok(nonce);
  assert.ok(html.includes(`nonce="${nonce}"`));
  response = await fetch(`${server.origin}/api/c/${slug}`); assert.equal(response.status, 200); assert.equal((await response.json()).name, 'Luna');
  response = await fetch(`${server.origin}/api/c/${slug}/photos/0`); assert.equal(response.status, 200); assert.equal(response.headers.get('content-type'), 'image/jpeg');
  server.set({ state: 'closed', resolution: 'resolved', closed_at: '2026-10-17T18:00:00Z' });
  const closed = await (await fetch(`${server.origin}/c/${slug}`)).text(); assert.match(closed, /Este caso ya fue cerrado/); assert.doesNotMatch(closed, /<h1>Luna|class="pet-photo"/);
  server.set({ state: 'unavailable' }); response = await fetch(`${server.origin}/api/c/${slug}`); assert.equal(response.status, 404);
  assert.match(await (await fetch(`${server.origin}/c/${slug}`)).text(), /Este enlace no está disponible/);
  response = await fetch(`${server.origin}/api/c/not-valid`); assert.equal(response.status, 404);
  response = await fetch(`${server.origin}/api/c/${slug}`, { method: 'POST' }); assert.equal(response.status, 405);
  server.fail(true); response = await fetch(`${server.origin}/api/c/${slug}`); assert.equal(response.status, 503); assert.doesNotMatch(await response.text(), /PRIVATE/);
  for (const path of ['/.env', '/src/app/config.mjs', '/server/utils/reader.ts']) {
    const body = await (await fetch(server.origin + path)).text(); assert.doesNotMatch(body, /SUPABASE_SERVER_KEY|sb_secret_test-private-canary/);
  }
});

test('SSR API leases release after responses and metadata rate limiting remains bounded', async t => {
  const server = await productionFixture(); t.after(server.close);
  const statuses = [];
  for (let index = 0; index < 63; index++) {
    const response = await fetch(`${server.origin}/api/c/${slug}`); statuses.push(response.status); await response.arrayBuffer();
  }
  assert.equal(statuses.filter(status => status === 200).length, 60);
  assert.deepEqual(statuses.slice(60), [429, 429, 429]);
  assert.equal(statuses.includes(503), false);
});
