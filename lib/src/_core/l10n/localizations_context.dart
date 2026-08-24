import 'package:flutter/widgets.dart';
import 'package:tracksu/src/_core/l10n/generated/app_localizations.dart';

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get t => AppLocalizations.of(this)!;
}
