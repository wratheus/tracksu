import 'package:flutter/material.dart';
import 'package:tracksu/src/_shared/content/content_media_controller.dart';
import 'package:tracksu/src/_shared/content/data/content_media_loader.dart';

/// One bounded queue for a lazy media collection. Hidden routes/branches and
/// revoked permission stop requests; the builder must not fetch without a loader.
final class ContentMediaScope extends StatefulWidget {
  const ContentMediaScope({
    required this.permission,
    required this.builder,
    super.key,
  });
  final ContentMediaController permission;
  final Widget Function(BuildContext context, ContentMediaLoader? loader)
  builder;

  @override
  State<ContentMediaScope> createState() => _ContentMediaScopeState();
}

final class _ContentMediaScopeState extends State<ContentMediaScope>
    with WidgetsBindingObserver {
  ContentMediaLoader? _loader;
  bool _active = false;
  bool _foreground = true;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    widget.permission.addListener(_permissionChanged);
    WidgetsBinding.instance.addObserver(this);
    _foreground =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _visible =
        TickerMode.valuesOf(context).enabled &&
        (ModalRoute.isCurrentOf(context) ?? true);
    _sync();
  }

  @override
  void didUpdateWidget(ContentMediaScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.permission != widget.permission) {
      oldWidget.permission.removeListener(_permissionChanged);
      widget.permission.addListener(_permissionChanged);
      _sync();
    }
  }

  void _sync() {
    final bool active = _foreground && _visible && widget.permission.allowed;
    if (active && !_active) {
      _loader = ContentMediaLoader(cache: widget.permission.cache);
    } else if (!active) {
      _loader?.close();
      // Retain decoded previews while a route is covered. On resume a new
      // queue restarts only incomplete images, not all visible thumbnails.
      if (!widget.permission.allowed) _loader = null;
    }
    _active = active;
  }

  void _permissionChanged() => setState(_sync);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => setState(() {
    _foreground = state == AppLifecycleState.resumed;
    _sync();
  });

  @override
  void dispose() {
    widget.permission.removeListener(_permissionChanged);
    WidgetsBinding.instance.removeObserver(this);
    _loader?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _loader);
}
