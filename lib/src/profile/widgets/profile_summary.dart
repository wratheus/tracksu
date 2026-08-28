import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/profile/domain/profile.dart';

final class ProfileSummary extends StatelessWidget {
  const ProfileSummary({required this.profile, super.key});
  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final ProfileStatistics? statistics = profile.statistics;
    final List<String> rows = <String>[
      context.t.profileCountry(profile.countryCode),
      profile.isOnline ? context.t.profileOnline : context.t.profileOffline,
      if (profile.isSupporter) context.t.profileSupporter,
      if (statistics == null) context.t.profileNoStatistics,
      if (statistics != null) ...<String>[
        context.t.profilePerformance(statistics.performancePoints),
        statistics.globalRank == null
            ? context.t.profileUnranked
            : context.t.profileGlobalRank(statistics.globalRank!),
        if (statistics.countryRank case final int rank)
          context.t.profileCountryRank(rank),
        context.t.profileAccuracy(statistics.hitAccuracy),
        context.t.profilePlayCount(statistics.playCount),
        context.t.profilePlayTime(statistics.playTime ~/ 3600),
        context.t.profileMaximumCombo(statistics.maximumCombo),
      ],
    ];
    return SliverMainAxisGroup(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              spacing: 10,
              children: <Widget>[
                ClipOval(
                  child: Image.network(
                    profile.avatarUri.toString(),
                    width: 80,
                    height: 80,
                    cacheWidth: (80 * MediaQuery.devicePixelRatioOf(context))
                        .ceil(),
                    fit: BoxFit.cover,
                    excludeFromSemantics: true,
                    errorBuilder: (_, _, _) => const SizedBox(
                      width: 80,
                      height: 80,
                      child: Icon(Icons.person, size: 40),
                    ),
                  ),
                ),
                Text(
                  profile.username,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                Text(context.t.profileId(profile.id)),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
          sliver: SliverList.builder(
            itemCount: rows.length,
            itemBuilder: (_, int index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(rows[index]),
            ),
          ),
        ),
      ],
    );
  }
}
