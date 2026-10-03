import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/widgets/glass.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';

/// Floating return-to-top control over one vertical scrollable [child].
///
/// Uses [controller] or the route's [PrimaryScrollController]; it never owns
/// a controller. Appears after about one viewport of scroll. [scrollRequests]
/// lets the app ask for the same animation without a visible tap (tab reselect).
/// End the child scroll view with [UiSliverScrollToTopSpace] so its final
/// action can scroll fully above the overlay, including with enlarged text.
final class UiScrollToTop extends StatefulWidget {
  const UiScrollToTop({
    required this.tooltip,
    required this.child,
    this.controller,
    this.scrollRequests,
    super.key,
  });

  final String tooltip;
  final Widget child;
  final ScrollController? controller;
  final Listenable? scrollRequests;

  @override
  State<UiScrollToTop> createState() => _UiScrollToTopState();
}

final class _UiScrollToTopState extends State<UiScrollToTop> {
  ScrollController? _controller;
  bool _visible = false;
  bool _scheduled = false;

  @override
  void initState() {
    super.initState();
    widget.scrollRequests?.addListener(_scrollToTop);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bindController();
  }

  @override
  void didUpdateWidget(UiScrollToTop oldWidget) {
    super.didUpdateWidget(oldWidget);
    _bindController();
    if (oldWidget.scrollRequests == widget.scrollRequests) return;
    oldWidget.scrollRequests?.removeListener(_scrollToTop);
    widget.scrollRequests?.addListener(_scrollToTop);
  }

  @override
  void dispose() {
    widget.scrollRequests?.removeListener(_scrollToTop);
    _controller?.removeListener(_schedule);
    super.dispose();
  }

  void _bindController() {
    final ScrollController? controller =
        widget.controller ?? PrimaryScrollController.maybeOf(context);
    if (identical(controller, _controller)) return;
    _controller?.removeListener(_schedule);
    _controller = controller?..addListener(_schedule);
    _schedule();
  }

  /// Offsets and metrics can change several times, even in opposite
  /// directions, within one frame and while the tree is locked. Visibility is
  /// derived once after the frame from the controller's latest state.
  void _schedule() {
    if (_scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (!mounted) return;
      final bool visible = _farFromTop();
      if (visible != _visible) setState(() => _visible = visible);
    });
  }

  bool _farFromTop() {
    final ScrollController? controller = _controller;
    if (controller == null) return false;
    for (final ScrollPosition position in controller.positions) {
      if (position.axis != Axis.vertical ||
          !position.hasPixels ||
          !position.hasContentDimensions ||
          !position.hasViewportDimension) {
        continue;
      }
      if (position.pixels - position.minScrollExtent >
          position.viewportDimension) {
        return true;
      }
    }
    return false;
  }

  bool _onNotification(Notification notification) {
    if (notification is ScrollMetricsNotification ||
        notification is ScrollNotification) {
      _schedule();
    }
    return false;
  }

  void _scrollToTop() {
    final ScrollController? controller = _controller;
    if (!mounted) return;
    if (controller == null || !controller.hasClients) {
      // The scrollable was replaced by non-scrolling content: hide the button.
      _schedule();
      return;
    }
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    for (final ScrollPosition position in controller.positions.toList()) {
      if (position.axis != Axis.vertical || !position.hasPixels) continue;
      if (reduceMotion) {
        position.jumpTo(position.minScrollExtent);
      } else {
        unawaited(
          position.animateTo(
            position.minScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          ),
        );
      }
    }
  }

  /// The button floats in a [Stack] so it never displaces content.
  /// When hidden, no control remains in the hit-test or semantics tree.
  @override
  Widget build(BuildContext context) => Stack(
    children: <Widget>[
      NotificationListener<Notification>(
        onNotification: _onNotification,
        child: widget.child,
      ),
      // Fades and scales in/out; once hidden the control leaves the tree.
      Positioned(
        right: 0,
        bottom: 0,
        child: AnimatedSwitcher(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : UiMotion.reveal,
          switchInCurve: UiMotion.revealCurve,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (Widget child, Animation<double> animation) =>
              FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: .8, end: 1).animate(animation),
                  alignment: Alignment.bottomRight,
                  child: child,
                ),
              ),
          child: _visible
              ? Tooltip(
                  key: const ValueKey<bool>(true),
                  message: widget.tooltip,
                  child: _ScrollToTopControl(
                    tooltip: widget.tooltip,
                    onPressed: _scrollToTop,
                  ),
                )
              : const SizedBox.shrink(key: ValueKey<bool>(false)),
        ),
      ),
    ],
  );
}

/// Scrollable clearance with the exact control geometry. It adds scroll extent,
/// not a fixed bar or a changing viewport, and has no paint, focus or semantics.
final class UiSliverScrollToTopSpace extends StatelessWidget {
  const UiSliverScrollToTopSpace({required this.tooltip, super.key});
  final String tooltip;

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: Visibility(
      visible: false,
      maintainSize: true,
      maintainState: true,
      maintainAnimation: true,
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: _ScrollToTopControl(tooltip: tooltip),
      ),
    ),
  );
}

final class _ScrollToTopControl extends StatelessWidget {
  const _ScrollToTopControl({required this.tooltip, this.onPressed});
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsetsDirectional.only(
        end: UiSpace.lg,
        bottom: UiSpace.sm,
      ),
      child: _ScrollToTopButton(tooltip: tooltip, onPressed: onPressed),
    ),
  );
}

/// Round frosted-glass control with an arrow: a light veil on light pages,
/// smoky on dark ones, soft shadow, no saturated fill. The label lives in the
/// tooltip and semantics.
final class _ScrollToTopButton extends StatelessWidget {
  const _ScrollToTopButton({required this.tooltip, required this.onPressed});

  final String tooltip;
  final VoidCallback? onPressed;

  static const double _size = 44;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onPressed != null,
    label: tooltip,
    excludeSemantics: true,
    child: UiGlass.surface(
      shape: const CircleBorder(),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox.square(
            dimension: _size,
            child: Icon(
              Icons.keyboard_arrow_up_rounded,
              size: 26,
              color: UiGlass.onSurfaceGlass(context),
            ),
          ),
        ),
      ),
    ),
  );
}
