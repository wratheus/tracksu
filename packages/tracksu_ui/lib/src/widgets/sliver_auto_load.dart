import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tracksu_ui/src/widgets/feedback.dart';

/// Append after a lazy list only when its next page is available and idle.
/// The host replaces this sliver with progress/error/end while unavailable.
final class UiSliverAutoLoad extends StatelessWidget {
  const UiSliverAutoLoad({
    required this.pageKey,
    required this.onLoad,
    required this.label,
    super.key,
  });

  final Object pageKey;
  final VoidCallback onLoad;
  final String label;

  @override
  Widget build(BuildContext context) => SliverLayoutBuilder(
    builder: (BuildContext context, SliverConstraints constraints) =>
        SliverToBoxAdapter(
          child: _LoadTrigger(
            key: ValueKey<Object>(pageKey),
            nearEnd: constraints.remainingCacheExtent > 0,
            onLoad: onLoad,
            label: label,
          ),
        ),
  );
}

/// Layout only supplies visibility. The lifecycle-owned timer dispatches outside
/// build/layout, once per page, including when a page underfills the viewport.
final class _LoadTrigger extends StatefulWidget {
  const _LoadTrigger({
    required this.nearEnd,
    required this.onLoad,
    required this.label,
    super.key,
  });
  final bool nearEnd;
  final VoidCallback onLoad;
  final String label;

  @override
  State<_LoadTrigger> createState() => _LoadTriggerState();
}

final class _LoadTriggerState extends State<_LoadTrigger>
    with WidgetsBindingObserver {
  Timer? _debounce;
  bool _visible = false;
  bool _requested = false;
  bool _foreground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final AppLifecycleState? state = WidgetsBinding.instance.lifecycleState;
    _foreground = state == null || state == AppLifecycleState.resumed;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _visible =
        TickerMode.valuesOf(context).enabled &&
        (ModalRoute.isCurrentOf(context) ?? true);
    _schedule();
  }

  @override
  void didUpdateWidget(_LoadTrigger oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.nearEnd != oldWidget.nearEnd) _schedule();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _schedule();
  }

  void _schedule() {
    _debounce?.cancel();
    if (_requested || !_visible || !_foreground || !widget.nearEnd) return;
    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (!mounted ||
          _requested ||
          !_visible ||
          !_foreground ||
          !widget.nearEnd) {
        return;
      }
      _requested = true;
      widget.onLoad();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      Center(child: UiLoading(label: widget.label));
}
