import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
        primary: true,
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

  /// Content-fit draggable viewport. Builder returns a lazy scrollable with
  /// `primary: true` (no private controller), never Expanded or shrinkWrap.
  static Future<T?> scrollable<T>(
    BuildContext context, {
    required String title,
    required WidgetBuilder builder,
    Widget? cover,
    bool useRootNavigator = true,
  }) => _show<T>(
    context,
    title: title,
    builder: builder,
    scrollable: true,
    cover: cover,
    useRootNavigator: useRootNavigator,
  );

  static Future<T?> _show<T>(
    BuildContext context, {
    required String title,
    required WidgetBuilder builder,
    required bool scrollable,
    required bool useRootNavigator,
    Widget? cover,
  }) => showModalBottomSheet<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: cover == null ? null : false,
    clipBehavior: Clip.antiAlias,
    builder: (BuildContext modalContext) {
      final Widget titleHeader = _ModalHeader(
        title: title,
        onClose: () => _finish<T>(modalContext, null),
      );
      final Widget header = cover == null
          ? titleHeader
          : _ModalCoverHeader(cover: cover, title: titleHeader);
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(modalContext).bottom,
        ),
        child: SafeArea(
          top: false,
          child: scrollable
              ? _AdaptiveScrollSheet(header: header, builder: builder)
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

/// Full-bleed artwork is clipped by the sheet shape, not a second inset card.
/// An opaque surface behind text preserves contrast in both app themes.
final class _ModalCoverHeader extends StatelessWidget {
  const _ModalCoverHeader({required this.cover, required this.title});
  final Widget cover;
  final Widget title;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Stack(
      children: <Widget>[
        Positioned.fill(child: ExcludeSemantics(child: cover)),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const <double>[0, 0.35, 0.65, 1],
                colors: <Color>[
                  colors.surface.withValues(alpha: 0.2),
                  colors.surface.withValues(alpha: 0.1),
                  colors.surface.withValues(alpha: 0.95),
                  colors.surface,
                ],
              ),
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: UiSpace.md, bottom: 96),
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(UiShape.control),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(UiSpace.xs),
                    child: Container(
                      width: UiSpace.xxl,
                      height: UiSpace.xs,
                      decoration: BoxDecoration(
                        color: colors.onSurfaceVariant,
                        borderRadius: BorderRadius.circular(UiShape.control),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            title,
          ],
        ),
      ],
    );
  }
}

/// Fits short content after layout without shrink-wrapping an API-backed list.
/// Consumers use the inherited primary controller so dragging expands the sheet
/// before scrolling its contents. Once dragged, the user's chosen size wins.
final class _AdaptiveScrollSheet extends StatefulWidget {
  const _AdaptiveScrollSheet({required this.header, required this.builder});
  final Widget header;
  final WidgetBuilder builder;
  @override
  State<_AdaptiveScrollSheet> createState() => _AdaptiveScrollSheetState();
}

final class _AdaptiveScrollSheetState extends State<_AdaptiveScrollSheet> {
  final DraggableScrollableController _extent = DraggableScrollableController();
  final GlobalKey _header = GlobalKey();
  final GlobalKey _body = GlobalKey();
  bool _dragged = false;
  bool _scheduled = false;
  double? _target;
  double _minimum = 0.18;

  @override
  void dispose() {
    _extent.dispose();
    super.dispose();
  }

  bool _fit(ScrollMetricsNotification notification, double available) {
    if (_dragged || notification.depth != 0 || available <= 0) return false;
    final RenderObject? render = _header.currentContext?.findRenderObject();
    if (render is! RenderBox || !render.hasSize) return false;
    final double? content = _contentExtent();
    if (content == null) return false;
    final double minimum =
        ((render.size.height + UiShape.minTarget) / available).clamp(0.18, 0.9);
    _target = ((content + render.size.height + UiSpace.lg) / available).clamp(
      minimum,
      0.9,
    );
    if (!_scheduled) {
      _scheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scheduled = false;
        if (!mounted || _dragged || !_extent.isAttached) return;
        if ((_minimum - minimum).abs() > 0.005) {
          setState(() => _minimum = minimum);
        }
        final double? target = _target;
        if (target != null && (_extent.size - target).abs() > 0.005) {
          _extent.jumpTo(target);
        }
      });
    }
    return false;
  }

  double? _contentExtent() {
    double? result;
    void visit(RenderObject object) {
      if (result != null) return;
      if (object is RenderViewport) {
        double extent = 0;
        object.visitChildren((RenderObject child) {
          if (child is RenderSliver) {
            extent += child.geometry?.scrollExtent ?? 0;
          }
        });
        result = extent;
      } else {
        object.visitChildren(visit);
      }
    }

    final RenderObject? body = _body.currentContext?.findRenderObject();
    if (body != null) visit(body);
    return result;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) =>
        DraggableScrollableSheet(
          controller: _extent,
          expand: false,
          initialChildSize: (widget.header is _ModalCoverHeader ? 0.9 : 0.5)
              .clamp(_minimum, 0.95),
          minChildSize: _minimum,
          maxChildSize: 0.95,
          builder: (BuildContext context, ScrollController controller) =>
              PrimaryScrollController(
                controller: controller,
                child: NotificationListener<ScrollStartNotification>(
                  onNotification: (ScrollStartNotification notification) {
                    if (notification.dragDetails != null) _dragged = true;
                    return false;
                  },
                  child: NotificationListener<ScrollMetricsNotification>(
                    onNotification: (ScrollMetricsNotification notification) =>
                        _fit(notification, constraints.maxHeight),
                    child: Column(
                      children: <Widget>[
                        KeyedSubtree(key: _header, child: widget.header),
                        Expanded(
                          child: KeyedSubtree(
                            key: _body,
                            child: widget.builder(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ),
  );
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
