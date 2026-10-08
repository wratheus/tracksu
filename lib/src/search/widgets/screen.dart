import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/chrome/app_bar_actions.dart';
import 'package:tracksu/src/_shared/sharing/share_target.dart';
import 'package:tracksu/src/_shared/ui/osu_badges.dart';
import 'package:tracksu/src/beatmap_search/bloc/bloc.dart';
import 'package:tracksu/src/beatmap_search/widgets/screen.dart';
import 'package:tracksu/src/profile/domain/profile_params.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';
import 'package:tracksu/src/search/bloc/bloc.dart';
import 'package:tracksu/src/search/domain/user_search.dart';
import 'package:tracksu/src/search/domain/search_params.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class SearchScreen extends StatefulWidget {
  const SearchScreen({
    required this.initialText,
    required this.initialTab,
    super.key,
  });
  final String initialText;
  final SearchTab initialTab;
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

final class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _text = TextEditingController(
    text: widget.initialText,
  );
  late SearchTab _tab = widget.initialTab;
  Timer? _debounce;
  late TextEditingValue _previousValue;
  bool _opening = false;
  UserSearchFailureKind? _openFailure;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _previousValue = _text.value;
    _text.addListener(_edited);
    _submit();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _text.dispose();
    super.dispose();
  }

  void _pause() {
    _generation++;
    _opening = false;
    _openFailure = null;
    context.read<UserSearchBloc>().add(
      UserSearchPaused(
        query: _text.text.trim().characters.take(200).toString(),
      ),
    );
    context.read<BeatmapSearchBloc>().add(
      BeatmapSearchPaused(
        text: _text.text.trim().characters.take(200).toString(),
      ),
    );
  }

  void _edited() {
    final TextEditingValue value = _text.value;
    if (value.text == _previousValue.text &&
        value.composing == _previousValue.composing) {
      return;
    }
    _previousValue = value;
    _typed();
  }

  void _typed() {
    _debounce?.cancel();
    setState(_pause);
    // IME composing text is never submitted halfway through a character.
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!_text.value.composing.isValid || _text.value.composing.isCollapsed) {
        _submit();
      }
    });
  }

  void _submit() {
    _debounce?.cancel();
    final String query = _text.text.trim().characters.take(200).toString();
    switch (_tab) {
      case SearchTab.players:
        context.read<UserSearchBloc>().add(UserSearchChanged(query));
      case SearchTab.maps:
        final BeatmapSearchBloc bloc = context.read<BeatmapSearchBloc>();
        bloc.add(
          BeatmapSearchQueryChanged(bloc.state.query.copyWith(text: query)),
        );
    }
  }

  void _select(SearchTab tab) {
    if (_tab == tab) return;
    _debounce?.cancel();
    setState(() {
      _pause();
      _tab = tab;
    });
    _submit();
  }

  Future<void> _open(SearchPlayer player) async {
    if (_opening) return;
    FocusScope.of(context).unfocus();
    final int generation = ++_generation;
    setState(() {
      _opening = true;
      _openFailure = null;
    });
    try {
      // Compact search rows may omit playmode. Resolve the user's own mode
      // before opening the existing, explicitly-mode-scoped profile route.
      final SearchPlayer resolved = await context
          .read<UserSearchBloc>()
          .resolve(player);
      if (!mounted || generation != _generation) return;
      await DepsScope.of(context).appRouter.openProfile(
        context,
        ProfileParams(
          user: ProfileUserId(resolved.id),
          ruleset: resolved.ruleset ?? ProfileRuleset.osu,
        ),
      );
    } on Object catch (error) {
      if (mounted && generation == _generation) {
        setState(
          () => _openFailure = error is UserSearchFailure
              ? error.kind
              : UserSearchFailureKind.unavailable,
        );
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _opening = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: UiAppBar(
      title: UiText.titleLarge(context.t.navigationSearch),
      actions: <Widget>[
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _text,
          builder: (BuildContext context, TextEditingValue value, _) =>
              AppBarActions(
                share: _tab == SearchTab.players
                    ? ShareTarget.playerSearch(
                        value.text,
                        context.t.navigationSearch,
                      )
                    : ShareTarget.beatmapSearch(
                        value.text,
                        context.t.navigationSearch,
                      ),
              ),
        ),
      ],
      // The field sits under the shared actions so it keeps the full width.
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(136),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                UiSpace.lg,
                UiSpace.xs,
                UiSpace.lg,
                0,
              ),
              child: UiSearchField(
                controller: _text,
                label: _tab == SearchTab.players
                    ? context.t.profileSearchHint
                    : context.t.beatmapSearchHint,
                clearLabel: context.t.searchClear,
                onSubmitted: (_) => _submit(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                UiSpace.lg,
                UiSpace.sm,
                UiSpace.lg,
                UiSpace.sm,
              ),
              child: UiSegmentedControl<SearchTab>(
                selected: _tab,
                onChanged: _select,
                segments: [
                  UiSegment(
                    value: SearchTab.players,
                    label: context.t.rankingsPlayers,
                    icon: const Icon(Icons.person_outline),
                  ),
                  UiSegment(
                    value: SearchTab.maps,
                    label: context.t.unifiedSearchMaps,
                    icon: const Icon(Icons.library_music_outlined),
                  ),
                ],
              ),
            ),
            BlocBuilder<UserSearchBloc, UserSearchState>(
              builder: (context, users) =>
                  BlocBuilder<BeatmapSearchBloc, BeatmapSearchState>(
                    builder: (context, maps) => UiAppBarProgress(
                      visible:
                          _opening ||
                          (_tab == SearchTab.players ? users.busy : maps.busy),
                      semanticsLabel: context.t.unifiedSearchTitle,
                    ),
                  ),
            ),
          ],
        ),
      ),
    ),
    body: SafeArea(
      top: false,
      child: _tab == SearchTab.maps
          ? const BeatmapSearchResults()
          : _Players(
              onOpen: _opening ? null : _open,
              openFailure: _openFailure,
            ),
    ),
  );
}

final class _Players extends StatelessWidget {
  const _Players({required this.onOpen, this.openFailure});
  final ValueChanged<SearchPlayer>? onOpen;
  final UserSearchFailureKind? openFailure;

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<UserSearchBloc, UserSearchState>(
    builder: (context, state) => UiScrollToTop(
      tooltip: context.t.scrollToTop,
      child: CustomScrollView(
        key: const PageStorageKey('search-players'),
        primary: true,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          if (!state.started && state.query.length < 2)
            SliverToBoxAdapter(
              child: UiContentState.empty(
                title: context.t.unifiedSearchPrompt,
                message: context.t.profileSearchHelp,
              ),
            )
          else if (!state.started || (state.busy && state.items.isEmpty))
            SliverToBoxAdapter(
              child: UiPageSkeleton.list(label: context.t.unifiedSearchTitle),
            )
          else if (state.items.isEmpty && state.failure == null)
            SliverToBoxAdapter(
              child: UiContentState.empty(title: context.t.userSearchEmpty),
            ),
          if (state.failure != null)
            SliverToBoxAdapter(
              child: UiContentState.error(
                title: state.failure == UserSearchFailureKind.rateLimited
                    ? context.t.profileRateLimited
                    : context.t.userSearchFailed,
                actionLabel: context.t.retry,
                onAction: () =>
                    context.read<UserSearchBloc>().add(const UserSearchRetry()),
              ),
            ),
          if (openFailure != null)
            SliverToBoxAdapter(
              child: UiContentState.error(
                title: openFailure == UserSearchFailureKind.rateLimited
                    ? context.t.profileRateLimited
                    : context.t.userSearchFailed,
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.all(UiSpace.lg),
            sliver: UiSliverCardList(
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final SearchPlayer player = state.items[index];
                // Flag after the name, as on osu.ppy.sh; no country code.
                return ListTile(
                  key: ValueKey(player.id),
                  enabled: onOpen != null,
                  title: Row(
                    spacing: UiSpace.sm,
                    children: [
                      Flexible(
                        child: Text(
                          player.username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (player.country.isNotEmpty)
                        OsuCountryFlag(
                          code: player.country,
                          label: context.t.profileCountry(player.country),
                        ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  leading: ClipOval(
                    child: UiImage(
                      image: player.avatarUrl == null
                          ? null
                          : NetworkImage(player.avatarUrl!),
                      width: 44,
                      height: 44,
                      fallbackIcon: Icons.person_outline,
                    ),
                  ),
                  onTap: onOpen == null ? null : () => onOpen!(player),
                );
              },
            ),
          ),
          if (state.nextPage != null &&
              !state.busy &&
              state.failure == null &&
              onOpen != null)
            UiSliverAutoLoad(
              pageKey: (state.query, state.nextPage),
              label: context.t.unifiedSearchTitle,
              onLoad: () =>
                  context.read<UserSearchBloc>().add(const UserSearchMore()),
            ),
          if (state.busy && state.items.isNotEmpty)
            SliverToBoxAdapter(
              child: UiLoading(label: context.t.unifiedSearchTitle),
            ),
          if (state.items.length >= 100)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(UiSpace.lg),
                child: UiText.bodySmall(
                  context.t.userSearchLimit,
                  secondary: true,
                ),
              ),
            ),
          UiSliverScrollToTopSpace(tooltip: context.t.scrollToTop),
        ],
      ),
    ),
  );
}
