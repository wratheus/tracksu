import 'package:tracksu/src/_core/serialization/json_map_reader.dart';
import 'package:tracksu/src/_shared/events/domain/osu_event.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';

/// Parses one osu-web Event. Unknown event types return null so a new type on
/// the server hides one row instead of failing the whole list.
abstract final class OsuEventDto {
  static final RegExp _beatmap = RegExp(r'/(?:b|beatmaps)/([1-9][0-9]*)');
  static final RegExp _beatmapset = RegExp(r'/(?:s|beatmapsets)/([1-9][0-9]*)');
  static final RegExp _user = RegExp(r'/(?:u|users)/([1-9][0-9]*)');

  static OsuEvent? fromJson(Map<String, dynamic> json) {
    final JsonMapReader reader = JsonMapReader(json);
    final String type = reader.requiredString('type');
    final OsuEventKind? kind = OsuEventKind.values
        .where((OsuEventKind value) => value.name == type)
        .firstOrNull;
    if (kind == null) return null;

    final JsonMapReader? beatmap = _child(reader, 'beatmap');
    final JsonMapReader? beatmapset = _child(reader, 'beatmapset');
    final JsonMapReader? user = _child(reader, 'user');
    final JsonMapReader? achievement = _child(reader, 'achievement');
    final String? mode = reader.optionalString('mode');
    final String? icon = achievement?.optionalString('icon_url');

    return OsuEvent(
      id: reader.requiredInt('id', positive: true),
      kind: kind,
      createdAt: DateTime.parse(reader.requiredString('created_at')),
      ruleset: ProfileRuleset.values
          .where((ProfileRuleset value) => value.apiValue == mode)
          .firstOrNull,
      rank: reader.optionalInt('rank'),
      grade: reader.optionalString('scoreRank'),
      count: reader.optionalInt('count'),
      approval: reader.optionalString('approval'),
      beatmapId: _id(_beatmap, beatmap?.optionalString('url')),
      beatmapsetId: _id(_beatmapset, beatmapset?.optionalString('url')),
      title:
          beatmap?.optionalString('title') ??
          beatmapset?.optionalString('title'),
      medalName: achievement?.optionalString('name'),
      medalIcon: icon == null ? null : Uri.tryParse(icon),
      userId: _id(_user, user?.optionalString('url')),
      username: user?.optionalString('username'),
      previousUsername: user?.optionalString('previousUsername'),
    );
  }

  static JsonMapReader? _child(JsonMapReader reader, String key) {
    final Map<String, dynamic>? map = reader.optionalMap(key);
    return map == null ? null : JsonMapReader(map);
  }

  static int? _id(RegExp pattern, String? url) {
    if (url == null) return null;
    final String? match = pattern.firstMatch(url)?.group(1);
    return match == null ? null : int.tryParse(match);
  }
}
