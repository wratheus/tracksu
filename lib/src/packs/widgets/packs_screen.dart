import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/chrome/app_bar_actions.dart';
import 'package:tracksu/src/_shared/sharing/share_target.dart';
import 'package:tracksu/src/_shared/ui/category_picker.dart';
import 'package:tracksu/src/_shared/ui/osu_badges.dart';
import 'package:tracksu/src/packs/domain/packs.dart';
import 'package:tracksu/src/packs/list/bloc/bloc.dart';
import 'package:tracksu/src/packs/widgets/pack_type_style.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Packs of one type: the type picker on top (with the type's description),
/// then pack rows — tag, name, date and author, ruleset; older packs load at
/// the end. Pull down to refresh.
///
/// The API has no pack search, so the field does two cheap things: a tag
/// (`S1500`, `P345`…) opens that pack directly (one request), and any text
/// filters the packs already loaded. While filtering, older pages load only
/// on request — never in a loop looking for matches.
final class BeatmapPacksScreen extends StatefulWidget {
  const BeatmapPacksScreen({super.key});

  @override
  State<BeatmapPacksScreen> createState() => _BeatmapPacksScreenState();
}

final class _BeatmapPacksScreenState extends State<BeatmapPacksScreen> {
  final TextEditingController _filter = TextEditingController();
  String _query = '';

  static final RegExp _tag = RegExp(r'^[SFPLRTA][0-9]{1,6}$');

  @override
  void dispose() {
    _filter.dispose();
    super.dispose();
  }

  String? get _tagQuery {
    final String tag = _query.toUpperCase();
    return _tag.hasMatch(tag) ? tag : null;
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<BeatmapPacksBloc, BeatmapPacksState>(
        builder: (BuildContext context, BeatmapPacksState state) {
          final BeatmapPacksBloc bloc = context.read<BeatmapPacksBloc>();
          final String needle = _query.toLowerCase();
          final List<BeatmapPack>? items = needle.isEmpty
              ? state.items
              : state.items
                    ?.where(
                      (BeatmapPack pack) =>
                          pack.name.toLowerCase().contains(needle) ||
                          pack.tag.toLowerCase().contains(needle),
                    )
                    .toList(growable: false);
          final bool filtering = needle.isNotEmpty;
          final String? tag = _tagQuery;
          return Scaffold(
            appBar: UiAppBar(
              title: UiText.titleLarge(context.t.packsTitle),
              actions: <Widget>[
                AppBarActions(
                  share: ShareTarget.packs(
                    state.type.apiValue,
                    context.t.packsTitle,
                  ),
                ),
              ],
              bottom: UiAppBarProgressSlot(
                child: UiAppBarProgress(
                  visible: state.busy && items != null && !state.loadingMore,
                  semanticsLabel: context.t.packsLoading,
                ),
              ),
            ),
            body: UiScrollToTop(
              tooltip: context.t.scrollToTop,
              child: SafeArea(
                top: false,
                child: RefreshIndicator(
                  onRefresh: () async =>
                      bloc.add(const BeatmapPacksRefreshRequested()),
                  child: CustomScrollView(
                    primary: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: <Widget>[
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          UiSpace.lg,
                          UiSpace.lg,
                          UiSpace.lg,
                          UiSpace.md,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: UiSpace.sm,
                            children: <Widget>[
                              OsuCategoryPicker<BeatmapPackType>(
                                title: context.t.packsType,
                                selected: state.type,
                                groups: const <OsuCategoryGroup<BeatmapPackType>>[
                                  OsuCategoryGroup<BeatmapPackType>(
                                    options: BeatmapPackType.values,
                                  ),
                                ],
                                icon: (BeatmapPackType type) => type.icon,
                                label: (BuildContext context, BeatmapPackType type) =>
                                    type.label(context),
                                onSelected: (BeatmapPackType type) =>
                                    bloc.add(BeatmapPacksTypeSelected(type)),
                              ),
                              UiText.bodySmall(
                                state.type.hint(context),
                                secondary: true,
                              ),
                              const SizedBox(height: UiSpace.xs),
                              UiSearchField(
                                controller: _filter,
                                label: context.t.packsFilter,
                                clearLabel: context.t.searchClear,
                                onChanged: (String value) =>
                                    setState(() => _query = value.trim()),
                                onSubmitted: (_) {
                                  if (_tagQuery case final String tag) {
                                    unawaited(
                                      DepsScope.of(
                                        context,
                                      ).appRouter.openPack(context, tag),
                                    );
                                  }
                                },
                              ),
                              if (tag != null)
                                UiSurface.tonal(
                                  padding: EdgeInsets.zero,
                                  child: UiTile.navigation(
                                    leading: const Icon(
                                      Icons.arrow_forward_rounded,
                                    ),
                                    title: context.t.packsOpenTag(tag),
                                    onTap: () => unawaited(
                                      DepsScope.of(
                                        context,
                                      ).appRouter.openPack(context, tag),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (items == null)
                        SliverToBoxAdapter(
                          child: state.failure == null
                              ? UiPageSkeleton.list(
                                  label: context.t.packsLoading,
                                )
                              : _Failure(
                                  kind: state.failure!,
                                  onRetry: () => bloc.add(
                                    const BeatmapPacksRefreshRequested(),
                                  ),
                                ),
                        )
                      else if (items.isEmpty)
                        SliverToBoxAdapter(
                          child: UiContentState.empty(
                            title: filtering
                                ? context.t.packsFilterEmpty
                                : context.t.packsEmpty,
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: UiSpace.lg,
                          ),
                          sliver: UiSliverCardList(
                            key: ValueKey<BeatmapPackType>(state.type),
                            itemCount: items.length,
                            itemBuilder: (BuildContext context, int index) =>
                                BeatmapPackRow(
                                  key: ValueKey<String>(items[index].tag),
                                  pack: items[index],
                                ),
                          ),
                        ),
                      if (items != null)
                        if (state.failure case final kind?
                            when state.failedMore)
                          SliverToBoxAdapter(
                            child: _Failure(
                              kind: kind,
                              onRetry: () =>
                                  bloc.add(const BeatmapPacksMoreRequested()),
                            ),
                          )
                        else if (state.loadingMore)
                          SliverToBoxAdapter(
                            child: UiContentState.loading(
                              title: context.t.packsLoading,
                            ),
                          )
                        else if (state.cursor case final String cursor
                            when state.failure == null && !filtering)
                          UiSliverAutoLoad(
                            pageKey: (state.type, cursor),
                            label: context.t.packsLoading,
                            onLoad: () =>
                                bloc.add(const BeatmapPacksMoreRequested()),
                          )
                        // Filtering: one page per tap, never a search loop.
                        else if (state.cursor != null &&
                            state.failure == null)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(UiSpace.lg),
                              child: UiButton.secondary(
                                label: context.t.packsLoadMore,
                                icon: Icons.expand_more_rounded,
                                onPressed: () => bloc.add(
                                  const BeatmapPacksMoreRequested(),
                                ),
                              ),
                            ),
                          ),
                      UiSliverScrollToTopSpace(
                        tooltip: context.t.scrollToTop,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
}

/// Tag chip, name, then date · author and the ruleset; opens the pack. The
/// list API has no covers (one request per pack would be needed), so the
/// row carries its type instead: a faint accent wash from the right and the
/// type's icon as a large watermark.
final class BeatmapPackRow extends StatelessWidget {
  const BeatmapPackRow({required this.pack, super.key});
  final BeatmapPack pack;

  @override
  Widget build(BuildContext context) {
    final String meta = <String>[
      if (pack.date case final DateTime date)
        DateFormat.yMMMd(context.t.localeName).format(date.toLocal()),
      if (pack.author.isNotEmpty) pack.author,
    ].join(' · ');
    final BeatmapPackType? type = BeatmapPackTypeStyle.ofTag(pack.tag);
    final Color accent =
        type?.accent ?? Theme.of(context).colorScheme.primary;
    return UiSurface.card(
      padding: EdgeInsets.zero,
      onTap: () => unawaited(
        DepsScope.of(context).appRouter.openPack(context, pack.tag),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[
                    accent.withValues(alpha: 0),
                    accent.withValues(alpha: 0.14),
                  ],
                ),
              ),
            ),
          ),
          if (type != null)
            PositionedDirectional(
              end: -UiSpace.md,
              top: -UiSpace.sm,
              bottom: -UiSpace.sm,
              child: ExcludeSemantics(
                child: Icon(
                  type.icon,
                  size: 88,
                  color: accent.withValues(alpha: 0.12),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(UiSpace.md),
            child: _content(context, meta),
          ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context, String meta) => Row(
        spacing: UiSpace.md,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: UiSpace.xs,
              children: <Widget>[
                BeatmapPackTag(tag: pack.tag),
                UiText.titleSmall(
                  pack.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (meta.isNotEmpty)
                  UiText.bodySmall(
                    meta,
                    secondary: true,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (pack.ruleset case final ruleset?)
            OsuRulesetIcon(ruleset: ruleset),
          Icon(
            Icons.chevron_right_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      );
}

final class _Failure extends StatelessWidget {
  const _Failure({required this.kind, required this.onRetry});
  final BeatmapPacksFailureKind kind;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => UiContentState.error(
    title: packsFailureTitle(context, kind),
    actionLabel: context.t.retry,
    onAction: onRetry,
  );
}

String packsFailureTitle(BuildContext context, BeatmapPacksFailureKind kind) =>
    switch (kind) {
      BeatmapPacksFailureKind.notFound => context.t.packsNotFound,
      BeatmapPacksFailureKind.rateLimited => context.t.profileRateLimited,
      BeatmapPacksFailureKind.connection => context.t.profileConnectionFailed,
      _ => context.t.packsFailed,
    };
