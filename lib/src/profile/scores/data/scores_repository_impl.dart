import 'package:tracksu/src/auth/data/oauth_remote_source_exception.dart';
import 'package:tracksu/src/profile/scores/data/score_dto.dart';
import 'package:tracksu/src/profile/scores/data/scores_remote_source.dart';
import 'package:tracksu/src/profile/scores/domain/score.dart';
import 'package:tracksu/src/profile/scores/domain/scores_query.dart';
import 'package:tracksu/src/profile/scores/domain/scores_repository.dart';
import 'package:tracksu_network/tracksu_network.dart';

/// One instance per scores section; newer reads cancel this section's old IO.
final class ProfileScoresRepositoryImpl implements ProfileScoresRepository {
  factory ProfileScoresRepositoryImpl({
    required ProfileScoresRemoteSource remoteSource,
  }) => ProfileScoresRepositoryImpl._(remoteSource);

  ProfileScoresRepositoryImpl._(this._remoteSource);
  final ProfileScoresRemoteSource _remoteSource;
  RestCancellationToken? _pending;

  @override
  void cancelPending() {
    _pending?.cancel();
    _pending = null;
  }

  @override
  Future<ProfileScoresPage> load(ProfileScoresQuery query) async {
    cancelPending();
    final RestCancellationToken token = RestCancellationToken();
    _pending = token;
    try {
      final List<dynamic> payload = await _remoteSource.load(
        query,
        options: RestClientOptions(cancellationToken: token),
      );
      if (token.isCancelled) {
        throw const ProfileScoresFailure(ProfileScoresFailureKind.cancelled);
      }
      final List<ProfileScore> scores = <ProfileScore>[];
      for (final Object? item in payload) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Expected a score object.');
        }
        final ProfileScore score = ProfileScoreDto.fromJson(item).toDomain();
        if (score.userId != query.user.value ||
            score.ruleset != query.ruleset) {
          throw const FormatException(
            'Score does not match the requested player/ruleset.',
          );
        }
        scores.add(score);
      }
      return ProfileScoresPage(
        items: scores,
        nextOffset: scores.length == query.limit
            ? query.offset + scores.length
            : null,
      );
    } on ProfileScoresRemoteException catch (error, stackTrace) {
      Error.throwWithStackTrace(_statusFailure(error.statusCode), stackTrace);
    } on OAuthRemoteSourceException catch (error, stackTrace) {
      Error.throwWithStackTrace(_statusFailure(error.statusCode), stackTrace);
    } on FormatException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const ProfileScoresFailure(ProfileScoresFailureKind.invalidResponse),
        stackTrace,
      );
    } on RestRequestCancelledException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const ProfileScoresFailure(ProfileScoresFailureKind.cancelled),
        stackTrace,
      );
    } on RestClientException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const ProfileScoresFailure(ProfileScoresFailureKind.connection),
        stackTrace,
      );
    } finally {
      if (identical(_pending, token)) {
        _pending = null;
      }
    }
  }

  ProfileScoresFailure _statusFailure(int status) =>
      ProfileScoresFailure(switch (status) {
        404 => ProfileScoresFailureKind.notFound,
        401 || 403 => ProfileScoresFailureKind.accessDenied,
        429 => ProfileScoresFailureKind.rateLimited,
        _ => ProfileScoresFailureKind.unavailable,
      });
}
