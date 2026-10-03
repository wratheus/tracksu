import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracksu/src/_core/l10n/generated/app_localizations.dart';
import 'package:tracksu/src/_shared/preferences/language_picker.dart';

void main() {
  const List<String> autonyms = <String>[
    'English',
    'Русский',
    'Deutsch',
    'Français',
    'Español',
    '日本語',
    '中文',
  ];

  test('every UI locale shows languages as unchanged autonyms', () {
    for (final Locale locale in AppLocalizations.supportedLocales) {
      final AppLocalizations t = lookupAppLocalizations(locale);

      final List<String> labels = <String>[
        for (final AppLanguage language in AppLanguage.values)
          if (language != AppLanguage.system) language.label(t),
      ];

      expect(labels, autonyms, reason: locale.toLanguageTag());
    }
  });

  test('System stays localized in every UI locale', () {
    final Set<String> systemLabels = <String>{};

    for (final Locale locale in AppLocalizations.supportedLocales) {
      final AppLocalizations t = lookupAppLocalizations(locale);
      expect(AppLanguage.system.label(t), t.systemLanguage);
      systemLabels.add(AppLanguage.system.label(t));
    }

    expect(AppLocalizations.supportedLocales, hasLength(7));
    expect(systemLabels.length, greaterThan(1));
  });

  test('locale codes and order are unchanged', () {
    expect(
      <String?>[
        for (final AppLanguage language in AppLanguage.values) language.code,
      ],
      <String?>[null, 'en', 'ru', 'de', 'fr', 'es', 'ja', 'zh'],
    );
    expect(AppLanguage.fromLocale(const Locale('ja')), AppLanguage.japanese);
    expect(AppLanguage.fromLocale(null), AppLanguage.system);
  });
}
