import 'package:tracksu/src/_core/serialization/json_map_reader.dart';
import 'package:tracksu/src/auth/data/oauth_remote_source.dart';
import 'package:tracksu/src/auth/domain/public_access_repository.dart';

/// App-scoped, memory-only guest credentials. Never changes the user session.
final class PublicAccessRepositoryImpl implements PublicAccessRepository {
  factory PublicAccessRepositoryImpl({
    required OAuthRemoteSource remoteSource,
  }) => PublicAccessRepositoryImpl._(remoteSource);

  PublicAccessRepositoryImpl._(this._remoteSource);

  final OAuthRemoteSource _remoteSource;
  String? _token;
  DateTime? _validUntil;
  Future<String>? _pending;

  @override
  Future<String> getAccessToken() {
    if (_pending case final Future<String> pending) {
      return pending;
    }
    if ((_token, _validUntil) case (final String token, final DateTime until)
        when DateTime.now().isBefore(until)) {
      return Future<String>.value(token);
    }
    return _pending = _requestToken();
  }

  Future<String> _requestToken() async {
    try {
      final JsonMapReader reader = JsonMapReader(
        await _remoteSource.requestPublicToken(),
      );
      final String token = reader.requiredString('access_token');
      final int seconds = reader.requiredInt('expires_in', positive: true);
      if (reader.requiredString('token_type').toLowerCase() != 'bearer') {
        throw const FormatException('Expected a bearer token.');
      }
      _token = token;
      // Renew slightly early, including unusually short-lived responses.
      _validUntil = DateTime.now().add(
        Duration(seconds: seconds - (seconds > 60 ? 30 : seconds ~/ 2)),
      );
      return token;
    } finally {
      _pending = null;
    }
  }

  @override
  void invalidate(String rejectedToken) {
    if (_token == rejectedToken) {
      _token = null;
      _validUntil = null;
    }
  }
}
