import assert from 'node:assert/strict';
import { mkdir, writeFile } from 'node:fs/promises';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { recoveryFixture } from '../tests/recovery_fixture.mjs';
import { chooseField } from './field-browser-helpers.mjs';

const { chromium } = await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href);
const browser = await chromium.launch({ executablePath: process.env.CHROME_PATH, headless: true });
const server = await recoveryFixture();
const output = new URL('../../mobile/build/ui-preview/web-home/', import.meta.url);
await mkdir(output, { recursive: true });
try {
  const context = await browser.newContext({ viewport: { width: 1440, height: 1000 }, reducedMotion: 'reduce' });
  const page = await context.newPage(), errors = [];
  page.setDefaultTimeout(20000);
  page.on('dialog', dialog => dialog.accept());
  page.on('pageerror', error => errors.push(error.message));
  page.on('console', message => {
    if (/Content Security Policy|Refused to|[Hh]ydration.*mismatch/.test(message.text())) errors.push(message.text());
  });
  await page.route('https://basemaps.cartocdn.com/**', route => route.fulfill({ status: 200, contentType: 'image/jpeg', body: server.jpeg }));
  await page.goto(server.origin + '/inicio');
  await page.waitForURL('**/iniciar-sesion');
  async function login(email) {
    await page.getByLabel('Correo', { exact: true }).fill(email);
    await page.getByLabel('Contraseña', { exact: true }).fill('test-fixture-password');
    await page.getByLabel('Contraseña', { exact: true }).press('Enter');
    await page.waitForURL('**/inicio');
    await page.getByRole('heading', { name: 'Su regreso empieza contigo', exact: true }).waitFor();
    await page.evaluate(() => document.fonts.ready);
  }
  async function home() {
    await page.waitForURL('**/inicio');
    await page.getByRole('heading', { name: 'Su regreso empieza contigo', exact: true }).waitFor();
  }
  async function readyImages() {
    for (const image of await page.locator('.home-banner img').all()) {
      await image.scrollIntoViewIfNeeded();
      await image.evaluate(async element => { await element.decode(); });
      assert.equal(await image.evaluate(element => element.naturalWidth > 0 && element.alt === ''), true);
    }
  }
  await login('ordinario@example.test');
  await page.waitForFunction(() => document.querySelector('.account-grid')?.getAttribute('aria-busy') === 'false');
  assert.equal(await page.getByRole('link', { name: 'Revisar denuncias', exact: true }).count(), 0);
  assert.equal(await page.locator('a[href="/terminos"], a[href="/privacidad"]').count(), 0);
  assert.equal(await page.locator('.home-shortcuts, .home-reunion').count(), 0);
  assert.equal(await page.locator('.home-banner img').count(), 4);
  assert.equal(await page.locator('.home-title span').evaluate(element => getComputedStyle(element).fontWeight), '600');
  assert.match(await page.locator('.home-title').evaluate(element => getComputedStyle(element).fontFamily), /Poppins/);

  for (const [width, height, size, name] of [
    [1920, 1080, '100%', 'wide'], [1440, 1000, '100%', 'desktop'],
    [900, 1000, '100%', 'tablet'], [390, 844, '100%', 'mobile'],
    [320, 640, '100%', 'small'], [320, 700, '200%', 'text200'],
    [1440, 1000, '200%', 'desktop-text200'],
  ]) {
    await page.setViewportSize({ width, height });
    await page.evaluate(size => { document.documentElement.style.fontSize = size; }, size);
    await readyImages();
    await page.evaluate(() => window.scrollTo(0, 0));
    assert.equal(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), true, name + ' overflow');
    const report = await page.locator('.home-report').boundingBox();
    const found = await page.locator('.home-found').boundingBox();
    const photo = await page.locator('.home-photo').boundingBox();
    assert.ok(width > 850 ? found.x >= report.x + report.width : found.y >= report.y + report.height, name + ' composition');
    assert.ok(photo.y >= found.y + found.height, name + ' photo order');
    for (const text of await page.locator('.home-banner h2, .home-banner p').all()) {
      assert.equal(await text.evaluate(element => element.scrollWidth <= element.clientWidth + 1), true, name + ' text clipping');
    }
    for (const action of await page.locator('.home-banner-action, .home-pets-link, .home-photo-link').all()) {
      const box = await action.boundingBox();
      assert.ok(box.height >= 48 && box.width >= 48, name + ' touch target');
      assert.equal(await action.evaluate(element => element.scrollWidth <= element.clientWidth + 1), true, name + ' action overflow');
    }
    const brand = await page.locator('.account-header .site-brand').boundingBox();
    const actions = await page.locator('.account-header-actions').boundingBox();
    assert.ok(brand.x + brand.width <= actions.x || brand.y + brand.height <= actions.y, name + ' header overlap');
    await page.screenshot({ path: fileURLToPath(new URL(name + '.png', output)), fullPage: true });
    if (width === 390 && size === '100%') {
      await page.screenshot({ path: fileURLToPath(new URL('mobile-top.png', output)) });
      await page.locator('.home-found').scrollIntoViewIfNeeded();
      await page.screenshot({ path: fileURLToPath(new URL('mobile-scroll.png', output)) });
    }
  }
  await page.evaluate(() => { document.documentElement.style.fontSize = '100%'; window.scrollTo(0, 0); });
  await page.setViewportSize({ width: 1440, height: 1000 });
  await page.getByRole('button', { name: 'Abrir perfil', exact: true }).click();
  await page.getByText('ordinario@example.test', { exact: true }).waitFor();
  await page.keyboard.press('Escape');
  assert.equal(await page.getByRole('dialog', { name: 'Tu cuenta', exact: true }).count(), 0);

  for (const [selector, path] of [
    ['.home-pets-link', '/mis-mascotas'],
    ['.home-explore .home-banner-action', '/explorar'],
    ['.home-report .home-banner-action', '/reportar'],
    ['.home-found .home-banner-action', '/reportar?tipo=hallazgo'],
    ['.home-photo-link', '/coincidencias'],
  ]) {
    const trigger = page.locator(selector);
    await trigger.focus();
    await page.keyboard.press('Enter');
    await page.waitForURL(url => url.pathname + url.search === path);
    if (path.startsWith('/reportar')) {
      const kind = page.getByRole('combobox', { name: '¿Cómo quieres ayudar?', exact: true });
      await kind.waitFor();
      assert.match(await kind.innerText(), path.includes('hallazgo') ? /Encontré una mascota y no sé de quién es/ : /Se perdió mi mascota/);
      await page.getByRole('button', { name: 'Cerrar reporte', exact: true }).click();
      assert.equal(await page.getByRole('dialog').count(), 0, 'Untouched initial kind is not dirty');
    } else if (path === '/coincidencias') {
      await page.getByRole('button', { name: 'Volver a inicio', exact: true }).click();
    } else {
      await page.getByRole('navigation', { name: 'Navegación de usuario', exact: true }).getByRole('link', { name: 'Inicio', exact: true }).click();
    }
    await home();
  }

  // Observe normal playback without pausing navigation or its route guards.
  await page.emulateMedia({ reducedMotion: 'no-preference' });
  await page.goto(server.origin + '/inicio');
  await home();
  for (const width of [1440, 390]) {
    await page.setViewportSize({ width, height: 1000 });
    for (const selector of ['.home-report .home-banner-action', '.home-found .home-banner-action']) {
      await readyImages();
      const trigger = page.locator(selector);
      await trigger.evaluate(node => node.scrollIntoView({ block: 'center', behavior: 'instant' }));
      await page.waitForTimeout(500);
      await page.evaluate(() => {
        window.homeFrames = [];
        window.homeSampling = true;
        const sample = () => {
          const node = document.querySelector('main[data-origin-animating]');
          if (node?._flip) {
            const rect = node.getBoundingClientRect();
            window.homeFrames.push({ phase:node.dataset.originAnimating, width:rect.width, height:rect.height, duration:node._flip.duration(), identity:!!node.querySelector('[data-origin-identity] svg') });
          }
          if (window.homeSampling) requestAnimationFrame(sample);
        };
        requestAnimationFrame(sample);
      });
      await trigger.click();
      await page.waitForURL('**/reportar*');
      await page.waitForFunction(() => !document.querySelector('[data-origin-animating], main[inert]'));
      await page.getByRole('button', { name: 'Cerrar reporte', exact: true }).click();
      await home();
      await page.waitForFunction(() => !document.querySelector('[data-origin-animating], main[inert]'));
      const frames = await page.evaluate(() => { window.homeSampling = false; return window.homeFrames; });
      await writeFile(new URL(`${width}-${selector.includes('found') ? 'found' : 'report'}-motion.json`, output), JSON.stringify(frames, null, 2));
      for (const phase of ['opening', 'closing']) {
        const selected = frames.filter(frame => frame.phase === phase);
        assert.ok(selected.length > 2, selector + ' animated ' + phase);
        assert.ok(selected.every(frame => frame.duration === .7 && frame.identity), selector + ' duration and source identity');
        assert.ok(Math.max(...selected.map(frame => frame.width)) - Math.min(...selected.map(frame => frame.width)) > 50, selector + ' surface transforms');
      }
      assert.equal(await page.locator('[data-origin-animating], [data-origin-identity], .origin-transition-previous > *').count(), 0);
    }
  }
  await page.emulateMedia({ reducedMotion: 'reduce' });

  // A saved report takes precedence over a suggested kind; a Home click must not erase it.
  await page.locator('.home-report .home-banner-action').click();
  await page.getByRole('combobox', { name: '¿Cómo quieres ayudar?', exact: true }).waitFor();
  await chooseField(page, '¿Cómo quieres ayudar?', 'Vi una mascota posiblemente perdida');
  await page.getByLabel('Rasgos distintivos', { exact: true }).fill('Borrador conservado al abrir desde Inicio');
  await page.getByRole('button', { name: 'Guardar borrador', exact: true }).click();
  await page.getByText('Borrador guardado en este navegador para tu cuenta.', { exact: true }).waitFor();
  // Full reload simulates leaving and returning without changing the persisted draft.
  await page.goto(server.origin + '/inicio');
  await home();
  await page.locator('.home-found .home-banner-action').click();
  await page.getByText('Restauramos tu borrador de este navegador.', { exact: true }).waitFor();
  assert.match(await page.getByRole('combobox', { name: '¿Cómo quieres ayudar?', exact: true }).innerText(), /Vi una mascota posiblemente perdida/);
  assert.equal(await page.getByLabel('Rasgos distintivos', { exact: true }).inputValue(), 'Borrador conservado al abrir desde Inicio');
  await page.goto(server.origin + '/inicio');
  await home();
  await page.getByRole('button', { name: 'Cerrar sesión', exact: true }).click();
  await page.waitForURL('**/iniciar-sesion*');
  await login('moderador@example.test');
  await page.getByRole('link', { name: 'Revisar denuncias', exact: true }).waitFor();
  await page.screenshot({ path: fileURLToPath(new URL('moderator.png', output)), fullPage: true });
  assert.deepEqual(errors, []);
  await context.close();
  console.log('Home banners PASS: 1920/1440/900/390/320, text200, local images/fonts, keyboard/targets, source links/return, fresh hallazgo and saved draft preservation, anonymous access, account and management permissions.');
} finally { await browser.close(); await server.close(); }
