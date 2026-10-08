import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/chrome/app_bar_actions.dart';
import 'package:tracksu/src/_shared/navigation/external_links.dart';
import 'package:tracksu/src/_shared/sharing/share_target.dart';
import 'package:tracksu_ui/tracksu_ui.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Shows one linked web page inside the app — a page, not a browser.
///
/// There is no address bar and no way to enter a URL. Navigation is locked to
/// the opened page: redirects while it loads and in-page anchors are allowed;
/// any other link leaves the app for the system browser. Pop-ups do not open.
/// The page gets no app cookies, tokens or JavaScript bridges. See ADR-009.
final class WebPageScreen extends StatefulWidget {
  const WebPageScreen({required this.uri, super.key});
  final Uri uri;

  @override
  State<WebPageScreen> createState() => _WebPageScreenState();
}

final class _WebPageScreenState extends State<WebPageScreen> {
  late final WebViewController _controller;
  String? _title;
  bool _loading = true;
  bool _failed = false;

  /// Until the first page finishes, server redirects of the opened link are
  /// part of opening it.
  bool _settled = false;
  Uri? _page;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: _decide,
          onPageStarted: (_) => _set(loading: true),
          onPageFinished: (String url) async {
            _settled = true;
            _page = Uri.tryParse(url) ?? _page;
            final String? title = await _controller.getTitle();
            if (!mounted) return;
            setState(() {
              _loading = false;
              _title = title == null || title.trim().isEmpty ? null : title;
            });
          },
          onWebResourceError: (WebResourceError error) {
            if (error.isForMainFrame ?? true) {
              _set(loading: false, failed: true);
            }
          },
        ),
      )
      ..loadRequest(widget.uri);
  }

  void _set({required bool loading, bool failed = false}) {
    if (!mounted) return;
    setState(() {
      _loading = loading;
      _failed = failed;
    });
  }

  NavigationDecision _decide(NavigationRequest request) {
    if (!request.isMainFrame) return NavigationDecision.navigate;
    final Uri? target = Uri.tryParse(request.url);
    if (target == null || !target.isScheme('https')) {
      return NavigationDecision.prevent;
    }
    if (!_settled) return NavigationDecision.navigate;
    final Uri? page = _page;
    if (page != null &&
        target.removeFragment().toString() ==
            page.removeFragment().toString()) {
      return NavigationDecision.navigate;
    }
    // Following links is browsing: that happens outside the app.
    unawaited(ExternalLinks.openInBrowser(target));
    return NavigationDecision.prevent;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: UiAppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          UiText.titleMedium(
            _title ?? widget.uri.host,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          UiText.labelSmall(
            widget.uri.host,
            secondary: true,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      actions: <Widget>[
        AppBarActions(share: ShareTarget.webPage(widget.uri, _title)),
      ],
      bottom: UiAppBarProgressSlot(
        child: UiAppBarProgress(
          visible: _loading,
          semanticsLabel: context.t.webPageLoading,
        ),
      ),
    ),
    body: SafeArea(
      top: false,
      child: _failed
          ? UiContentState.error(
              title: context.t.webPageFailed,
              actionLabel: context.t.webPageOpenInBrowser,
              onAction: () =>
                  unawaited(ExternalLinks.openInBrowser(widget.uri)),
            )
          : WebViewWidget(controller: _controller),
    ),
  );
}
