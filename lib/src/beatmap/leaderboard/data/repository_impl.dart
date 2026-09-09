import 'package:tracksu/src/_core/serialization/json_map_reader.dart';
import 'package:tracksu/src/_shared/scores/data/score_dto.dart';
import 'package:tracksu/src/_shared/scores/domain/score.dart';
import 'package:tracksu/src/beatmap/data/failure_mapper.dart';
import 'package:tracksu/src/beatmap/leaderboard/data/remote_source.dart';
import 'package:tracksu/src/beatmap/leaderboard/domain/repository.dart';
import 'package:tracksu_network/tracksu_network.dart';

final class LeaderboardRepositoryImpl implements LeaderboardRepository {
  factory LeaderboardRepositoryImpl({
    required LeaderboardRemoteSource source,
  }) => LeaderboardRepositoryImpl._(source);
  LeaderboardRepositoryImpl._(this._source);
  final LeaderboardRemoteSource _source;
  RestCancellationToken? _pending;

  @override
  void cancelPending() {
    _pending?.cancel();
    _pending = null;
  }

  @override
  Future<List<LeaderboardEntry>> load(LeaderboardQuery query) async {
    cancelPending();
    final RestCancellationToken token = RestCancellationToken();
    _pending = token;
    try {
      final JsonMapReader payload = JsonMapReader(
        await _source.load(query, RestClientOptions(cancellationToken: token)),
      );
      final List<LeaderboardEntry> entries = <LeaderboardEntry>[];
      final Set<int> ids = <int>{};
      for (final Object? item in payload.requiredList('scores')) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Expected score.');
        }
        final OsuScore score = OsuScoreDto.fromJson(item).toDomain();
        if (score.beatmapId != query.beatmapId ||
            score.ruleset != query.ruleset ||
            !ids.add(score.id)) {
          throw const FormatException('Unexpected leaderboard score.');
        }
        final Map<String, dynamic>? user = JsonMapReader(item)
            .optionalMap('user');
        final JsonMapReader? reader = user == null ? null : JsonMapReader(user);
        if (reader != null && reader.requiredInt('id') != score.userId) {
          throw const FormatException('Unexpected score user.');
        }
        entries.add(
          LeaderboardEntry(
            avatarUri: _avatar(reader?.optionalString('avatar_url')),
            score: score,
            username: reader?.requiredString('username'),
          ),
        );
      }
      return List<LeaderboardEntry>.unmodifiable(entries);
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace(mapBeatmapFailure(error), stackTrace);
    } finally {
      if (identical(_pending, token)) _pending = null;
    }
  }

  static Uri? _avatar(String? value) {
    final Uri? uri = value == null ? null : Uri.tryParse(value);
    return uri != null &&
            uri.scheme == 'https' &&
            uri.host.isNotEmpty &&
            uri.userInfo.isEmpty
        ? uri
        : null;
  }
}
