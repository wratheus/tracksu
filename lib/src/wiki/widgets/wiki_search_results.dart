import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/wiki/search/bloc/bloc.dart';
import 'package:tracksu/src/wiki/domain/wiki.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Wiki tab of the unified search: article titles with their section; a tap
/// opens the article in the app.
final class WikiSearchResults extends StatelessWidget {
  const WikiSearchResults({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<WikiSearchBloc, WikiSearchState>(
        builder: (BuildContext context, WikiSearchState state) => UiScrollToTop(
          tooltip: context.t.scrollToTop,
          child: CustomScrollView(
            key: const PageStorageKey<String>('search-wiki'),
            primary: true,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: <Widget>[
              if (state.query.length < 2)
                SliverToBoxAdapter(
                  child: UiContentState.empty(
                    title: context.t.unifiedSearchPrompt,
                    message: context.t.wikiSearchHelp,
                  ),
                )
              else if (state.items.isEmpty && state.busy)
                SliverToBoxAdapter(
                  child: UiPageSkeleton.list(label: context.t.wikiLoading),
                )
              else if (state.items.isEmpty && state.failure != null)
                SliverToBoxAdapter(
                  child: UiContentState.error(
                    title: context.t.wikiFailed,
                    actionLabel: context.t.retry,
                    onAction: () => context.read<WikiSearchBloc>().add(
                      WikiSearchChanged(state.query),
                    ),
                  ),
                )
              else if (state.items.isEmpty && state.page > 0)
                SliverToBoxAdapter(
                  child: UiContentState.empty(title: context.t.wikiNoResults),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(UiSpace.lg),
                  sliver: UiSliverCardList(
                    itemCount: state.items.length,
                    itemBuilder: (BuildContext context, int index) {
                      final WikiSearchHit hit = state.items[index];
                      return UiTile.navigation(
                        key: ValueKey<String>(hit.path),
                        title: hit.title,
                        subtitle: hit.subtitle,
                        leading: const UiTileIcon(Icons.menu_book_outlined),
                        onTap: () => unawaited(
                          DepsScope.of(context).appRouter.openWiki(
                            context,
                            WikiParams(hit.path, locale: hit.locale),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (state.hasMore && !state.busy && state.failure == null)
                UiSliverAutoLoad(
                  pageKey: (state.query, state.page),
                  label: context.t.wikiLoading,
                  onLoad: () => context.read<WikiSearchBloc>().add(
                    const WikiSearchMoreRequested(),
                  ),
                ),
              UiSliverScrollToTopSpace(tooltip: context.t.scrollToTop),
            ],
          ),
        ),
      );
}
