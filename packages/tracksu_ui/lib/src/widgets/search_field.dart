import 'package:flutter/material.dart';

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
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String clearLabel;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final String? errorText;
  final String? helperText;
  final bool enabled;

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
