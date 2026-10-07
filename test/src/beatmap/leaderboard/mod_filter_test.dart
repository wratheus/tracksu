import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracksu/src/_core/l10n/generated/app_localizations.dart';
import 'package:tracksu/src/beatmap/leaderboard/widgets/mod_filter.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

void main() {
  testWidgets('mod picker excludes conflicting choices and resets to all', (
    tester,
  ) async {
    List<String>? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: TracksuTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: LeaderboardModFilter(
            ruleset: ProfileRuleset.osu,
            selected: const [],
            onChanged: (mods) => result = mods,
          ),
        ),
      ),
    );
    await tester.tap(find.byType(LeaderboardModFilter));
    await tester.pumpAndSettle();
    for (final mod in ['HR', 'EZ', 'DT', 'HT', 'HD']) {
      await tester.tap(find.widgetWithText(FilterChip, mod));
      await tester.pump();
    }
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(result, ['EZ', 'HT', 'HD']);
    await tester.tap(find.byType(LeaderboardModFilter));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'HD'));
    await tester.pump();
    final t = lookupAppLocalizations(const Locale('en'));
    await tester.tap(find.widgetWithText(FilterChip, t.scoresNoMods));
    await tester.pump();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(result, ['NM']);
    await tester.tap(find.byType(LeaderboardModFilter));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    expect(result, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
