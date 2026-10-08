import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_shared/navigation/external_links.dart';
import 'package:tracksu/src/beatmap/domain/beatmap.dart';
import 'package:tracksu/src/forum/domain/forum.dart';
import 'package:tracksu/src/profile/domain/profile_params.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';
import 'package:tracksu/src/wiki/domain/wiki.dart';

/// One place that decides where a tapped link goes (ADR-009):
///
/// 1. osu.ppy.sh pages the app has natively — wiki articles, players,
///    beatmaps and sets, teams, forums and topics — open as app screens.
/// 2. Video sites open in their own app.
/// 3. Any other https page opens in the single-page viewer: no address bar,
///    links inside it leave for the system browser.
/// 4. Other schemes go to the system handler.
abstract final class AppLinks {
  static const Set<String> _videoHosts = <String>{
    'youtube.com',
    'www.youtube.com',
    'm.youtube.com',
    'youtu.be',
  };

  static final RegExp _user = RegExp(
    r'^/(?:users|u)/([^/]+)(?:/(osu|taiko|fruits|mania))?/?$',
  );
  static final RegExp _set = RegExp(r'^/(?:beatmapsets|s)/([1-9][0-9]*)/?$');
  static final RegExp _map = RegExp(r'^/(?:beatmaps|b)/([1-9][0-9]*)/?$');
  static final RegExp _setFragment = RegExp(
    r'^(osu|taiko|fruits|mania)/([1-9][0-9]*)$',
  );
  static final RegExp _team = RegExp(r'^/teams/([1-9][0-9]*)');

  static Future<bool> open(BuildContext context, Uri uri) async {
    final router = DepsScope.of(context).appRouter;
    if (!uri.isScheme('https') && !uri.isScheme('http')) {
      return ExternalLinks.openInBrowser(uri);
    }
    if (uri.host == 'osu.ppy.sh') {
      if (WikiLinks.fromUri(uri) case final WikiParams wiki) {
        unawaited(router.openWiki(context, wiki));
        return true;
      }
      if (_user.firstMatch(uri.path) case final RegExpMatch match) {
        final String value = Uri.decodeComponent(match.group(1)!);
        final int? id = int.tryParse(value);
        final ProfileUserReference user = id != null && id > 0
            ? ProfileUserId(id)
            : ProfileUsername(value);
        final ProfileRuleset? mode = ProfileRuleset.values
            .where((ProfileRuleset value) => value.apiValue == match.group(2))
            .firstOrNull;
        unawaited(
          router.openProfile(
            context,
            mode == null
                ? ProfileParams.defaultMode(user: user)
                : ProfileParams(user: user, ruleset: mode),
          ),
        );
        return true;
      }
      if (_set.firstMatch(uri.path) case final RegExpMatch match) {
        final RegExpMatch? map = _setFragment.firstMatch(uri.fragment);
        unawaited(
          router.openBeatmap(
            context,
            map == null
                ? BeatmapsetParams(int.parse(match.group(1)!))
                : BeatmapDifficultyParams(
                    int.parse(map.group(2)!),
                    ruleset: ProfileRuleset.values
                        .where((m) => m.apiValue == map.group(1))
                        .firstOrNull,
                  ),
          ),
        );
        return true;
      }
      if (_map.firstMatch(uri.path) case final RegExpMatch match) {
        unawaited(
          router.openBeatmap(
            context,
            BeatmapDifficultyParams(int.parse(match.group(1)!)),
          ),
        );
        return true;
      }
      if (ForumLinks.topicId(uri) case final int topic) {
        unawaited(router.openForumTopic(context, topic));
        return true;
      }
      if (ForumLinks.boardId(uri) case final int forum) {
        unawaited(router.openForum(context, forum));
        return true;
      }
      if (_team.firstMatch(uri.path) case final RegExpMatch match) {
        unawaited(router.openTeam(context, int.parse(match.group(1)!)));
        return true;
      }
    }
    if (_videoHosts.contains(uri.host.toLowerCase()) ||
        !uri.isScheme('https')) {
      return ExternalLinks.openInBrowser(uri);
    }
    unawaited(router.openWebPage(context, uri));
    return true;
  }
}
