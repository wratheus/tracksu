import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';
import 'package:tracksu_ui/src/widgets/button.dart';
import 'package:tracksu_ui/src/widgets/icon_button.dart';
import 'package:tracksu_ui/src/widgets/text.dart';
import 'package:tracksu_ui/src/widgets/tile.dart';

@immutable
final class UiChoice<T extends Object> {
  const UiChoice({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
    this.enabled = true,
  });
  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
  final bool enabled;
}

/// One modal policy. No feature mutations, stored context or hidden localization.
abstract final class UiModal {
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required String cancelLabel,
    bool useRootNavigator = true,
  }) => _confirmation(
    context,
    title: title,
    message: message,
    confirmLabel: confirmLabel,
    cancelLabel: cancelLabel,
    destructive: false,
    useRootNavigator: useRootNavigator,
  );

  static Future<bool> destructive(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required String cancelLabel,
    bool useRootNavigator = true,
  }) => _confirmation(
    context,
    title: title,
    message: message,
    confirmLabel: confirmLabel,
    cancelLabel: cancelLabel,
    destructive: true,
    useRootNavigator: useRootNavigator,
  );

  static Future<bool> _confirmation(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required String cancelLabel,
    required bool destructive,
    required bool useRootNavigator,
  }) async =>
      await sheet<bool>(
        context,
        title: title,
        useRootNavigator: useRootNavigator,
        builder: (BuildContext modalContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: UiSpace.lg,
          children: <Widget>[
            UiText.bodyLarge(message, secondary: true),
            UiButton(
              label: confirmLabel,
              style: destructive
                  ? UiButtonStyle.destructive
                  : UiButtonStyle.primary,
              onPressed: () => _finish(modalContext, true),
            ),
            UiButton.text(
              label: cancelLabel,
              onPressed: () => _finish(modalContext, false),
            ),
          ],
        ),
      ) ??
      false;

  static Future<void> info(
    BuildContext context, {
    required String title,
    required String message,
    required String closeLabel,
    bool useRootNavigator = true,
  }) => sheet<void>(
    context,
    title: title,
    useRootNavigator: useRootNavigator,
    builder: (BuildContext modalContext) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: UiSpace.lg,
      children: <Widget>[
        UiText.bodyLarge(message, secondary: true),
        UiButton.primary(
          label: closeLabel,
          onPressed: () => _finish<void>(modalContext, null),
        ),
      ],
    ),
  );

  /// A single tap returns the typed choice; dismiss returns null, not selection.
  static Future<T?> selection<T extends Object>(
    BuildContext context, {
    required String title,
    required List<UiChoice<T>> choices,
    T? selected,
    bool useRootNavigator = true,
  }) {
    final List<UiChoice<T>> items = List<UiChoice<T>>.unmodifiable(choices);
    assert(
      items.map((UiChoice<T> item) => item.value).toSet().length ==
          items.length,
    );
    return scrollable<T>(
      context,
      title: title,
      useRootNavigator: useRootNavigator,
      builder: (BuildContext modalContext) => ListView.builder(
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final UiChoice<T> item = items[index];
          return UiTile.selection(
            key: ValueKey<T>(item.value),
            title: item.label,
            subtitle: item.subtitle,
            leading: item.icon == null ? null : Icon(item.icon),
            selected: item.value == selected,
            onTap: item.enabled
                ? () => _finish(modalContext, item.value)
                : null,
          );
        },
      ),
    );
  }

  /// Short content/form; the sheet owns scrolling, padding and keyboard insets.
  static Future<T?> sheet<T>(
    BuildContext context, {
    required String title,
    required WidgetBuilder builder,
    bool useRootNavigator = true,
  }) => _show<T>(
    context,
    title: title,
    builder: builder,
    scrollable: false,
    useRootNavigator: useRootNavigator,
  );

  /// Bounded viewport; builder must return its own lazy scrollable, not Expanded.
  static Future<T?> scrollable<T>(
    BuildContext context, {
    required String title,
    required WidgetBuilder builder,
    bool useRootNavigator = true,
  }) => _show<T>(
    context,
    title: title,
    builder: builder,
    scrollable: true,
    useRootNavigator: useRootNavigator,
  );

  static Future<T?> _show<T>(
    BuildContext context, {
    required String title,
    required WidgetBuilder builder,
    required bool scrollable,
    required bool useRootNavigator,
  }) => showModalBottomSheet<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (BuildContext modalContext) {
      final Widget header = _ModalHeader(
        title: title,
        onClose: () => _finish<T>(modalContext, null),
      );
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(modalContext).bottom,
        ),
        child: SafeArea(
          top: false,
          child: scrollable
              ? FractionallySizedBox(
                  heightFactor: 0.85,
                  child: Column(
                    children: <Widget>[
                      header,
                      Expanded(child: builder(modalContext)),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      header,
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          UiSpace.lg,
                          0,
                          UiSpace.lg,
                          UiSpace.xl,
                        ),
                        child: builder(modalContext),
                      ),
                    ],
                  ),
                ),
        ),
      );
    },
  );

  static void _finish<T>(BuildContext context, T? result) {
    // A second tap during reverse animation must not pop the underlying page.
    if (ModalRoute.of(context)?.isCurrent != true) return;
    Navigator.of(context).pop<T>(result);
  }
}

final class _ModalHeader extends StatelessWidget {
  const _ModalHeader({required this.title, required this.onClose});
  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(UiSpace.lg, 0, UiSpace.sm, UiSpace.md),
    child: Row(
      spacing: UiSpace.sm,
      children: <Widget>[
        Expanded(
          child: Semantics(header: true, child: UiText.headlineSmall(title)),
        ),
        UiIconButton.standard(
          icon: Icons.close,
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          onPressed: onClose,
        ),
      ],
    ),
  );
}
