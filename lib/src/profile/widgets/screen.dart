import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/profile/bloc/bloc.dart';
import 'package:tracksu/src/profile/beatmaps/main.dart';
import 'package:tracksu/src/profile/domain/profile_failure.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/widgets/profile_summary.dart';
import 'package:tracksu/src/profile/scores/main.dart';
import 'package:tracksu/src/_shared/ui/osu_ui.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _refresh(BuildContext context) async {
    final ProfileBloc bloc = context.read<ProfileBloc>();
    final ProfileState current = bloc.state;
    if (current is ProfileInitialState ||
        current is ProfileLoadingState ||
        (current is ProfileLoadedState && current.isRefreshing)) {
      return;
    }
    // Route disposal closes the stream; end the indicator without a late effect.
    final Future<void> completed = bloc.stream
        .firstWhere(
          (ProfileState state) =>
              state is! ProfileLoadingState &&
              !(state is ProfileLoadedState && state.isRefreshing),
        )
        .then<void>((_) {}, onError: (Object _, StackTrace _) {});
    bloc.add(const ProfileRefreshRequested());
    await completed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: UiText.titleLarge(context.t.appTitle)),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () => _refresh(context),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: BlocSelector<ProfileBloc, ProfileState, ProfileRuleset>(
                  selector: (ProfileState state) => state.ruleset,
                  builder: (BuildContext context, ProfileRuleset selected) =>
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: UiSpace.lg,
                        ),
                        child: OsuRulesetSelector(
                          selected: selected,
                          onChanged: (ProfileRuleset ruleset) => context
                              .read<ProfileBloc>()
                              .add(ProfileRulesetSelected(ruleset)),
                        ),
                      ),
                ),
              ),
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (BuildContext context, ProfileState state) =>
                    switch (state) {
                      ProfileInitialState() => SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: UiContentState.empty(
                            title: context.t.profileSearchIntroduction,
                          ),
                        ),
                      ),
                      ProfileLoadingState() => SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: UiContentState.loading(
                            title: context.t.profileLoading,
                          ),
                        ),
                      ),
                      ProfileFailureState(:final failure) =>
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: ProfileErrorMessage(failure: failure),
                          ),
                        ),
                      ProfileLoadedState() => SliverMainAxisGroup(
                        slivers: <Widget>[
                          SliverToBoxAdapter(
                            child: Column(
                              children: <Widget>[
                                if (state.isRefreshing)
                                  LinearProgressIndicator(
                                    semanticsLabel: context.t.profileRefreshing,
                                  ),
                                if (state.refreshFailure
                                    case final ProfileFailureKind failure)
                                  ProfileErrorMessage(
                                    failure: failure,
                                    refreshing: true,
                                  ),
                                Align(
                                  alignment: AlignmentDirectional.centerEnd,
                                  child: UiButton.text(
                                    onPressed: state.isRefreshing
                                        ? null
                                        : () => context.read<ProfileBloc>().add(
                                            const ProfileRefreshRequested(),
                                          ),
                                    icon: Icons.refresh,
                                    label: context.t.profileRefresh,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ProfileSummary(profile: state.profile),
                          ProfileBeatmapsMain(
                            key: ValueKey<int>(state.profile.id),
                            userId: state.profile.id,
                          ),
                          ProfileScoresMain(
                            key: ValueKey<(int, ProfileRuleset)>((
                              state.profile.id,
                              state.ruleset,
                            )),
                            userId: state.profile.id,
                            ruleset: state.ruleset,
                          ),
                        ],
                      ),
                    },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class ProfileErrorMessage extends StatelessWidget {
  const ProfileErrorMessage({
    required this.failure,
    this.refreshing = false,
    super.key,
  });
  final ProfileFailureKind failure;
  final bool refreshing;

  @override
  Widget build(BuildContext context) {
    return UiContentState.error(
      title: switch (failure) {
        ProfileFailureKind.notFound => context.t.profileNotFound,
        ProfileFailureKind.accessDenied => context.t.profileAccessDenied,
        ProfileFailureKind.rateLimited => context.t.profileRateLimited,
        ProfileFailureKind.connection => context.t.profileConnectionFailed,
        ProfileFailureKind.invalidResponse => context.t.profileInvalidResponse,
        ProfileFailureKind.unavailable => context.t.profileUnavailable,
      },
      message: refreshing ? context.t.profileShowingPreviousData : null,
      actionLabel: context.t.retry,
      onAction: () =>
          context.read<ProfileBloc>().add(const ProfileRefreshRequested()),
    );
  }
}
