import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Whether the app may keep data between screens and launches (on by
/// default). Null means no explicit choice was saved.
abstract interface class CachePreferenceStore {
  Future<bool?> readEnabled();
  Future<void> writeEnabled(bool enabled);
}

final class FlutterSecureCachePreferenceStore implements CachePreferenceStore {
  const FlutterSecureCachePreferenceStore({
    required FlutterSecureStorage storage,
  }) : _storage = storage;
  final FlutterSecureStorage _storage;
  static const String _key = 'cache_enabled_v1';

  @override
  Future<bool?> readEnabled() async => switch (await _storage.read(key: _key)) {
    'on' => true,
    'off' => false,
    _ => null,
  };

  @override
  Future<void> writeEnabled(bool enabled) =>
      _storage.write(key: _key, value: enabled ? 'on' : 'off');
}
