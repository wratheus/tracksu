import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class ContentMediaStore {
  Future<bool?> readPermission();
  Future<void> writePermission(bool allowed);
}

/// Versioned consent; absent/unrecognised values never grant permission.
final class FlutterSecureContentMediaStore implements ContentMediaStore {
  factory FlutterSecureContentMediaStore({
    required FlutterSecureStorage storage,
  }) => FlutterSecureContentMediaStore._(storage);
  FlutterSecureContentMediaStore._(this._storage);
  final FlutterSecureStorage _storage;
  static const String _key = 'external_content_images_v1';

  @override
  Future<bool?> readPermission() async =>
      switch (await _storage.read(key: _key)) {
        'allowed' => true,
        'denied' => false,
        _ => null,
      };

  @override
  Future<void> writePermission(bool allowed) =>
      _storage.write(key: _key, value: allowed ? 'allowed' : 'denied');
}
