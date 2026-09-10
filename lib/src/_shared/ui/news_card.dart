import 'package:flutter/material.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class OsuNewsCard extends StatelessWidget {
  const OsuNewsCard({
    required this.title,
    required this.authorLabel,
    required this.dateLabel,
    this.preview,
    this.cover,
    this.coverContent,
    this.onTap,
    super.key,
  }) : assert(cover == null || coverContent == null);
  final String title;
  final String authorLabel;
  final String dateLabel;
  final String? preview;
  final ImageProvider? cover;

  /// A policy-controlled image slot, e.g. an external-content preview.
  final Widget? coverContent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => UiSurface.card(
    padding: EdgeInsets.zero,
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (cover != null) UiCover(image: cover),
        ?coverContent,
        Padding(
          padding: const EdgeInsets.all(UiSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: UiSpace.sm,
            children: <Widget>[
              UiText.bodySmall(dateLabel, secondary: true),
              UiText.titleLarge(title),
              UiText.labelMedium(
                authorLabel,
                color: Theme.of(context).colorScheme.primary,
              ),
              if (preview != null)
                UiText.bodyMedium(
                  preview!,
                  secondary: true,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
