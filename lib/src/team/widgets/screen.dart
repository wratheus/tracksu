import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/chrome/app_bar_actions.dart';
import 'package:tracksu/src/_shared/sharing/share_target.dart';
import 'package:tracksu/src/team/bloc/bloc.dart';
import 'package:tracksu/src/team/domain/team.dart';
import 'package:tracksu/src/team/widgets/team_content.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class TeamScreen extends StatelessWidget {
  const TeamScreen({required this.id, super.key});
  final int id;
  @override
  Widget build(BuildContext context) => BlocBuilder<TeamBloc, TeamState>(
    builder: (BuildContext context, TeamState state) {
      final TeamDetails? data = state is TeamLoaded ? state.data : null;
      final bool busy =
          state is TeamInitial ||
          state is TeamLoading ||
          (state is TeamLoaded && state.refreshing);
      return Scaffold(
        appBar: UiAppBar(
          title: Text(data?.identity.name ?? context.t.teamTitle),
          actions: <Widget>[
            AppBarActions(
              share: ShareTarget.team(
                id,
                data?.ruleset,
                data?.identity.name ?? context.t.teamTitle,
              ),
            ),
          ],
          bottom: UiAppBarProgressSlot(
            child: UiAppBarProgress(
              visible: state is TeamLoaded && state.refreshing,
              semanticsLabel: context.t.teamLoading,
            ),
          ),
        ),
        body: UiScrollToTop(
          tooltip: context.t.scrollToTop,
          child: SafeArea(
            // Pull down to refresh; progress is the line under the app bar.
            child: RefreshIndicator(
              onRefresh: () async {
                if (!busy) {
                  context.read<TeamBloc>().add(const TeamRefreshRequested());
                }
              },
              child: CustomScrollView(
                // Desktop does not inherit the route controller implicitly.
                primary: true,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: <Widget>[
                  if (data == null)
                    if (state case TeamError(:final failure))
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: _Failure(failure)),
                      )
                    else
                      SliverToBoxAdapter(
                        child: UiPageSkeleton.profile(
                          label: context.t.teamLoading,
                        ),
                      )
                  else
                    UiSliverReveal(
                      sliver: SliverMainAxisGroup(
                        slivers: <Widget>[
                          if (state case TeamLoaded(
                            failure: final TeamFailureKind failure,
                          ))
                            SliverToBoxAdapter(child: _Failure(failure)),
                          TeamContent(
                            data: data,
                            selectedMode: state is TeamLoaded
                                ? (state.requestedMode ?? data.ruleset)
                                : data.ruleset,
                            mediaPermission: DepsScope.of(context)
                                .contentMediaController,
                          ),
                        ],
                      ),
                    ),
                  UiSliverScrollToTopSpace(tooltip: context.t.scrollToTop),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

final class _Failure extends StatelessWidget {
  const _Failure(this.kind);
  final TeamFailureKind kind;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(UiSpace.lg),
    child: UiContentState.error(
      title: switch (kind) {
        TeamFailureKind.notFound => context.t.teamNotFound,
        TeamFailureKind.accessDenied => context.t.teamAccessDenied,
        _ => context.t.teamFailed,
      },
      actionLabel: context.t.retry,
      onAction: () =>
          context.read<TeamBloc>().add(const TeamRefreshRequested()),
    ),
  );
}
