import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/media/widgets/app_media.dart';
import 'package:tracksu/src/_shared/navigation/team_navigation.dart';
import 'package:tracksu/src/_shared/ui/osu_ui.dart';
import 'package:tracksu/src/profile/domain/profile_params.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';
import 'package:tracksu/src/rankings/kudosu/bloc/bloc.dart';
import 'package:tracksu/src/rankings/kudosu/domain/kudosu_ranking.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Kudosu ranking: player rows with total kudosu (available in the
/// tooltip/semantics). Kudosu has no ruleset, so the shared filters are
/// hidden on this page. Starts loading the first time it is shown.
final class KudosuRankingSection extends StatefulWidget {
  const KudosuRankingSection({super.key});

  @override
  State<KudosuRankingSection> createState() => _KudosuRankingSectionState();
}

final class _KudosuRankingSectionState extends State<KudosuRankingSection> {
  @override
  void initState() {
    super.initState();
    final KudosuRankingBloc bloc = context.read<KudosuRankingBloc>();
    if (bloc.state.items == null && bloc.state.operation == null) {
      bloc.add(const KudosuRankingRequested());
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<KudosuRankingBloc, KudosuRankingState>(
        builder: (BuildContext context, KudosuRankingState state) {
          final List<KudosuRankingEntry>? items = state.items;
          final String locale = context.t.localeName;
          final NumberFormat number = NumberFormat.decimalPattern(locale);
          if (items == null) {
            return SliverToBoxAdapter(
              child: state.failure == null
                  ? UiPageSkeleton.list(label: context.t.rankingsKudosu)
                  : UiContentState.error(
                      title: context.t.rankingsUnavailable,
                      actionLabel: context.t.retry,
                      onAction: () => context.read<KudosuRankingBloc>().add(
                        const KudosuRankingRequested(),
                      ),
                    ),
            );
          }
          return SliverMainAxisGroup(
            slivers: <Widget>[
              if (items.isEmpty)
                SliverToBoxAdapter(
                  child: UiContentState.empty(title: context.t.rankingsEmpty),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  UiSpace.lg,
                  UiSpace.md,
                  UiSpace.lg,
                  UiSpace.sm,
                ),
                sliver: SliverToBoxAdapter(
                  child: UiText.bodySmall(
                    context.t.rankingsKudosuHint,
                    secondary: true,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg),
                sliver: UiSliverCardList(
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) {
                    final KudosuRankingEntry entry = items[index];
                    return Tooltip(
                      key: ValueKey<int>(entry.userId),
                      message: context.t.rankingsKudosuAvailable(
                        entry.available,
                      ),
                      child: TeamNavigation(
                        teamId: entry.team?.id,
                        builder: (VoidCallback? openTeam) => OsuRankingRow(
                          username: entry.username,
                          country: entry.countryCode ?? '',
                          team: entry.team,
                          onTeamTap: openTeam,
                          avatar: AppMedia.image(context, entry.avatarUri),
                          position: '#${number.format(entry.position)}',
                          value: number.format(entry.total),
                          valueLabel: '',
                          onTap: () =>
                              DepsScope.of(context).appRouter.openProfile(
                                context,
                                ProfileParams(
                                  user: ProfileUserId(entry.userId),
                                  ruleset: ProfileRuleset.osu,
                                ),
                              ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (state.nextPage != null &&
                  state.operation == null &&
                  state.failure == null)
                UiSliverAutoLoad(
                  pageKey: state.nextPage!,
                  label: context.t.rankingsLoading,
                  onLoad: () => context.read<KudosuRankingBloc>().add(
                    const KudosuRankingMoreRequested(),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(UiSpace.lg),
                  child: switch (state) {
                    KudosuRankingState(
                      operation: KudosuRankingOperation.loadMore,
                    ) =>
                      UiLoading(label: context.t.rankingsLoading),
                    KudosuRankingState(failure: _?) => UiNotice(
                      message: context.t.rankingsUnavailable,
                      tone: UiNoticeTone.warning,
                      actionLabel: context.t.retry,
                      onAction: () => context.read<KudosuRankingBloc>().add(
                        state.failedOperation == KudosuRankingOperation.loadMore
                            ? const KudosuRankingMoreRequested()
                            : const KudosuRankingRequested(),
                      ),
                    ),
                    _ when state.nextPage == null && items.isNotEmpty => Center(
                      child: UiText.bodySmall(
                        context.t.rankingsEnd,
                        secondary: true,
                      ),
                    ),
                    _ => const SizedBox.shrink(),
                  },
                ),
              ),
            ],
          );
        },
      );
}
