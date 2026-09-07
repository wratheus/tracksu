import 'package:flutter/material.dart';

enum _IconButtonStyle { standard, filled, tonal, outlined }

/// Icon actions always require localized tooltip/accessibility text.
final class UiIconButton extends StatelessWidget {
  const UiIconButton.standard({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isSelected,
    this.selectedIcon,
    super.key,
  }) : _style = _IconButtonStyle.standard;

  const UiIconButton.filled({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isSelected,
    this.selectedIcon,
    super.key,
  }) : _style = _IconButtonStyle.filled;

  const UiIconButton.tonal({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isSelected,
    this.selectedIcon,
    super.key,
  }) : _style = _IconButtonStyle.tonal;

  const UiIconButton.outlined({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isSelected,
    this.selectedIcon,
    super.key,
  }) : _style = _IconButtonStyle.outlined;

  final IconData icon;
  final IconData? selectedIcon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool? isSelected;
  final _IconButtonStyle _style;

  @override
  Widget build(BuildContext context) => switch (_style) {
    _IconButtonStyle.standard => IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: onPressed,
      isSelected: isSelected,
      selectedIcon: selectedIcon == null ? null : Icon(selectedIcon),
    ),
    _IconButtonStyle.filled => IconButton.filled(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: onPressed,
      isSelected: isSelected,
      selectedIcon: selectedIcon == null ? null : Icon(selectedIcon),
    ),
    _IconButtonStyle.tonal => IconButton.filledTonal(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: onPressed,
      isSelected: isSelected,
      selectedIcon: selectedIcon == null ? null : Icon(selectedIcon),
    ),
    _IconButtonStyle.outlined => IconButton.outlined(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: onPressed,
      isSelected: isSelected,
      selectedIcon: selectedIcon == null ? null : Icon(selectedIcon),
    ),
  };
}
