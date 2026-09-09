import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/content/domain/public_web_link.dart';
import 'package:tracksu/src/_shared/content/widgets/content_frame.dart';
import 'package:tracksu/src/_shared/content/domain/content_page.dart';
import 'package:tracksu_ui/tracksu_ui.dart';
import 'package:url_launcher/url_launcher.dart';

/// Optional rich content stays collapsed until requested; large content uses
/// the renderer's sliver mode rather than a shrink-wrapped page column.
final class ContentPageSection extends StatefulWidget {
  const ContentPageSection({
    required this.page,
    required this.title,
    super.key,
  });
  final ContentPage page;
  final String title;

  @override
  State<ContentPageSection> createState() => _ContentPageSectionState();
}

final class _ContentPageSectionState extends State<ContentPageSection> {
  bool _expanded = false;
  bool _opening = false;

  @override
  void didUpdateWidget(ContentPageSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page.uri != widget.page.uri) _expanded = false;
  }

  Future<bool> _open(String value) async {
    if (_opening) return true;
    final Uri? uri = PublicWebLink.resolve(value, base: widget.page.uri);
    setState(() => _opening = true);
    try {
      if (uri == null ||
          !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          UiFeedback.snack(context, message: context.t.contentLinkFailed);
        }
      }
    } on Object {
      if (mounted) {
        UiFeedback.snack(context, message: context.t.contentLinkFailed);
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.fromLTRB(UiSpace.lg, 0, UiSpace.lg, UiSpace.lg),
    sliver: SliverMainAxisGroup(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: UiSpace.sm,
            children: <Widget>[
              Semantics(
                expanded: _expanded,
                child: UiButton.text(
                  label: widget.title,
                  icon: _expanded ? Icons.expand_less : Icons.expand_more,
                  onPressed: () => setState(() => _expanded = !_expanded),
                ),
              ),
              if (_expanded) ...<Widget>[
                UiText.bodySmall(
                  widget.page.document == null
                      ? context.t.contentPageUnavailable
                      : context.t.contentPageNotice,
                  secondary: true,
                ),
                UiButton.text(
                  label: context.t.contentOriginal,
                  icon: Icons.open_in_new,
                  onPressed: _opening
                      ? null
                      : () => _open(widget.page.uri.toString()),
                ),
              ],
            ],
          ),
        ),
        if (_expanded && widget.page.document != null)
          ContentFrame.sliver(
            document: widget.page.document!,
            onOpenLink: _open,
          ),
      ],
    ),
  );
}
