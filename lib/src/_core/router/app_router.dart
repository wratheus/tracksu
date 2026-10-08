import 'package:flutter/material.dart';
import 'package:tracksu/src/packs/domain/packs.dart';
import 'package:tracksu/src/packs/main.dart';
import 'package:tracksu/src/forum/main.dart';
import 'package:tracksu/src/web_page/screen.dart';
import 'package:tracksu/src/wiki/domain/wiki.dart';
import 'package:tracksu/src/wiki/main.dart';
import 'package:tracksu/src/about/licenses/screen.dart';
import 'package:tracksu/src/about/main.dart';
import 'package:tracksu/src/settings/main.dart';
import 'package:tracksu/src/team/main.dart';
import 'package:tracksu/src/team/domain/team.dart';
import 'package:tracksu/src/profile/medals/main.dart';
import 'package:go_router/go_router.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/auth/domain/authorization.dart';
import 'package:tracksu/src/auth/main.dart';
import 'package:tracksu/src/beatmap/domain/beatmap.dart';
import 'package:tracksu/src/beatmap/main.dart';
import 'package:tracksu/src/guest/widgets/guest_shell.dart';
import 'package:tracksu/src/guest/widgets/search_home.dart';
import 'package:tracksu/src/news/domain/news.dart';
import 'package:tracksu/src/news/main.dart';
import 'package:tracksu/src/osu_hub/main.dart';
import 'package:tracksu/src/profile/domain/profile_params.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';
import 'package:tracksu/src/profile/main.dart';
import 'package:tracksu/src/rankings/main.dart';
import 'package:tracksu/src/search/main.dart';
import 'package:tracksu/src/search/domain/search_params.dart';
import 'package:tracksu/src/daily/main.dart';
import 'package:tracksu/src/spotlights/main.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Features pass typed values; only this facade knows route paths and stacks.
final class TracksuAppRouter {
  TracksuAppRouter({Uri? initialOAuthCallbackUri}) {
    config = GoRouter(
      navigatorKey: _rootKey,
      initialLocation: initialOAuthCallbackUri == null
          ? '/search'
          : '/search/oauth-callback',
      overridePlatformDefaultLocation: true,
      restorationScopeId: 'tracksu_router',
      routes: <RouteBase>[
        StatefulShellRoute.indexedStack(
          restorationScopeId: 'tracksu_shell',
          pageBuilder:
              (_, GoRouterState state, StatefulNavigationShell shell) =>
                  MaterialPage<void>(
                    key: state.pageKey,
                    restorationId: 'tracksu_shell_page',
                    child: GuestShell(navigationShell: shell),
                  ),
          branches: <StatefulShellBranch>[
            // Order = ShellTab: home (kept at /search for old links),
            // rankings, osu!, and the separate search tab.
            for (final String path in <String>[
              'search',
              'rankings',
              'news',
              'find',
            ])
              StatefulShellBranch(
                restorationScopeId: '${path}_branch',
                routes: <RouteBase>[
                  GoRoute(
                    path: '/$path',
                    builder: (_, GoRouterState state) => switch (path) {
                      'rankings' => const RankingsMain(),
                      'news' => const OsuHubMain(),
                      // A new query (deep link, "search maps") starts fresh;
                      // returning to the tab keeps the same screen.
                      'find' => SearchMain(
                        key: ValueKey<String>(state.uri.query),
                        params: _searchParams(state),
                      ),
                      _ => const SearchHome(),
                    },
                    routes: <RouteBase>[
                      ..._detailRoutes(),
                      GoRoute(
                        path: 'auth',
                        parentNavigatorKey: _rootKey,
                        builder: (_, _) => const AuthMain(
                          params: AuthorizationParams(startOnOpen: true),
                        ),
                      ),
                      if (path == 'search')
                        GoRoute(
                          path: 'oauth-callback',
                          parentNavigatorKey: _rootKey,
                          // Never serialize OAuth code/state into router paths,
                          // extras, restoration data or diagnostic messages.
                          builder: (_, _) => AuthMain(
                            params: AuthorizationParams(
                              initialCallbackUri: initialOAuthCallbackUri,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ],
      errorBuilder: (BuildContext context, _) => Scaffold(
        body: SafeArea(
          child: UiContentState.error(
            title: context.t.navigationUnavailable,
            actionLabel: context.t.navigationSearch,
            onAction: () => config.go('/search'),
          ),
        ),
      ),
    );
  }

  final GlobalKey<NavigatorState> _rootKey = GlobalKey<NavigatorState>();
  late final GoRouter config;

  List<RouteBase> _detailRoutes() => <RouteBase>[
    GoRoute(
      path: 'team/:id',
      redirect: (_, GoRouterState state) =>
          _positiveId(state.pathParameters['id']) == null ? '/search' : null,
      builder: (_, GoRouterState state) => TeamMain(
        params: TeamParams(_positiveId(state.pathParameters['id'])!),
      ),
    ),
    GoRoute(path: 'settings', builder: (_, _) => const SettingsMain()),
    GoRoute(path: 'about', builder: (_, _) => const AboutMain()),
    GoRoute(path: 'licenses', builder: (_, _) => const LicensesScreen()),
    GoRoute(
      path: 'medals/:user',
      redirect: (_, GoRouterState state) =>
          _positiveId(state.pathParameters['user']) == null ? '/search' : null,
      builder: (_, GoRouterState state) =>
          MedalsMain(userId: _positiveId(state.pathParameters['user'])!),
    ),
    GoRoute(
      path: 'profile/:kind/:user/:ruleset',
      redirect: (_, GoRouterState state) =>
          _profileParams(state) == null ? '/search' : null,
      builder: (_, GoRouterState state) =>
          ProfileMain(params: _profileParams(state)!),
    ),
    GoRoute(path: 'me', builder: (_, _) => const ProfileMain.current()),
    GoRoute(
      path: 'beatmap/:kind/:id',
      redirect: (_, GoRouterState state) =>
          _beatmapParams(state) == null ? '/search' : null,
      builder: (_, GoRouterState state) =>
          BeatmapMain(params: _beatmapParams(state)!),
    ),
    GoRoute(
      path: 'article/:id',
      redirect: (_, GoRouterState state) =>
          _positiveId(state.pathParameters['id']) == null ? '/search' : null,
      builder: (_, GoRouterState state) => NewsMain(
        params: NewsArticleParams(_positiveId(state.pathParameters['id'])!),
      ),
    ),
    GoRoute(
      path: 'wiki',
      redirect: (_, GoRouterState state) =>
          _wikiParams(state) == null ? '/search' : null,
      builder: (_, GoRouterState state) =>
          WikiMain(params: _wikiParams(state)!),
    ),
    GoRoute(
      path: 'web',
      redirect: (_, GoRouterState state) =>
          _webUri(state) == null ? '/search' : null,
      builder: (_, GoRouterState state) => WebPageScreen(uri: _webUri(state)!),
    ),
    GoRoute(
      path: 'forums/:id',
      redirect: (_, GoRouterState state) =>
          _positiveId(state.pathParameters['id']) == null ? '/search' : null,
      builder: (_, GoRouterState state) =>
          ForumBoardMain(forumId: _positiveId(state.pathParameters['id'])!),
    ),
    GoRoute(
      path: 'topic/:id',
      redirect: (_, GoRouterState state) =>
          _positiveId(state.pathParameters['id']) == null ? '/search' : null,
      builder: (_, GoRouterState state) =>
          ForumTopicMain(topicId: _positiveId(state.pathParameters['id'])!),
    ),
    GoRoute(
      path: 'packs',
      builder: (_, GoRouterState state) => BeatmapPacksMain(
        type:
            BeatmapPackType.fromApi(state.uri.queryParameters['type']) ??
            BeatmapPackType.standard,
      ),
    ),
    GoRoute(
      path: 'pack/:tag',
      redirect: (_, GoRouterState state) =>
          BeatmapPackLinks.tagPattern.hasMatch(
            state.pathParameters['tag'] ?? '',
          )
          ? null
          : '/search',
      builder: (_, GoRouterState state) =>
          BeatmapPackMain(tag: state.pathParameters['tag']!),
    ),
    GoRoute(path: 'spotlights', builder: (_, _) => const SpotlightsMain()),
    GoRoute(path: 'daily', builder: (_, _) => const DailyChallengeMain()),
    GoRoute(path: 'daily/history', builder: (_, _) => const DailyHistoryMain()),
    GoRoute(
      path: 'daily/day/:room',
      redirect: (_, GoRouterState state) =>
          _positiveId(state.pathParameters['room']) == null ? '/search' : null,
      builder: (_, GoRouterState state) => DailyChallengeMain(
        pastRoomId: _positiveId(state.pathParameters['room'])!,
      ),
    ),
    GoRoute(
      path: 'beatmaps',
      redirect: (_, GoRouterState state) => Uri(
        path: '/find',
        queryParameters: {...state.uri.queryParameters, 'tab': 'maps'},
      ).toString(),
    ),
  ];

  static SearchParams _searchParams(GoRouterState state) => SearchParams(
    tab: switch (state.uri.queryParameters['tab']) {
      'maps' => SearchTab.maps,
      'wiki' => SearchTab.wiki,
      _ => SearchTab.players,
    },
    // Bounded so a pasted deep link cannot carry an unbounded query.
    text: (state.uri.queryParameters['q'] ?? '')
        .trim()
        .characters
        .take(200)
        .toString(),
  );

  String get _branchPath =>
      '/${config.routerDelegate.currentConfiguration.uri.pathSegments.first}';

  Future<void> openProfile(BuildContext context, ProfileParams params) async {
    final (String kind, String value) = switch (params.user) {
      ProfileUserId(:final value) => ('id', value.toString()),
      ProfileUsername(:final value) => ('name', value),
    };
    await config.push<void>(
      '$_branchPath/profile/$kind/${Uri.encodeComponent(value)}/${params.ruleset?.apiValue ?? _defaultMode}',
    );
  }

  Future<void> openCurrentProfile(BuildContext context) async =>
      config.push<void>('$_branchPath/me');

  Future<void> openSettings(BuildContext context) async =>
      config.push<void>('$_branchPath/settings');

  Future<void> openTeam(BuildContext context, int id) async {
    if (id <= 0) throw ArgumentError.value(id, 'id');
    await config.push<void>('$_branchPath/team/$id');
  }

  Future<void> openAbout(BuildContext context) async =>
      config.push<void>('$_branchPath/about');

  Future<void> openLicenses(BuildContext context) async =>
      config.push<void>('$_branchPath/licenses');

  Future<void> openMedals(BuildContext context, int userId) async {
    if (userId <= 0) throw ArgumentError.value(userId, 'userId');
    await config.push<void>('$_branchPath/medals/$userId');
  }

  Future<void> openNewsArticle(
    BuildContext context,
    NewsArticleParams params,
  ) async => config.push<void>('$_branchPath/article/${params.id}');

  /// osu! wiki article; the path travels as a query value (it has slashes).
  Future<void> openWiki(BuildContext context, WikiParams params) async =>
      config.push<void>(
        Uri(
          path: '$_branchPath/wiki',
          queryParameters: <String, String>{
            'path': params.path,
            'locale': ?params.locale,
          },
        ).toString(),
      );

  /// One linked web page in the single-page viewer (ADR-009).
  Future<void> openWebPage(BuildContext context, Uri uri) async =>
      config.push<void>(
        Uri(
          path: '$_branchPath/web',
          queryParameters: <String, String>{'url': uri.toString()},
        ).toString(),
      );

  /// One osu! forum (topics and subforums), P54.
  Future<void> openForum(BuildContext context, int id) async {
    if (id <= 0) throw ArgumentError.value(id, 'id');
    await config.push<void>('$_branchPath/forums/$id');
  }

  /// One forum topic, read from the first post.
  Future<void> openForumTopic(BuildContext context, int id) async {
    if (id <= 0) throw ArgumentError.value(id, 'id');
    await config.push<void>('$_branchPath/topic/$id');
  }

  /// Beatmap packs of one type (P55).
  Future<void> openPacks(BuildContext context, BeatmapPackType type) async =>
      config.push<void>(
        Uri(
          path: '$_branchPath/packs',
          queryParameters: <String, String>{'type': type.apiValue},
        ).toString(),
      );

  /// One beatmap pack by tag.
  Future<void> openPack(BuildContext context, String tag) async {
    if (!BeatmapPackLinks.tagPattern.hasMatch(tag)) {
      throw ArgumentError.value(tag, 'tag');
    }
    await config.push<void>('$_branchPath/pack/$tag');
  }

  Future<void> openSpotlights(BuildContext context) async =>
      config.push<void>('$_branchPath/spotlights');

  Future<void> openDailyChallenge(BuildContext context) async =>
      config.push<void>('$_branchPath/daily');

  Future<void> openDailyHistory(BuildContext context) async =>
      config.push<void>('$_branchPath/daily/history');

  Future<void> openPastDailyChallenge(BuildContext context, int roomId) async {
    if (roomId <= 0) throw ArgumentError.value(roomId, 'roomId');
    await config.push<void>('$_branchPath/daily/day/$roomId');
  }

  Future<void> openSearch(
    BuildContext context, {
    String text = '',
    SearchTab tab = SearchTab.players,
  }) async => config.go(
    // The search tab of the bottom bar, not a page on the current stack.
    Uri(
      path: '/find',
      queryParameters: {
        if (text.trim().isNotEmpty) 'q': text.trim(),
        'tab': tab.name,
      },
    ).toString(),
  );

  Future<void> openBeatmap(BuildContext context, BeatmapParams params) async {
    final String kind = params is BeatmapsetParams ? 'set' : 'difficulty';
    final String query = switch (params) {
      BeatmapDifficultyParams(ruleset: final ProfileRuleset ruleset) =>
        '?ruleset=${ruleset.apiValue}',
      _ => '',
    };
    await config.push<void>('$_branchPath/beatmap/$kind/${params.id}$query');
  }

  Future<void> openLogin(BuildContext context) async =>
      config.push<void>('$_branchPath/auth');

  void finishAuthorization(BuildContext context) {
    if (config.canPop()) {
      config.pop();
    } else {
      config.go('/search');
    }
  }

  void dispose() => config.dispose();

  static Uri? _webUri(GoRouterState state) {
    final String? value = state.uri.queryParameters['url'];
    if (value == null || value.length > 4096) return null;
    final Uri? uri = Uri.tryParse(value);
    return uri != null &&
            uri.isScheme('https') &&
            uri.host.isNotEmpty &&
            uri.userInfo.isEmpty
        ? uri
        : null;
  }

  static WikiParams? _wikiParams(GoRouterState state) {
    final String? path = state.uri.queryParameters['path'];
    final String? locale = state.uri.queryParameters['locale'];
    if (path == null || path.length > 300) return null;
    try {
      return WikiParams(
        path,
        locale:
            locale != null && RegExp(r'^[a-z]{2}(-[a-z]{2})?$').hasMatch(locale)
            ? locale
            : null,
      );
    } on ArgumentError {
      return null;
    }
  }

  static int? _positiveId(String? text) {
    final int? id = int.tryParse(text ?? '');
    return id != null && id > 0 ? id : null;
  }

  static ProfileRuleset? _ruleset(String? value) => ProfileRuleset.values
      .where((ProfileRuleset mode) => mode.apiValue == value)
      .firstOrNull;

  /// Route segment for "the player's own main mode".
  static const String _defaultMode = 'default';

  static ProfileParams? _profileParams(GoRouterState state) {
    final String? mode = state.pathParameters['ruleset'];
    final ProfileRuleset? ruleset = _ruleset(mode);
    final String? value = state.pathParameters['user'];
    if ((ruleset == null && mode != _defaultMode) || value == null) {
      return null;
    }
    try {
      final ProfileUserReference? user = switch (state.pathParameters['kind']) {
        'id' when _positiveId(value) != null => ProfileUserId(
          _positiveId(value)!,
        ),
        'name' => ProfileUsername(value),
        _ => null,
      };
      return user == null ? null : ProfileParams(user: user, ruleset: ruleset);
    } on ArgumentError {
      return null;
    }
  }

  static BeatmapParams? _beatmapParams(GoRouterState state) {
    final int? id = _positiveId(state.pathParameters['id']);
    final String? mode = state.uri.queryParameters['ruleset'];
    if (id == null || (mode != null && _ruleset(mode) == null)) return null;
    return switch (state.pathParameters['kind']) {
      'set' => BeatmapsetParams(id),
      'difficulty' => BeatmapDifficultyParams(id, ruleset: _ruleset(mode)),
      _ => null,
    };
  }
}
