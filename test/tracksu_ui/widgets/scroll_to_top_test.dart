import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

const String _tooltip = 'Top';

/// Counts registrations so listener ownership is observable.
final class _Requests implements Listenable {
  final Set<VoidCallback> listeners = <VoidCallback>{};

  @override
  void addListener(VoidCallback listener) => listeners.add(listener);

  @override
  void removeListener(VoidCallback listener) => listeners.remove(listener);

  void request() {
    for (final VoidCallback listener in listeners.toList()) {
      listener();
    }
  }
}

Widget _list({ScrollController? controller, int count = 100, Key? key}) =>
    ListView.builder(
      key: key,
      controller: controller,
      primary: controller == null,
      itemExtent: 100,
      itemCount: count,
      itemBuilder: (BuildContext context, int index) => Text('item $index'),
    );

Widget _app(Widget body, {bool disableAnimations = false}) => MaterialApp(
  home: Builder(
    builder: (BuildContext context) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(disableAnimations: disableAnimations),
      child: Scaffold(body: body),
    ),
  ),
);

ScrollPosition _position(WidgetTester tester, [Finder? scrollable]) => tester
    .state<ScrollableState>(scrollable ?? find.byType(Scrollable))
    .position;

void main() {
  testWidgets('appears after one viewport and hides back at the top', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(UiScrollToTop(tooltip: _tooltip, child: _list())),
    );

    _position(tester).jumpTo(500);
    await tester.pump();
    await tester.pump();
    expect(find.byTooltip(_tooltip), findsNothing);

    _position(tester).jumpTo(700);
    await tester.pump();
    await tester.pump();
    expect(find.byTooltip(_tooltip), findsOneWidget);

    await tester.tap(find.byTooltip(_tooltip));
    await tester.pumpAndSettle();

    expect(_position(tester).pixels, 0);
    expect(find.byTooltip(_tooltip), findsNothing);
  });

  testWidgets('opposite offsets within one frame use the latest one', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(UiScrollToTop(tooltip: _tooltip, child: _list())),
    );

    _position(tester)
      ..jumpTo(3000)
      ..jumpTo(0);
    await tester.pump();
    await tester.pump();
    expect(find.byTooltip(_tooltip), findsNothing);

    _position(tester)
      ..jumpTo(0)
      ..jumpTo(3000);
    await tester.pump();
    await tester.pump();
    expect(find.byTooltip(_tooltip), findsOneWidget);
  });

  testWidgets('hides when long content is replaced by short content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        UiScrollToTop(
          tooltip: _tooltip,
          child: _list(key: const ValueKey<String>('long')),
        ),
      ),
    );
    _position(tester).jumpTo(3000);
    await tester.pump();
    await tester.pump();
    expect(find.byTooltip(_tooltip), findsOneWidget);

    await tester.pumpWidget(
      _app(
        UiScrollToTop(
          tooltip: _tooltip,
          child: _list(key: const ValueKey<String>('short'), count: 2),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byTooltip(_tooltip), findsNothing);
  });

  testWidgets('reduced motion jumps to the top without animation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        UiScrollToTop(tooltip: _tooltip, child: _list()),
        disableAnimations: true,
      ),
    );
    _position(tester).jumpTo(3000);
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byTooltip(_tooltip));
    await tester.pump();

    expect(_position(tester).pixels, 0);
  });

  for (final bool reduce in <bool>[false, true]) {
    testWidgets('last link stays tappable at max extent, reduce=$reduce', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      // A final right-aligned action must be reachable below the overlay.
      await tester.pumpWidget(
        _app(
          UiScrollToTop(
            tooltip: _tooltip,
            child: CustomScrollView(
              primary: true,
              slivers: <Widget>[
                SliverList.builder(
                  itemCount: 30,
                  itemBuilder: (BuildContext context, int index) => SizedBox(
                    height: 100,
                    child: index == 29
                        ? Align(
                            alignment: Alignment.bottomRight,
                            child: TextButton(
                              onPressed: () => taps++,
                              child: const Text('last link'),
                            ),
                          )
                        : Text('item $index'),
                  ),
                ),
                const UiSliverScrollToTopSpace(tooltip: _tooltip),
              ],
            ),
          ),
          disableAnimations: reduce,
        ),
      );
      final ScrollPosition position = _position(tester);
      position.jumpTo(position.maxScrollExtent);
      await tester.pump();
      await tester.pump();
      expect(find.byTooltip(_tooltip), findsOneWidget);

      await tester.tap(find.text('last link'));

      expect(taps, 1);
    });
  }

  testWidgets('viewport is identical with and without the button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(UiScrollToTop(tooltip: _tooltip, child: _list())),
    );
    final Size hidden = tester.getSize(find.byType(ListView));
    expect(find.byTooltip(_tooltip), findsNothing);

    _position(tester).jumpTo(3000);
    await tester.pump();
    await tester.pump();

    expect(find.byTooltip(_tooltip), findsOneWidget);
    expect(tester.getSize(find.byType(ListView)), hidden);
  });

  testWidgets('request listener is moved on update and removed on dispose', (
    WidgetTester tester,
  ) async {
    final _Requests first = _Requests();
    final _Requests second = _Requests();

    await tester.pumpWidget(
      _app(
        UiScrollToTop(tooltip: _tooltip, scrollRequests: first, child: _list()),
      ),
    );
    expect(first.listeners, hasLength(1));

    await tester.pumpWidget(
      _app(
        UiScrollToTop(
          tooltip: _tooltip,
          scrollRequests: second,
          child: _list(),
        ),
      ),
    );
    expect(first.listeners, isEmpty);
    expect(second.listeners, hasLength(1));

    await tester.pumpWidget(_app(const Text('gone')));
    expect(second.listeners, isEmpty);
  });

  testWidgets('a request without an attached scrollable is a no-op', (
    WidgetTester tester,
  ) async {
    final _Requests requests = _Requests();
    await tester.pumpWidget(
      _app(
        UiScrollToTop(
          tooltip: _tooltip,
          scrollRequests: requests,
          child: const Text('no scroll'),
        ),
      ),
    );

    requests.request();
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byTooltip(_tooltip), findsNothing);
  });

  testWidgets('a request scrolls only the explicit controller owner', (
    WidgetTester tester,
  ) async {
    final ScrollController owned = ScrollController();
    addTearDown(owned.dispose);
    final _Requests requests = _Requests();
    await tester.pumpWidget(
      _app(
        Row(
          children: <Widget>[
            Expanded(
              child: UiScrollToTop(
                tooltip: _tooltip,
                controller: owned,
                scrollRequests: requests,
                child: _list(controller: owned),
              ),
            ),
            Expanded(child: _list()),
          ],
        ),
      ),
    );
    final Finder primary = find.byType(Scrollable).last;
    owned.jumpTo(3000);
    _position(tester, primary).jumpTo(2000);
    await tester.pump();

    requests.request();
    await tester.pumpAndSettle();

    expect(owned.offset, 0);
    expect(_position(tester, primary).pixels, 2000);
  });

  testWidgets('without a controller it scrolls the inherited primary one', (
    WidgetTester tester,
  ) async {
    final ScrollController owned = ScrollController();
    addTearDown(owned.dispose);
    final _Requests requests = _Requests();
    await tester.pumpWidget(
      _app(
        Row(
          children: <Widget>[
            Expanded(
              child: UiScrollToTop(
                tooltip: _tooltip,
                scrollRequests: requests,
                child: _list(),
              ),
            ),
            Expanded(child: _list(controller: owned)),
          ],
        ),
      ),
    );
    final Finder primary = find.byType(Scrollable).first;
    _position(tester, primary).jumpTo(3000);
    owned.jumpTo(2000);
    await tester.pump();

    requests.request();
    await tester.pumpAndSettle();

    expect(_position(tester, primary).pixels, 0);
    expect(owned.offset, 2000);
  });
}
