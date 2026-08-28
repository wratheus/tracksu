import 'package:tracksu/src/auth/data/oauth_remote_source_exception.dart';
import 'package:tracksu/src/profile/data/profile_dto.dart';
import 'package:tracksu/src/profile/data/profile_mapper.dart';
import 'package:tracksu/src/profile/data/profile_remote_source.dart';
import 'package:tracksu/src/profile/data/profile_remote_source_exception.dart';
import 'package:tracksu/src/profile/domain/profile_failure.dart';
import 'package:tracksu/src/profile/domain/profile.dart';
import 'package:tracksu/src/profile/domain/profile_repository.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';
import 'package:tracksu_network/tracksu_network.dart';

final class ProfileRepositoryImpl implements ProfileRepository {
  factory ProfileRepositoryImpl({required ProfileRemoteSource remoteSource}) {
    return ProfileRepositoryImpl._(remoteSource);
  }

  ProfileRepositoryImpl._(this._remoteSource);

  final ProfileRemoteSource _remoteSource;
  RestCancellationToken? _pending;

  @override
  void cancelPending() {
    _pending?.cancel();
    _pending = null;
  }

  @override
  Future<Profile> getCurrentProfile({required ProfileRuleset ruleset}) {
    return _read(
      (RestClientOptions options) =>
          _remoteSource.getCurrentProfile(ruleset: ruleset, options: options),
    );
  }

  @override
  Future<Profile> getProfile({
    required ProfileUserReference user,
    required ProfileRuleset ruleset,
  }) {
    return _read(
      (RestClientOptions options) => _remoteSource.getProfile(
        userIdentifier: user.apiValue,
        ruleset: ruleset,
        options: options,
      ),
    );
  }

  Future<Profile> _read(
    Future<Map<String, dynamic>> Function(RestClientOptions) load,
  ) async {
    cancelPending();
    final RestCancellationToken token = RestCancellationToken();
    _pending = token;
    try {
      final Map<String, dynamic> response = await load(
        RestClientOptions(cancellationToken: token),
      );
      return ProfileDto.fromJson(response).toDomain();
    } on ProfileRemoteSourceException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        ProfileFailure(switch (error.statusCode) {
          404 => ProfileFailureKind.notFound,
          401 || 403 => ProfileFailureKind.accessDenied,
          429 => ProfileFailureKind.rateLimited,
          _ => ProfileFailureKind.unavailable,
        }),
        stackTrace,
      );
    } on OAuthRemoteSourceException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        ProfileFailure(switch (error.statusCode) {
          400 || 401 || 403 => ProfileFailureKind.accessDenied,
          429 => ProfileFailureKind.rateLimited,
          _ => ProfileFailureKind.unavailable,
        }),
        stackTrace,
      );
    } on FormatException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const ProfileFailure(ProfileFailureKind.invalidResponse),
        stackTrace,
      );
    } on RestClientException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const ProfileFailure(ProfileFailureKind.connection),
        stackTrace,
      );
    } finally {
      if (identical(_pending, token)) {
        _pending = null;
      }
    }
  }
}
