import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/chrome/app_bar_actions.dart';
import 'package:tracksu/src/_shared/sharing/share_target.dart';
import 'package:tracksu/src/_shared/ui/osu_badges.dart';
import 'package:tracksu/src/beatmap/domain/beatmap.dart';
import 'package:tracksu/src/packs/domain/packs.dart';
import 'package:tracksu/src/packs/pack/bloc/bloc.dart';
import 'package:tracksu/src/packs/widgets/pack_type_style.dart';
import 'package:tracksu/src/packs/widgets/packs_screen.dart';
import 'package:tracksu/src/profile/beatmaps/domain/beatmap.dart';
import 'package:tracksu/src/profile/beatmaps/widgets/beatmap_card.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// One pack: a header tinted with the type's accent (type, tag, name,
/// date and author, ruleset, rules), then its beatmapsets as cards.
final class BeatmapPackScreen extends StatelessWidget {
  const BeatmapPackScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<BeatmapPackBloc, BeatmapPackState>(
        builder: (BuildContext context, BeatmapPackState state) {
          final BeatmapPack? pack = state.pack;
          final BeatmapPackBloc bloc = context.read<BeatmapPackBloc>();
          final List<ProfileBeatmap> sets =
              pack?.beatmapsets ?? const <ProfileBeatmap>[];
          return Scaffold(
            appBar: UiAppBar(
              title: UiText.titleLarge(context.t.packTitle),
              actions: <Widget>[
                AppBarActions(
                  share: pack == null
                      ? null
                      : ShareTarget.pack(pack.tag, pack.name),
                ),
              ],
              bottom: UiAppBarProgressSlot(
                child: UiAppBarProgress(
                  visible: pack != null && state.loading,
                  semanticsLabel: context.t.packsLoading,
                ),
              ),
            ),
            body: UiScrollToTop(
              tooltip: context.t.scrollToTop,
              child: SafeArea(
                top: false,
                child: RefreshIndicator(
                  onRefresh: () async =>
                      bloc.add(const BeatmapPackRefreshRequested()),
                  child: CustomScrollView(
                    primary: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: <Widget>[
                      if (pack == null)
                        SliverToBoxAdapter(
                          child: state.failure == null
                              ? UiPageSkeleton.list(
                                  label: context.t.packsLoading,
                                )
                              : UiContentState.error(
                                  title: packsFailureTitle(
                                    context,
                                    state.failure!,
                                  ),
                                  actionLabel: context.t.retry,
                                  onAction: () => bloc.add(
                                    const BeatmapPackRefreshRequested(),
                                  ),
                                ),
                        )
                      else ...<Widget>[
                        SliverPadding(
                          padding: const EdgeInsets.all(UiSpace.lg),
                          sliver: SliverToBoxAdapter(
                            child: UiReveal(child: _Header(pack: pack)),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: UiSpace.lg,
                          ),
                          sliver: UiSliverCardList(
                            itemCount: sets.length,
                            itemBuilder: (BuildContext context, int index) =>
                                ProfileBeatmapCard(
                                  key: ValueKey<int>(sets[index].id),
                                  beatmap: sets[index],
                                  onTap: () => unawaited(
                                    DepsScope.of(context).appRouter
                                        .openBeatmap(
                                          context,
                                          BeatmapsetParams(sets[index].id),
                                        ),
                                  ),
                                ),
                          ),
                        ),
                      ],
                      UiSliverScrollToTopSpace(
                        tooltip: context.t.scrollToTop,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
}

final class _Header extends StatelessWidget {
  const _Header({required this.pack});
  final BeatmapPack pack;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final BeatmapPackType? type = BeatmapPackTypeStyle.ofTag(pack.tag);
    final Color accent = type?.accent ?? colors.primary;
    final String meta = <String>[
      if (pack.date case final DateTime date)
        DateFormat.yMMMMd(context.t.localeName).format(date.toLocal()),
      if (pack.author.isNotEmpty) pack.author,
    ].join(' · ');
    return Material(
      shape: const BeveledRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(UiSpace.lg),
          bottomRight: Radius.circular(UiSpace.lg),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      color: colors.surfaceContainerLow,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              accent.withValues(alpha: 0.26),
              accent.withValues(alpha: 0.03),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(UiSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: UiSpace.sm,
            children: <Widget>[
              Row(
                spacing: UiSpace.sm,
                children: <Widget>[
                  if (type != null) ...<Widget>[
                    Icon(type.icon, color: accent, size: 20),
                    UiText.labelLarge(type.label(context), color: accent),
                  ],
                  const Spacer(),
                  BeatmapPackTag(tag: pack.tag),
                ],
              ),
              UiText.headlineSmall(pack.name),
              if (meta.isNotEmpty) UiText.bodyMedium(meta, secondary: true),
              Wrap(
                spacing: UiSpace.md,
                runSpacing: UiSpace.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  if (pack.ruleset case final ruleset?)
                    OsuRulesetIcon(ruleset: ruleset)
                  else
                    UiText.labelLarge(context.t.packsAllModes, secondary: true),
                  if (pack.beatmapsets case final sets?)
                    UiText.labelLarge(
                      context.t.packsSets(sets.length),
                      secondary: true,
                    ),
                ],
              ),
              if (pack.noDiffReduction)
                Row(
                  spacing: UiSpace.xs,
                  children: <Widget>[
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: colors.onSurfaceVariant,
                    ),
                    Expanded(
                      child: UiText.bodySmall(
                        context.t.packsNoDiffReduction,
                        secondary: true,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
