import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tracksu_storage/src/locale_store.dart';

final class FlutterSecureLocaleStore implements LocaleStore {
  factory FlutterSecureLocaleStore({required FlutterSecureStorage storage}) {
    return FlutterSecureLocaleStore._(storage);
  }

  FlutterSecureLocaleStore._(this._storage);

  static const _languageCodeKey = 'app_locale_language_code';

  final FlutterSecureStorage _storage;

  @override
  Future<void> clear() {
    return _storage.delete(key: _languageCodeKey);
  }

  @override
  Future<String?> readLanguageCode() {
    return _storage.read(key: _languageCodeKey);
  }

  @override
  Future<void> writeLanguageCode(String languageCode) {
    return _storage.write(key: _languageCodeKey, value: languageCode);
  }
}
