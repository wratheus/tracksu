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

  /// The closed picker in the app's control shape: a chamfered glass bar
  /// like the segmented controls, the current option's icon in an accent
  /// chip, the picker's name above the value, an unfold mark at the end.
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return Semantics(
      button: true,
      label: widget.title,
      value: widget.label(context, widget.selected),
      excludeSemantics: true,
      child: Material(
        shape: UiOptionRow.shape.copyWith(
          side: BorderSide(color: colors.onSurface.withValues(alpha: 0.1)),
        ),
        clipBehavior: Clip.antiAlias,
        color: colors.surfaceContainerHighest.withValues(alpha: 0.72),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                colors.onSurface.withValues(alpha: 0.08),
                colors.onSurface.withValues(alpha: 0.01),
              ],
            ),
          ),
          child: InkWell(
            onTap: _open ? null : _choose,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                UiSpace.sm,
                UiSpace.sm,
                UiSpace.md,
                UiSpace.sm,
              ),
              child: Row(
                spacing: UiSpace.md,
                children: <Widget>[
                  DecoratedBox(
                    decoration: ShapeDecoration(
                      shape: const BeveledRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(UiSpace.sm),
                          bottomRight: Radius.circular(UiSpace.sm),
                        ),
                      ),
                      color: colors.primaryContainer,
                    ),
                    child: SizedBox.square(
                      dimension: 36,
                      child: Icon(
                        widget.icon(widget.selected),
                        size: 20,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          widget.label(context, widget.selected),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.unfold_more_rounded,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
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
    padding: const EdgeInsets.fromLTRB(UiSpace.lg, 0, UiSpace.lg, UiSpace.lg),
    children: <Widget>[
      for (final OsuCategoryGroup<T> group in picker.groups) ...<Widget>[
        if (group.title case final String title)
          Padding(
            padding: const EdgeInsets.fromLTRB(0, UiSpace.md, 0, UiSpace.sm),
            child: UiText.labelLarge(title, secondary: true),
          ),
        for (final T option in group.options)
          Padding(
            key: ValueKey<T>(option),
            padding: const EdgeInsets.only(bottom: UiSpace.sm),
            child: UiOptionRow(
              label: picker.label(context, option),
              icon: picker.icon(option),
              selected: option == picker.selected,
              onTap: () {
                if (ModalRoute.of(context)?.isCurrent == true) {
                  Navigator.of(context).pop(option);
                }
              },
            ),
          ),
      ],
    ],
  );
}
