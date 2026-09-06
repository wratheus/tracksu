import 'package:flutter/widgets.dart';
import 'package:tracksu/src/_core/l10n/generated/app_localizations.dart';
import 'package:tracksu_storage/tracksu_storage.dart';

final class LocaleController extends ValueNotifier<Locale?> {
  factory LocaleController({required LocaleStore localeStore}) {
    return LocaleController._(localeStore);
  }

  LocaleController._(this._localeStore) : super(null);

  final LocaleStore _localeStore;

  Future<void> restore() async {
    final String? languageCode = await _localeStore.readLanguageCode();
    value = _localeFromLanguageCode(languageCode);
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

  Locale? _localeFromLanguageCode(String? languageCode) {
    for (final Locale locale in AppLocalizations.supportedLocales) {
      if (locale.languageCode == languageCode) {
        return locale;
      }
    }
    return null;
  }
}
