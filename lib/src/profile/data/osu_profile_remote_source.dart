import 'dart:convert';

import 'package:tracksu/src/profile/data/profile_dto.dart';
import 'package:tracksu/src/profile/data/profile_remote_source.dart';
import 'package:tracksu/src/profile/data/profile_remote_source_exception.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu_network/tracksu_network.dart';

final class OsuProfileRemoteSource implements ProfileRemoteSource {
  factory OsuProfileRemoteSource({required RestClient restClient}) {
    return OsuProfileRemoteSource._(restClient);
  }

  const OsuProfileRemoteSource._(this._restClient);

  final RestClient _restClient;

  @override
  Future<ProfileDto> getCurrentProfile({
    required ProfileRuleset ruleset,
  }) async {
    final RestResponse response = await _restClient.get(
      path: '/me/${ruleset.apiValue}',
    );
    if (response.statusCode != 200) {
      throw ProfileRemoteSourceException(statusCode: response.statusCode);
    }

    final Object? decoded = jsonDecode(response.bodyText);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'The profile response must be a JSON object.',
      );
    }

    return ProfileDto.fromJson(decoded);
  }

  @override
  Future<ProfileDto> getProfile({
    required String userIdentifier,
    required ProfileRuleset ruleset,
  }) async {
    final String encodedUserIdentifier = Uri.encodeComponent(userIdentifier);
    final RestResponse response = await _restClient.get(
      path: '/users/$encodedUserIdentifier/${ruleset.apiValue}',
    );
    if (response.statusCode != 200) {
      throw ProfileRemoteSourceException(statusCode: response.statusCode);
    }

    final Object? decoded = jsonDecode(response.bodyText);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'The profile response must be a JSON object.',
      );
    }

    return ProfileDto.fromJson(decoded);
  }
}
