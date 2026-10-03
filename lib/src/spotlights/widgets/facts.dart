import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/spotlights/domain/spotlight.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Localized name of a spotlight kind; null for values the app does not know.
String? spotlightKindLabel(BuildContext context, SpotlightKind kind) =>
    switch (kind) {
      SpotlightKind.monthly => context.t.spotlightsKindMonthly,
      SpotlightKind.bestOf => context.t.spotlightsKindBestOf,
      SpotlightKind.special => context.t.spotlightsKindSpecial,
      SpotlightKind.theme => context.t.spotlightsKindTheme,
      SpotlightKind.other => null,
    };

/// Kind and the two staff-entered dates, each shown on its own like osu-web.
/// Dates are not joined into a range: their order is not guaranteed.
final class SpotlightFacts extends StatelessWidget {
  const SpotlightFacts({required this.spotlight, super.key});
  final Spotlight spotlight;

  @override
  Widget build(BuildContext context) {
    final String? kind = spotlightKindLabel(context, spotlight.kind);
    // Published UTC calendar dates, not local event times.
    final DateFormat date = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    );
    final List<String> dates = <String>[
      if (spotlight.startDate case final DateTime start)
        context.t.spotlightsStartDate(date.format(start)),
      if (spotlight.endDate case final DateTime end)
        context.t.spotlightsEndDate(date.format(end)),
    ];
    if (kind == null && dates.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: UiSpace.sm,
      children: <Widget>[
        if (kind != null)
          UiBadge.accent(kind, icon: Icons.collections_bookmark_outlined),
        for (final String line in dates)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: UiSpace.sm,
            children: <Widget>[
              const ExcludeSemantics(
                child: Icon(Icons.event_outlined, size: 18),
              ),
              Expanded(child: UiText.bodySmall(line, secondary: true)),
            ],
          ),
      ],
    );
  }
}
