import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';

enum UiButtonStyle { primary, secondary, outlined, text, destructive }

/// The caller owns async work and loading state. No implicit network/haptic effect.
final class UiButton extends StatelessWidget {
  const UiButton({
    required this.label,
    required this.onPressed,
    this.style = UiButtonStyle.primary,
    this.icon,
    this.isLoading = false,
    this.loadingLabel,
    super.key,
  });

  const UiButton.primary({
    required String label,
    required VoidCallback? onPressed,
    Key? key,
    IconData? icon,
    bool isLoading = false,
    String? loadingLabel,
  }) : this(
         label: label,
         onPressed: onPressed,
         key: key,
         icon: icon,
         isLoading: isLoading,
         loadingLabel: loadingLabel,
         style: UiButtonStyle.primary,
       );

  const UiButton.secondary({
    required String label,
    required VoidCallback? onPressed,
    Key? key,
    IconData? icon,
    bool isLoading = false,
    String? loadingLabel,
  }) : this(
         label: label,
         onPressed: onPressed,
         key: key,
         icon: icon,
         isLoading: isLoading,
         loadingLabel: loadingLabel,
         style: UiButtonStyle.secondary,
       );

  const UiButton.outlined({
    required String label,
    required VoidCallback? onPressed,
    Key? key,
    IconData? icon,
    bool isLoading = false,
    String? loadingLabel,
  }) : this(
         label: label,
         onPressed: onPressed,
         key: key,
         icon: icon,
         isLoading: isLoading,
         loadingLabel: loadingLabel,
         style: UiButtonStyle.outlined,
       );

  const UiButton.text({
    required String label,
    required VoidCallback? onPressed,
    Key? key,
    IconData? icon,
    bool isLoading = false,
    String? loadingLabel,
  }) : this(
         label: label,
         onPressed: onPressed,
         key: key,
         icon: icon,
         isLoading: isLoading,
         loadingLabel: loadingLabel,
         style: UiButtonStyle.text,
       );

  const UiButton.destructive({
    required String label,
    required VoidCallback? onPressed,
    Key? key,
    IconData? icon,
    bool isLoading = false,
    String? loadingLabel,
  }) : this(
         label: label,
         onPressed: onPressed,
         key: key,
         icon: icon,
         isLoading: isLoading,
         loadingLabel: loadingLabel,
         style: UiButtonStyle.destructive,
       );

  final String label;
  final VoidCallback? onPressed;
  final UiButtonStyle style;
  final IconData? icon;
  final bool isLoading;
  final String? loadingLabel;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? action = isLoading ? null : onPressed;
    final Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: UiSpace.sm,
      children: <Widget>[
        if (isLoading)
          const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else if (icon != null)
          Icon(icon, size: 20),
        Flexible(
          child: Text(
            isLoading ? loadingLabel ?? label : label,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Widget button = switch (style) {
      UiButtonStyle.primary => FilledButton(onPressed: action, child: child),
      UiButtonStyle.secondary => FilledButton.tonal(
        onPressed: action,
        child: child,
      ),
      UiButtonStyle.outlined => OutlinedButton(onPressed: action, child: child),
      UiButtonStyle.text => TextButton(onPressed: action, child: child),
      UiButtonStyle.destructive => FilledButton(
        onPressed: action,
        style: FilledButton.styleFrom(
          backgroundColor: colors.error,
          foregroundColor: colors.onError,
        ),
        child: child,
      ),
    };
    return Semantics(liveRegion: isLoading, child: button);
  }
}
