import 'package:flutter/material.dart';

enum _TileStyle { navigation, action, selection }

/// Semantic rows for menus, settings and choices. Theme owns density and shape.
final class UiTile extends StatelessWidget {
  const UiTile.navigation({
    required this.title,
    required this.onTap,
    this.subtitle,
    this.leading,
    super.key,
  }) : _style = _TileStyle.navigation,
       selected = false;
  const UiTile.action({
    required this.title,
    required this.onTap,
    this.subtitle,
    this.leading,
    super.key,
  }) : _style = _TileStyle.action,
       selected = false;
  const UiTile.selection({
    required this.title,
    required this.onTap,
    required this.selected,
    this.subtitle,
    this.leading,
    super.key,
  }) : _style = _TileStyle.selection;

  final String title;
  final String? subtitle;
  final Widget? leading;
  final VoidCallback? onTap;
  final bool selected;
  final _TileStyle _style;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(title),
    subtitle: subtitle == null ? null : Text(subtitle!),
    leading: leading,
    enabled: onTap != null,
    selected: selected,
    onTap: onTap,
    trailing: switch (_style) {
      _TileStyle.navigation => const Icon(Icons.chevron_right),
      _TileStyle.action => null,
      _TileStyle.selection => selected ? const Icon(Icons.check) : null,
    },
  );
}
