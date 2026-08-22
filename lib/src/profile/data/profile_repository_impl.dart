import 'package:tracksu/src/profile/data/profile_dto.dart';
import 'package:tracksu/src/profile/data/profile_mapper.dart';
import 'package:tracksu/src/profile/data/profile_remote_source.dart';
import 'package:tracksu/src/profile/domain/profile.dart';
import 'package:tracksu/src/profile/domain/profile_repository.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';

final class ProfileRepositoryImpl implements ProfileRepository {
  factory ProfileRepositoryImpl({required ProfileRemoteSource remoteSource}) {
    return ProfileRepositoryImpl._(remoteSource);
  }

  const ProfileRepositoryImpl._(this._remoteSource);

  final ProfileRemoteSource _remoteSource;

  @override
  Future<Profile> getCurrentProfile({required ProfileRuleset ruleset}) async {
    final Map<String, dynamic> response = await _remoteSource.getCurrentProfile(
      ruleset: ruleset,
    );
    final ProfileDto profileDto = ProfileDto.fromJson(response);
    return profileDto.toDomain();
  }

  @override
  Future<Profile> getProfile({
    required ProfileUserReference user,
    required ProfileRuleset ruleset,
  }) async {
    final Map<String, dynamic> response = await _remoteSource.getProfile(
      userIdentifier: user.apiValue,
      ruleset: ruleset,
    );
    final ProfileDto profileDto = ProfileDto.fromJson(response);
    return profileDto.toDomain();
  }
}
