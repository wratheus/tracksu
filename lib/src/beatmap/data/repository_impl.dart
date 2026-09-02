import 'package:tracksu/src/_core/serialization/json_map_reader.dart';
import 'package:tracksu/src/beatmap/data/failure_mapper.dart';
import 'package:tracksu/src/beatmap/data/beatmap_dto.dart';
import 'package:tracksu/src/beatmap/data/remote_source.dart';
import 'package:tracksu/src/beatmap/domain/beatmap.dart';
import 'package:tracksu/src/beatmap/domain/repository.dart';
import 'package:tracksu_network/tracksu_network.dart';

final class BeatmapRepositoryImpl implements BeatmapRepository {
  factory BeatmapRepositoryImpl({required BeatmapRemoteSource source}) =>
      BeatmapRepositoryImpl._(source);
  BeatmapRepositoryImpl._(this._source);
  final BeatmapRemoteSource _source;
  RestCancellationToken? _pending;

  @override
  void cancelPending() {
    _pending?.cancel();
    _pending = null;
  }

  @override
  Future<BeatmapDetails> load(BeatmapParams params) async {
    cancelPending();
    final RestCancellationToken token = RestCancellationToken();
    _pending = token;
    final RestClientOptions options = RestClientOptions(
      cancellationToken: token,
    );
    try {
      var setId = params.id;
      if (params is BeatmapDifficultyParams) {
        final JsonMapReader map = JsonMapReader(
          await _source.loadDifficulty(params.id, options),
        );
        if (map.requiredInt('id', positive: true) != params.id) {
          throw const FormatException('Unexpected beatmap ID.');
        }
        setId = map.requiredInt('beatmapset_id', positive: true);
      }
      final BeatmapDetails details = BeatmapDetailsDto.fromJson(
        await _source.loadSet(setId, options),
      ).toDomain();
      if (details.id != setId ||
          (params is BeatmapDifficultyParams &&
              !details.difficulties.any(
                (BeatmapDifficulty item) => item.id == params.id,
              ))) {
        throw const FormatException('Requested beatmap missing from set.');
      }
      return details;
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace(mapBeatmapFailure(error), stackTrace);
    } finally {
      if (identical(_pending, token)) _pending = null;
    }
  }
}
