import 'package:intl/intl.dart';

/// Integer quantities use CLDR units, not hard-coded English K/M suffixes.
final class LocalizedCount {
  LocalizedCount(int value, {required String locale})
    : exact = NumberFormat.decimalPattern(locale).format(value),
      compact = (NumberFormat.compact(
        locale: locale,
      )..maximumFractionDigits = 1).format(value);
  final String exact;
  final String compact;
}
