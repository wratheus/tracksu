import 'package:flutter/material.dart';
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
import 'package:tracksu/src/profile/domain/profile_params.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';
import 'package:tracksu/src/profile/main.dart';
import 'package:tracksu/src/rankings/main.dart';
import 'package:tracksu/src/rankings/spotlights/main.dart';
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
            for (final (String path, Widget screen) in <(String, Widget)>[
              ('search', const SearchHome()),
              ('rankings', const RankingsMain()),
              ('news', const NewsMain()),
            ])
              StatefulShellBranch(
                restorationScopeId: '${path}_branch',
                routes: <RouteBase>[
                  GoRoute(
                    path: '/$path',
                    builder: (_, _) => screen,
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
    GoRoute(path: 'spotlights', builder: (_, _) => const SpotlightsMain()),
  ];

  String get _branchPath =>
      '/${config.routerDelegate.currentConfiguration.uri.pathSegments.first}';

  Future<void> openProfile(BuildContext context, ProfileParams params) async {
    final (String kind, String value) = switch (params.user) {
      ProfileUserId(:final value) => ('id', value.toString()),
      ProfileUsername(:final value) => ('name', value),
    };
    await config.push<void>(
      '$_branchPath/profile/$kind/${Uri.encodeComponent(value)}/${params.ruleset.apiValue}',
    );
  }

  Future<void> openCurrentProfile(BuildContext context) async =>
      config.push<void>('$_branchPath/me');

  Future<void> openNewsArticle(
    BuildContext context,
    NewsArticleParams params,
  ) async => config.push<void>('$_branchPath/article/${params.id}');

  Future<void> openSpotlights(BuildContext context) async =>
      config.push<void>('$_branchPath/spotlights');

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

  static int? _positiveId(String? text) {
    final int? id = int.tryParse(text ?? '');
    return id != null && id > 0 ? id : null;
  }

  static ProfileRuleset? _ruleset(String? value) => ProfileRuleset.values
      .where((ProfileRuleset mode) => mode.apiValue == value)
      .firstOrNull;

  static ProfileParams? _profileParams(GoRouterState state) {
    final ProfileRuleset? ruleset = _ruleset(state.pathParameters['ruleset']);
    final String? value = state.pathParameters['user'];
    if (ruleset == null || value == null) return null;
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
