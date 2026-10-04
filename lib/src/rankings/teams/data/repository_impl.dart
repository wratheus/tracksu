import 'package:tracksu/src/_core/serialization/json_map_reader.dart';
import 'package:tracksu/src/auth/data/oauth_remote_source_exception.dart';
import 'package:tracksu/src/profile/data/profile_details_dto.dart';
import 'package:tracksu/src/profile/data/profile_details_mapper.dart';
import 'package:tracksu/src/profile/domain/profile_details.dart';
import 'package:tracksu/src/rankings/data/rankings_remote_source.dart';
import 'package:tracksu/src/rankings/domain/rankings_repository.dart';
import 'package:tracksu/src/rankings/teams/data/remote_source.dart';
import 'package:tracksu/src/rankings/teams/domain/team_ranking.dart';
import 'package:tracksu_network/tracksu_network.dart';

/// Same paging contract as player rankings: 50 rows, `cursor.page`, `total`.
final class TeamRankingsRepositoryImpl implements TeamRankingsRepository {
  TeamRankingsRepositoryImpl({required TeamRankingsRemoteSource remoteSource})
    : _source = remoteSource;
  final TeamRankingsRemoteSource _source;
  RestCancellationToken? _pending;

  static const int _pageSize = 50;

  @override
  void cancelPending() {
    _pending?.cancel();
    _pending = null;
  }

  @override
  Future<TeamRankingsPage> load(TeamRankingsQuery query) async {
    cancelPending();
    final RestCancellationToken token = RestCancellationToken();
    _pending = token;
    try {
      final Map<String, dynamic> raw = await _source.load(
        query,
        options: RestClientOptions(cancellationToken: token),
      );
      if (token.isCancelled) {
        throw const RankingsFailure(RankingsFailureKind.cancelled);
      }
      return _decode(raw, query.page);
    } on RankingsRemoteException catch (error, stackTrace) {
      Error.throwWithStackTrace(_status(error.statusCode), stackTrace);
    } on OAuthRemoteSourceException catch (error, stackTrace) {
      Error.throwWithStackTrace(_status(error.statusCode), stackTrace);
    } on FormatException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const RankingsFailure(RankingsFailureKind.invalidResponse),
        stackTrace,
      );
    } on RestRequestCancelledException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const RankingsFailure(RankingsFailureKind.cancelled),
        stackTrace,
      );
    } on RestClientException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const RankingsFailure(RankingsFailureKind.connection),
        stackTrace,
      );
    } finally {
      if (identical(_pending, token)) _pending = null;
    }
  }

  static TeamRankingsPage _decode(Map<String, dynamic> raw, int page) {
    final JsonMapReader reader = JsonMapReader(raw);
    final List<dynamic> rows = reader.requiredList('ranking');
    final Map<String, dynamic>? cursor = reader.optionalMap('cursor');
    final int? next = cursor == null
        ? null
        : JsonMapReader(cursor).requiredInt('page', positive: true);
    if (next != null && next <= page) {
      throw const FormatException('Non-advancing cursor.');
    }
    final int total = reader.requiredInt('total');
    if (total < 0 || (total == 0 && rows.isNotEmpty)) {
      throw const FormatException('Invalid ranking total.');
    }
    final int lastPage = total == 0 ? 1 : (total + _pageSize - 1) ~/ _pageSize;
    if (page > lastPage) {
      throw const FormatException('Ranking pages changed; refresh required.');
    }
    if (rows.length > _pageSize) {
      throw const FormatException('Unexpected ranking page size.');
    }
    final List<TeamRankingEntry> items = <TeamRankingEntry>[];
    for (final Object? row in rows) {
      final JsonMapReader item = JsonMapReader(JsonMapReader.asMap(row));
      final ProfileTeam? team = ProfileDetailsDto.fromJson(<String, dynamic>{
        'team': item.optionalMap('team'),
      }).toDomain().team;
      if (team == null) throw const FormatException('Missing team.');
      if (item.requiredInt('team_id', positive: true) != team.id) {
        throw const FormatException('Team id mismatch.');
      }
      final double performance = item.requiredDouble('performance');
      final int score = item.requiredInt('ranked_score');
      final int plays = item.requiredInt('play_count');
      final int members = item.requiredInt('member_count');
      if (!performance.isFinite ||
          performance < 0 ||
          score < 0 ||
          plays < 0 ||
          members < 0) {
        throw const FormatException('Invalid team ranking values.');
      }
      items.add(
        TeamRankingEntry(
          team: team,
          position: (page - 1) * _pageSize + items.length + 1,
          performance: performance,
          rankedScore: score,
          playCount: plays,
          memberCount: members,
        ),
      );
    }
    if (items.map((TeamRankingEntry e) => e.team.id).toSet().length !=
        items.length) {
      throw const FormatException('Duplicate team row.');
    }
    return TeamRankingsPage(items: items, nextPage: next);
  }

  static RankingsFailure _status(int status) => RankingsFailure(switch (status) {
    404 => RankingsFailureKind.notFound,
    401 || 403 => RankingsFailureKind.accessDenied,
    429 => RankingsFailureKind.rateLimited,
    _ => RankingsFailureKind.unavailable,
  });
}
