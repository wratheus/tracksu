import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/generated/app_localizations.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/ui/osu_ui.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

enum AppLanguage {
  system(null, null),
  english('en', 'GB'),
  russian('ru', 'RU'),
  german('de', 'DE'),
  french('fr', 'FR'),
  spanish('es', 'ES'),
  japanese('ja', 'JP'),
  chinese('zh', 'CN');

  const AppLanguage(this.code, this.country);
  final String? code;
  final String? country;

  static AppLanguage fromLocale(Locale? locale) => values.firstWhere(
    (AppLanguage language) => language.code == locale?.languageCode,
    orElse: () => system,
  );

  String label(AppLocalizations t) => switch (this) {
    system => t.systemLanguage,
    english => t.englishLanguage,
    russian => t.russianLanguage,
    german => t.germanLanguage,
    french => t.frenchLanguage,
    spanish => t.spanishLanguage,
    japanese => t.japaneseLanguage,
    chinese => t.chineseLanguage,
  };
}

abstract final class LanguagePicker {
  static Future<void> show(BuildContext context) async {
    final controller = DepsScope.of(context).localeController;
    final AppLanguage selected = AppLanguage.fromLocale(controller.value);
    final AppLanguage? choice = await UiModal.scrollable<AppLanguage>(
      context,
      title: context.t.languageSelection,
      builder: (BuildContext sheetContext) => ListView.builder(
        primary: true,
        itemCount: AppLanguage.values.length,
        itemBuilder: (BuildContext context, int index) {
          final AppLanguage language = AppLanguage.values[index];
          return UiTile.selection(
            title: language.label(context.t),
            selected: language == selected,
            leading: AppLanguageIcon(language: language),
            onTap: () => Navigator.of(sheetContext).pop(language),
          );
        },
      ),
    );
    if (!context.mounted || choice == null || choice == selected) return;
    try {
      await controller.select(
        choice.code == null ? null : Locale(choice.code!),
      );
    } on Object {
      if (context.mounted) {
        UiFeedback.snack(context, message: context.t.languageChangeFailed);
      }
    }
  }
}

/// Same flag in the choice list and the persisted settings selection.
final class AppLanguageIcon extends StatelessWidget {
  const AppLanguageIcon({required this.language, super.key});
  final AppLanguage language;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: language.country == null
        ? const Icon(Icons.language)
        : OsuCountryFlag(
            code: language.country!,
            label: language.label(context.t),
          ),
  );
}
