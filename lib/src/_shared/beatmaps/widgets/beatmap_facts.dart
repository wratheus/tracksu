import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/beatmaps/domain/beatmap_metadata.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Optional facts come from the existing response, never per-card requests.
final class BeatmapFacts extends StatelessWidget {
  const BeatmapFacts({
    this.metadata,
    this.stars,
    this.lengthSeconds,
    this.bpm,
    super.key,
  });
  final BeatmapMetadata? metadata;
  final double? stars;
  final int? lengthSeconds;
  final double? bpm;

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toLanguageTag();
    final NumberFormat number = NumberFormat.decimalPattern(locale);
    final NumberFormat decimal = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 2,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: UiSpace.sm,
      children: <Widget>[
        if (metadata?.creator case final String creator)
          UiText.bodySmall(context.t.beatmapCreator(creator), secondary: true),
        Wrap(
          spacing: UiSpace.md,
          runSpacing: UiSpace.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            if (metadata?.status case final String status)
              UiBadge.neutral(switch (status) {
                'ranked' => context.t.beatmapsRanked,
                'pending' => context.t.beatmapsPending,
                'graveyard' => context.t.beatmapsGraveyard,
                'loved' => context.t.beatmapsLoved,
                _ => status,
              }),
            if (stars case final double value)
              UiBadge.accent('${decimal.format(value)} ★'),
            if (bpm case final double value)
              UiBadge.neutral(
                '${number.format(value)} ${context.t.mapBpm}',
                icon: Icons.speed,
              ),
            if (lengthSeconds case final int value)
              UiBadge.neutral(
                '${value ~/ 60}:${(value % 60).toString().padLeft(2, '0')}',
                icon: Icons.schedule,
              ),
          ],
        ),
        if (metadata?.plays != null || metadata?.favourites != null)
          Wrap(
            spacing: UiSpace.lg,
            runSpacing: UiSpace.sm,
            children: <Widget>[
              if (metadata?.plays case final int value)
                _Fact(
                  icon: Icons.play_circle_outline,
                  label: context.t.mapSetPlays,
                  value: number.format(value),
                ),
              if (metadata?.favourites case final int value)
                _Fact(
                  icon: Icons.favorite_border,
                  label: context.t.mapFavourites,
                  value: number.format(value),
                ),
            ],
          ),
      ],
    );
  }
}

final class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$label: $value',
    excludeSemantics: true,
    child: Tooltip(
      message: label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: UiSpace.xs,
        children: <Widget>[
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          UiText.bodySmall(value, secondary: true),
        ],
      ),
    ),
  );
}
