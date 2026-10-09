import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';

// Where a page placeholder has been shown, by scrollable and by route.
// Content that replaces a placeholder fades in; content that is already
// there when its page first builds (a cache hit, or a tab page swiped into
// after it loaded in the background) appears at once, so a swipe never
// carries a half-transparent page.
final Expando<bool> _shownIn = Expando<bool>('placeholder shown in');
final Expando<bool> _shownAround = Expando<bool>('placeholder outside a list');

/// Records that a page placeholder is on screen; [UiPageSkeleton] calls it.
void markRevealPlaceholder(BuildContext context) {
  final ScrollableState? scrollable = context
      .findAncestorStateOfType<ScrollableState>();
  final ModalRoute<Object?>? route = ModalRoute.of(context);
  if (scrollable != null) _shownIn[scrollable] = true;
  if (route != null) {
    _shownIn[route] = true;
    if (scrollable == null) _shownAround[route] = true;
  }
}

/// Inside a list: a placeholder showed in that list, or around it on the
/// page. Outside a list: a placeholder showed anywhere on the page.
bool _followsPlaceholder(BuildContext context) {
  final ScrollableState? scrollable = context
      .findAncestorStateOfType<ScrollableState>();
  final ModalRoute<Object?>? route = ModalRoute.of(context);
  if (scrollable == null && route == null) return true;
  if (scrollable != null) {
    return _shownIn[scrollable] ?? (route != null && _shownAround[route] == true);
  }
  return _shownIn[route!] ?? false;
}

mixin _RevealAnimation<T extends StatefulWidget>
    on State<T>, SingleTickerProviderStateMixin<T> {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: UiMotion.reveal,
  );
  late final Animation<double> _opacity = _controller.drive(
    CurveTween(curve: UiMotion.revealCurve),
  );
  bool _started = false;

  /// Fade even without a placeholder before (an image that just decoded).
  bool get _always;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      // Also stops a fade already in flight; turning it off later won't replay.
      _started = true;
      _controller.value = 1;
      return;
    }
    if (_started) return;
    _started = true;
    if (_always || _followsPlaceholder(context)) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Fades its child in once, when it replaces a page placeholder. Content
/// that is ready on the page's first build appears at once. Later rebuilds of
/// the same element, such as refresh or pagination, keep it fully opaque, so
/// keep it at a stable position in the tree. Respects reduced motion.
final class UiReveal extends StatefulWidget {
  const UiReveal({required this.child, this.always = false, super.key});
  final Widget child;

  /// Fade in even when no placeholder was shown, e.g. an image that has
  /// just been decoded over its blank box.
  final bool always;

  @override
  State<UiReveal> createState() => _UiRevealState();
}

final class _UiRevealState extends State<UiReveal>
    with SingleTickerProviderStateMixin, _RevealAnimation {
  @override
  bool get _always => widget.always;

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _opacity,
    alwaysIncludeSemantics: true,
    child: widget.child,
  );
}

/// Sliver counterpart of [UiReveal]; keeps lazy slivers lazy.
final class UiSliverReveal extends StatefulWidget {
  const UiSliverReveal({required this.sliver, super.key});
  final Widget sliver;

  @override
  State<UiSliverReveal> createState() => _UiSliverRevealState();
}

final class _UiSliverRevealState extends State<UiSliverReveal>
    with SingleTickerProviderStateMixin, _RevealAnimation {
  @override
  bool get _always => false;

  @override
  Widget build(BuildContext context) => SliverFadeTransition(
    opacity: _opacity,
    alwaysIncludeSemantics: true,
    sliver: widget.sliver,
  );
}
