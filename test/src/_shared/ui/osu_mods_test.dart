import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracksu/src/_shared/ui/osu_mods.dart';

void main() {
  test('known acronyms map to names, types and bundled glyphs', () {
    expect(OsuModInfo.of('HD')?.name, 'Hidden');
    expect(OsuModInfo.of('dt')?.type, OsuModType.increase);
    expect(OsuModInfo.of('7K')?.icon, 'seven-keys');
    expect(OsuModInfo.of('NEW'), isNull);
    for (final String acronym in <String>['EZ', 'HR', 'CL', 'AT', 'BR', 'TD']) {
      final String? icon = OsuModInfo.of(acronym)?.icon;
      expect(File('assets/icon_mods/$icon.png').existsSync(), isTrue);
    }
    expect(File('assets/icon_mods/mod-icon.png').existsSync(), isTrue);
    expect(File('assets/icon_mods/no-mod.png').existsSync(), isTrue);
  });

  testWidgets('chips show acronyms, unknown mods and the empty label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: <Widget>[
              OsuMods(mods: <String>['HD', 'NEW'], emptyLabel: 'No mods'),
              OsuMods(mods: <String>[], emptyLabel: 'No mods'),
            ],
          ),
        ),
      ),
    );
    expect(find.text('HD'), findsOneWidget);
    expect(find.text('NEW'), findsOneWidget);
    expect(find.text('No mods'), findsOneWidget);
    expect(find.byType(OsuModIcon), findsNWidgets(3));
    expect(find.bySemanticsLabel('Hidden'), findsOneWidget);
  });
}
