import assert from 'node:assert/strict';
import { mkdir } from 'node:fs/promises';
import { fileURLToPath, pathToFileURL } from 'node:url';
import sharp from 'sharp';
import { recoveryFixture } from '../tests/recovery_fixture.mjs';

const { chromium } = await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href);
const browser = await chromium.launch({ executablePath: process.env.CHROME_PATH, headless: true });
const server = await recoveryFixture();
const output = new URL('../../mobile/build/ui-preview/map-pins/web/', import.meta.url);
await mkdir(output, { recursive: true });
try {
  const context = await browser.newContext();
  const tile = await sharp({ create: { width: 256, height: 256, channels: 3, background: '#edf0ec' } }).png().toBuffer();
  await context.route('https://basemaps.cartocdn.com/**', route => route.fulfill({ contentType: 'image/png', body: tile }));
  const page = await context.newPage(), errors = [];
  page.on('pageerror', error => errors.push(error.message));
  page.on('console', message => { if (/Content Security Policy|Refused to|[Hh]ydration.*mismatch/.test(message.text())) errors.push(message.text()); });
  await page.goto(server.origin + '/iniciar-sesion');
  await page.getByLabel('Correo', { exact: true }).fill('ordinario@example.test');
  await page.getByLabel('Contraseña', { exact: true }).fill('test-fixture-password');
  await page.getByLabel('Contraseña', { exact: true }).press('Enter');
  await page.waitForURL('**/inicio');
  await page.goto(server.origin + '/reportar');
  const map = page.locator('.location-map.leaflet-container');
  await map.waitFor();
  for (const [name, width, enlarged, reduced] of [['desktop', 1440, false, false], ['mobile', 390, false, false], ['small-text200-reduced', 320, true, true]]) {
    await page.setViewportSize({ width, height: 900 });
    await page.emulateMedia({ reducedMotion: reduced ? 'reduce' : 'no-preference' });
    await page.evaluate(value => { document.documentElement.style.fontSize = value ? '200%' : '100%'; }, enlarged);
    await map.scrollIntoViewIfNeeded();
    await map.click({ position: { x: 100, y: 100 } });
    const marker = page.locator('.location-map-pin');
    await marker.waitFor();
    const info = await marker.evaluate(async image => {
      await image.decode();
      const markerRect = image.getBoundingClientRect(), mapRect = image.closest('.location-map').getBoundingClientRect();
      return { width: markerRect.width, height: markerRect.height, x: markerRect.x + markerRect.width / 2 - mapRect.x, y: markerRect.y + markerRect.height / 2 - mapRect.y, naturalWidth: image.naturalWidth, naturalHeight: image.naturalHeight, src: image.getAttribute('src') };
    });
    assert.equal(info.width, 48); assert.equal(info.height, 56);
    assert.equal(info.naturalWidth, 48); assert.equal(info.naturalHeight, 56);
    assert.equal(info.src, '/map-location-pin.svg');
    const bounds = await map.boundingBox();
    assert.ok(Math.abs(info.x - bounds.width / 2) <= 1 && Math.abs(info.y - bounds.height / 2) <= 1, 'Selection must stay centered after panTo');
    assert.equal(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), true);
    const pinSource = await (await context.request.get(server.origin + info.src)).text();
    assert.equal((pinSource.match(/fill="white"/g) || []).length, 5, 'The complete official mark must render');
    await map.screenshot({ path: fileURLToPath(new URL(name + '.png', output)) });
    await marker.screenshot({ path: fileURLToPath(new URL(name + '-pin.png', output)) });
    // Exercise a second selection via the public keyboard adapter.
    await map.focus();
    await page.keyboard.press('ArrowRight');
    await page.keyboard.press('Enter');
    assert.equal(await marker.count(), 1);
  }
  assert.deepEqual(errors, []);
  await context.close();
  console.log('Map brand pin passed in Chromium: desktop/mobile/text200/reduced, pointer/keyboard, 48×56 centered anchor, local SVG, no overflow/CSP/hydration errors. Tiles and authentication use local fixtures.');
} finally {
  await browser.close();
  await server.close();
}
