import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';
import 'package:tracksu_ui/src/widgets/button.dart';
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
  Widget build(BuildContext context) => Semantics(
    liveRegion:
        _state == _ContentState.error || _state == _ContentState.loading,
    child: Padding(
      padding: const EdgeInsets.all(UiSpace.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: UiSpace.md,
        children: <Widget>[
          if (_state == _ContentState.loading)
            const SizedBox.square(
              dimension: 32,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(
              switch (_state) {
                _ContentState.empty => Icons.search_off,
                _ContentState.error => Icons.error_outline,
                _ContentState.offline => Icons.wifi_off_outlined,
                _ContentState.loading => Icons.hourglass_empty,
              },
              size: 32,
              color: _state == _ContentState.error
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          UiText.titleMedium(title, textAlign: TextAlign.center),
          if (message != null)
            UiText.bodyMedium(
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
