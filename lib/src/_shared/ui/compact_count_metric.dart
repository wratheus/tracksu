import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/l10n/localized_count.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Full-width, compact typography keeps exact grouped counts readable.
/// Avoid hiding precision behind ambiguous large-unit abbreviations.
final class CompactCountMetric extends StatelessWidget {
  const CompactCountMetric({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
  });
  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toLanguageTag();
    final LocalizedCount count = LocalizedCount(value, locale: locale);
    return Semantics(
      label: label,
      value: count.exact,
      excludeSemantics: true,
      child: Tooltip(
        message: '$label: ${count.exact}',
        child: UiMetric.row(label: label, value: count.exact, icon: icon),
      ),
    );
  }
}
