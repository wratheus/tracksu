import 'package:tracksu/src/auth/data/oauth_remote_source_exception.dart';
import 'package:tracksu/src/beatmap/data/remote_source.dart';
import 'package:tracksu/src/beatmap/domain/repository.dart';
import 'package:tracksu_network/tracksu_network.dart';

BeatmapFailure mapBeatmapFailure(Object error) =>
    BeatmapFailure(switch (error) {
      BeatmapRemoteException(:final statusCode) ||
      OAuthRemoteSourceException(:final statusCode) => switch (statusCode) {
        404 => BeatmapFailureKind.notFound,
        401 || 403 => BeatmapFailureKind.accessDenied,
        429 => BeatmapFailureKind.rateLimited,
        _ => BeatmapFailureKind.unavailable,
      },
      FormatException() => BeatmapFailureKind.invalidResponse,
      RestClientException() => BeatmapFailureKind.connection,
      _ => BeatmapFailureKind.unavailable,
    });
