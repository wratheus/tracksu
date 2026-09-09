import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/rankings/spotlights/domain/spotlight.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class SpotlightPeriod extends StatelessWidget {
  const SpotlightPeriod({required this.spotlight, super.key});
  final Spotlight spotlight;
  @override
  Widget build(BuildContext context) {
    final DateTime? start = spotlight.startsAt;
    final DateTime? end = spotlight.endsAt;
    if (start == null && end == null) return const SizedBox.shrink();
    // Catalogue dates are a published calendar period, not local event times.
    final DateFormat date = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    );
    final String label = start != null && end != null
        ? context.t.spotlightsPeriod(date.format(start), date.format(end))
        : start != null
        ? context.t.spotlightsStarts(date.format(start))
        : context.t.spotlightsEnds(date.format(end!));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: UiSpace.sm,
      children: <Widget>[
        const ExcludeSemantics(
          child: Icon(Icons.date_range_outlined, size: 18),
        ),
        Expanded(child: UiText.bodySmall(label, secondary: true)),
      ],
    );
  }
}
