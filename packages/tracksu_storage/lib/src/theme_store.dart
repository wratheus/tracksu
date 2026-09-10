import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class ThemeStore {
  Future<String?> readMode();
  Future<void> writeMode(String mode);
}

final class FlutterSecureThemeStore implements ThemeStore {
  factory FlutterSecureThemeStore({required FlutterSecureStorage storage}) =>
      FlutterSecureThemeStore._(storage);
  FlutterSecureThemeStore._(this._storage);
  final FlutterSecureStorage _storage;
  static const String _key = 'app_theme_mode';

  @override
  Future<String?> readMode() => _storage.read(key: _key);

  @override
  Future<void> writeMode(String mode) => _storage.write(key: _key, value: mode);
}
