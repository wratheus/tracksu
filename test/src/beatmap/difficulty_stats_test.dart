import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracksu/src/_core/l10n/generated/app_localizations.dart';
import 'package:tracksu/src/beatmap/data/beatmap_dto.dart';
import 'package:tracksu/src/beatmap/domain/beatmap.dart';
import 'package:tracksu/src/beatmap/widgets/difficulty_stats.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

void main() {
  test('broken optional attributes leave the beatmap usable', () {
    final details = BeatmapDetailsDto.fromJson({
      'id': 1,
      'title': 'Song',
      'artist': 'Artist',
      'creator': 'Mapper',
      'beatmaps': [
        {
          'id': 2,
          'beatmapset_id': 1,
          'difficulty_rating': 4.0,
          'total_length': 90,
          'version': 'Hard',
          'mode': 'osu',
          'cs': 'broken',
          'ar': 9,
          'accuracy': 8,
          'drain': 5,
        },
      ],
    }).toDomain();
    expect(details.difficulties.single.id, 2);
    expect(details.difficulties.single.stats, isNull);
  });

  testWidgets('mania and taiko hide irrelevant bars and missing counts', (
    tester,
  ) async {
    const stats = BeatmapDifficultyStats(cs: 4, ar: 9, od: 8, hp: 5);
    final t = lookupAppLocalizations(const Locale('en'));
    for (final ruleset in [ProfileRuleset.mania, ProfileRuleset.taiko]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: TracksuTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: BeatmapDifficultyStatsView(stats: stats, ruleset: ruleset),
          ),
        ),
      );
      expect(find.text(t.beatmapApproachRate), findsNothing);
      expect(find.text(t.beatmapCircleSize), findsNothing);
      expect(
        find.text(t.beatmapKeys),
        ruleset == ProfileRuleset.mania ? findsOneWidget : findsNothing,
      );
      expect(find.text(t.beatmapMaxCombo), findsNothing);
      expect(find.text(t.beatmapPassRate), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });
}
