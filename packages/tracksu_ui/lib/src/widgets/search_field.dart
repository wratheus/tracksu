import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';

/// Controller/focus/query policy belong to the calling feature.
final class UiSearchField extends StatelessWidget {
  const UiSearchField({
    required this.controller,
    required this.label,
    required this.clearLabel,
    this.onSubmitted,
    this.onChanged,
    this.focusNode,
    this.errorText,
    this.helperText,
    this.enabled = true,
    this.autofocus = false,
    super.key,
  });

  /// One-line field height at the current text scale (theme padding is
  /// [UiSpace.lg] around a body-large line); app bars size from it.
  static double heightOf(BuildContext context) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: 'Ag', style: Theme.of(context).textTheme.bodyLarge),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final double line = painter.height;
    painter.dispose();
    return (UiSpace.lg * 2 + line).ceilToDouble();
  }

  final TextEditingController controller;
  final String label;
  final String clearLabel;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final String? errorText;
  final String? helperText;
  final bool enabled;

  /// Opens the keyboard as soon as the field appears (search screens).
  final bool autofocus;

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder:
            (BuildContext context, TextEditingValue value, Widget? child) =>
                TextField(
                  controller: controller,
                  focusNode: focusNode,
                  enabled: enabled,
                  autofocus: autofocus,
                  onSubmitted: onSubmitted,
                  onChanged: onChanged,
                  textInputAction: TextInputAction.search,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: label,
                    helperText: helperText,
                    errorText: errorText,
                    errorMaxLines: 4,
                    helperMaxLines: 4,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: value.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: clearLabel,
                            onPressed: enabled
                                ? () {
                                    controller.clear();
                                    onChanged?.call('');
                                  }
                                : null,
                            icon: const Icon(Icons.close),
                          ),
                  ),
                ),
      );
}
