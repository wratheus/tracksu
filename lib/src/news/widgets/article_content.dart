import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_shared/content/widgets/content_frame.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/news/domain/news.dart';
import 'package:tracksu/src/_shared/content/domain/public_web_link.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class NewsPostHeading extends StatelessWidget {
  const NewsPostHeading({required this.post, super.key});
  final NewsPost post;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: UiSpace.md,
    children: <Widget>[
      UiText.headlineSmall(post.title),
      Wrap(
        spacing: UiSpace.lg,
        runSpacing: UiSpace.sm,
        children: <Widget>[
          UiText.labelLarge(
            post.author,
            color: Theme.of(context).colorScheme.primary,
          ),
          UiText.bodySmall(
            DateFormat.yMMMd(context.t.localeName)
                .format(post.publishedAt.toLocal()),
            secondary: true,
          ),
        ],
      ),
    ],
  );
}

final class NewsArticleContent extends StatefulWidget {
  const NewsArticleContent({required this.article, super.key});
  final NewsArticle article;
  @override
  State<NewsArticleContent> createState() => _NewsArticleContentState();
}

final class _NewsArticleContentState extends State<NewsArticleContent> {
  bool _opening = false;
  Future<bool> _open(String value) async {
    if (_opening) return true;
    final Uri? uri = PublicWebLink.resolve(
      value,
      base: widget.article.post.uri,
    );
    setState(() => _opening = true);
    try {
      if (uri == null ||
          !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) _showFailure();
      }
    } on Object {
      if (mounted) _showFailure();
    } finally {
      if (mounted) setState(() => _opening = false);
    }
    // Always handled: the renderer must never fall back to its own launcher.
    return true;
  }

  void _showFailure() =>
      UiFeedback.snack(context, message: context.t.newsLinkFailed);
  @override
  Widget build(BuildContext context) => SliverMainAxisGroup(
    slivers: <Widget>[
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(UiSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: UiSpace.md,
            children: <Widget>[
              NewsPostHeading(post: widget.article.post),
              UiText.bodySmall(context.t.newsReaderNotice, secondary: true),
              UiButton.text(
                onPressed: _opening
                    ? null
                    : () => _open(widget.article.post.uri.toString()),
                icon: Icons.open_in_new,
                label: context.t.newsOriginal,
              ),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          UiSpace.lg,
          0,
          UiSpace.lg,
          UiSpace.xl,
        ),
        sliver: widget.article.document == null
            ? SliverToBoxAdapter(
                child: UiText.bodyMedium(context.t.contentUnavailable),
              )
            : ContentFrame.sliver(
                mediaPermission: DepsScope.of(context).contentMediaController,
                document: widget.article.document!,
                onOpenLink: _open,
              ),
      ),
    ],
  );
}
