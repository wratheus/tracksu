import 'package:flutter/material.dart';
import 'package:tracksu/src/_shared/ui/osu_badges.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class OsuPlayCard extends StatelessWidget {
  const OsuPlayCard({
    required this.title,
    required this.grade,
    required this.gradeLabel,
    required this.accuracyLabel,
    required this.comboLabel,
    required this.performanceLabel,
    required this.dateLabel,
    required this.mods,
    required this.noModsLabel,
    this.artist,
    this.difficulty,
    this.totalLabel,
    this.failureLabel,
    this.cover,
    this.onTap,
    super.key,
  });
  final String title;
  final String grade;
  final String gradeLabel;
  final String accuracyLabel;
  final String comboLabel;
  final String performanceLabel;
  final String dateLabel;
  final String? artist;
  final String? difficulty;
  final String? totalLabel;
  final String? failureLabel;
  final List<String> mods;
  final String noModsLabel;
  final ImageProvider? cover;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => UiSurface.card(
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: UiSpace.sm,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: UiSpace.md,
          children: <Widget>[
            if (cover != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(UiShape.control),
                child: UiImage(image: cover, width: 56, height: 56),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: UiSpace.xs,
                children: <Widget>[
                  UiText.titleMedium(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (artist != null)
                    UiText.bodySmall(
                      artist!,
                      secondary: true,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (difficulty != null)
                    UiText.bodySmall(
                      difficulty!,
                      color: Theme.of(context).colorScheme.tertiary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (onTap != null) const Icon(Icons.chevron_right, size: 20),
          ],
        ),
        Wrap(
          spacing: UiSpace.md,
          runSpacing: UiSpace.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            OsuGradeBadge(grade: grade, label: gradeLabel),
            UiText.titleMedium(
              performanceLabel,
              color: Theme.of(context).colorScheme.primary,
            ),
            UiText.bodyMedium(accuracyLabel),
            UiText.bodyMedium(comboLabel, secondary: true),
          ],
        ),
        OsuMods(mods: mods, emptyLabel: noModsLabel),
        if (failureLabel != null)
          UiBadge.negative(failureLabel!, icon: Icons.close),
        if (totalLabel != null) UiText.bodySmall(totalLabel!, secondary: true),
        UiText.bodySmall(dateLabel, secondary: true),
      ],
    ),
  );
}
