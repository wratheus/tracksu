import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/wiki/search/bloc/bloc.dart';
import 'package:tracksu/src/wiki/widgets/wiki_search_results.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/chrome/app_bar_actions.dart';
import 'package:tracksu/src/_shared/navigation/shell_reselect.dart';
import 'package:tracksu/src/_shared/sharing/share_target.dart';
import 'package:tracksu/src/_shared/media/widgets/app_media.dart';
import 'package:tracksu/src/_shared/ui/avatar_bands.dart';
import 'package:tracksu/src/_shared/ui/osu_badges.dart';
import 'package:tracksu/src/beatmap_search/bloc/bloc.dart';
import 'package:tracksu/src/beatmap_search/widgets/screen.dart';
import 'package:tracksu/src/profile/domain/profile_params.dart';
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

  /// Tapping the search tab again brings the keyboard back.
  final FocusNode _focus = FocusNode();
  Listenable? _reselect;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Listenable? reselect = ShellReselectScope.maybeOf(
      context,
      ShellTab.find,
    );
    if (!identical(reselect, _reselect)) {
      _reselect?.removeListener(_focusField);
      _reselect = reselect?..addListener(_focusField);
    }
  }

  void _focusField() => _focus.requestFocus();

  @override
  void dispose() {
    _reselect?.removeListener(_focusField);
    _focus.dispose();
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
      case SearchTab.wiki:
        context.read<WikiSearchBloc>().add(WikiSearchChanged(query));
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
      // Compact rows omit playmode: open the player's own main mode
      // directly instead of looking it up first (one request, no wait).
      final ProfileUserId user = ProfileUserId(player.id);
      final Future<void> opening = DepsScope.of(context).appRouter.openProfile(
        context,
        player.ruleset == null
            ? ProfileParams.defaultMode(user: user)
            : ProfileParams(user: user, ruleset: player.ruleset),
      );
      // The row is free again as soon as the profile route is pushed.
      setState(() => _opening = false);
      await opening;
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
    // The results never resize with the keyboard (a relayout of the whole
    // list per keyboard frame was the stutter); only the field moves.
    resizeToAvoidBottomInset: false,
    appBar: UiAppBar(
      title: UiText.titleLarge(context.t.navigationSearch),
      actions: <Widget>[
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _text,
          builder: (BuildContext context, TextEditingValue value, _) =>
              AppBarActions(
                share: switch (_tab) {
                  SearchTab.players => ShareTarget.playerSearch(
                    value.text,
                    context.t.navigationSearch,
                  ),
                  SearchTab.maps => ShareTarget.beatmapSearch(
                    value.text,
                    context.t.navigationSearch,
                  ),
                  SearchTab.wiki => ShareTarget.wikiSearch(
                    value.text,
                    context.t.navigationSearch,
                  ),
                },
              ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(
          UiAppBar.segmentedRowHeight(context) + UiAppBarProgress.height,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: UiAppBar.rowPadding,
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
                  UiSegment(
                    value: SearchTab.wiki,
                    label: context.t.wikiTitle,
                    icon: const Icon(Icons.menu_book_outlined),
                  ),
                ],
              ),
            ),
            BlocBuilder<UserSearchBloc, UserSearchState>(
              builder: (context, users) =>
                  BlocBuilder<BeatmapSearchBloc, BeatmapSearchState>(
                    builder: (context, maps) =>
                        BlocSelector<WikiSearchBloc, WikiSearchState, bool>(
                          selector: (WikiSearchState state) => state.busy,
                          builder: (context, wiki) => UiAppBarProgress(
                            visible:
                                _opening ||
                                switch (_tab) {
                                  SearchTab.players => users.busy,
                                  SearchTab.maps => maps.busy,
                                  SearchTab.wiki => wiki,
                                },
                            semanticsLabel: context.t.unifiedSearchTitle,
                          ),
                        ),
                  ),
            ),
          ],
        ),
      ),
    ),
    // iOS 26 search tab: results above, the field at the bottom within
    // thumb reach and right above the keyboard (the bottom bar fades under it).
    body: SafeArea(
      top: false,
      child: Stack(
        children: <Widget>[
          // Results scroll under the field; the extra bottom inset keeps
          // their end and the scroll-to-top button clear of it. Dragging
          // the list dismisses the keyboard, so nothing stays hidden.
          Positioned.fill(
            child: _ResultsInsets(
              child: switch (_tab) {
                SearchTab.maps => const BeatmapSearchResults(),
                SearchTab.wiki => const WikiSearchResults(),
                SearchTab.players => _Players(
                  onOpen: _opening ? null : _open,
                  openFailure: _openFailure,
                ),
              },
            ),
          ),
          _AboveKeyboard(
            child: UiSearchBar(
              controller: _text,
              focusNode: _focus,
              hint: switch (_tab) {
                SearchTab.players => context.t.profileSearchHint,
                SearchTab.maps => context.t.beatmapSearchHint,
                SearchTab.wiki => context.t.wikiSearchHint,
              },
              clearLabel: context.t.searchClear,
              // Opening search means typing: the keyboard comes up at once.
              autofocus: true,
              onSubmitted: (_) => _submit(),
            ),
          ),
        ],
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
                // Same geometry as ranking rows: rounded square avatar,
                // the name on its top edge, flags (and team) on its bottom.
                return UiSurface.card(
                  key: ValueKey(player.id),
                  onTap: onOpen == null ? null : () => onOpen!(player),
                  padding: const EdgeInsets.all(UiSpace.md),
                  child: OsuAvatarBands(
                    avatar: UiAvatar.row(
                      name: player.username,
                      image: player.avatarUrl == null
                          ? null
                          : AppMedia.image(
                              context,
                              Uri.parse(player.avatarUrl!),
                            ),
                    ),
                    top: Row(
                      spacing: UiSpace.sm,
                      children: [
                        Flexible(
                          child: UiText.titleMedium(
                            player.username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (player.isSupporter)
                          const OsuSupporterHeart(size: 14),
                        if (player.isOnline)
                          Semantics(
                            label: context.t.profileOnline,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFB3D944),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    bottom: Align(
                      alignment: AlignmentDirectional.bottomStart,
                      child: OsuPlayerFlags(
                        countryCode: player.country.isEmpty
                            ? null
                            : player.country,
                        team: player.team,
                        bottomAligned: true,
                      ),
                    ),
                  ),
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

/// Keeps the search field just above the keyboard. Only this small subtree
/// reads the keyboard inset, so the results do not rebuild or relayout while
/// it moves; a short ease smooths platforms that report the keyboard in a
/// few large steps instead of every frame.
final class _AboveKeyboard extends StatelessWidget {
  const _AboveKeyboard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedPositionedDirectional(
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 90),
    curve: Curves.easeOutCubic,
    start: UiSpace.lg,
    end: UiSpace.lg,
    bottom: UiSpace.md + MediaQuery.viewInsetsOf(context).bottom,
    child: child,
  );
}

/// The results' insets: room for the field at the bottom, and no keyboard
/// inset at all, so the lists below are not notified (and do not rebuild)
/// on every keyboard frame. Only this widget follows the keyboard.
final class _ResultsInsets extends StatelessWidget {
  const _ResultsInsets({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        padding: media.padding.copyWith(bottom: UiSearchBar.area),
        viewInsets: EdgeInsets.zero,
      ),
      child: child,
    );
  }
}
