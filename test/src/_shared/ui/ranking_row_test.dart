import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracksu/src/_core/l10n/generated/app_localizations.dart';
import 'package:tracksu/src/_core/l10n/localized_count.dart';
import 'package:tracksu/src/_shared/ui/avatar_bands.dart';
import 'package:tracksu/src/_shared/ui/ranking_row.dart';
import 'package:tracksu/src/_shared/ui/osu_badges.dart';
import 'package:tracksu/src/profile/domain/profile_details.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

void main() {
  testWidgets('row follows the avatar grid: top band and bottom band', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TracksuTheme.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 370,
              child: OsuRankingRow(
                username: 'mrekk',
                position: '#1',
                value: '32 256',
                valueLabel: 'PP',
                country: 'AU',
                team: ProfileTeam(id: 1, name: 'Team', shortName: 'TM'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    double baseline(String text) {
      final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
        find.text(text, findRichText: true),
      );
      return paragraph
          .localToGlobal(
            Offset(
              0,
              paragraph.getDryBaseline(
                paragraph.constraints,
                TextBaseline.alphabetic,
              )!,
            ),
          )
          .dy;
    }

    expect(baseline('mrekk'), closeTo(baseline('32 256 PP'), .01));
    expect(baseline('#1'), closeTo(baseline('32 256 PP'), .01));

    // User-reported regressions: flags hung below the avatar, the value sat
    // mid-row and its unit floated alone. Value + unit share the top-right
    // corner; flags end on the avatar's bottom edge.
    final Rect avatar = tester.getRect(find.byType(UiAvatar));
    final Rect card = tester.getRect(find.byType(OsuAvatarBands));
    final Rect value = tester.getRect(
      find.text('32 256 PP', findRichText: true),
    );
    expect(value.top, closeTo(avatar.top, .5));
    expect(value.right, closeTo(card.right, .5));
    expect(
      tester.getRect(find.byType(OsuCountryFlag)).bottom,
      closeTo(avatar.bottom, .5),
    );
    // The team flag's 44 px target grows upward; its visible flag does not.
    final Rect team = tester.getRect(
      find
          .descendant(
            of: find.byType(OsuTeamFlag),
            matching: find.byType(ClipRRect),
          )
          .first,
    );
    expect(team.bottom, closeTo(avatar.bottom, .5));
    expect(tester.takeException(), isNull);
  });

  for (final double scale in <double>[1, 2]) {
    testWidgets('long ranked score fits a narrow row at text scale $scale', (
      WidgetTester tester,
    ) async {
      final AppLocalizations t = lookupAppLocalizations(const Locale('ru'));
      final String score = LocalizedCount(1234567890123, locale: 'ru').compact;
      await tester.pumpWidget(
        MaterialApp(
          theme: TracksuTheme.light(),
          locale: const Locale('ru'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 320,
                  child: OsuRankingRow(
                    username: 'A long player name',
                    position: '#10000',
                    value: score,
                    valueLabel: t.profileRankedScoreLabel,
                    country: 'AU',
                    team: const ProfileTeam(
                      id: 1,
                      name: 'Team',
                      shortName: 'TM',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      final Rect row = tester.getRect(find.byType(OsuRankingRow));
      for (final String label in <String>[
        'A long player name',
        '#10000',
        score,
        t.profileRankedScoreLabel,
      ]) {
        final Rect text = tester.getRect(find.text(label));
        expect(text.width, greaterThan(0));
        expect(row.contains(text.topLeft), isTrue);
        expect(row.contains(text.bottomRight), isTrue);
      }
    });
  }
}
