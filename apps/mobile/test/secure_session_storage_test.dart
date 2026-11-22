import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_entrehuellas/core/data_sources/secure_session_storage.dart';

class _MemoryStore implements SecureValueStore {
  final values = <String, String>{};
  bool failWrites = false, failReads = false;

  @override
  Future<String?> read(String key) async {
    if (failReads) throw StateError('keystore');
    return values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    if (failWrites) throw StateError('keystore');
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async => values.remove(key);
}

void main() {
  const key = 'sb-project-auth-token';

  test('Session key matches the SDK default for migration', () {
    expect(
      supabaseSessionKey('https://project.supabase.co'),
      'sb-project-auth-token',
    );
  });

  test('A plain legacy session moves to the secure store once', () async {
    SharedPreferences.setMockInitialValues({key: 'legacy-session'});
    final store = _MemoryStore();
    final storage = SecureSessionStorage(persistSessionKey: key, store: store);

    await storage.initialize();

    expect(store.values[key], 'legacy-session');
    expect((await SharedPreferences.getInstance()).getString(key), isNull);
    expect(await storage.hasAccessToken(), isTrue);
    expect(await storage.accessToken(), 'legacy-session');
  });

  test('An existing secure session wins over a stale legacy copy', () async {
    SharedPreferences.setMockInitialValues({key: 'stale'});
    final store = _MemoryStore()..values[key] = 'current';
    final storage = SecureSessionStorage(persistSessionKey: key, store: store);

    await storage.initialize();

    expect(store.values[key], 'current');
    expect((await SharedPreferences.getInstance()).getString(key), isNull);
  });

  test('A failed migration keeps the legacy copy and never throws', () async {
    SharedPreferences.setMockInitialValues({key: 'legacy-session'});
    final store = _MemoryStore()..failWrites = true;
    final storage = SecureSessionStorage(persistSessionKey: key, store: store);

    await storage.initialize();

    expect(
      (await SharedPreferences.getInstance()).getString(key),
      'legacy-session',
    );
  });

  test('Persist, read and remove use only the secure store', () async {
    SharedPreferences.setMockInitialValues({});
    final store = _MemoryStore();
    final storage = SecureSessionStorage(persistSessionKey: key, store: store);
    await storage.initialize();

    await storage.persistSession('session');
    expect(store.values[key], 'session');
    expect((await SharedPreferences.getInstance()).getKeys(), isEmpty);

    await storage.removePersistedSession();
    expect(await storage.hasAccessToken(), isFalse);
  });

  test('Keystore failures degrade to signed out instead of crashing', () async {
    SharedPreferences.setMockInitialValues({});
    final store = _MemoryStore()
      ..failReads = true
      ..failWrites = true;
    final storage = SecureSessionStorage(persistSessionKey: key, store: store);

    await storage.initialize();
    await storage.persistSession('session');
    expect(await storage.accessToken(), isNull);
    expect(await storage.hasAccessToken(), isFalse);
  });

  test('PKCE verifiers are stored securely and errors propagate', () async {
    final store = _MemoryStore();
    final pkce = SecurePkceStorage(store);

    await pkce.setItem(key: 'verifier', value: 'abc');
    expect(await pkce.getItem(key: 'verifier'), 'abc');
    await pkce.removeItem(key: 'verifier');
    expect(await pkce.getItem(key: 'verifier'), isNull);

    store.failWrites = true;
    expect(pkce.setItem(key: 'verifier', value: 'x'), throwsStateError);
  });
}
