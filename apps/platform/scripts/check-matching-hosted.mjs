// Read-only hosted preflight. Does not publish cases, compare photos or save reviews.
// Existing QA refresh tokens are rotated only in the ignored local config.
import { readFile, writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';

const configPath = resolve(process.argv[2] || '../mobile/config/profile_test.local.json');
const config = JSON.parse(await readFile(configPath, 'utf8'));
const release = JSON.parse(await readFile(resolve('../mobile/config/release.local.json'), 'utf8'));
const origin = new URL(process.argv[3] || release.PUBLIC_CASE_WEB_URL);
const backend = new URL(config.SUPABASE_URL);
for (const url of [origin, backend]) {
  if (url.protocol !== 'https:' || url.username || url.password || url.search || url.hash || url.pathname !== '/') {
    throw new Error('Validation requires HTTPS origins without credentials, paths or parameters');
  }
}
const checks = [], actors = [];
const record = (name, passed, details = {}) => checks.push({ name, passed, ...details });
const request = (url, options = {}) => fetch(url, {
  ...options, redirect: 'manual', signal: AbortSignal.timeout(20000),
});
const post = (path, headers = {}, body = {}) => request(new URL(path, origin), {
  method: 'POST', headers: { 'Content-Type': 'application/json', ...headers }, body: JSON.stringify(body),
});

for (const [name, path, expected] of [
  ['hosted-health', '/health', [200]],
  ['anonymous-page-redirect', '/coincidencias', [302, 303]],
]) {
  try {
    const response = await request(new URL(path, origin));
    record(name, expected.includes(response.status), { status: response.status });
    await response.body?.cancel();
  } catch { record(name, false, { error: 'network-unavailable' }); }
}
for (const [name, headers, expected] of [
  ['anonymous-native-rejected', {}, 403],
  ['invalid-token-rejected', { Authorization: 'Bearer ' + 'x'.repeat(30) }, 401],
]) {
  try {
    const response = await post('/api/app/matching/searches', headers);
    record(name, response.status === expected, { status: response.status });
    await response.body?.cancel();
  } catch { record(name, false, { error: 'network-unavailable' }); }
}
for (const suffix of ['A', 'B']) {
  try {
    const refreshKey = 'PROFILE_TEST_REFRESH_TOKEN_' + suffix;
    const refresh = config[refreshKey];
    const password = config['PROFILE_TEST_PASSWORD_' + suffix];
    if (!refresh && !password) { record('account-' + suffix, false, { error: 'missing-local-credentials' }); continue; }
    const grant = refresh ? 'refresh_token' : 'password';
    const response = await request(new URL('/auth/v1/token?grant_type=' + grant, backend), {
      method: 'POST', headers: { apikey: config.SUPABASE_PUBLISHABLE_KEY, 'Content-Type': 'application/json' },
      body: JSON.stringify(refresh ? { refresh_token: refresh } : { email: config['PROFILE_TEST_EMAIL_' + suffix], password }),
    });
    const session = await response.json().catch(() => null);
    if (!response.ok || !session?.access_token || !session?.user?.id) {
      record('account-' + suffix, false, { status: response.status, error: 'qa-authentication-failed' });
      continue;
    }
    if (refresh && session.refresh_token) {
      config[refreshKey] = session.refresh_token;
      await writeFile(configPath, JSON.stringify(config, null, 2) + '\n');
    }
    actors.push(session.user.id);
    const searches = await post('/api/app/matching/searches', { Authorization: 'Bearer ' + session.access_token });
    const body = await searches.json().catch(() => null);
    const safe = Array.isArray(body) && !/"(?:owner|embedding|path|email|score|photos)"/.test(JSON.stringify(body));
    record('account-' + suffix + '-searches', searches.status === 200 && safe, {
      status: searches.status, searchCount: Array.isArray(body) ? body.length : undefined,
    });
  } catch { record('account-' + suffix, false, { error: 'preflight-unavailable' }); }
}
record('two-distinct-qa-accounts', actors.length === 2 && new Set(actors).size === 2);
const passed = checks.every(check => check.passed);
console.log(JSON.stringify({ origin: origin.origin, passed, checks,
  scope: 'Hosted availability, access rejection and authenticated search listing only. Full publication/comparison/review demo and model quality require separate evidence.',
}, null, 2));
if (!passed) process.exitCode = 1;
