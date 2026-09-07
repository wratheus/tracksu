import 'package:flutter/material.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Same content contract for list entries and a featured/detail header.
final class OsuBeatmapCard extends StatelessWidget {
  const OsuBeatmapCard.compact({
    required this.title,
    this.artist,
    this.difficulty,
    this.cover,
    this.badges = const <Widget>[],
    this.detail,
    this.onTap,
    super.key,
  }) : _featured = false;
  const OsuBeatmapCard.featured({
    required this.title,
    this.artist,
    this.difficulty,
    this.cover,
    this.badges = const <Widget>[],
    this.detail,
    this.onTap,
    super.key,
  }) : _featured = true;
  final String title;
  final String? artist;
  final String? difficulty;
  final ImageProvider? cover;
  final List<Widget> badges;
  final String? detail;
  final VoidCallback? onTap;
  final bool _featured;

  @override
  Widget build(BuildContext context) => UiSurface.card(
    onTap: onTap,
    padding: EdgeInsets.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (_featured) UiCover(image: cover),
        Padding(
          padding: const EdgeInsets.all(UiSpace.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: UiSpace.md,
            children: <Widget>[
              if (!_featured && cover != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(UiShape.control),
                  child: UiImage(image: cover, width: 64, height: 64),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: UiSpace.sm,
                  children: <Widget>[
                    UiText.titleMedium(title),
                    if (artist != null)
                      UiText.bodyMedium(artist!, secondary: true),
                    if (difficulty != null)
                      UiText.bodySmall(
                        difficulty!,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    if (badges.isNotEmpty)
                      Wrap(
                        spacing: UiSpace.sm,
                        runSpacing: UiSpace.sm,
                        children: badges,
                      ),
                    if (detail != null)
                      UiText.bodySmall(detail!, secondary: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
