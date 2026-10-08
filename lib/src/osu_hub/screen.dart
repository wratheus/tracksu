import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/chrome/app_bar_actions.dart';
import 'package:tracksu/src/_shared/navigation/shell_reselect.dart';
import 'package:tracksu/src/_shared/sharing/share_target.dart';
import 'package:tracksu/src/changelog/bloc/bloc.dart';
import 'package:tracksu/src/changelog/widgets/changelog_slivers.dart';
import 'package:tracksu/src/events/bloc/bloc.dart';
import 'package:tracksu/src/events/widgets/events_slivers.dart';
import 'package:tracksu/src/news/bloc/bloc.dart';
import 'package:tracksu/src/news/widgets/screen.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

enum _HubTab { news, events, changelog }

/// "osu!" tab: News / Changelog pages under one AppBar, switched by the
/// segmented control or a swipe (snaps past halfway, as in Rankings). Each
/// page keeps its own scroll; refresh is pull-to-refresh.
final class OsuHubScreen extends StatefulWidget {
  const OsuHubScreen({super.key});

  @override
  State<OsuHubScreen> createState() => _OsuHubScreenState();
}

final class _OsuHubScreenState extends State<OsuHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(
    length: _HubTab.values.length,
    vsync: this,
  )..addListener(_tabChanged);
  final List<ScrollController> _scrolls = <ScrollController>[
    for (final _HubTab _ in _HubTab.values) ScrollController(),
  ];
  int _index = 0;

  _HubTab get _tab => _HubTab.values[_index];

  void _tabChanged() {
    if (_tabs.index != _index) setState(() => _index = _tabs.index);
  }

  @override
  void dispose() {
    _tabs.dispose();
    for (final ScrollController scroll in _scrolls) {
      scroll.dispose();
    }
    super.dispose();
  }

  void _refresh(_HubTab tab) {
    switch (tab) {
      case _HubTab.news:
        final NewsBloc bloc = context.read<NewsBloc>();
        if (bloc.state case NewsContentState(operation: null)) {
          bloc.add(const NewsRefreshRequested());
        }
      case _HubTab.events:
        context.read<OsuEventsBloc>().add(const OsuEventsRefreshRequested());
      case _HubTab.changelog:
        context.read<ChangelogBloc>().add(const ChangelogRefreshRequested());
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: UiAppBar(
      title: UiText.titleLarge(context.t.hubTitle),
      actions: <Widget>[
        BlocSelector<ChangelogBloc, ChangelogState, String?>(
          selector: (ChangelogState state) => state.stream,
          builder: (BuildContext context, String? stream) => AppBarActions(
            share: switch (_tab) {
              _HubTab.news => ShareTarget.newsList(context.t.newsTitle),
              // The website has no page for the global feed.
              _HubTab.events => null,
              _HubTab.changelog => ShareTarget.changelog(
                stream,
                context.t.changelogTitle,
              ),
            },
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(66),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                UiSpace.lg,
                UiSpace.sm,
                UiSpace.lg,
                UiSpace.xs,
              ),
              child: UiSegmentedControl<int>(
                selected: _index,
                // Switches as soon as a page is swiped past halfway.
                position: _tabs.animation,
                segments: <UiSegment<int>>[
                  UiSegment<int>(
                    value: _HubTab.news.index,
                    label: context.t.newsTitle,
                    icon: const Icon(Icons.newspaper_rounded),
                  ),
                  UiSegment<int>(
                    value: _HubTab.events.index,
                    label: context.t.eventsTitle,
                    icon: const Icon(Icons.bolt_rounded),
                  ),
                  UiSegment<int>(
                    value: _HubTab.changelog.index,
                    label: context.t.changelogTitle,
                    icon: const Icon(Icons.update_rounded),
                  ),
                ],
                onChanged: _tabs.animateTo,
              ),
            ),
            BlocSelector<NewsBloc, NewsState, bool>(
              selector: (NewsState state) =>
                  state is NewsContentState &&
                  state.operation == NewsOperation.refresh,
              builder: (BuildContext context, bool news) =>
                  BlocSelector<ChangelogBloc, ChangelogState, bool>(
                    selector: (ChangelogState state) =>
                        state is ChangelogLoadedState &&
                        state.operation == ChangelogOperation.refresh,
                    builder: (BuildContext context, bool changelog) =>
                        BlocSelector<OsuEventsBloc, OsuEventsState, bool>(
                          selector: (OsuEventsState state) =>
                              state.items != null &&
                              state.operation == OsuEventsOperation.refresh,
                          builder: (BuildContext context, bool events) =>
                              UiAppBarProgress(
                                visible: switch (_tab) {
                                  _HubTab.news => news,
                                  _HubTab.events => events,
                                  _HubTab.changelog => changelog,
                                },
                                semanticsLabel: context.t.hubTitle,
                              ),
                        ),
                  ),
            ),
          ],
        ),
      ),
    ),
    body: SafeArea(
      top: false,
      child: TabBarView(
        controller: _tabs,
        children: <Widget>[
          for (final _HubTab tab in _HubTab.values)
            _HubPage(
              key: ValueKey<_HubTab>(tab),
              controller: _scrolls[tab.index],
              // Re-tapping the tab scrolls the visible page to the top.
              scrollRequests: tab == _tab
                  ? ShellReselectScope.maybeOf(context, ShellTab.news)
                  : null,
              onRefresh: () => _refresh(tab),
              slivers: switch (tab) {
                _HubTab.news => const <Widget>[NewsSlivers(article: false)],
                _HubTab.events => const <Widget>[OsuEventsSlivers()],
                _HubTab.changelog => const <Widget>[ChangelogSlivers()],
              },
            ),
        ],
      ),
    ),
  );
}

final class _HubPage extends StatefulWidget {
  const _HubPage({
    required this.controller,
    required this.onRefresh,
    required this.slivers,
    this.scrollRequests,
    super.key,
  });
  final ScrollController controller;
  final VoidCallback onRefresh;
  final List<Widget> slivers;
  final Listenable? scrollRequests;

  @override
  State<_HubPage> createState() => _HubPageState();
}

final class _HubPageState extends State<_HubPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return UiScrollToTop(
      tooltip: context.t.scrollToTop,
      controller: widget.controller,
      scrollRequests: widget.scrollRequests,
      // Pull to refresh; progress continues on the app-bar line.
      child: RefreshIndicator(
        onRefresh: () async => widget.onRefresh(),
        child: CustomScrollView(
          controller: widget.controller,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            ...widget.slivers,
            UiSliverScrollToTopSpace(tooltip: context.t.scrollToTop),
          ],
        ),
      ),
    );
  }
}
