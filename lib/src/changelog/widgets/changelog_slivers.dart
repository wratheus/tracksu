import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart'
    show HtmlWidget;
import 'package:intl/intl.dart';
import 'package:tracksu/src/_shared/navigation/external_links.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/ui/relative_time.dart';
import 'package:tracksu/src/changelog/bloc/bloc.dart';
import 'package:tracksu/src/changelog/domain/changelog.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Stream colours of osu.ppy.sh/home/changelog (osu-web `variables.less`).
Color changelogStreamColour(String? stream) => switch (stream) {
  'stable40' => const Color(0xFF66CCFF),
  'beta40' => const Color(0xFFFFDD55),
  'cuttingedge' => const Color(0xFFEEAA00),
  'lazer' => const Color(0xFFED1221),
  'tachyon' => const Color(0xFFCE00FF),
  'web' => const Color(0xFF8866EE),
  _ => const Color(0xFF9E9E9E),
};

/// Changelog page content: stream tiles, then builds with entries grouped by
/// category, as on the website. Older builds load at the end.
final class ChangelogSlivers extends StatelessWidget {
  const ChangelogSlivers({super.key});

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<ChangelogBloc, ChangelogState>(
    builder: (BuildContext context, ChangelogState state) =>
        SliverMainAxisGroup(
          slivers: <Widget>[
            if (state.streams.isNotEmpty)
              SliverToBoxAdapter(
                child: _StreamTiles(
                  streams: state.streams,
                  selected: state.stream,
                ),
              ),
            ...switch (state) {
              ChangelogInitialState() || ChangelogLoadingState() => <Widget>[
                SliverToBoxAdapter(
                  child: UiPageSkeleton.list(label: context.t.changelogLoading),
                ),
              ],
              ChangelogFailureState(:final failure) => <Widget>[
                SliverToBoxAdapter(child: _Failure(failure)),
              ],
              final ChangelogLoadedState loaded => <Widget>[
                if (loaded.failure case final ChangelogFailureKind failure
                    when loaded.failedOperation == ChangelogOperation.refresh)
                  SliverToBoxAdapter(child: _Failure(failure, keeping: true)),
                if (loaded.builds.isEmpty)
                  SliverToBoxAdapter(
                    child: UiContentState.empty(
                      title: context.t.changelogEmpty,
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg),
                  sliver: SliverList.builder(
                    itemCount: loaded.builds.length,
                    itemBuilder: (BuildContext context, int index) => Padding(
                      key: ValueKey<int>(loaded.builds[index].id),
                      padding: const EdgeInsets.only(bottom: UiSpace.md),
                      child: _BuildCard(item: loaded.builds[index]),
                    ),
                  ),
                ),
                if (loaded.operation == ChangelogOperation.loadMore)
                  SliverToBoxAdapter(
                    child: UiContentState.loading(
                      title: context.t.changelogLoading,
                    ),
                  )
                else if (loaded.failure case final ChangelogFailureKind failure
                    when loaded.failedOperation == ChangelogOperation.loadMore)
                  SliverToBoxAdapter(
                    child: _Failure(failure, keeping: true, more: true),
                  )
                else if (loaded.nextMaxId case final int next
                    when loaded.operation == null)
                  UiSliverAutoLoad(
                    pageKey: (loaded.stream, next),
                    label: context.t.changelogLoading,
                    onLoad: () => context.read<ChangelogBloc>().add(
                      const ChangelogMoreRequested(),
                    ),
                  ),
              ],
            },
          ],
        ),
  );
}

final class _Failure extends StatelessWidget {
  const _Failure(this.failure, {this.keeping = false, this.more = false});
  final ChangelogFailureKind failure;
  final bool keeping;
  final bool more;

  @override
  Widget build(BuildContext context) => UiContentState.error(
    title: switch (failure) {
      ChangelogFailureKind.rateLimited => context.t.profileRateLimited,
      ChangelogFailureKind.connection => context.t.profileConnectionFailed,
      _ => context.t.changelogFailed,
    },
    message: keeping ? context.t.newsKeepingContent : null,
    actionLabel: context.t.retry,
    onAction: () => context.read<ChangelogBloc>().add(
      more ? const ChangelogMoreRequested() : const ChangelogRefreshRequested(),
    ),
  );
}

/// Horizontal stream tiles: name, latest version and active users. "All"
/// comes first; the selected tile is filled with its stream colour.
final class _StreamTiles extends StatelessWidget {
  const _StreamTiles({required this.streams, required this.selected});
  final List<ChangelogStream> streams;
  final String? selected;

  @override
  Widget build(BuildContext context) {
    final NumberFormat compact = NumberFormat.compact(
      locale: context.t.localeName,
    );
    return SizedBox(
      height: 76,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          UiSpace.lg,
          UiSpace.md,
          UiSpace.lg,
          UiSpace.md,
        ),
        children: <Widget>[
          _StreamTile(
            name: context.t.changelogAllStreams,
            colour: Theme.of(context).colorScheme.onSurface,
            selected: selected == null,
            onTap: () => context.read<ChangelogBloc>().add(
              const ChangelogStreamSelected(null),
            ),
          ),
          for (final ChangelogStream stream in streams)
            _StreamTile(
              name: stream.displayName,
              version: stream.latestVersion,
              users: stream.userCount == null
                  ? null
                  : context.t.changelogUsers(compact.format(stream.userCount)),
              colour: changelogStreamColour(stream.name),
              selected: selected == stream.name,
              onTap: () => context.read<ChangelogBloc>().add(
                ChangelogStreamSelected(stream.name),
              ),
            ),
        ],
      ),
    );
  }
}

final class _StreamTile extends StatelessWidget {
  const _StreamTile({
    required this.name,
    required this.colour,
    required this.selected,
    required this.onTap,
    this.version,
    this.users,
  });
  final String name;
  final String? version;
  final String? users;
  final Color colour;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: UiSpace.sm),
      child: Semantics(
        selected: selected,
        button: true,
        child: Material(
          color: selected
              ? colour.withValues(alpha: .22)
              : colors.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UiShape.control),
            side: BorderSide(
              color: selected ? colour : Colors.transparent,
              width: 1.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: selected ? null : onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UiSpace.md,
                vertical: UiSpace.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: UiSpace.sm,
                children: <Widget>[
                  Container(
                    width: 4,
                    height: 28,
                    decoration: BoxDecoration(
                      color: colour,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      UiText.labelLarge(name),
                      if (version != null || users != null)
                        UiText.bodySmall(
                          <String>[?version, ?users].join(' · '),
                          secondary: true,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One build: coloured stream name, version and date, then entries grouped
/// by category in API order.
final class _BuildCard extends StatelessWidget {
  const _BuildCard({required this.item});
  final ChangelogBuild item;

  @override
  Widget build(BuildContext context) {
    final Color colour = changelogStreamColour(item.streamName);
    final Map<String, List<ChangelogEntry>> groups =
        <String, List<ChangelogEntry>>{};
    for (final ChangelogEntry entry in item.entries) {
      (groups[entry.category] ??= <ChangelogEntry>[]).add(entry);
    }
    return UiSurface.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: UiSpace.sm,
        children: <Widget>[
          Row(
            spacing: UiSpace.sm,
            children: <Widget>[
              if (item.streamDisplayName case final String stream)
                UiText.labelLarge(stream, color: colour),
              Expanded(child: UiText.titleMedium(item.version)),
              UiText.bodySmall(
                relativeTime(context, item.createdAt),
                secondary: true,
              ),
            ],
          ),
          for (final MapEntry<String, List<ChangelogEntry>> group
              in groups.entries) ...<Widget>[
            if (group.key.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: UiSpace.xs),
                child: UiText.labelMedium(group.key, secondary: true),
              ),
            for (final ChangelogEntry entry in group.value)
              _EntryRow(entry: entry),
          ],
        ],
      ),
    );
  }
}

final class _EntryRow extends StatefulWidget {
  const _EntryRow({required this.entry});
  final ChangelogEntry entry;

  @override
  State<_EntryRow> createState() => _EntryRowState();
}

final class _EntryRowState extends State<_EntryRow> {
  bool _expanded = false;

  Future<void> _open(Uri uri) async {
    try {
      if (!await ExternalLinks.open(uri) && mounted) {
        UiFeedback.snack(context, message: context.t.contentLinkFailed);
      }
    } on Object {
      if (mounted) {
        UiFeedback.snack(context, message: context.t.contentLinkFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ChangelogEntry entry = widget.entry;
    final ColorScheme colors = Theme.of(context).colorScheme;
    final (IconData icon, Color tint) = switch (entry.type) {
      'add' => (Icons.add_rounded, const Color(0xFFB3D944)),
      'fix' => (Icons.build_rounded, const Color(0xFFFFCC22)),
      _ => (Icons.circle, colors.onSurfaceVariant),
    };
    final Uri? link = entry.githubUrl ?? entry.url;
    final String? html = entry.messageHtml;
    return InkWell(
      // The whole row opens the pull request or post; with no link it
      // expands the text instead. The chevron always toggles the text.
      onTap: link != null
          ? () => unawaited(_open(link))
          : html == null
          ? null
          : () => setState(() => _expanded = !_expanded),
      borderRadius: BorderRadius.circular(UiShape.control),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: UiSpace.sm,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    icon,
                    size: entry.type == 'misc' ? 8 : 16,
                    color: tint,
                    semanticLabel: switch (entry.type) {
                      'add' => context.t.changelogTypeAdd,
                      'fix' => context.t.changelogTypeFix,
                      _ => context.t.changelogTypeMisc,
                    },
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: <Widget>[
                      Text(
                        entry.title ?? '—',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: entry.major
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                      if (entry.author != null || entry.pullRequest != null)
                        UiText.bodySmall(
                          <String>[
                            if (entry.repository != null &&
                                entry.pullRequest != null)
                              '${entry.repository!.split('/').last}#${entry.pullRequest}',
                            ?entry.author,
                          ].join(' · '),
                          secondary: true,
                        ),
                    ],
                  ),
                ),
                if (html != null)
                  UiIconButton.standard(
                    tooltip: context.t.changelogShowText,
                    icon: _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    onPressed: () => setState(() => _expanded = !_expanded),
                  )
                else if (link != null)
                  Icon(
                    Icons.open_in_new_rounded,
                    size: 16,
                    semanticLabel: context.t.changelogOpenLink,
                    color: colors.onSurfaceVariant,
                  ),
              ],
            ),
            if (_expanded && html != null)
              Padding(
                padding: const EdgeInsets.only(left: 24, top: UiSpace.xs),
                child: HtmlWidget(
                  html,
                  textStyle: Theme.of(context).textTheme.bodySmall,
                  onTapUrl: (String url) {
                    final Uri? uri = Uri.tryParse(url);
                    if (uri != null && uri.isScheme('https')) {
                      unawaited(_open(uri));
                    }
                    return true;
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
