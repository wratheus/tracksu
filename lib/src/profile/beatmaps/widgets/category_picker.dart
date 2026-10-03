import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/profile/beatmaps/domain/beatmaps_query.dart';
import 'package:tracksu/src/_shared/ui/category_picker.dart';

extension ProfileBeatmapsTypePresentation on ProfileBeatmapsType {
  IconData get icon => switch (this) {
    ProfileBeatmapsType.mostPlayed => Icons.play_circle_outline,
    ProfileBeatmapsType.favourite => Icons.favorite_outline,
    ProfileBeatmapsType.ranked => Icons.verified_outlined,
    ProfileBeatmapsType.pending => Icons.hourglass_empty,
    ProfileBeatmapsType.graveyard => Icons.archive_outlined,
    ProfileBeatmapsType.loved => Icons.favorite,
    ProfileBeatmapsType.guest => Icons.group_outlined,
    ProfileBeatmapsType.nominated => Icons.workspace_premium_outlined,
  };

  String label(BuildContext context) => switch (this) {
    ProfileBeatmapsType.mostPlayed => context.t.beatmapsMostPlayed,
    ProfileBeatmapsType.favourite => context.t.beatmapsFavourite,
    ProfileBeatmapsType.ranked => context.t.beatmapsRanked,
    ProfileBeatmapsType.pending => context.t.beatmapsPending,
    ProfileBeatmapsType.graveyard => context.t.beatmapsGraveyard,
    ProfileBeatmapsType.loved => context.t.beatmapsLoved,
    ProfileBeatmapsType.guest => context.t.beatmapsGuest,
    ProfileBeatmapsType.nominated => context.t.beatmapsNominated,
  };
}

/// Groups mirror the osu! profile: what the player plays, then what they map,
/// from most to least finished.
final class ProfileBeatmapsCategoryBar extends StatelessWidget {
  const ProfileBeatmapsCategoryBar({
    required this.selected,
    required this.onSelected,
    super.key,
  });
  final ProfileBeatmapsType selected;
  final ValueChanged<ProfileBeatmapsType> onSelected;

  @override
  Widget build(BuildContext context) => OsuCategoryPicker<ProfileBeatmapsType>(
    title: context.t.beatmapsCategory,
    selected: selected,
    icon: (ProfileBeatmapsType type) => type.icon,
    label: (BuildContext context, ProfileBeatmapsType type) =>
        type.label(context),
    onSelected: onSelected,
    groups: <OsuCategoryGroup<ProfileBeatmapsType>>[
      OsuCategoryGroup<ProfileBeatmapsType>(
        title: context.t.beatmapsGroupPlayer,
        options: const <ProfileBeatmapsType>[
          ProfileBeatmapsType.mostPlayed,
          ProfileBeatmapsType.favourite,
        ],
      ),
      OsuCategoryGroup<ProfileBeatmapsType>(
        title: context.t.beatmapsGroupMapper,
        options: const <ProfileBeatmapsType>[
          ProfileBeatmapsType.ranked,
          ProfileBeatmapsType.loved,
          ProfileBeatmapsType.nominated,
          ProfileBeatmapsType.guest,
          ProfileBeatmapsType.pending,
          ProfileBeatmapsType.graveyard,
        ],
      ),
    ],
  );
}
