import 'package:flutter/material.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// A titled group of options in the category sheet; a null title is ungrouped.
@immutable
final class OsuCategoryGroup<T extends Object> {
  const OsuCategoryGroup({required this.options, this.title});
  final String? title;
  final List<T> options;
}

/// One compact line showing the current category (icon, label, chevron); a tap
/// opens a sheet with all options. Used for profile score and map lists
/// instead of rows of chips. Refresh is pull-to-refresh on the page.
final class OsuCategoryPicker<T extends Object> extends StatefulWidget {
  const OsuCategoryPicker({
    required this.title,
    required this.selected,
    required this.groups,
    required this.icon,
    required this.label,
    required this.onSelected,
    super.key,
  });

  /// Semantics label and sheet title.
  final String title;
  final T selected;
  final List<OsuCategoryGroup<T>> groups;
  final IconData Function(T) icon;
  final String Function(BuildContext, T) label;
  final ValueChanged<T> onSelected;

  @override
  State<OsuCategoryPicker<T>> createState() => _OsuCategoryPickerState<T>();
}

final class _OsuCategoryPickerState<T extends Object>
    extends State<OsuCategoryPicker<T>> {
  bool _open = false;

  Future<void> _choose() async {
    if (_open) return;
    setState(() => _open = true);
    try {
      final T? value = await UiModal.scrollable<T>(
        context,
        title: widget.title,
        builder: (_) => _CategorySheet<T>(picker: widget),
      );
      if (!mounted || value == null || value == widget.selected) return;
      widget.onSelected(value);
    } finally {
      if (mounted) setState(() => _open = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: widget.title,
      value: widget.label(context, widget.selected),
      excludeSemantics: true,
      child: UiSurface.tonal(
        onTap: _open ? null : _choose,
        padding: const EdgeInsets.symmetric(
          horizontal: UiSpace.md,
          vertical: UiSpace.sm,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 32),
          child: Row(
            spacing: UiSpace.sm,
            children: <Widget>[
              Icon(widget.icon(widget.selected), size: 20, color: colors.primary),
              Expanded(
                child: UiText.labelLarge(
                  widget.label(context, widget.selected),
                  maxLines: 1,
                ),
              ),
              Icon(Icons.expand_more_rounded, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

final class _CategorySheet<T extends Object> extends StatelessWidget {
  const _CategorySheet({required this.picker});
  final OsuCategoryPicker<T> picker;

  @override
  Widget build(BuildContext context) => ListView(
    primary: true,
    padding: const EdgeInsets.only(bottom: UiSpace.lg),
    children: <Widget>[
      for (final OsuCategoryGroup<T> group in picker.groups) ...<Widget>[
        if (group.title case final String title)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              UiSpace.lg,
              UiSpace.md,
              UiSpace.lg,
              UiSpace.xs,
            ),
            child: UiText.labelLarge(title, secondary: true),
          ),
        for (final T option in group.options)
          UiTile.selection(
            key: ValueKey<T>(option),
            title: picker.label(context, option),
            leading: Icon(picker.icon(option)),
            selected: option == picker.selected,
            onTap: () {
              if (ModalRoute.of(context)?.isCurrent == true) {
                Navigator.of(context).pop(option);
              }
            },
          ),
      ],
    ],
  );
}
