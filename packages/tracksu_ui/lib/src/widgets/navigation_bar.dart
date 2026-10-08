import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';

final class UiNavigationItem {
  const UiNavigationItem({
    required this.label,
    required this.icon,
    this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData? selectedIcon;
}

/// Bottom bar: the tabs, and — as the iOS 26 search tab — search as its own
/// round button at the trailing end. [selectedIndex] is null while search is
/// the open tab. The app owns stacks and selection policy.
final class UiNavigationBar extends StatelessWidget {
  const UiNavigationBar({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.search,
    this.searchSelected = false,
    this.onSearch,
    super.key,
  });

  final List<UiNavigationItem> items;
  final int? selectedIndex;
  final ValueChanged<int> onSelected;

  /// Label (tooltip, accessibility) of the separate search tab; null hides it.
  final String? search;
  final bool searchSelected;
  final VoidCallback? onSearch;

  static const double height = 72;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: height,
          child: Row(
            children: <Widget>[
              for (int index = 0; index < items.length; index++)
                Expanded(
                  child: _Destination(
                    item: items[index],
                    selected: index == selectedIndex,
                    onTap: () => onSelected(index),
                  ),
                ),
              if (search case final String label)
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: UiSpace.xs,
                    end: UiSpace.lg,
                  ),
                  child: _SearchTab(
                    label: label,
                    selected: searchSelected,
                    onTap: onSearch,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _Destination extends StatelessWidget {
  const _Destination({
    required this.item,
    required this.selected,
    required this.onTap,
  });
  final UiNavigationItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final Duration duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 200);
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: Tooltip(
        message: item.label,
        excludeFromSemantics: true,
        child: InkResponse(
          onTap: onTap,
          containedInkWell: true,
          highlightShape: BoxShape.rectangle,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: UiSpace.xs,
            children: <Widget>[
              AnimatedContainer(
                duration: duration,
                curve: Curves.easeOutCubic,
                width: selected ? 64 : 48,
                height: 32,
                decoration: BoxDecoration(
                  color: selected
                      ? colors.primaryContainer
                      : colors.primaryContainer.withValues(alpha: 0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  selected ? item.selectedIcon ?? item.icon : item.icon,
                  color: selected
                      ? colors.onPrimaryContainer
                      : colors.onSurfaceVariant,
                ),
              ),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: selected ? colors.onSurface : colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Round, separate from the tabs, filled with the accent while open.
final class _SearchTab extends StatelessWidget {
  const _SearchTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  static const double size = 52;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        excludeFromSemantics: true,
        child: Material(
          color: selected
              ? colors.primaryContainer
              : colors.surfaceContainerHighest,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox.square(
              dimension: size,
              child: Icon(
                Icons.search_rounded,
                color: selected
                    ? colors.onPrimaryContainer
                    : colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
