import 'package:tracksu/src/profile/data/profile_details_dto.dart';
import 'package:tracksu/src/profile/domain/profile_details.dart';

extension ProfileDetailsDtoMapper on ProfileDetailsDto {
  ProfileDetails toDomain() {
    final ProfileTeamDto? teamValue = team;
    final ProfileDailyChallengeDto? daily = dailyChallenge;
    final List<ProfileMedal>? earned = medals
        ?.map(
          (ProfileMedalDto value) => ProfileMedal(
            id: value.id,
            achievedAt: DateTime.parse(value.achievedAt),
          ),
        )
        .toList();
    earned?.sort(
      (ProfileMedal a, ProfileMedal b) => b.achievedAt.compareTo(a.achievedAt),
    );
    return ProfileDetails(
      previousNames: previousNames?.toSet().toList(growable: false),
      groups: groups
          ?.map(
            (ProfileGroupDto value) => ProfileGroup(
              id: value.id,
              name: value.name,
              shortName: value.shortName,
              hasListing: value.hasListing,
              colour: _rgb(value.colour),
            ),
          )
          .toList(growable: false),
      team: teamValue == null
          ? null
          : ProfileTeam(
              id: teamValue.id,
              name: teamValue.name,
              shortName: teamValue.shortName,
              flagUri: _flagUri(teamValue.flagUrl),
            ),
      medals: earned,
      rankedPlay: rankedPlay
          ?.map((ProfileRankedPlayDto value) {
            if (!value.rating.isFinite ||
                value.plays < 0 ||
                value.firstPlaces < 0 ||
                value.totalPoints < 0 ||
                (value.rank != null && value.rank! <= 0)) {
              throw const FormatException('Invalid ranked play statistics.');
            }
            return ProfileRankedPlay(
              poolId: value.poolId,
              poolName: value.poolName,
              plays: value.plays,
              firstPlaces: value.firstPlaces,
              rating: value.rating,
              provisional: value.provisional,
              rank: value.rank,
              totalPoints: value.totalPoints,
            );
          })
          .toList(growable: false),
      dailyChallenge: daily == null ? null : _daily(daily),
    );
  }

  static int? _rgb(String? colour) =>
      colour != null && RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(colour)
      ? int.parse(colour.substring(1), radix: 16)
      : null;
  static Uri? _flagUri(String? value) {
    final Uri? uri = value == null ? null : Uri.tryParse(value);
    return uri != null &&
            uri.scheme == 'https' &&
            uri.userInfo.isEmpty &&
            uri.port == 443 &&
            (uri.host == 'osu.ppy.sh' || uri.host.endsWith('.ppy.sh'))
        ? uri
        : null;
  }

  static ProfileDailyChallenge _daily(ProfileDailyChallengeDto value) {
    if (<int>[
      value.plays,
      value.dailyCurrent,
      value.dailyBest,
      value.weeklyCurrent,
      value.weeklyBest,
      value.top10,
      value.top50,
    ].any((int n) => n < 0)) {
      throw const FormatException('Invalid daily challenge statistics.');
    }
    return ProfileDailyChallenge(
      plays: value.plays,
      dailyCurrent: value.dailyCurrent,
      dailyBest: value.dailyBest,
      weeklyCurrent: value.weeklyCurrent,
      weeklyBest: value.weeklyBest,
      top10: value.top10,
      top50: value.top50,
      lastUpdate: value.lastUpdate == null
          ? null
          : DateTime.parse(value.lastUpdate!),
      lastWeeklyStreak: value.lastWeeklyStreak == null
          ? null
          : DateTime.parse(value.lastWeeklyStreak!),
    );
  }
}
