import 'package:flutter/material.dart';
import 'package:tracksu/src/profile/widgets/profile_details_sections.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/profile/bloc/bloc.dart';
import 'package:tracksu/src/profile/beatmaps/main.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/scores/main.dart';
import 'package:tracksu/src/profile/widgets/profile_summary.dart';
import 'package:tracksu/src/_shared/content/widgets/content_page_section.dart';
import 'package:tracksu/src/profile/widgets/profile_error_message.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// TabBarView mounts sections lazily; keep-alive retains each visited section's
/// scroll and local Bloc. Only scores are recreated when the ruleset changes.
final class ProfileContent extends StatelessWidget {
  const ProfileContent({required this.state, super.key});
  final ProfileLoadedState state;

  void _retry(BuildContext context) => context.read<ProfileBloc>().add(
    state.failedRuleset == null
        ? const ProfileRefreshRequested()
        : ProfileRulesetSelected(state.failedRuleset!),
  );

  Future<void> _refresh(BuildContext context) async {
    final ProfileBloc bloc = context.read<ProfileBloc>();
    if (bloc.state case ProfileLoadedState(isBusy: true)) return;
    final Future<void> completed = bloc.stream
        .firstWhere(
          (ProfileState state) =>
              state is! ProfileLoadingState &&
              !(state is ProfileLoadedState && state.isBusy),
        )
        .then<void>((_) {}, onError: (Object _, StackTrace _) {});
    bloc.add(const ProfileRefreshRequested());
    await completed;
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 3,
    child: Column(
      children: <Widget>[
        if (state.isBusy)
          LinearProgressIndicator(semanticsLabel: context.t.profileRefreshing),
        if (state.requestedRuleset != null)
          Padding(
            padding: const EdgeInsets.all(UiSpace.sm),
            child: UiText.bodySmall(
              context.t.profileSwitchingMode,
              secondary: true,
            ),
          ),
        if (state.refreshFailure != null)
          Padding(
            padding: const EdgeInsets.all(UiSpace.sm),
            child: UiNotice(
              message: context.t.profileUpdateFailed,
              tone: UiNoticeTone.warning,
              actionLabel: context.t.retry,
              onAction: () => _retry(context),
            ),
          ),
        Expanded(
          child: IgnorePointer(
            ignoring: state.requestedRuleset != null,
            child: Column(
              children: <Widget>[
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: <Widget>[
                    Tab(text: context.t.profileOverview),
                    Tab(text: context.t.scoresTitle),
                    Tab(text: context.t.beatmapsTitle),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: <Widget>[
                      _ProfileSection(
                        key: const ValueKey<String>('overview'),
                        onRefresh: () => _refresh(context),
                        slivers: <Widget>[
                          if (state.refreshFailure case final failure?)
                            SliverToBoxAdapter(
                              child: ProfileErrorMessage(
                                failure: failure,
                                refreshing: true,
                                onRetry: () => _retry(context),
                              ),
                            ),
                          ProfileSummary(
                            profile: state.profile,
                            ruleset: state.ruleset,
                          ),
                          if (state.profile.details case final details?)
                            ProfileDetailsSections(
                              details: details,
                              userId: state.profile.id,
                            ),
                          if (state.profile.about case final about?)
                            ContentPageSection(
                              page: about,
                              title: context.t.profileAbout,
                            ),
                        ],
                      ),
                      _ProfileSection(
                        key: ValueKey<ProfileRuleset>(state.ruleset),
                        slivers: <Widget>[
                          ProfileScoresMain(
                            userId: state.profile.id,
                            ruleset: state.ruleset,
                          ),
                        ],
                      ),
                      _ProfileSection(
                        key: const ValueKey<String>('maps'),
                        slivers: <Widget>[
                          ProfileBeatmapsMain(userId: state.profile.id),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

final class _ProfileSection extends StatefulWidget {
  const _ProfileSection({required this.slivers, this.onRefresh, super.key});
  final List<Widget> slivers;
  final Future<void> Function()? onRefresh;

  @override
  State<_ProfileSection> createState() => _ProfileSectionState();
}

final class _ProfileSectionState extends State<_ProfileSection>
    with AutomaticKeepAliveClientMixin {
  // Keep-alive owns the visited section's position. A new ruleset gets a new
  // controller rather than restoring an offset into a freshly loaded score list.
  final ScrollController _scrollController = ScrollController(
    keepScrollOffset: false,
  );

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final Widget scroll = CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: widget.slivers,
    );
    return widget.onRefresh == null
        ? scroll
        : RefreshIndicator(onRefresh: widget.onRefresh!, child: scroll);
  }
}
