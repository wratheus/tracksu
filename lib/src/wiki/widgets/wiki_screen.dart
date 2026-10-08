import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/chrome/app_bar_actions.dart';
import 'package:tracksu/src/_shared/content/domain/public_web_link.dart';
import 'package:tracksu/src/_shared/content/widgets/content_frame.dart';
import 'package:tracksu/src/_shared/navigation/app_links.dart';
import 'package:tracksu/src/_shared/navigation/external_links.dart';
import 'package:tracksu/src/_shared/sharing/share_target.dart';
import 'package:tracksu/src/wiki/article/bloc/bloc.dart';
import 'package:tracksu/src/wiki/domain/wiki.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Wiki article in the shared reader. Links to other wiki articles stay in
/// the app; other links open in the in-app browser sheet.
final class WikiScreen extends StatelessWidget {
  const WikiScreen({super.key});

  Future<bool> _open(BuildContext context, WikiArticle article, String url) {
    if (url.startsWith('#')) return Future<bool>.value(true);
    final Uri? uri = PublicWebLink.resolve(
      url,
      base: WikiLinks.base(article.path, article.locale),
    );
    if (uri == null) return Future<bool>.value(true);
    // Wiki articles, players and maps open in the app (AppLinks).
    return AppLinks.open(context, uri);
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<WikiArticleBloc, WikiArticleState>(
    builder: (BuildContext context, WikiArticleState state) {
      final WikiArticle? article = state.article;
      return Scaffold(
        appBar: UiAppBar(
          title: UiText.titleLarge(
            article?.title ?? context.t.wikiTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: <Widget>[
            AppBarActions(
              share: article == null
                  ? null
                  : ShareTarget.wiki(article.webUri, article.title),
            ),
          ],
          bottom: UiAppBarProgressSlot(
            child: UiAppBarProgress(
              visible: state.loading && article != null,
              semanticsLabel: context.t.wikiLoading,
            ),
          ),
        ),
        body: UiScrollToTop(
          tooltip: context.t.scrollToTop,
          child: SafeArea(
            top: false,
            child: RefreshIndicator(
              onRefresh: () async => context.read<WikiArticleBloc>().add(
                const WikiArticleRequested(),
              ),
              child: CustomScrollView(
                primary: true,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: <Widget>[
                  if (article == null)
                    SliverToBoxAdapter(
                      child: state.failure == null
                          ? UiPageSkeleton.article(label: context.t.wikiLoading)
                          : UiContentState.error(
                              title: state.failure == WikiFailureKind.notFound
                                  ? context.t.wikiNotFound
                                  : context.t.wikiFailed,
                              actionLabel: context.t.retry,
                              onAction: () => context
                                  .read<WikiArticleBloc>()
                                  .add(const WikiArticleRequested()),
                            ),
                    )
                  else ...<Widget>[
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        UiSpace.lg,
                        UiSpace.lg,
                        UiSpace.lg,
                        UiSpace.sm,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: UiSpace.xs,
                          children: <Widget>[
                            if (article.subtitle case final String sub)
                              UiText.labelLarge(sub, secondary: true),
                            UiText.headlineSmall(article.title),
                            if (article.locale !=
                                Localizations.localeOf(context).languageCode)
                              UiText.bodySmall(
                                context.t.wikiShownInEnglish,
                                secondary: true,
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (article.document case final document?)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: UiSpace.lg,
                        ),
                        sliver: ContentFrame.sliver(
                          audioController: DepsScope.of(context)
                              .audioPlaybackController,
                          mediaPermission: DepsScope.of(context)
                              .contentMediaController,
                          document: document,
                          onOpenLink: (String url) =>
                              _open(context, article, url),
                        ),
                      )
                    else
                      SliverToBoxAdapter(
                        child: UiContentState.error(
                          title: context.t.contentUnavailable,
                          actionLabel: context.t.contentOriginal,
                          onAction: () => unawaited(
                            ExternalLinks.openInBrowser(article.webUri),
                          ),
                        ),
                      ),
                  ],
                  UiSliverScrollToTopSpace(tooltip: context.t.scrollToTop),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
