import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';
import 'package:tracksu_ui/src/widgets/button.dart';
import 'package:tracksu_ui/src/widgets/feedback.dart';
import 'package:tracksu_ui/src/widgets/text.dart';

enum _ContentState { empty, error, offline, loading }

/// Content-sized state, usable inside a SliverToBoxAdapter or bounded body.
final class UiContentState extends StatelessWidget {
  const UiContentState.empty({
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  }) : _state = _ContentState.empty,
       assert((actionLabel == null) == (onAction == null));
  const UiContentState.error({
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  }) : _state = _ContentState.error,
       assert((actionLabel == null) == (onAction == null));
  const UiContentState.offline({
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  }) : _state = _ContentState.offline,
       assert((actionLabel == null) == (onAction == null));
  const UiContentState.loading({required this.title, this.message, super.key})
    : _state = _ContentState.loading,
      actionLabel = null,
      onAction = null;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final _ContentState _state;

  @override
  Widget build(BuildContext context) => _state == _ContentState.loading
      ? Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            UiLoading(label: title),
            if (message case final String detail)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: UiSpace.xl),
                child: UiText.bodyMedium(
                  detail,
                  secondary: true,
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        )
      : Semantics(
          liveRegion:
              _state == _ContentState.error || _state == _ContentState.loading,
          child: Padding(
            // Empty/offline are notes inside a list, not page headlines: a
            // smaller icon and body text; errors keep the stronger title.
            padding: EdgeInsets.all(_quiet ? UiSpace.lg : UiSpace.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: _quiet ? UiSpace.sm : UiSpace.md,
              children: <Widget>[
                Icon(
                  switch (_state) {
                    _ContentState.empty => Icons.search_off,
                    _ContentState.error => Icons.error_outline,
                    _ContentState.offline => Icons.wifi_off_outlined,
                    _ContentState.loading => Icons.hourglass_empty,
                  },
                  size: _quiet ? 24 : 32,
                  color: _state == _ContentState.error
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                if (_quiet)
                  UiText.bodyMedium(
                    title,
                    secondary: true,
                    textAlign: TextAlign.center,
                  )
                else
                  UiText.titleMedium(title, textAlign: TextAlign.center),
                if (message != null)
                  (_quiet ? UiText.bodySmall : UiText.bodyMedium)(
                    message!,
                    secondary: true,
                    textAlign: TextAlign.center,
                  ),
                if (actionLabel != null)
                  UiButton.secondary(label: actionLabel!, onPressed: onAction),
              ],
            ),
          ),
        );

  bool get _quiet =>
      _state == _ContentState.empty || _state == _ContentState.offline;
}

/// The pulse a page skeleton gives its blocks: their fill fades between
/// [opacity] values without an opacity layer over the whole placeholder,
/// which had to be re-composited every frame (and stuttered page swipes
/// while several pages were loading, on Android most of all).
final class UiSkeletonPulse extends InheritedWidget {
  const UiSkeletonPulse({
    required this.opacity,
    required super.child,
    super.key,
  });
  final Animation<double> opacity;

  static Animation<double>? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<UiSkeletonPulse>()?.opacity;

  @override
  bool updateShouldNotify(UiSkeletonPulse oldWidget) =>
      oldWidget.opacity != opacity;
}

/// Skeleton block: static on its own, pulsing inside a page skeleton
/// ([UiSkeletonPulse]); its parent announces loading once.
final class UiSkeleton extends StatelessWidget {
  const UiSkeleton.line({this.width = double.infinity, super.key})
    : height = 12,
      radius = UiShape.control;
  const UiSkeleton.block({
    required this.height,
    this.width = double.infinity,
    super.key,
  }) : assert(height > 0),
       radius = UiShape.control;

  /// Fills its parent (e.g. a cover's aspect box) with square corners.
  const UiSkeleton.fill({super.key})
    : width = double.infinity,
      height = double.infinity,
      radius = 0;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _SkeletonPainter(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          radius: radius,
          pulse: UiSkeletonPulse.maybeOf(context),
        ),
      ),
    ),
  );
}

/// Repaints with the pulse; never rebuilds or adds a layer.
final class _SkeletonPainter extends CustomPainter {
  _SkeletonPainter({required this.color, required this.radius, this.pulse})
    : super(repaint: pulse);
  final Color color;
  final double radius;
  final Animation<double>? pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final double alpha = color.a * (pulse?.value ?? 1);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      Paint()..color = color.withValues(alpha: alpha),
    );
  }

  @override
  bool shouldRepaint(_SkeletonPainter old) =>
      old.color != color || old.radius != radius || old.pulse != pulse;
}
