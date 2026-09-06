import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tracksu/src/auth/main.dart';
import 'package:tracksu/src/auth/domain/authorization.dart';
import 'package:tracksu/src/guest/widgets/guest_shell.dart';
import 'package:tracksu/src/beatmap/domain/beatmap.dart';
import 'package:tracksu/src/beatmap/main.dart';
import 'package:tracksu/src/rankings/main.dart';
import 'package:tracksu/src/news/main.dart';
import 'package:tracksu/src/news/domain/news.dart';
import 'package:tracksu/src/rankings/spotlights/main.dart';
import 'package:tracksu/src/profile/main.dart';
import 'package:tracksu/src/profile/domain/profile_params.dart';

final class TracksuAppRouter {
  const TracksuAppRouter({this.initialOAuthCallbackUri});

  static const _oauthCallbackRoute = '/oauth-callback';

  final Uri? initialOAuthCallbackUri;

  Future<void> openProfile(BuildContext context, ProfileParams params) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: '/profile', arguments: params),
        builder: (_) =>
            ProfileMain(params: params, actions: const SizedBox.shrink()),
      ),
    );
  }

  Future<void> openRankings(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/rankings'),
        builder: (_) => const RankingsMain(),
      ),
    );
  }

  Future<void> openNews(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/news'),
        builder: (_) => const NewsMain(),
      ),
    );
  }

  Future<void> openNewsArticle(
    BuildContext context,
    NewsArticleParams params,
  ) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: '/news/article', arguments: params),
        builder: (_) => NewsMain(params: params),
      ),
    );
  }

  Future<void> openSpotlights(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/rankings/spotlights'),
        builder: (_) => const SpotlightsMain(),
      ),
    );
  }

  Future<void> openBeatmap(BuildContext context, BeatmapParams params) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: '/beatmap', arguments: params),
        builder: (_) => BeatmapMain(params: params),
      ),
    );
  }

  String get initialRoute =>
      initialOAuthCallbackUri == null ? '/' : _oauthCallbackRoute;

  Future<void> openLogin(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) =>
            const AuthMain(params: AuthorizationParams(startOnOpen: true)),
      ),
    );
  }

  void finishAuthorization(BuildContext context) {
    unawaited(
      Navigator.of(context).pushAndRemoveUntil<void>(
        MaterialPageRoute<void>(builder: (_) => const GuestShell()),
        (Route<dynamic> route) => false,
      ),
    );
  }

  Route<void> onGenerateRoute(RouteSettings settings) {
    if (settings.name == _oauthCallbackRoute) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => AuthMain(
          params: AuthorizationParams(
            initialCallbackUri: initialOAuthCallbackUri,
          ),
        ),
      );
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => const GuestShell(),
    );
  }
}
