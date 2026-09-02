import 'package:tracksu/src/_core/serialization/json_map_reader.dart';
import 'package:tracksu/src/auth/data/oauth_remote_source_exception.dart';
import 'package:tracksu/src/rankings/data/entry_dto.dart';
import 'package:tracksu/src/rankings/data/rankings_remote_source.dart';
import 'package:tracksu/src/rankings/domain/entry.dart';
import 'package:tracksu/src/rankings/domain/rankings_query.dart';
import 'package:tracksu/src/rankings/domain/rankings_repository.dart';
import 'package:tracksu_network/tracksu_network.dart';

/// One instance per rankings section; newer reads cancel this section's old IO.
final class RankingsRepositoryImpl implements RankingsRepository {
  factory RankingsRepositoryImpl({
    required RankingsRemoteSource remoteSource,
  }) => RankingsRepositoryImpl._(remoteSource);

  RankingsRepositoryImpl._(this._remoteSource);
  final RankingsRemoteSource _remoteSource;
  RestCancellationToken? _pending;

  @override
  void cancelPending() {
    _pending?.cancel();
    _pending = null;
  }

  @override
  Future<RankingsPage> load(RankingsQuery query) async {
    cancelPending();
    final RestCancellationToken token = RestCancellationToken();
    _pending = token;
    try {
      final Map<String, dynamic> raw = await _remoteSource.load(
        query,
        options: RestClientOptions(cancellationToken: token),
      );
      if (token.isCancelled) {
        throw const RankingsFailure(RankingsFailureKind.cancelled);
      }
      final JsonMapReader reader = JsonMapReader(raw);
      final List<dynamic> payload = reader.requiredList('ranking');
      final Map<String, dynamic>? cursor = reader.optionalMap('cursor');
      final int? next = cursor == null
          ? null
          : JsonMapReader(cursor).requiredInt('page', positive: true);
      if (next != null && next <= query.page) {
        throw const FormatException('Non-advancing cursor.');
      }
      final List<RankingEntry> rankings = <RankingEntry>[];
      for (final Object? item in payload) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Expected a entry object.');
        }
        final RankingEntry entry = RankingEntryDto.fromJson(item).toDomain();
        rankings.add(entry);
      }
      return RankingsPage(items: rankings, nextPage: next);
    } on RankingsRemoteException catch (error, stackTrace) {
      Error.throwWithStackTrace(_statusFailure(error.statusCode), stackTrace);
    } on OAuthRemoteSourceException catch (error, stackTrace) {
      Error.throwWithStackTrace(_statusFailure(error.statusCode), stackTrace);
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
      if (identical(_pending, token)) {
        _pending = null;
      }
    }
  }

  RankingsFailure _statusFailure(int status) =>
      RankingsFailure(switch (status) {
        404 => RankingsFailureKind.notFound,
        401 || 403 => RankingsFailureKind.accessDenied,
        429 => RankingsFailureKind.rateLimited,
        _ => RankingsFailureKind.unavailable,
      });
}
