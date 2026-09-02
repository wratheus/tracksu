import 'package:tracksu/src/auth/data/oauth_remote_source_exception.dart';
import 'package:tracksu/src/profile/beatmaps/data/beatmap_dto.dart';
import 'package:tracksu/src/profile/beatmaps/data/beatmaps_remote_source.dart';
import 'package:tracksu/src/profile/beatmaps/domain/beatmap.dart';
import 'package:tracksu/src/profile/beatmaps/domain/beatmaps_query.dart';
import 'package:tracksu/src/profile/beatmaps/domain/beatmaps_repository.dart';
import 'package:tracksu_network/tracksu_network.dart';

/// One instance per beatmaps section; newer reads cancel this section's old IO.
final class ProfileBeatmapsRepositoryImpl implements ProfileBeatmapsRepository {
  factory ProfileBeatmapsRepositoryImpl({
    required ProfileBeatmapsRemoteSource remoteSource,
  }) => ProfileBeatmapsRepositoryImpl._(remoteSource);

  ProfileBeatmapsRepositoryImpl._(this._remoteSource);
  final ProfileBeatmapsRemoteSource _remoteSource;
  RestCancellationToken? _pending;

  @override
  void cancelPending() {
    _pending?.cancel();
    _pending = null;
  }

  @override
  Future<ProfileBeatmapsPage> load(ProfileBeatmapsQuery query) async {
    cancelPending();
    final RestCancellationToken token = RestCancellationToken();
    _pending = token;
    try {
      final List<dynamic> payload = await _remoteSource.load(
        query,
        options: RestClientOptions(cancellationToken: token),
      );
      if (token.isCancelled) {
        throw const ProfileBeatmapsFailure(
          ProfileBeatmapsFailureKind.cancelled,
        );
      }
      final List<ProfileBeatmap> beatmaps = <ProfileBeatmap>[];
      for (final Object? item in payload) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Expected a beatmap object.');
        }
        final ProfileBeatmap beatmap = ProfileBeatmapDto.fromJson(
          item,
          type: query.type,
        ).toDomain();
        beatmaps.add(beatmap);
      }
      return ProfileBeatmapsPage(
        items: beatmaps,
        nextOffset: beatmaps.length == query.limit
            ? query.offset + beatmaps.length
            : null,
      );
    } on ProfileBeatmapsRemoteException catch (error, stackTrace) {
      Error.throwWithStackTrace(_statusFailure(error.statusCode), stackTrace);
    } on OAuthRemoteSourceException catch (error, stackTrace) {
      Error.throwWithStackTrace(_statusFailure(error.statusCode), stackTrace);
    } on FormatException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const ProfileBeatmapsFailure(
          ProfileBeatmapsFailureKind.invalidResponse,
        ),
        stackTrace,
      );
    } on RestRequestCancelledException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const ProfileBeatmapsFailure(ProfileBeatmapsFailureKind.cancelled),
        stackTrace,
      );
    } on RestClientException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const ProfileBeatmapsFailure(ProfileBeatmapsFailureKind.connection),
        stackTrace,
      );
    } finally {
      if (identical(_pending, token)) {
        _pending = null;
      }
    }
  }

  ProfileBeatmapsFailure _statusFailure(int status) =>
      ProfileBeatmapsFailure(switch (status) {
        404 => ProfileBeatmapsFailureKind.notFound,
        401 || 403 => ProfileBeatmapsFailureKind.accessDenied,
        429 => ProfileBeatmapsFailureKind.rateLimited,
        _ => ProfileBeatmapsFailureKind.unavailable,
      });
}
