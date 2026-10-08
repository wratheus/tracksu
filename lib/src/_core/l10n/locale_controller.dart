import 'package:flutter/widgets.dart';
import 'package:tracksu/src/_core/l10n/generated/app_localizations.dart';
import 'package:tracksu_storage/tracksu_storage.dart';

final class LocaleController extends ValueNotifier<Locale?>
    with WidgetsBindingObserver {
  factory LocaleController({required LocaleStore localeStore}) {
    return LocaleController._(localeStore);
  }

  LocaleController._(this._localeStore) : super(null);

  final LocaleStore _localeStore;

  Future<void> restore() async {
    final String? languageCode = await _localeStore.readLanguageCode();
    value = _localeFromLanguageCode(languageCode);
    WidgetsBinding.instance.addObserver(this);
  }

  /// Following the system language: a system change is a language change
  /// for listeners too (API header, page cache).
  @override
  void didChangeLocales(List<Locale>? locales) {
    if (value == null) notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> select(Locale? locale) async {
    if (locale == null) {
      await _localeStore.clear();
      value = null;
      return;
    }

    final Locale selectedLocale =
        _localeFromLanguageCode(locale.languageCode) ??
        (throw ArgumentError.value(locale, 'locale', 'Unsupported locale.'));
    await _localeStore.writeLanguageCode(selectedLocale.languageCode);
    value = selectedLocale;
  }

  /// The language the interface actually shows: the saved choice, else the
  /// system language when supported, else English (Flutter's resolution).
  String get effectiveLanguageCode =>
      value?.languageCode ??
      _localeFromLanguageCode(
        WidgetsBinding.instance.platformDispatcher.locale.languageCode,
      )?.languageCode ??
      'en';

  Locale? _localeFromLanguageCode(String? languageCode) {
    for (final Locale locale in AppLocalizations.supportedLocales) {
      if (locale.languageCode == languageCode) {
        return locale;
      }
    }
    return null;
  }
}
