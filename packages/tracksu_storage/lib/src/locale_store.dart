abstract interface class LocaleStore {
  Future<String?> readLanguageCode();

  Future<void> writeLanguageCode(String languageCode);

  Future<void> clear();
}
