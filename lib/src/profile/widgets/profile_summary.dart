import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/profile/domain/profile.dart';
import 'package:tracksu/src/_shared/ui/osu_ui.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class ProfileSummary extends StatelessWidget {
  const ProfileSummary({required this.profile, super.key});
  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final ProfileStatistics? statistics = profile.statistics;
    final List<UiMetric> metrics = statistics == null
        ? const <UiMetric>[]
        : <UiMetric>[
            UiMetric(
              label: context.t.profilePerformance(statistics.performancePoints),
              value: '${statistics.performancePoints.round()} pp',
            ),
            UiMetric(
              label: context.t.profileGlobalRank(statistics.globalRank ?? 0),
              value: statistics.globalRank == null
                  ? context.t.profileUnranked
                  : '#${statistics.globalRank}',
            ),
            if (statistics.countryRank case final int rank)
              UiMetric(
                label: context.t.profileCountryRank(rank),
                value: '#$rank',
              ),
            UiMetric(
              label: context.t.profileAccuracy(statistics.hitAccuracy),
              value: '${statistics.hitAccuracy.toStringAsFixed(2)}%',
            ),
            UiMetric(
              label: context.t.profilePlayCount(statistics.playCount),
              value: '${statistics.playCount}',
            ),
            UiMetric(
              label: context.t.profilePlayTime(statistics.playTime ~/ 3600),
              value: '${statistics.playTime ~/ 3600} h',
            ),
            UiMetric(
              label: context.t.profileMaximumCombo(statistics.maximumCombo),
              value: '${statistics.maximumCombo}',
            ),
          ];
    return SliverMainAxisGroup(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(UiSpace.lg),
            child: OsuPlayerCard.profile(
              username: profile.username,
              countryCode: profile.countryCode,
              countryLabel: context.t.profileCountry(profile.countryCode),
              avatar: NetworkImage(profile.avatarUri.toString()),
              statusLabel: profile.isOnline
                  ? context.t.profileOnline
                  : context.t.profileOffline,
              rankLabel: context.t.profileId(profile.id),
              performanceLabel: statistics == null
                  ? context.t.profileNoStatistics
                  : context.t.profilePerformance(statistics.performancePoints),
              metrics: metrics,
            ),
          ),
        ),
      ],
    );
  }
}
