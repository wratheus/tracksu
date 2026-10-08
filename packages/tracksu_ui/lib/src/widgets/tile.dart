import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/widgets/switch.dart';

enum _TileStyle { navigation, action, selection, value, toggle }

/// Semantic rows for menus, settings and choices. Theme owns density and shape.
final class UiTile extends StatelessWidget {
  const UiTile.navigation({
    required this.title,
    required this.onTap,
    this.subtitle,
    this.leading,
    super.key,
  }) : _style = _TileStyle.navigation,
       _onToggle = null,
       selected = false,
       value = null;
  const UiTile.action({
    required this.title,
    required this.onTap,
    this.subtitle,
    this.leading,
    super.key,
  }) : _style = _TileStyle.action,
       _onToggle = null,
       selected = false,
       value = null;
  const UiTile.selection({
    required this.title,
    required this.onTap,
    required this.selected,
    this.subtitle,
    this.leading,
    super.key,
  }) : _style = _TileStyle.selection,
       _onToggle = null,
       value = null;

  /// Settings-style row: the current [value] sits on the trailing edge before
  /// the chevron, so the row reads "Theme ……… Dark ›" without a subtitle.
  const UiTile.value({
    required this.title,
    required this.onTap,
    this.value,
    this.subtitle,
    this.leading,
    super.key,
  }) : _style = _TileStyle.value,
       _onToggle = null,
       selected = false;

  /// On/off row: [UiSwitch] on the trailing edge, the whole row toggles.
  /// A null [onToggle] disables it (e.g. while saving).
  const UiTile.toggle({
    required this.title,
    required this.selected,
    required ValueChanged<bool>? onToggle,
    this.subtitle,
    this.leading,
    super.key,
  }) : _style = _TileStyle.toggle,
       _onToggle = onToggle,
       onTap = null,
       value = null;

  final String title;
  final String? subtitle;
  final Widget? leading;
  final VoidCallback? onTap;
  final bool selected;
  final String? value;
  final _TileStyle _style;
  final ValueChanged<bool>? _onToggle;

  @override
  Widget build(BuildContext context) => _style == _TileStyle.toggle
      // The row is the control: it reports on/off, the switch is visual.
      ? Semantics(toggled: selected, child: _tile(context))
      : _tile(context);

  Widget _tile(BuildContext context) => ListTile(
    title: Text(title),
    subtitle: subtitle == null ? null : Text(subtitle!),
    leading: leading,
    enabled: _style == _TileStyle.toggle ? _onToggle != null : onTap != null,
    selected: _style == _TileStyle.toggle ? false : selected,
    onTap: _style == _TileStyle.toggle
        ? (_onToggle == null ? null : () => _onToggle(!selected))
        : onTap,
    trailing: switch (_style) {
      _TileStyle.navigation => const Icon(Icons.chevron_right),
      _TileStyle.action => null,
      _TileStyle.selection => selected ? const Icon(Icons.check) : null,
      _TileStyle.toggle => ExcludeSemantics(
        child: UiSwitch(value: selected, onChanged: _onToggle),
      ),
      _TileStyle.value => Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: <Widget>[
          if (value case final String text)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          const Icon(Icons.chevron_right),
        ],
      ),
    },
  );
}

/// Leading icon for list rows: a tinted rounded square, so a list of
/// settings scans by colour and shape rather than by text alone.
final class UiTileIcon extends StatelessWidget {
  const UiTileIcon(this.icon, {super.key});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox.square(
        dimension: 32,
        child: Icon(icon, size: 18, color: colors.onPrimaryContainer),
      ),
    );
  }
}

/// Grouped list section: a quiet caption, rows on one card with inset
/// dividers, optional footnote. The reusable shape of settings-like pages.
final class UiListGroup extends StatelessWidget {
  const UiListGroup({
    required this.children,
    this.title,
    this.footer,
    super.key,
  });
  final String? title;
  final List<Widget> children;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: <Widget>[
        if (title case final String caption)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 16),
            child: Semantics(
              header: true,
              child: Text(
                caption,
                style: text.labelLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (int i = 0; i < children.length; i++) ...<Widget>[
                  if (i > 0)
                    const Divider(height: 1, indent: 64, endIndent: 16),
                  children[i],
                ],
              ],
            ),
          ),
        ),
        if (footer case final String note)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
            child: Text(
              note,
              style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ),
      ],
    );
  }
}
