import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/profile/activity/main.dart';
import 'package:tracksu/src/profile/activity/widgets/activity_section.dart';
import 'package:tracksu/src/profile/bloc/bloc.dart';
import 'package:tracksu/src/profile/beatmaps/main.dart';
import 'package:tracksu/src/profile/beatmaps/widgets/beatmaps_section.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/scores/main.dart';
import 'package:tracksu/src/profile/scores/widgets/scores_section.dart';
import 'package:tracksu/src/profile/widgets/profile_summary.dart';
import 'package:tracksu/src/_shared/content/widgets/content_page_section.dart';
import 'package:tracksu/src/_shared/ui/page_activity.dart';
import 'package:tracksu/src/profile/widgets/profile_error_message.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Section Blocs live above the tabs and start with the profile, so Results
/// and Maps load in the background while the overview is read; switching to
/// a tab shows ready data. Activity is lazy and loads on its first visit. TabBarView still builds section widgets lazily and
/// keep-alive retains their scroll. Only scores are recreated (new provider
/// key) when the ruleset changes. See P42.
final class ProfileContent extends StatelessWidget {
  const ProfileContent({required this.state, super.key});
  final ProfileLoadedState state;

  void _retry(BuildContext context) => context.read<ProfileBloc>().add(
    state.failedRuleset == null
        ? const ProfileRefreshRequested()
        : ProfileRulesetSelected(state.failedRuleset!),
  );

  /// Pull-to-refresh only starts the request: the pull spinner retracts at
  /// once and progress continues on the app-bar line, so there is one
  /// loading indicator per page.
  Future<void> _refresh(BuildContext context) async {
    final ProfileBloc bloc = context.read<ProfileBloc>();
    if (bloc.state case ProfileLoadedState(isBusy: true)) return;
    bloc.add(const ProfileRefreshRequested());
  }

  @override
  Widget build(BuildContext context) => ProfileScoresProvider(
    userId: state.profile.id,
    ruleset: state.ruleset,
    child: ProfileBeatmapsProvider(
      userId: state.profile.id,
      child: ProfileActivityProvider(
        userId: state.profile.id,
        child: _tabs(context),
      ),
    ),
  );

  Widget _tabs(BuildContext context) => DefaultTabController(
    length: 4,
    child: Column(
      children: <Widget>[
        // Refresh and ruleset switches show the line under the app bar
        // (ProfileScreen), not a bar or a caption inside the content.
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
                _ProfileTabs(
                  tabs: <(IconData, String)>[
                    (Icons.person_outline_rounded, context.t.profileOverview),
                    (Icons.emoji_events_outlined, context.t.scoresTitle),
                    (Icons.timeline_rounded, context.t.profileActivity),
                    (Icons.library_music_outlined, context.t.beatmapsTitle),
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
                            about: switch (state.profile.about) {
                              final about? => ContentPageSection(
                                page: about,
                                title: context.t.profileAbout,
                              ),
                              null => null,
                            },
                          ),
                        ],
                      ),
                      _ProfileSection(
                        key: ValueKey<ProfileRuleset>(state.ruleset),
                        slivers: <Widget>[const ProfileScoresSection()],
                      ),
                      _ProfileSection(
                        key: const ValueKey<String>('activity'),
                        slivers: <Widget>[
                          ProfileActivitySection(userId: state.profile.id),
                        ],
                      ),
                      _ProfileSection(
                        key: const ValueKey<String>('maps'),
                        slivers: <Widget>[const ProfileBeatmapsSection()],
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
  final PageRefresh _sectionRefresh = PageRefresh();

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
      slivers: <Widget>[
        ...widget.slivers,
        UiSliverScrollToTopSpace(tooltip: context.t.scrollToTop),
      ],
    );
    // Every tab refreshes by pulling: the overview refreshes the profile, a
    // section refreshes its own Bloc through PageRefreshTarget. Progress is
    // the app-bar line (PageActivity), not a loader in the list.
    return UiScrollToTop(
      tooltip: context.t.scrollToTop,
      controller: _scrollController,
      child: PageRefreshScope(
        refresh: _sectionRefresh,
        child: RefreshIndicator(
          onRefresh: () async {
            if (widget.onRefresh case final Future<void> Function() refresh) {
              await refresh();
            } else {
              _sectionRefresh();
            }
          },
          child: scroll,
        ),
      ),
    );
  }
}

/// Section switcher built from the same segmented control as the ruleset
/// selector above it, kept in sync with the TabBarView (taps and swipes).
final class _ProfileTabs extends StatelessWidget {
  const _ProfileTabs({required this.tabs});
  final List<(IconData, String)> tabs;

  @override
  Widget build(BuildContext context) {
    final TabController controller = DefaultTabController.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        UiSpace.lg,
        UiSpace.sm,
        UiSpace.lg,
        UiSpace.xs,
      ),
      child: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, _) => UiSegmentedControl<int>(
          selected: controller.index,
          // Switches as soon as the page is swiped past halfway.
          position: controller.animation,
          segments: <UiSegment<int>>[
            for (int i = 0; i < tabs.length; i++)
              UiSegment<int>(
                value: i,
                label: tabs[i].$2,
                icon: Icon(tabs[i].$1),
              ),
          ],
          onChanged: controller.animateTo,
        ),
      ),
    );
  }
}
