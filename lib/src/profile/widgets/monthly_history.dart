import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/profile/domain/profile.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Both API monthly series use real calendar positions, never inferred zeros.
final class ProfileMonthlyChart extends StatelessWidget {
  const ProfileMonthlyChart({
    required this.history,
    required this.title,
    super.key,
  });
  final ProfileMonthlyHistory history;
  final String title;

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toLanguageTag();
    final NumberFormat number = NumberFormat.decimalPattern(locale);
    final List<ProfileMonthlyCount> months = history.months;
    int ordinal(DateTime month) => month.year * 12 + month.month;
    return UiSurface.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: UiSpace.sm,
        children: <Widget>[
          UiChart.line(
            title: title,
            tone: UiChartTone.tertiary,
            emptyLabel: context.t.profileHistoryEmpty,
            points: <UiChartPoint>[
              for (int i = 0; i < months.length; i++)
                UiChartPoint(
                  x: ordinal(months[i].month).toDouble(),
                  value: months[i].count.toDouble(),
                  label: DateFormat.yMMM(locale).format(months[i].month),
                  valueLabel: number.format(months[i].count),
                  breakBefore:
                      i > 0 &&
                      ordinal(months[i].month) !=
                          ordinal(months[i - 1].month) + 1,
                ),
            ],
          ),
          UiText.bodySmall(
            context.t.profileReplayHistoryExplanation,
            secondary: true,
          ),
        ],
      ),
    );
  }
}
