import 'package:flutter/material.dart';

/// Collects "working" flags from independent parts of one page (e.g. the
/// profile and its lazily mounted score/map sections) so the page shows a
/// single progress line under its app bar instead of loaders in content.
final class PageActivity extends ChangeNotifier {
  final Set<Object> _busy = <Object>{};

  bool get busy => _busy.isNotEmpty;

  void report(Object owner, {required bool busy}) {
    final bool changed = busy ? _busy.add(owner) : _busy.remove(owner);
    if (changed) notifyListeners();
  }
}

/// Owns a [PageActivity] for the subtree (one per page).
final class PageActivityHost extends StatefulWidget {
  const PageActivityHost({required this.child, super.key});
  final Widget child;

  /// Without a dependency: reporters must not rebuild when others report.
  static PageActivity? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_PageActivityScope>()?.notifier;

  @override
  State<PageActivityHost> createState() => _PageActivityHostState();
}

final class _PageActivityHostState extends State<PageActivityHost> {
  final PageActivity _activity = PageActivity();

  @override
  void dispose() {
    _activity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _PageActivityScope(notifier: _activity, child: widget.child);
}

final class _PageActivityScope extends InheritedNotifier<PageActivity> {
  const _PageActivityScope({required super.notifier, required super.child});
}

/// Reports [busy] for this widget's lifetime; clears it when disposed.
final class PageActivityReporter extends StatefulWidget {
  const PageActivityReporter({
    required this.busy,
    required this.child,
    super.key,
  });
  final bool busy;
  final Widget child;

  @override
  State<PageActivityReporter> createState() => _PageActivityReporterState();
}

final class _PageActivityReporterState extends State<PageActivityReporter> {
  PageActivity? _activity;

  void _report() {
    final PageActivity? activity = _activity;
    if (activity == null) return;
    final bool busy = widget.busy;
    // Reporting during build would notify the app bar mid-frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (identical(_activity, activity)) activity.report(this, busy: busy);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final PageActivity? next = PageActivityHost.maybeOf(context);
    if (!identical(next, _activity)) {
      _activity?.report(this, busy: false);
      _activity = next;
      _report();
    }
  }

  @override
  void didUpdateWidget(PageActivityReporter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.busy != widget.busy) _report();
  }

  @override
  void dispose() {
    final PageActivity? activity = _activity;
    _activity = null;
    activity?.report(this, busy: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Lets a scrollable own pull-to-refresh while the content that knows how to
/// refresh (a lazily provided section Bloc) lives deeper in its slivers.
final class PageRefresh {
  VoidCallback? _action;

  /// Returns whether a target handled the pull.
  bool call() {
    final VoidCallback? action = _action;
    action?.call();
    return action != null;
  }
}

final class PageRefreshScope extends InheritedWidget {
  const PageRefreshScope({
    required this.refresh,
    required super.child,
    super.key,
  });
  final PageRefresh refresh;

  static PageRefresh? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<PageRefreshScope>()?.refresh;

  @override
  bool updateShouldNotify(PageRefreshScope oldWidget) =>
      !identical(refresh, oldWidget.refresh);
}

/// Registers [onRefresh] with the nearest [PageRefreshScope] while mounted.
final class PageRefreshTarget extends StatefulWidget {
  const PageRefreshTarget({
    required this.onRefresh,
    required this.child,
    super.key,
  });
  final VoidCallback onRefresh;
  final Widget child;

  @override
  State<PageRefreshTarget> createState() => _PageRefreshTargetState();
}

final class _PageRefreshTargetState extends State<PageRefreshTarget> {
  PageRefresh? _refresh;

  void _run() => widget.onRefresh();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final PageRefresh? next = PageRefreshScope.maybeOf(context);
    if (!identical(next, _refresh)) {
      if (_refresh?._action == _run) _refresh?._action = null;
      _refresh = next?.._action = _run;
    }
  }

  @override
  void dispose() {
    if (_refresh?._action == _run) _refresh?._action = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
