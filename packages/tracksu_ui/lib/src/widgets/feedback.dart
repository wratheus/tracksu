import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';
import 'package:tracksu_ui/src/widgets/text.dart';

enum UiNoticeTone { information, success, warning, error }

/// In-content feedback, never a global listener or a full-screen error policy.
final class UiNotice extends StatelessWidget {
  const UiNotice({
    required this.message,
    this.tone = UiNoticeTone.information,
    this.actionLabel,
    this.onAction,
    super.key,
  }) : assert((actionLabel == null) == (onAction == null));

  final String message;
  final UiNoticeTone tone;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final UiStatusColors? status = theme.extension<UiStatusColors>();
    final (Color background, Color foreground, IconData icon) = switch (tone) {
      UiNoticeTone.information => (
        colors.secondaryContainer,
        colors.onSecondaryContainer,
        Icons.info_outline,
      ),
      UiNoticeTone.success => (
        status?.success ?? colors.secondaryContainer,
        status?.onSuccess ?? colors.onSecondaryContainer,
        Icons.check_circle_outline,
      ),
      UiNoticeTone.warning => (
        status?.warning ?? colors.tertiaryContainer,
        status?.onWarning ?? colors.onTertiaryContainer,
        Icons.warning_amber_rounded,
      ),
      UiNoticeTone.error => (
        colors.errorContainer,
        colors.onErrorContainer,
        Icons.error_outline,
      ),
    };
    return Semantics(
      liveRegion: tone == UiNoticeTone.error,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(UiShape.control),
        child: Padding(
          padding: const EdgeInsets.all(UiSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: UiSpace.sm,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: UiSpace.md,
                children: <Widget>[
                  Icon(icon, color: foreground),
                  Expanded(
                    child: Text(
                      message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: foreground,
                      ),
                    ),
                  ),
                ],
              ),
              if (actionLabel != null)
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    style: TextButton.styleFrom(foregroundColor: foreground),
                    onPressed: onAction,
                    child: Text(actionLabel!),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Host supplies localized text and decides when an effect occurs.
abstract final class UiFeedback {
  /// Replaces the visible snackbar; avoid replaying a queue of stale errors.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snack(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    assert((actionLabel == null) == (onAction == null));
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.removeCurrentSnackBar();
    return messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        action: actionLabel == null || onAction == null
            ? null
            : SnackBarAction(label: actionLabel, onPressed: onAction),
      ),
    );
  }
}

/// Inline, labelled progress for initial loading or pagination.
final class UiLoading extends StatelessWidget {
  const UiLoading({required this.label, super.key});
  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Padding(
      padding: const EdgeInsets.all(UiSpace.lg),
      child: Row(
        spacing: UiSpace.md,
        children: <Widget>[
          const SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          Expanded(child: UiText.bodyMedium(label, secondary: true)),
        ],
      ),
    ),
  );
}
