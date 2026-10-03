import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracksu/src/_core/cache/page_cache.dart';
import 'package:tracksu/src/_core/l10n/generated/app_localizations.dart';
import 'package:tracksu/src/rankings/bloc/bloc.dart';
import 'package:tracksu/src/rankings/domain/countries.dart';
import 'package:tracksu/src/rankings/domain/entry.dart';
import 'package:tracksu/src/rankings/domain/rankings_query.dart';
import 'package:tracksu/src/rankings/domain/rankings_repository.dart';
import 'package:tracksu/src/rankings/widgets/entry_card.dart';
import 'package:tracksu/src/rankings/widgets/rankings_section.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class _Repository implements RankingsRepository {
  Completer<RankingsPage> pending = Completer<RankingsPage>();
  int calls = 0;

  @override
  Future<RankingsPage> load(RankingsQuery query) {
    calls++;
    return pending.future;
  }

  @override
  void cancelPending() {}
}

final class _Countries implements RankingCountriesRepository {
  @override
  Future<List<RankingCountryOption>> load({String languageCode = 'en'}) async =>
      const <RankingCountryOption>[];
}

RankingsPage _page() => RankingsPage(
  nextPage: 2,
  items: <RankingEntry>[
    for (int index = 0; index < 50; index++)
      RankingEntry(
        id: index + 1,
        username: 'Player $index',
        country: 'AU',
        pp: 10000 - index.toDouble(),
        rankedScore: 1000000,
        position: index + 1,
      ),
  ],
);

void main() {
  testWidgets('refresh and Retry retain visible rows, scroll and usable data', (
    WidgetTester tester,
  ) async {
    final _Repository repository = _Repository();
    final RankingsBloc bloc = RankingsBloc(
      repository: repository,
      cache: PageCache(identityRevision: () => 0),
    );
    final ScrollController scroll = ScrollController();
    addTearDown(bloc.close);
    addTearDown(scroll.dispose);
    final AppLocalizations t = lookupAppLocalizations(const Locale('en'));
    await tester.pumpWidget(
      RepositoryProvider<RankingCountriesRepository>.value(
        value: _Countries(),
        child: BlocProvider<RankingsBloc>.value(
          value: bloc,
          child: MaterialApp(
            theme: TracksuTheme.light(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: CustomScrollView(
                controller: scroll,
                slivers: const <Widget>[RankingsSection()],
              ),
            ),
          ),
        ),
      ),
    );
    bloc.add(const RankingsStarted());
    await tester.pump();
    repository.pending.complete(_page());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    scroll.jumpTo(500);
    await tester.pump();
    final Element row = find.byType(RankingEntryCard).evaluate().first;
    final Key key = row.widget.key!;
    final double offset = scroll.offset;

    repository.pending = Completer<RankingsPage>();
    bloc.add(const RankingsRefreshRequested());
    await tester.pump();
    await tester.pump();

    expect(bloc.state, isA<RankingsLoadedState>());
    expect(find.byType(UiPageSkeleton), findsNothing);
    expect(tester.element(find.byKey(key)), same(row));
    expect(scroll.offset, offset);
    repository.pending.completeError(
      const RankingsFailure(RankingsFailureKind.connection),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.element(find.byKey(key)), same(row));
    expect(scroll.offset, offset);
    expect((bloc.state as RankingsLoadedState).items, hasLength(50));
    // A stale first page must not accept pagination until refresh recovers.
    bloc.add(const RankingsMoreRequested());
    await tester.pump();
    expect(repository.calls, 2);

    scroll.jumpTo(0);
    await tester.pump();
    repository.pending = Completer<RankingsPage>();
    await tester.ensureVisible(find.text(t.retry));
    await tester.pump();
    await tester.tap(find.text(t.retry));
    await tester.pump();
    expect(repository.calls, 3);
    repository.pending.complete(_page());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect((bloc.state as RankingsLoadedState).failure, isNull);
    expect((bloc.state as RankingsLoadedState).items, hasLength(50));
    expect(tester.takeException(), isNull);
  });
}
