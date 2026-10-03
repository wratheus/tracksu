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

/// Static skeleton: reduced-motion friendly; its parent announces loading once.
final class UiSkeleton extends StatelessWidget {
  const UiSkeleton.line({this.width = double.infinity, super.key})
    : height = 12;
  const UiSkeleton.block({
    required this.height,
    this.width = double.infinity,
    super.key,
  }) : assert(height > 0);
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(UiShape.control),
        ),
      ),
    ),
  );
}
