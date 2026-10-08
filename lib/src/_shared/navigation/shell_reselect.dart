import 'package:flutter/widgets.dart';

/// Shell destinations in StatefulShellRoute branch order.
/// `home` is the landing page (route `/search` for old links), `find` the
/// separate search tab.
enum ShellTab { home, rankings, news, find }

final class _ReselectNotifier extends ChangeNotifier {
  void request() => notifyListeners();
}

/// One notifier per branch: only the reselected tab's root scrolls to top.
final class ShellReselectController {
  final Map<ShellTab, _ReselectNotifier> _notifiers =
      <ShellTab, _ReselectNotifier>{
        for (final ShellTab tab in ShellTab.values) tab: _ReselectNotifier(),
      };

  Listenable listenable(ShellTab tab) => _notifiers[tab]!;

  void request(ShellTab tab) => _notifiers[tab]!.request();

  void dispose() {
    for (final _ReselectNotifier notifier in _notifiers.values) {
      notifier.dispose();
    }
  }
}

/// Lets a branch root observe reselect of its own tab without a router import.
final class ShellReselectScope extends InheritedWidget {
  const ShellReselectScope({
    required this.controller,
    required super.child,
    super.key,
  });

  final ShellReselectController controller;

  /// Null outside the shell (tests, catalog), where there is no reselect.
  /// Depends on the scope so a replaced controller rebinds its listeners.
  static Listenable? maybeOf(BuildContext context, ShellTab tab) => context
      .dependOnInheritedWidgetOfExactType<ShellReselectScope>()
      ?.controller
      .listenable(tab);

  @override
  bool updateShouldNotify(ShellReselectScope oldWidget) =>
      controller != oldWidget.controller;
}
