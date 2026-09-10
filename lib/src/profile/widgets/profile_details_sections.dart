import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/ui/osu_ui.dart';
import 'package:tracksu/src/profile/domain/profile_details.dart';
import 'package:tracksu_ui/tracksu_ui.dart';
import 'package:url_launcher/url_launcher.dart';

/// Bounded summary cards; API-backed collections stay lazy, including sheets.
final class ProfileDetailsSections extends StatefulWidget {
  const ProfileDetailsSections({
    required this.details,
    required this.userId,
    super.key,
  });
  final ProfileDetails details;
  final int userId;
  @override
  State<ProfileDetailsSections> createState() => _ProfileDetailsSectionsState();
}

final class _ProfileDetailsSectionsState extends State<ProfileDetailsSections> {
  bool _opening = false;
  Future<void> _open(Uri uri) async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
          mounted) {
        UiFeedback.snack(context, message: context.t.contentLinkFailed);
      }
    } on Object {
      if (mounted) {
        UiFeedback.snack(context, message: context.t.contentLinkFailed);
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  Future<void> _medals() async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      await DepsScope.of(context).appRouter.openMedals(context, widget.userId);
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProfileDetails details = widget.details;
    final List<ProfileGroup> groups = details.groups ?? const <ProfileGroup>[];
    final List<ProfileRankedPlay> ranked =
        details.rankedPlay ?? const <ProfileRankedPlay>[];
    final NumberFormat number = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    );
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(UiSpace.lg, 0, UiSpace.lg, UiSpace.lg),
      sliver: SliverMainAxisGroup(
        slivers: <Widget>[
          if (details.dailyChallenge
              case final ProfileDailyChallenge daily) ...<Widget>[
            _heading(context.t.profileDailyChallenge),
            SliverToBoxAdapter(child: _DailyChallengeCard(stats: daily)),
          ],
          if (details.team case final ProfileTeam team)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: UiSpace.md),
                child: OsuAffiliationTile(
                  name: team.name,
                  subtitle: context.t.profileTeamTag(team.shortName),
                  icon: Icons.groups_outlined,
                  image: team.flagUri == null
                      ? null
                      : NetworkImage(team.flagUri.toString()),
                  onTap: _opening
                      ? null
                      : () =>
                            _open(Uri.https('osu.ppy.sh', '/teams/${team.id}')),
                ),
              ),
            ),
          if (groups.isNotEmpty) ...<Widget>[
            _heading(context.t.profileGroups),
            UiSliverCardList(
              itemCount: groups.length,
              itemBuilder: (BuildContext context, int index) {
                final ProfileGroup group = groups[index];
                return OsuAffiliationTile(
                  name: group.name,
                  subtitle: group.shortName,
                  icon: Icons.verified_outlined,
                  colour: group.colour == null
                      ? null
                      : Color(0xFF000000 | group.colour!),
                  onTap: !group.hasListing || _opening
                      ? null
                      : () => _open(
                          Uri.https('osu.ppy.sh', '/groups/${group.id}'),
                        ),
                );
              },
            ),
          ],
          if (details.medals case final List<ProfileMedal> medals)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: UiSpace.lg),
                child: UiSurface.card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: UiSpace.md,
                    children: <Widget>[
                      UiMetric.compact(
                        label: context.t.profileMedals,
                        value: number.format(medals.length),
                        icon: Icons.workspace_premium_outlined,
                        tone: UiMetricTone.tertiary,
                      ),
                      if (medals.isNotEmpty)
                        UiButton.secondary(
                          label: context.t.profileMedalsView,
                          icon: Icons.military_tech_outlined,
                          onPressed: _opening ? null : _medals,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          if (details.rankedPlay != null) ...<Widget>[
            _heading(context.t.profileRankedPlay),
            if (ranked.isEmpty)
              SliverToBoxAdapter(
                child: UiText.bodySmall(
                  context.t.profileRankedPlayEmpty,
                  secondary: true,
                ),
              ),
            UiSliverCardList(
              itemCount: ranked.length,
              itemBuilder: (BuildContext context, int index) =>
                  _RankedPlayCard(stats: ranked[index]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _heading(String text) => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.only(top: UiSpace.lg, bottom: UiSpace.md),
      child: UiText.titleMedium(text),
    ),
  );
}

final class _RankedPlayCard extends StatelessWidget {
  const _RankedPlayCard({required this.stats});
  final ProfileRankedPlay stats;
  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toLanguageTag();
    final NumberFormat number = NumberFormat.decimalPattern(locale);
    return UiSurface.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: UiSpace.md,
        children: <Widget>[
          UiText.titleMedium(
            stats.poolName ?? context.t.profileRankedPool(stats.poolId),
          ),
          if (stats.provisional)
            UiBadge.warning(context.t.profileProvisionalRating),
          UiMetricGroup(
            children: <UiMetric>[
              UiMetric.compact(
                label: context.t.profileRating,
                value: NumberFormat.decimalPatternDigits(
                  locale: locale,
                  decimalDigits: 0,
                ).format(stats.rating),
                icon: Icons.show_chart,
                tone: UiMetricTone.primary,
              ),
              UiMetric.compact(
                label: context.t.profileGlobalRankLabel,
                value: stats.rank == null
                    ? context.t.profileUnranked
                    : '#${number.format(stats.rank)}',
                icon: Icons.public,
                tone: UiMetricTone.tertiary,
              ),
              UiMetric.compact(
                label: context.t.profilePlayCountLabel,
                value: number.format(stats.plays),
                icon: Icons.sports_esports_outlined,
              ),
              UiMetric.compact(
                label: context.t.profileFirstPlaces,
                value: number.format(stats.firstPlaces),
                icon: Icons.emoji_events_outlined,
              ),
              UiMetric.compact(
                label: context.t.profileRankedPoints,
                value: number.format(stats.totalPoints),
                icon: Icons.stars_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

final class _DailyChallengeCard extends StatelessWidget {
  const _DailyChallengeCard({required this.stats});
  final ProfileDailyChallenge stats;
  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toLanguageTag();
    final NumberFormat number = NumberFormat.decimalPattern(locale);
    if (stats.plays == 0) {
      return UiSurface.card(
        child: Row(
          spacing: UiSpace.md,
          children: <Widget>[
            Icon(
              Icons.event_available,
              color: Theme.of(context).colorScheme.primary,
            ),
            Expanded(
              child: UiText.bodyMedium(
                context.t.profileDailyEmpty,
                secondary: true,
              ),
            ),
          ],
        ),
      );
    }
    return UiSurface.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: UiSpace.md,
        children: <Widget>[
          UiMetricGroup(
            children: <UiMetric>[
              UiMetric.compact(
                label: context.t.profileDailyPlays,
                value: number.format(stats.plays),
                icon: Icons.event_available,
                tone: UiMetricTone.primary,
              ),
              UiMetric.compact(
                label: context.t.profileDailyCurrent,
                value: number.format(stats.dailyCurrent),
                icon: Icons.local_fire_department_outlined,
                tone: UiMetricTone.tertiary,
              ),
              UiMetric.compact(
                label: context.t.profileDailyBest,
                value: number.format(stats.dailyBest),
                icon: Icons.emoji_events_outlined,
              ),
              UiMetric.compact(
                label: context.t.profileWeeklyCurrent,
                value: number.format(stats.weeklyCurrent),
                icon: Icons.date_range,
              ),
              UiMetric.compact(
                label: context.t.profileWeeklyBest,
                value: number.format(stats.weeklyBest),
                icon: Icons.military_tech_outlined,
              ),
              UiMetric.compact(
                label: context.t.profileTop10,
                value: number.format(stats.top10),
                icon: Icons.star_outline,
              ),
              UiMetric.compact(
                label: context.t.profileTop50,
                value: number.format(stats.top50),
                icon: Icons.star_half,
              ),
            ],
          ),
          if (stats.lastUpdate case final DateTime date)
            UiText.bodySmall(
              context.t.profileDailyUpdated(
                DateFormat.yMMMd(locale).format(date.toLocal()),
              ),
              secondary: true,
            ),
          if (stats.lastWeeklyStreak case final DateTime date
              when stats.weeklyBest > 0)
            UiText.bodySmall(
              context.t.profileWeeklyUpdated(
                DateFormat.yMMMd(locale).format(date.toLocal()),
              ),
              secondary: true,
            ),
        ],
      ),
    );
  }
}
