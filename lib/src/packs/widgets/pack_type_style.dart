import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/packs/domain/packs.dart';

/// Name, one-line description, icon and accent of each pack type, shared by
/// the Home shelf, the type picker and pack headers.
extension BeatmapPackTypeStyle on BeatmapPackType {
  String label(BuildContext context) => switch (this) {
    BeatmapPackType.standard => context.t.packsTypeStandard,
    BeatmapPackType.featured => context.t.packsTypeFeatured,
    BeatmapPackType.tournament => context.t.packsTypeTournament,
    BeatmapPackType.loved => context.t.packsTypeLoved,
    BeatmapPackType.chart => context.t.packsTypeChart,
    BeatmapPackType.theme => context.t.packsTypeTheme,
    BeatmapPackType.artist => context.t.packsTypeArtist,
  };

  String hint(BuildContext context) => switch (this) {
    BeatmapPackType.standard => context.t.packsHintStandard,
    BeatmapPackType.featured => context.t.packsHintFeatured,
    BeatmapPackType.tournament => context.t.packsHintTournament,
    BeatmapPackType.loved => context.t.packsHintLoved,
    BeatmapPackType.chart => context.t.packsHintChart,
    BeatmapPackType.theme => context.t.packsHintTheme,
    BeatmapPackType.artist => context.t.packsHintArtist,
  };

  IconData get icon => switch (this) {
    BeatmapPackType.standard => Icons.library_music_outlined,
    BeatmapPackType.featured => Icons.mic_external_on_outlined,
    BeatmapPackType.tournament => Icons.emoji_events_outlined,
    BeatmapPackType.loved => Icons.favorite_border_rounded,
    BeatmapPackType.chart => Icons.insights_rounded,
    BeatmapPackType.theme => Icons.palette_outlined,
    BeatmapPackType.artist => Icons.album_outlined,
  };

  /// A hue per type; tiles and tag chips tint with it.
  Color get accent => switch (this) {
    BeatmapPackType.standard => const Color(0xFF66A3FF),
    BeatmapPackType.featured => const Color(0xFFFF66AA),
    BeatmapPackType.tournament => const Color(0xFFE8B84A),
    BeatmapPackType.loved => const Color(0xFFFF6B7A),
    BeatmapPackType.chart => const Color(0xFF4FD1C5),
    BeatmapPackType.theme => const Color(0xFFB388FF),
    BeatmapPackType.artist => const Color(0xFFFF9F59),
  };

  /// Pack tags start with the type's letter (osu-web `BeatmapPack::TYPES`).
  static BeatmapPackType? ofTag(String tag) => switch (tag.characters.first) {
    'S' => BeatmapPackType.standard,
    'F' => BeatmapPackType.featured,
    'P' => BeatmapPackType.tournament,
    'L' => BeatmapPackType.loved,
    'R' => BeatmapPackType.chart,
    'T' => BeatmapPackType.theme,
    'A' => BeatmapPackType.artist,
    _ => null,
  };
}

/// The pack tag in a chamfered chip tinted with the type's accent.
final class BeatmapPackTag extends StatelessWidget {
  const BeatmapPackTag({required this.tag, super.key});
  final String tag;

  @override
  Widget build(BuildContext context) {
    final Color accent =
        BeatmapPackTypeStyle.ofTag(tag)?.accent ??
        Theme.of(context).colorScheme.primary;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: accent.withValues(alpha: 0.16),
        shape: BeveledRectangleBorder(
          side: BorderSide(color: accent.withValues(alpha: 0.5)),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            bottomRight: Radius.circular(6),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          tag,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: accent),
        ),
      ),
    );
  }
}
