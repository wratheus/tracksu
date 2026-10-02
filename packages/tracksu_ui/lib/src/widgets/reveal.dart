import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';

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
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Fades its child in once, when first mounted (cold load). Later rebuilds of
/// the same element, such as refresh or pagination, keep it fully opaque, so
/// keep it at a stable position in the tree. Respects reduced motion.
final class UiReveal extends StatefulWidget {
  const UiReveal({required this.child, super.key});
  final Widget child;

  @override
  State<UiReveal> createState() => _UiRevealState();
}

final class _UiRevealState extends State<UiReveal>
    with SingleTickerProviderStateMixin, _RevealAnimation {
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
  Widget build(BuildContext context) => SliverFadeTransition(
    opacity: _opacity,
    alwaysIncludeSemantics: true,
    sliver: widget.sliver,
  );
}
