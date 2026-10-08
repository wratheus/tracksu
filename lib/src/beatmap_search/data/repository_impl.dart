import 'dart:io';

import 'package:tracksu/src/_core/serialization/json_map_reader.dart';
import 'package:tracksu/src/auth/data/oauth_remote_source_exception.dart';
import 'package:tracksu/src/beatmap_search/data/remote_source.dart';
import 'package:tracksu/src/beatmap_search/domain/beatmap_search.dart';
import 'package:tracksu/src/profile/beatmaps/data/beatmap_dto.dart';
import 'package:tracksu/src/profile/beatmaps/domain/beatmap.dart';
import 'package:tracksu/src/profile/beatmaps/domain/beatmaps_query.dart';
import 'package:tracksu_network/tracksu_network.dart';

final class BeatmapSearchRepositoryImpl implements BeatmapSearchRepository {
  BeatmapSearchRepositoryImpl({required this._source});
  final BeatmapSearchRemoteSource _source;
  RestCancellationToken? _pending;
  @override
  void cancelPending() => _pending?.cancel();

  @override
  Future<BeatmapSearchPage> search(
    BeatmapSearchQuery query, {
    String? cursor,
  }) async {
    cancelPending();
    final RestCancellationToken token = _pending = RestCancellationToken();
    try {
      return decode(
        await _source.search(query, cursor: cursor, cancellationToken: token),
      );
    } on BeatmapSearchRemoteException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        BeatmapSearchFailure(
          error.statusCode == 429
              ? BeatmapSearchFailureKind.rateLimited
              : BeatmapSearchFailureKind.unavailable,
        ),
        stackTrace,
      );
    } on OAuthRemoteSourceException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const BeatmapSearchFailure(BeatmapSearchFailureKind.unavailable),
        stackTrace,
      );
    } on FormatException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const BeatmapSearchFailure(BeatmapSearchFailureKind.invalidResponse),
        stackTrace,
      );
    } on Object catch (error, stackTrace) {
      if (error is RestClientException || error is IOException) {
        Error.throwWithStackTrace(
          const BeatmapSearchFailure(BeatmapSearchFailureKind.connection),
          stackTrace,
        );
      }
      rethrow;
    }
  }

  /// `BeatmapsetSearchResult`: `beatmapsets` (BeatmapsetExtended with
  /// `beatmaps`), `cursor_string`, `total`.
  static BeatmapSearchPage decode(Map<String, dynamic> raw) {
    final JsonMapReader reader = JsonMapReader(raw);
    final List<ProfileBeatmap> items = <ProfileBeatmap>[];
    final Set<int> seen = <int>{};
    for (final Object? item in reader.requiredList('beatmapsets')) {
      final Map<String, dynamic> set = JsonMapReader.asMap(item);
      final ProfileBeatmap beatmap = ProfileBeatmapDto.fromJson(
        set,
        type: ProfileBeatmapsType.ranked,
      ).toDomain();
      if (!seen.add(beatmap.id)) {
        throw const FormatException('Duplicate beatmapset.');
      }
      items.add(beatmap);
    }
    final String? cursor = reader.optionalString('cursor_string');
    final int? total = reader.optionalInt('total');
    if (total != null && total < 0) {
      throw const FormatException('Negative search total.');
    }
    return BeatmapSearchPage(
      items: items,
      cursor: cursor == null || cursor.isEmpty ? null : cursor,
      total: total,
    );
  }
}
