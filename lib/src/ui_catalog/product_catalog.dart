import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/l10n/generated/app_localizations.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/ui/osu_ui.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Manual samples, not domain fixtures or an API-connected product screen.
final class ProductCatalogSliver extends StatelessWidget {
  const ProductCatalogSliver({super.key});
  static const AssetImage _art = AssetImage('assets/utils/1024x500_banner.png');
  static const AssetImage _avatar = AssetImage('assets/utils/painted_logo.png');

  @override
  Widget build(BuildContext context) => SliverList.builder(
    itemCount: 18,
    itemBuilder: (BuildContext context, int index) =>
        KeyedSubtree(key: ValueKey<int>(index), child: _sample(context, index)),
  );

  Widget _sample(BuildContext context, int index) {
    final AppLocalizations t = context.t;
    final String locale = Localizations.localeOf(context).toLanguageTag();
    final NumberFormat number = NumberFormat.decimalPattern(locale);
    final NumberFormat decimal = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 2,
    );
    final String date = DateFormat.yMMMd(locale).format(DateTime(2026, 9, 7));
    void preview() =>
        UiFeedback.snack(context, message: t.uiCatalogConfirmMessage);
    final List<UiChartPoint> rankPoints = <UiChartPoint>[
      for (int i = 0; i < 9; i++)
        UiChartPoint(
          x: i.toDouble(),
          breakBefore: i == 4,
          value: <double>[
            26000,
            25740,
            26020,
            24960,
            24500,
            24760,
            24150,
            24320,
            24000,
          ][i],
          label: DateFormat.MMMd(locale).format(DateTime(2026, 8, 30 + i)),
          valueLabel: t.profileGlobalRank(
            <int>[
              26000,
              25740,
              26020,
              24960,
              24500,
              24760,
              24150,
              24320,
              24000,
            ][i],
          ),
        ),
    ];
    final Widget sample = switch (index) {
      0 => UiSection(
        title: t.uiCatalogCards,
        child: UiNotice(message: t.uiCatalogSampleNotice),
      ),
      1 => UiSection(
        title: t.uiCatalogMedia,
        child: UiSurface.card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: UiSpace.lg,
            children: <Widget>[
              const Wrap(
                spacing: UiSpace.md,
                runSpacing: UiSpace.md,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  UiAvatar.small(name: 'Tracksu Preview', image: _avatar),
                  UiAvatar.medium(name: 'Preview'),
                  UiAvatar.large(name: 'あおい'),
                  UiAvatar.medium(name: ''),
                ],
              ),
              Wrap(
                spacing: UiSpace.md,
                runSpacing: UiSpace.md,
                children: <Widget>[
                  for (final String code in <String>[
                    'JP',
                    'DE',
                    'FR',
                    'US',
                    '??',
                  ])
                    OsuCountryFlag(code: code, label: t.profileCountry(code)),
                ],
              ),
              Wrap(
                spacing: UiSpace.sm,
                runSpacing: UiSpace.sm,
                children: <Widget>[
                  for (final String grade in <String>[
                    'XH',
                    'X',
                    'SH',
                    'S',
                    'A',
                    'B',
                    'C',
                    'D',
                    'F',
                    '?',
                  ])
                    OsuGradeBadge(grade: grade, label: t.scoresGrade(grade)),
                ],
              ),
              Wrap(
                spacing: UiSpace.sm,
                runSpacing: UiSpace.sm,
                children: <Widget>[
                  UiBadge.positive(t.beatmapsRanked),
                  UiBadge.accent(t.beatmapsLoved),
                  UiBadge.warning(t.beatmapsPending),
                  UiBadge.neutral(t.beatmapsGraveyard),
                ],
              ),
              OsuMods(
                mods: const <String>['HD', 'DT', 'CL', 'DA', 'NEW'],
                emptyLabel: t.scoresNoMods,
              ),
              OsuMods(mods: const <String>[], emptyLabel: t.scoresNoMods),
              // Missing and in-flight states can be inspected without network access.
              const Wrap(
                spacing: UiSpace.md,
                runSpacing: UiSpace.md,
                children: <Widget>[
                  UiImage(image: _art, width: 96, height: 64),
                  UiImage(image: null, width: 96, height: 64),
                  UiImage.loading(width: 96, height: 64),
                ],
              ),
            ],
          ),
        ),
      ),
      2 => UiSection(
        title: t.rankingsTitle,
        child: OsuPlayerCard.compact(
          username: 'Tracksu Preview',
          avatar: _avatar,
          countryCode: 'JP',
          countryLabel: t.profileCountry('JP'),
          rankLabel: t.profileGlobalRank(24000),
          performanceLabel: t.profilePerformance(7837),
          statusLabel: t.profileOnline,
          onTap: preview,
        ),
      ),
      3 => UiSection(
        title: t.profileTitle,
        child: OsuPlayerCard.profile(
          username: 'Preview — 長いプレイヤー名',
          avatar: _avatar,
          cover: _art,
          countryCode: 'DE',
          countryLabel: t.profileCountry('DE'),
          statusLabel: t.profileOffline,
          metrics: <UiMetric>[
            UiMetric(
              label: t.uiMetricPerformance,
              value: number.format(7837),
              tone: UiMetricTone.primary,
            ),
            UiMetric(
              label: t.uiMetricGlobalRank,
              value: '#${number.format(24000)}',
            ),
            UiMetric.compact(
              label: t.uiMetricAccuracy,
              icon: Icons.gps_fixed,
              value: '${decimal.format(97.59)}%',
            ),
            UiMetric.row(
              label: t.uiMetricPlayCount,
              value: number.format(83770),
              icon: Icons.play_circle_outline,
            ),
          ],
        ),
      ),
      4 => UiSection(
        title: t.beatmapTitle,
        child: OsuBeatmapCard.featured(
          title: 'Today Is Gonna be a Great Day (TV Size)',
          artist: 'Bowling For Soup',
          difficulty: "[browiec’s Something That Doesn’t Exist]",
          cover: _art,
          badges: <Widget>[
            UiBadge.positive(t.beatmapsRanked),
            UiBadge.accent('${decimal.format(5.54)} ★'),
            const OsuRulesetIcon(ruleset: ProfileRuleset.osu),
          ],
          detail: t.beatmapCreator('Preview Mapper'),
          onTap: preview,
        ),
      ),
      5 => UiSection(
        title: t.beatmapsTitle,
        child: Column(
          spacing: UiSpace.sm,
          children: <Widget>[
            OsuBeatmapCard.compact(
              title: 'Sakura no Uta',
              artist: 'Hana',
              difficulty: "Rean’s Insane",
              cover: _art,
              detail: t.beatmapsPlayCount(143),
              onTap: preview,
            ),
            OsuBeatmapCard.compact(
              title: t.beatmapsMapFallback(123456),
              detail: t.beatmapsPlayCount(0),
              onTap: preview,
            ),
          ],
        ),
      ),
      6 => UiSection(
        title: t.scoresBest,
        child: OsuPlayCard(
          title: 'Natsuzora Yell (TV Size)',
          artist: 'Konohara Mikuru',
          difficulty: "Taeyang’s Expert",
          cover: _art,
          grade: 'S',
          gradeLabel: t.scoresGrade('S'),
          accuracyLabel: t.profileAccuracy(99.47),
          comboLabel: t.scoresCombo(1024),
          performanceLabel: t.profilePerformance(401),
          dateLabel: t.scoresPlayedAt(date),
          mods: const <String>['HD', 'HR'],
          noModsLabel: t.scoresNoMods,
          totalLabel: t.scoresTotal(987654),
          onTap: preview,
        ),
      ),
      7 => UiSection(
        title: t.scoresRecent,
        child: OsuPlayCard(
          title: t.scoresBeatmap(123456),
          grade: 'F',
          gradeLabel: t.scoresGrade('F'),
          accuracyLabel: t.profileAccuracy(72.4),
          comboLabel: t.scoresCombo(42),
          performanceLabel: t.scoresNoPp,
          dateLabel: t.scoresPlayedAt(date),
          mods: const <String>[],
          noModsLabel: t.scoresNoMods,
          failureLabel: t.scoresFailedPlay,
          onTap: preview,
        ),
      ),
      8 => UiSection(
        title: t.newsTitle,
        child: OsuNewsCard(
          title: 'Project Loved: May 2022',
          authorLabel: 'clayton',
          dateLabel: date,
          preview: t.uiCatalogSampleNotice,
          cover: _art,
          onTap: preview,
        ),
      ),
      9 => UiSection(
        title: t.newsOriginal,
        child: OsuNewsCard(
          title: 'Tracksu',
          authorLabel: 'Tracksu',
          dateLabel: date,
          onTap: preview,
        ),
      ),
      10 => UiSection(title: t.uiCatalogInputs, child: const _RulesetSample()),
      11 => UiSection(
        title: t.uiCatalogCharts,
        child: UiSurface.card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: UiSpace.md,
            children: <Widget>[
              UiText.bodySmall(t.uiCatalogChartHint, secondary: true),
              UiChart.line(
                title: t.uiCatalogHistory,
                points: rankPoints,
                emptyLabel: t.uiCatalogNoData,
                lowerIsBetter: true,
              ),
            ],
          ),
        ),
      ),
      12 => UiSection(
        title: t.uiCatalogActivity,
        child: UiSurface.card(
          child: UiChart.bars(
            title: t.uiMetricPlayCount,
            emptyLabel: t.uiCatalogNoData,
            points: <UiChartPoint>[
              for (int i = 0; i < 7; i++)
                UiChartPoint(
                  x: i.toDouble(),
                  value: <double>[120, 90, 0, 340, 240, 70, 160][i],
                  label: DateFormat.MMM(locale).format(DateTime(2026, i + 1)),
                  valueLabel: t.profilePlayCount(
                    <int>[120, 90, 0, 340, 240, 70, 160][i],
                  ),
                ),
            ],
          ),
        ),
      ),
      13 => UiSection(
        title: t.uiCatalogStates,
        child: UiSurface.card(
          child: Column(
            spacing: UiSpace.xl,
            children: <Widget>[
              UiChart.line(
                title: t.uiCatalogSinglePoint,
                points: <UiChartPoint>[rankPoints.last],
                emptyLabel: t.uiCatalogNoData,
              ),
              UiChart.line(
                title: t.uiCatalogFlatSeries,
                points: <UiChartPoint>[
                  UiChartPoint(
                    x: 0,
                    value: 100,
                    label: rankPoints.first.label,
                    valueLabel: number.format(100),
                  ),
                  UiChartPoint(
                    x: 1,
                    value: 100,
                    label: rankPoints.last.label,
                    valueLabel: number.format(100),
                  ),
                ],
                emptyLabel: t.uiCatalogNoData,
              ),
              UiChart.line(
                title: t.uiCatalogHistory,
                points: const <UiChartPoint>[],
                emptyLabel: t.uiCatalogNoData,
              ),
            ],
          ),
        ),
      ),
      14 => UiSection(
        title: t.uiCatalogStates,
        child: UiSurface.card(
          child: Column(
            children: <Widget>[
              UiContentState.empty(
                title: t.rankingsEmpty,
                message: t.profileSearchHelp,
                actionLabel: t.profileSearch,
                onAction: preview,
              ),
              UiContentState.error(
                title: t.profileUnavailable,
                actionLabel: t.retry,
                onAction: preview,
              ),
              UiContentState.offline(
                title: t.uiCatalogOffline,
                message: t.profileConnectionFailed,
                actionLabel: t.retry,
                onAction: preview,
              ),
              UiContentState.loading(title: t.profileLoading),
            ],
          ),
        ),
      ),
      15 => UiSection(
        title: t.scoresLoading,
        child: Semantics(
          label: t.scoresLoading,
          child: const UiSurface.card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: UiSpace.md,
              children: <Widget>[
                Row(
                  spacing: UiSpace.md,
                  children: <Widget>[
                    UiSkeleton.block(height: 56, width: 56),
                    Expanded(
                      child: Column(
                        spacing: UiSpace.sm,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          UiSkeleton.line(),
                          UiSkeleton.line(width: 120),
                        ],
                      ),
                    ),
                  ],
                ),
                UiSkeleton.line(),
                UiSkeleton.line(width: 160),
              ],
            ),
          ),
        ),
      ),
      16 => UiSection(
        title: t.scoresLoadMore,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: UiSpace.md,
          children: <Widget>[
            UiNotice(
              message: t.profileShowingPreviousData,
              tone: UiNoticeTone.warning,
              actionLabel: t.retry,
              onAction: preview,
            ),
            UiLoading(label: t.scoresLoading),
            UiButton.outlined(label: t.scoresLoadMore, onPressed: preview),
          ],
        ),
      ),
      17 => const _NavigationSample(),
      _ => throw RangeError.range(index, 0, 17, 'index'),
    };
    return sample;
  }
}

final class _NavigationSample extends StatefulWidget {
  const _NavigationSample();

  @override
  State<_NavigationSample> createState() => _NavigationSampleState();
}

final class _NavigationSampleState extends State<_NavigationSample> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) => UiNavigationBar(
    selectedIndex: _selected,
    onSelected: (int value) => setState(() => _selected = value),
    items: <UiNavigationItem>[
      UiNavigationItem(label: context.t.navigationSearch, icon: Icons.search),
      UiNavigationItem(label: context.t.rankingsTitle, icon: Icons.leaderboard),
      UiNavigationItem(label: context.t.newsTitle, icon: Icons.newspaper),
    ],
  );
}

final class _RulesetSample extends StatefulWidget {
  const _RulesetSample();
  @override
  State<_RulesetSample> createState() => _RulesetSampleState();
}

final class _RulesetSampleState extends State<_RulesetSample> {
  ProfileRuleset _ruleset = ProfileRuleset.osu;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: UiSpace.md,
    children: <Widget>[
      OsuRulesetSelector(
        selected: _ruleset,
        onChanged: (ProfileRuleset value) => setState(() => _ruleset = value),
      ),
      OsuRulesetSelector(selected: _ruleset, onChanged: null),
    ],
  );
}
