import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/profile/bloc/bloc.dart';
import 'package:tracksu/src/profile/beatmaps/main.dart';
import 'package:tracksu/src/profile/domain/profile_failure.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/widgets/profile_summary.dart';
import 'package:tracksu/src/profile/widgets/search_field.dart';
import 'package:tracksu/src/profile/scores/main.dart';

final class ProfileScreen extends StatelessWidget {
  const ProfileScreen({required this.actions, super.key});
  final Widget actions;

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
      appBar: AppBar(
        title: Text(context.t.appTitle),
        actions: <Widget>[actions],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () => _refresh(context),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              const SliverToBoxAdapter(child: ProfileSearchField()),
              SliverToBoxAdapter(
                child: BlocSelector<ProfileBloc, ProfileState, ProfileRuleset>(
                  selector: (ProfileState state) => state.ruleset,
                  builder: (BuildContext context, ProfileRuleset selected) =>
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Wrap(
                          spacing: 10,
                          children: ProfileRuleset.values
                              .map(
                                (ProfileRuleset ruleset) => ChoiceChip(
                                  label: Text(switch (ruleset) {
                                    ProfileRuleset.osu => context.t.rulesetOsu,
                                    ProfileRuleset.taiko =>
                                      context.t.rulesetTaiko,
                                    ProfileRuleset.fruits =>
                                      context.t.rulesetFruits,
                                    ProfileRuleset.mania =>
                                      context.t.rulesetMania,
                                  }),
                                  selected: ruleset == selected,
                                  onSelected: (_) => context
                                      .read<ProfileBloc>()
                                      .add(ProfileRulesetSelected(ruleset)),
                                ),
                              )
                              .toList(growable: false),
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
                          child: Padding(
                            padding: const EdgeInsets.all(30),
                            child: Text(
                              context.t.profileSearchIntroduction,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      ProfileLoadingState() => SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 15,
                            children: <Widget>[
                              const CircularProgressIndicator(),
                              Text(context.t.profileLoading),
                            ],
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
                                  child: TextButton.icon(
                                    onPressed: state.isRefreshing
                                        ? null
                                        : () => context.read<ProfileBloc>().add(
                                            const ProfileRefreshRequested(),
                                          ),
                                    icon: const Icon(Icons.refresh),
                                    label: Text(context.t.profileRefresh),
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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: <Widget>[
          if (refreshing) Text(context.t.profileShowingPreviousData),
          Text(switch (failure) {
            ProfileFailureKind.notFound => context.t.profileNotFound,
            ProfileFailureKind.accessDenied => context.t.profileAccessDenied,
            ProfileFailureKind.rateLimited => context.t.profileRateLimited,
            ProfileFailureKind.connection => context.t.profileConnectionFailed,
            ProfileFailureKind.invalidResponse =>
              context.t.profileInvalidResponse,
            ProfileFailureKind.unavailable => context.t.profileUnavailable,
          }, textAlign: TextAlign.center),
          TextButton(
            onPressed: () => context.read<ProfileBloc>().add(
              const ProfileRefreshRequested(),
            ),
            child: Text(context.t.retry),
          ),
        ],
      ),
    );
  }
}
