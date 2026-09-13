import 'package:tracksu/src/auth/data/oauth_remote_source_exception.dart';
import 'package:tracksu/src/team/data/remote_source.dart';
import 'package:tracksu/src/team/data/team_dto.dart';
import 'package:tracksu/src/team/domain/team.dart';
import 'package:tracksu_network/tracksu_network.dart';

final class TeamRepositoryImpl implements TeamRepository {
  TeamRepositoryImpl(this._source);
  final TeamRemoteSource _source;
  RestCancellationToken? _pending;
  @override
  void cancelPending() {
    _pending?.cancel();
    _pending = null;
  }

  @override
  Future<TeamDetails> load(TeamParams params) async {
    cancelPending();
    final RestCancellationToken token = RestCancellationToken();
    _pending = token;
    try {
      return TeamDto.fromJson(
        await _source.load(params, RestClientOptions(cancellationToken: token)),
        params,
      ).toDomain();
    } on Object catch (error, stack) {
      final TeamFailureKind kind = switch (error) {
        TeamRemoteException(:final statusCode) ||
        OAuthRemoteSourceException(:final statusCode) => switch (statusCode) {
          404 => TeamFailureKind.notFound,
          401 || 403 => TeamFailureKind.accessDenied,
          429 => TeamFailureKind.rateLimited,
          _ => TeamFailureKind.unavailable,
        },
        FormatException() => TeamFailureKind.invalidResponse,
        RestClientException() => TeamFailureKind.connection,
        _ => TeamFailureKind.unavailable,
      };
      Error.throwWithStackTrace(TeamFailure(kind), stack);
    } finally {
      if (identical(_pending, token)) _pending = null;
    }
  }
}
