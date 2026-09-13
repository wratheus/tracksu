import 'package:tracksu/src/_core/serialization/json_map_reader.dart';
import 'package:tracksu/src/_shared/content/data/bbcode_content.dart';
import 'package:tracksu/src/_shared/content/domain/content_page.dart';
import 'package:tracksu/src/profile/data/profile_details_dto.dart';
import 'package:tracksu/src/profile/data/profile_details_mapper.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/team/domain/team.dart';

final class TeamDto {
  const TeamDto._(this._details);
  final TeamDetails _details;
  TeamDetails toDomain() => _details;

  factory TeamDto.fromJson(Map<String, dynamic> json, TeamParams params) {
    final JsonMapReader reader = JsonMapReader(json);
    final int id = reader.requiredInt('id', positive: true);
    if (id != params.id) throw const FormatException('Unexpected team.');
    final identity = ProfileDetailsDto.fromJson({'team': json})
        .toDomain()
        .team!;
    final ProfileRuleset defaultMode = _mode(
      reader.requiredInt('default_ruleset_id'),
    );
    final JsonMapReader stats = JsonMapReader(
      JsonMapReader.asMap(json['statistics']),
    );
    final ProfileRuleset mode = params.ruleset ?? defaultMode;
    final int? returnedMode = stats.optionalInt('ruleset_id');
    if ((returnedMode != null && _mode(returnedMode) != mode) ||
        (stats.optionalInt('team_id') != null &&
            stats.optionalInt('team_id') != id)) {
      throw const FormatException('Unexpected team statistics.');
    }
    final int emptySlots = reader.requiredInt('empty_slots');
    final int plays = stats.requiredInt('play_count');
    final int score = stats.requiredInt('ranked_score');
    final double pp = stats.requiredDouble('performance');
    final int? rank = stats.optionalInt('rank');
    if (emptySlots < 0 ||
        plays < 0 ||
        score < 0 ||
        !pp.isFinite ||
        pp < 0 ||
        (rank != null && rank <= 0)) {
      throw const FormatException('Invalid team statistics.');
    }
    final TeamMember leader = _member(JsonMapReader.asMap(json['leader']));
    final List<dynamic> rawMembers = reader.requiredList('members');
    if (rawMembers.length > 1000) {
      throw const FormatException('Too many members.');
    }
    final Map<int, TeamMember> members = {};
    for (final Object? value in rawMembers) {
      final TeamMember member = _member(JsonMapReader.asMap(value));
      if (member.id != leader.id) members[member.id] = member;
    }
    final Uri uri = Uri.https('osu.ppy.sh', '/teams/$id/${mode.apiValue}');
    ContentPage? description;
    final String? raw = reader.optionalString('description');
    if (raw != null && raw.trim().isNotEmpty) {
      try {
        description = ContentPage(
          uri: uri,
          document: BbcodeContent.parse(raw, uri),
        );
      } on FormatException {
        description = ContentPage(uri: uri, document: null);
      }
    }
    return TeamDto._(
      TeamDetails(
        identity: identity,
        createdAt: DateTime.parse(reader.requiredString('created_at')),
        defaultRuleset: defaultMode,
        ruleset: mode,
        isOpen: reader.requiredBool('is_open'),
        emptySlots: emptySlots,
        leader: leader,
        members: members.values.toList(),
        statistics: TeamStatistics(
          playCount: plays,
          rankedScore: score,
          performance: pp,
          rank: rank,
        ),
        cover: _image(reader.optionalString('cover_url')),
        description: description,
      ),
    );
  }

  static ProfileRuleset _mode(int id) => switch (id) {
    0 => ProfileRuleset.osu,
    1 => ProfileRuleset.taiko,
    2 => ProfileRuleset.fruits,
    3 => ProfileRuleset.mania,
    _ => throw const FormatException('Invalid team ruleset.'),
  };

  static Uri? _image(String? value) {
    final Uri? uri = value == null ? null : Uri.tryParse(value);
    return uri != null &&
            uri.scheme == 'https' &&
            uri.port == 443 &&
            uri.userInfo.isEmpty &&
            (uri.host == 'ppy.sh' || uri.host.endsWith('.ppy.sh'))
        ? uri
        : null;
  }

  static TeamMember _member(Map<String, dynamic> json) {
    final JsonMapReader reader = JsonMapReader(json);
    final details = ProfileDetailsDto.fromJson({'groups': json['groups']})
        .toDomain();
    final String? visited = reader.optionalString('last_visit');
    final bool deleted = reader.requiredBool('is_deleted');
    return TeamMember(
      id: deleted
          ? (reader.optionalInt('id') ?? 0)
          : reader.requiredInt('id', positive: true),
      name: reader.requiredString('username'),
      country: deleted
          ? (reader.optionalString('country_code') ?? 'XX')
          : reader.requiredString('country_code'),
      avatar: _image(reader.optionalString('avatar_url')),
      online: reader.requiredBool('is_online'),
      deleted: reader.requiredBool('is_deleted'),
      supporter: reader.requiredBool('is_supporter'),
      lastVisit: visited == null ? null : DateTime.parse(visited),
      groups: details.groups ?? [],
    );
  }
}
