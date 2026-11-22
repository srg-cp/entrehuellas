import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Key-value port over the platform keystore, replaceable in tests.
abstract interface class SecureValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// Android Keystore / iOS Keychain. Tokens stay on this device: they are not
/// restored from backups to another phone, and a corrupt keystore is reset
/// (the user signs in again) instead of blocking startup.
final class KeychainValueStore implements SecureValueStore {
  const KeychainValueStore([
    this._storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        resetOnError: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    ),
  ]);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// Same key supabase_flutter uses for its default SharedPreferences storage,
/// so sessions persisted by earlier builds can be migrated.
String supabaseSessionKey(String supabaseUrl) =>
    'sb-${Uri.parse(supabaseUrl).host.split('.').first}-auth-token';

/// Persists the Supabase session (including the refresh token) encrypted.
/// On first start it moves a session left in plain SharedPreferences by older
/// builds, so updating the app does not sign the user out.
final class SecureSessionStorage extends LocalStorage {
  SecureSessionStorage({
    required this.persistSessionKey,
    SecureValueStore store = const KeychainValueStore(),
    Future<SharedPreferences> Function() legacyPreferences =
        SharedPreferences.getInstance,
  }) : _store = store,
       _legacyPreferences = legacyPreferences;

  final String persistSessionKey;
  final SecureValueStore _store;
  final Future<SharedPreferences> Function() _legacyPreferences;

  @override
  Future<void> initialize() async {
    try {
      final preferences = await _legacyPreferences();
      final legacy = preferences.getString(persistSessionKey);
      if (legacy == null) return;
      if (await _store.read(persistSessionKey) == null) {
        await _store.write(persistSessionKey, legacy);
      }
      // Remove the plain copy only once the encrypted one is stored.
      await preferences.remove(persistSessionKey);
    } catch (_) {
      // Never block startup; an unmigrated session only means signing in again.
    }
  }

  @override
  Future<bool> hasAccessToken() async => await accessToken() != null;

  @override
  Future<String?> accessToken() async {
    try {
      return await _store.read(persistSessionKey);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> removePersistedSession() async {
    try {
      await _store.delete(persistSessionKey);
    } catch (_) {
      // The in-memory session is already cleared by the SDK.
    }
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    try {
      await _store.write(persistSessionKey, persistSessionString);
    } catch (_) {
      // The session stays valid in memory for this run.
    }
  }
}

/// PKCE code verifiers for OAuth, kept out of plain SharedPreferences too.
/// Errors propagate: a missing verifier must fail the sign-in visibly.
final class SecurePkceStorage extends GotrueAsyncStorage {
  const SecurePkceStorage([this._store = const KeychainValueStore()]);

  final SecureValueStore _store;

  @override
  Future<String?> getItem({required String key}) => _store.read(key);

  @override
  Future<void> setItem({required String key, required String value}) =>
      _store.write(key, value);

  @override
  Future<void> removeItem({required String key}) => _store.delete(key);
}
