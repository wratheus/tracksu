import 'package:tracksu/src/_core/serialization/json_map_reader.dart';
import 'package:tracksu/src/auth/data/oauth_remote_source_exception.dart';
import 'package:tracksu/src/profile/data/profile_details_dto.dart';
import 'package:tracksu/src/profile/data/profile_details_mapper.dart';
import 'package:tracksu/src/rankings/data/rankings_remote_source.dart';
import 'package:tracksu/src/rankings/domain/rankings_repository.dart';
import 'package:tracksu/src/rankings/kudosu/domain/kudosu_ranking.dart';
import 'package:tracksu/src/rankings/kudosu/data/remote_source.dart';
import 'package:tracksu_network/tracksu_network.dart';

/// `GET /rankings/kudosu?page=N` — documented ("Get Kudosu Ranking").
/// osu-web: `UserCompactTransformer` with `kudosu` (+ team), ordered by
/// total kudosu, 50 per page, at most 1000 users (20 pages); the response
/// has only `ranking`, so the next page exists while pages are full.
final class KudosuRankingRepositoryImpl implements KudosuRankingRepository {
  const KudosuRankingRepositoryImpl({
    required KudosuRankingRemoteSource remoteSource,
  }) : _source = remoteSource;
  final KudosuRankingRemoteSource _source;

  static const int pageSize = 50;
  static const int lastPage = 20;

  @override
  Future<KudosuRankingPage> load(int page) async {
    try {
      return decode(await _source.load(page), page);
    } on RankingsRemoteException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        RankingsFailure(switch (error.statusCode) {
          404 => RankingsFailureKind.notFound,
          401 || 403 => RankingsFailureKind.accessDenied,
          429 => RankingsFailureKind.rateLimited,
          _ => RankingsFailureKind.unavailable,
        }),
        stackTrace,
      );
    } on OAuthRemoteSourceException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const RankingsFailure(RankingsFailureKind.accessDenied),
        stackTrace,
      );
    } on FormatException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const RankingsFailure(RankingsFailureKind.invalidResponse),
        stackTrace,
      );
    } on RestClientException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const RankingsFailure(RankingsFailureKind.connection),
        stackTrace,
      );
    }
  }

  static KudosuRankingPage decode(Map<String, dynamic> raw, int page) {
    final List<dynamic> rows = JsonMapReader(raw).requiredList('ranking');
    if (rows.length > pageSize) {
      throw const FormatException('Unexpected kudosu page size.');
    }
    final List<KudosuRankingEntry> items = <KudosuRankingEntry>[];
    final Set<int> seen = <int>{};
    for (final Object? row in rows) {
      final Map<String, dynamic> user = JsonMapReader.asMap(row);
      final JsonMapReader reader = JsonMapReader(user);
      final int id = reader.requiredInt('id', positive: true);
      if (!seen.add(id)) throw const FormatException('Duplicate kudosu row.');
      final JsonMapReader kudosu = JsonMapReader(
        reader.optionalMap('kudosu') ??
            (throw const FormatException('Missing kudosu.')),
      );
      final int total = kudosu.requiredInt('total');
      final int available = kudosu.requiredInt('available');
      if (total < 0 || available < 0) {
        throw const FormatException('Negative kudosu.');
      }
      final Uri? avatar = Uri.tryParse(
        reader.optionalString('avatar_url') ?? '',
      );
      items.add(
        KudosuRankingEntry(
          position: (page - 1) * pageSize + items.length + 1,
          userId: id,
          username: reader.requiredString('username'),
          total: total,
          available: available,
          countryCode: reader.optionalString('country_code'),
          avatarUri:
              avatar != null &&
                  avatar.isScheme('https') &&
                  avatar.host.isNotEmpty
              ? avatar
              : null,
          team: (() {
            try {
              return ProfileDetailsDto.fromJson(<String, dynamic>{
                'team': user['team'],
              }).toDomain().team;
            } on FormatException {
              return null; // Optional affiliation must not hide a row.
            }
          })(),
        ),
      );
    }
    return KudosuRankingPage(
      items: items,
      nextPage: items.length == pageSize && page < lastPage ? page + 1 : null,
    );
  }
}
