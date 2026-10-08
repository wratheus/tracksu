import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tracksu/src/_core/l10n/generated/app_localizations.dart';
import 'package:tracksu/src/_shared/navigation/shell_reselect.dart';
import 'package:tracksu/src/guest/widgets/guest_shell.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Long branch root observing reselect of its own tab, like feature roots.
final class _Root extends StatelessWidget {
  const _Root(this.tab);

  final ShellTab tab;

  @override
  Widget build(BuildContext context) => Scaffold(
    key: ValueKey<ShellTab>(tab),
    body: UiScrollToTop(
      tooltip: 'top ${tab.name}',
      scrollRequests: ShellReselectScope.maybeOf(context, tab),
      child: ListView.builder(
        primary: true,
        itemExtent: 100,
        itemCount: 200,
        itemBuilder: (BuildContext context, int index) =>
            Text('${tab.name} $index'),
      ),
    ),
  );
}

void main() {
  final AppLocalizations t = lookupAppLocalizations(const Locale('en'));
  late GoRouter router;

  setUp(() {
    router = GoRouter(
      initialLocation: '/home',
      routes: <RouteBase>[
        StatefulShellRoute.indexedStack(
          builder: (
            BuildContext context,
            GoRouterState state,
            StatefulNavigationShell shell,
          ) => GuestShell(navigationShell: shell),
          branches: <StatefulShellBranch>[
            for (final ShellTab tab in ShellTab.values)
              StatefulShellBranch(
                routes: <RouteBase>[
                  GoRoute(
                    path: '/${tab.name}',
                    builder: (BuildContext context, GoRouterState state) =>
                        _Root(tab),
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'details',
                        builder: (BuildContext context, GoRouterState state) =>
                            const Scaffold(body: Text('details')),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  });

  tearDown(() => router.dispose());

  Future<void> pumpShell(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: TracksuTheme.light(),
      ),
    );
    await tester.pumpAndSettle();
  }

  ScrollPosition position(WidgetTester tester, ShellTab tab) => tester
      .state<ScrollableState>(
        find.descendant(
          of: find.byKey(ValueKey<ShellTab>(tab), skipOffstage: false),
          matching: find.byType(Scrollable, skipOffstage: false),
          skipOffstage: false,
        ),
      )
      .position;

  Finder tabLabel(String label) => find.descendant(
    of: find.byType(UiNavigationBar),
    matching: find.text(label),
  );

  /// The search tab is a round icon button labelled only by its tooltip.
  Finder searchTab() => find.descendant(
    of: find.byType(UiNavigationBar),
    matching: find.byTooltip(t.navigationSearch),
  );

  testWidgets('reselect scrolls only the active root; other tab retained', (
    WidgetTester tester,
  ) async {
    await pumpShell(tester);
    position(tester, ShellTab.home).jumpTo(3000);

    await tester.tap(tabLabel(t.rankingsTitle));
    await tester.pumpAndSettle();
    expect(position(tester, ShellTab.rankings).pixels, 0);
    position(tester, ShellTab.rankings).jumpTo(2000);

    await tester.tap(tabLabel(t.navigationHome));
    await tester.pumpAndSettle();
    expect(position(tester, ShellTab.home).pixels, 3000);

    await tester.tap(tabLabel(t.navigationHome));
    await tester.pumpAndSettle();

    expect(position(tester, ShellTab.home).pixels, 0);
    expect(position(tester, ShellTab.rankings).pixels, 2000);
  });

  testWidgets('the round search button selects and reselects its branch', (
    WidgetTester tester,
  ) async {
    await pumpShell(tester);
    position(tester, ShellTab.home).jumpTo(1500);

    await tester.tap(searchTab());
    await tester.pumpAndSettle();
    expect(position(tester, ShellTab.find).pixels, 0);
    position(tester, ShellTab.find).jumpTo(3000);

    await tester.tap(searchTab());
    await tester.pumpAndSettle();

    expect(position(tester, ShellTab.find).pixels, 0);
    expect(position(tester, ShellTab.home).pixels, 1500);
  });

  testWidgets('reselect from details returns to root and scrolls it to top', (
    WidgetTester tester,
  ) async {
    await pumpShell(tester);
    await tester.tap(tabLabel(t.hubTitle));
    await tester.pumpAndSettle();
    position(tester, ShellTab.news).jumpTo(3000);
    position(tester, ShellTab.home).jumpTo(1500);
    router.go('/news/details');
    await tester.pumpAndSettle();
    expect(find.text('details'), findsOneWidget);

    await tester.tap(tabLabel(t.hubTitle));
    await tester.pumpAndSettle();

    expect(find.text('details'), findsNothing);
    expect(position(tester, ShellTab.news).pixels, 0);
    expect(position(tester, ShellTab.home).pixels, 1500);
  });

  testWidgets('a reselect superseded by a tab switch scrolls nothing', (
    WidgetTester tester,
  ) async {
    await pumpShell(tester);
    position(tester, ShellTab.home).jumpTo(3000);

    await tester.tap(tabLabel(t.navigationHome));
    await tester.tap(tabLabel(t.rankingsTitle));
    await tester.pumpAndSettle();

    expect(position(tester, ShellTab.home).pixels, 3000);
    expect(position(tester, ShellTab.rankings).pixels, 0);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
