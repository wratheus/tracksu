import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/content/domain/public_web_link.dart';
import 'package:tracksu/src/profile/domain/profile.dart';
import 'package:tracksu_ui/tracksu_ui.dart';
import 'package:url_launcher/url_launcher.dart';

/// Optional rich content stays collapsed until requested; large content uses
/// the renderer's sliver mode rather than a shrink-wrapped profile column.
final class ProfileAboutSection extends StatefulWidget {
  const ProfileAboutSection({required this.about, super.key});
  final ProfileAbout about;

  @override
  State<ProfileAboutSection> createState() => _ProfileAboutSectionState();
}

final class _ProfileAboutSectionState extends State<ProfileAboutSection> {
  bool _expanded = false;
  bool _opening = false;

  Future<bool> _open(String value) async {
    if (_opening) return true;
    final Uri? uri = PublicWebLink.resolve(value, base: widget.about.uri);
    setState(() => _opening = true);
    try {
      if (uri == null ||
          !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          UiFeedback.snack(context, message: context.t.profileLinkFailed);
        }
      }
    } on Object {
      if (mounted) {
        UiFeedback.snack(context, message: context.t.profileLinkFailed);
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
                  label: context.t.profileAbout,
                  icon: _expanded ? Icons.expand_less : Icons.expand_more,
                  onPressed: () => setState(() => _expanded = !_expanded),
                ),
              ),
              if (_expanded) ...<Widget>[
                UiText.bodySmall(
                  widget.about.safeHtml == null
                      ? context.t.profileAboutUnavailable
                      : context.t.profileAboutNotice,
                  secondary: true,
                ),
                UiButton.text(
                  label: context.t.profileOriginal,
                  icon: Icons.open_in_new,
                  onPressed: _opening
                      ? null
                      : () => _open(widget.about.uri.toString()),
                ),
              ],
            ],
          ),
        ),
        if (_expanded && widget.about.safeHtml != null)
          HtmlWidget(
            widget.about.safeHtml!,
            baseUrl: widget.about.uri,
            renderMode: RenderMode.sliverList,
            onTapUrl: _open,
            textStyle: Theme.of(context).textTheme.bodyMedium,
          ),
      ],
    ),
  );
}
