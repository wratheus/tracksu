import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/content/data/content_media_loader.dart';
import 'package:tracksu/src/_shared/content/domain/content_document.dart';
import 'package:tracksu/src/_shared/content/widgets/content_image.dart';
import 'package:tracksu_ui/tracksu_ui.dart';
import 'package:tracksu/src/_shared/content/content_media_controller.dart';
import 'package:tracksu/src/_shared/content/widgets/content_media_settings.dart';

/// Feature-agnostic lazy document. Parent supplies navigation and the document.
final class ContentFrame extends StatefulWidget {
  const ContentFrame.sliver({
    required this.document,
    required this.onOpenLink,
    this.mediaPermission,
    super.key,
  });
  final ContentDocument document;
  final Future<bool> Function(String url) onOpenLink;
  // No controller (e.g. offline catalog) never permits network images.
  final ContentMediaController? mediaPermission;
  @override
  State<ContentFrame> createState() => _ContentFrameState();
}

final class _ContentFrameState extends State<ContentFrame>
    with WidgetsBindingObserver {
  late ContentMediaLoader _media;
  bool _foreground = true;
  bool _visibleBranch = true;
  bool _fetching = true;
  final Set<int> _expanded = <int>{};
  late List<({ContentBlock block, int depth})> _visible;

  @override
  void initState() {
    super.initState();
    _media = ContentMediaLoader(cache: widget.mediaPermission?.cache);
    widget.mediaPermission?.addListener(_permissionChanged);
    WidgetsBinding.instance.addObserver(this);
    _foreground =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    _flatten();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _visibleBranch =
        TickerMode.valuesOf(context).enabled &&
        (ModalRoute.isCurrentOf(context) ?? true);
    _syncMedia();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _foreground = state == AppLifecycleState.resumed;
      _syncMedia();
    });
  }

  void _syncMedia() {
    final bool fetching =
        _foreground &&
        _visibleBranch &&
        widget.mediaPermission?.allowed == true;
    if (_fetching == fetching) return;
    _fetching = fetching;
    if (fetching) {
      _media = ContentMediaLoader(cache: widget.mediaPermission?.cache);
    } else {
      _media.close();
    }
  }

  @override
  void didUpdateWidget(ContentFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mediaPermission != widget.mediaPermission) {
      oldWidget.mediaPermission?.removeListener(_permissionChanged);
      widget.mediaPermission?.addListener(_permissionChanged);
      _syncMedia();
    }
    if (!identical(oldWidget.document, widget.document)) {
      _media.close();
      _media = ContentMediaLoader(cache: widget.mediaPermission?.cache);
      if (!_fetching) _media.close();
      _expanded.clear();
      _flatten();
    }
  }

  void _flatten() {
    _visible = <({ContentBlock block, int depth})>[];
    void visit(List<ContentBlock> blocks, int depth) {
      for (final ContentBlock block in blocks) {
        _visible.add((block: block, depth: depth));
        if (block is ContentDisclosure && _expanded.contains(block.id)) {
          visit(block.children, depth + 1);
        }
      }
    }

    visit(widget.document.blocks, 0);
  }

  @override
  void dispose() {
    widget.mediaPermission?.removeListener(_permissionChanged);
    WidgetsBinding.instance.removeObserver(this);
    _media.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SliverMainAxisGroup(
    slivers: <Widget>[
      if (widget.mediaPermission case final ContentMediaController permission
          when permission.choice == null && _hasImages(widget.document.blocks))
        SliverToBoxAdapter(
          child: UiSurface.inset(
            child: ContentMediaSettings(controller: permission),
          ),
        ),
      _content(context),
    ],
  );

  void _permissionChanged() => setState(_syncMedia);

  bool _hasImages(List<ContentBlock> blocks) => blocks.any(
    (ContentBlock block) =>
        block is ContentImage && block.uri != null ||
        block is ContentDisclosure && _hasImages(block.children),
  );

  Widget _content(BuildContext context) => SliverList.builder(
    key: ObjectKey(widget.document),
    itemCount: _visible.length,
    findChildIndexCallback: (Key key) {
      final int index = _visible.indexWhere(
        (entry) => ValueKey<int>(entry.block.id) == key,
      );
      return index < 0 ? null : index;
    },
    itemBuilder: (BuildContext context, int index) {
      final (:ContentBlock block, :int depth) = _visible[index];
      return Padding(
        key: ValueKey<int>(block.id),
        padding: EdgeInsetsDirectional.only(
          start: depth.clamp(0, 3) * UiSpace.sm,
          top: UiSpace.sm,
          bottom: UiSpace.sm,
        ),
        child: switch (block) {
          ContentText() => _text(context, block),
          ContentImage() =>
            widget.mediaPermission?.allowed == true
                ? ContentImageView(image: block, loader: _media)
                : UiSurface.inset(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: UiSpace.sm,
                      children: <Widget>[
                        if (block.alt.isNotEmpty) UiText.bodySmall(block.alt),
                        UiText.bodySmall(
                          context.t.contentMediaDisabled,
                          secondary: true,
                        ),
                      ],
                    ),
                  ),
          ContentDisclosure() => Semantics(
            expanded: _expanded.contains(block.id),
            child: UiSurface.outlined(
              padding: const EdgeInsets.all(UiSpace.xs),
              child: UiButton.text(
                label: block.title.isEmpty
                    ? context.t.contentDisclosure
                    : block.title,
                icon: _expanded.contains(block.id)
                    ? Icons.expand_less
                    : Icons.expand_more,
                onPressed: () => setState(() {
                  if (!_expanded.remove(block.id)) _expanded.add(block.id);
                  _flatten();
                }),
              ),
            ),
          ),
          ContentUnsupported() => UiSurface.inset(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: UiSpace.sm,
              children: <Widget>[
                UiText.bodySmall(context.t.contentUnsupported, secondary: true),
                UiButton.text(
                  label: context.t.contentOriginal,
                  icon: Icons.open_in_new,
                  onPressed: () =>
                      widget.onOpenLink(widget.document.uri.toString()),
                ),
              ],
            ),
          ),
        },
      );
    },
  );

  Widget _text(BuildContext context, ContentText block) {
    final ThemeData theme = Theme.of(context);
    final Widget text = SelectionArea(
      child: HtmlWidget(
        block.html,
        baseUrl: widget.document.uri,
        onTapUrl: widget.onOpenLink,
        textStyle: theme.textTheme.bodyMedium,
        customStylesBuilder: (element) {
          final Map<String, String> styles = <String, String>{};
          final String? scale = element.attributes['data-content-scale'];
          if (scale != null) {
            final double fontSize = theme.textTheme.bodyMedium?.fontSize ?? 14;
            styles['font-size'] = '${fontSize * int.parse(scale) / 100}px';
          }
          final String? hex = element.attributes['data-content-color'];
          if (hex == null) return styles.isEmpty ? null : styles;
          final Color original = Color(
            0xff000000 | int.parse(hex.substring(1), radix: 16),
          );
          final Color surface = theme.colorScheme.surface;
          Color visible = original;
          for (int step = 0; step <= 10; step++) {
            visible = Color.lerp(
              original,
              theme.colorScheme.onSurface,
              step / 10,
            )!;
            final double a = visible.computeLuminance();
            final double b = surface.computeLuminance();
            if ((a > b ? (a + .05) / (b + .05) : (b + .05) / (a + .05)) >=
                4.5) {
              break;
            }
          }
          styles['color'] =
              '#${(visible.toARGB32() & 0xffffff).toRadixString(16).padLeft(6, '0')}';
          return styles;
        },
      ),
    );
    if (!block.horizontal) return text;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) =>
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
                maxWidth: constraints.maxWidth * 2,
              ),
              child: text,
            ),
          ),
    );
  }
}
