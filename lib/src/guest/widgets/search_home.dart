import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_core/router/app_router.dart';
import 'package:tracksu/src/_shared/chrome/app_bar_actions.dart';
import 'package:tracksu/src/_shared/navigation/shell_reselect.dart';
import 'package:tracksu/src/_shared/sharing/share_target.dart';
import 'package:tracksu/src/daily/bloc/bloc.dart';
import 'package:tracksu/src/daily/main.dart';
import 'package:tracksu/src/daily/widgets/home_section.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Guest landing with one entry to player and map search.
final class SearchHome extends StatefulWidget {
  const SearchHome({super.key});

  @override
  State<SearchHome> createState() => _SearchHomeState();
}

final class _SearchHomeState extends State<SearchHome> {
  bool _opening = false;
  int _navigation = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // goBranch(initialLocation: true) can remove the pushed route without
    // completing its push Future. Returning to Search always releases the form.
    if ((ModalRoute.isCurrentOf(context) ?? true) &&
        TickerMode.valuesOf(context).enabled) {
      _opening = false;
      _navigation++;
    }
  }

  Future<void> _openDaily() async {
    if (_opening) return;
    await _open(
      (TracksuAppRouter router) => router.openDailyChallenge(context),
    );
  }

  /// One detail push at a time from the landing page; see didChangeDependencies.
  Future<void> _open(Future<void> Function(TracksuAppRouter) push) async {
    setState(() => _opening = true);
    FocusScope.of(context).unfocus();
    final int navigation = ++_navigation;
    try {
      await push(DepsScope.of(context).appRouter);
    } finally {
      if (mounted && navigation == _navigation) {
        setState(() => _opening = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => BlocProvider<DailyChallengeBloc>(
    create: (_) => createDailyChallengeBloc(DepsScope.of(context)),
    child: Builder(builder: _buildPage),
  );

  Widget _buildPage(BuildContext context) => Scaffold(
    appBar: UiAppBar(
      title: UiText.titleLarge(context.t.appTitle),
      actions: <Widget>[
        AppBarActions(share: ShareTarget.search(context.t.appTitle)),
      ],
      bottom: UiAppBarProgressSlot(
        child: BlocSelector<DailyChallengeBloc, DailyChallengeState, bool>(
          selector: (DailyChallengeState state) =>
              state is DailyChallengeLoaded && state.refreshing,
          builder: (BuildContext context, bool busy) => UiAppBarProgress(
            visible: busy,
            semanticsLabel: context.t.dailyTitle,
          ),
        ),
      ),
    ),
    body: UiScrollToTop(
      tooltip: context.t.scrollToTop,
      scrollRequests: ShellReselectScope.maybeOf(context, ShellTab.home),
      child: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async => context.read<DailyChallengeBloc>().add(
            const DailyChallengeRequested(),
          ),
          child: CustomScrollView(
            key: const PageStorageKey<String>('search_home'),
            physics: const AlwaysScrollableScrollPhysics(),
            // Desktop does not inherit the route controller implicitly.
            primary: true,
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.all(UiSpace.lg),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: UiSpace.lg,
                    children: <Widget>[
                      DailyChallengeHomeSection(
                        onOpen: _opening ? null : _openDaily,
                      ),
                    ],
                  ),
                ),
              ),
              UiSliverScrollToTopSpace(tooltip: context.t.scrollToTop),
            ],
          ),
        ),
      ),
    ),
  );
}
