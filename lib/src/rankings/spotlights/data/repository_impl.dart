import 'package:tracksu/src/_core/serialization/json_map_reader.dart';
import 'package:tracksu/src/auth/data/oauth_remote_source_exception.dart';
import 'package:tracksu/src/rankings/data/rankings_remote_source.dart';
import 'package:tracksu/src/rankings/domain/rankings_repository.dart';
import 'package:tracksu/src/rankings/spotlights/domain/spotlight.dart';
import 'package:tracksu/src/rankings/spotlights/data/remote_source.dart';
import 'package:tracksu/src/rankings/spotlights/data/spotlight_dto.dart';
import 'package:tracksu_network/tracksu_network.dart';

final class SpotlightsRepositoryImpl implements SpotlightsRepository {
  SpotlightsRepositoryImpl({required SpotlightsRemoteSource remoteSource})
    : _source = remoteSource;
  final SpotlightsRemoteSource _source;
  RestCancellationToken? _pending;

  @override
  void cancelPending() {
    _pending?.cancel();
    _pending = null;
  }

  @override
  Future<List<Spotlight>> catalog() => _read(
    (RestClientOptions options) => _source.catalog(options: options),
    (Map<String, dynamic> raw) {
      final List<Spotlight> items = <Spotlight>[];
      for (final Object? item in JsonMapReader(
        raw,
      ).requiredList('spotlights')) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Invalid spotlight.');
        }
        items.add(SpotlightDto.fromJson(item).toDomain());
      }
      if (items.map((Spotlight item) => item.id).toSet().length !=
          items.length) {
        throw const FormatException('Duplicate spotlight IDs.');
      }
      return List<Spotlight>.unmodifiable(items);
    },
  );

  @override
  Future<SpotlightDetails> load(SpotlightQuery query) => _read(
    (RestClientOptions options) => _source.load(query, options: options),
    (Map<String, dynamic> raw) {
      final SpotlightDetails details = SpotlightDetailsDto.fromJson(raw)
          .toDomain();
      if (details.spotlight.id != query.id) {
        throw const FormatException('Spotlight mismatch.');
      }
      return details;
    },
  );

  Future<T> _read<T>(
    Future<Map<String, dynamic>> Function(RestClientOptions) request,
    T Function(Map<String, dynamic>) decode,
  ) async {
    cancelPending();
    final RestCancellationToken token = RestCancellationToken();
    _pending = token;
    try {
      final Map<String, dynamic> raw = await request(
        RestClientOptions(cancellationToken: token),
      );
      if (token.isCancelled) {
        throw const RankingsFailure(RankingsFailureKind.cancelled);
      }
      return decode(raw);
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
