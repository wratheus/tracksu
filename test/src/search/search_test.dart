import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tracksu/src/_core/l10n/generated/app_localizations.dart';
import 'package:tracksu/src/beatmap_search/bloc/bloc.dart';
import 'package:tracksu/src/beatmap_search/domain/beatmap_search.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/search/bloc/bloc.dart';
import 'package:tracksu/src/_shared/sharing/share_target.dart';
import 'package:tracksu/src/search/data/remote_source.dart';
import 'package:tracksu/src/search/data/repository_impl.dart';
import 'package:tracksu/src/search/domain/user_search.dart';
import 'package:tracksu/src/search/domain/search_params.dart';
import 'package:tracksu/src/search/widgets/screen.dart';
import 'package:tracksu_ui/tracksu_ui.dart';
import 'package:tracksu_network/tracksu_network.dart';

SearchPlayer player(int id) =>
    SearchPlayer(id: id, username: 'Player $id', country: 'JP');
UserSearchPage page(int id) => UserSearchPage(items: [player(id)], total: 1);
Future<void> tick() => Future<void>.delayed(Duration.zero);

final class Users implements UserSearchRepository {
  final List<(String, int)> calls = [];
  final List<Completer<UserSearchPage>> pending = [];
  bool deferred = false;
  int cancellations = 0;
  @override
  void cancelPending() {
    cancellations++;
  }

  @override
  Future<SearchPlayer> lookup(String identifier) async =>
      player(int.parse(identifier));
  @override
  Future<UserSearchPage> search(String query, {int page = 1}) {
    calls.add((query, page));
    if (deferred) {
      final c = Completer<UserSearchPage>();
      pending.add(c);
      return c.future;
    }
    return Future.value(UserSearchPage(items: [], total: 0));
  }
}

final class Maps implements BeatmapSearchRepository {
  final List<BeatmapSearchQuery> calls = [];
  @override
  void cancelPending() {}
  @override
  Future<BeatmapSearchPage> search(
    BeatmapSearchQuery query, {
    String? cursor,
  }) async {
    calls.add(query);
    return BeatmapSearchPage(items: [], cursor: null);
  }
}

void main() {
  test('ranking share targets match teams, countries and mode-free kudosu', () {
    expect(
      ShareTarget.rankingCategory(
        ProfileRuleset.mania,
        'team',
        'Teams',
      ).uri.path,
      '/rankings/mania/team',
    );
    expect(
      ShareTarget.rankingCategory(
        ProfileRuleset.taiko,
        'country',
        'Countries',
      ).uri.path,
      '/rankings/taiko/country',
    );
    expect(
      ShareTarget.rankingCategory(
        ProfileRuleset.mania,
        'kudosu',
        'Kudosu',
      ).uri.path,
      '/rankings/kudosu',
    );
  });

  test(
    'latest query wins, pause cancels, cache avoids a repeat request',
    () async {
      final repo = Users()..deferred = true;
      final bloc = UserSearchBloc(repository: repo);
      bloc.add(const UserSearchChanged('alpha'));
      await tick();
      bloc.add(const UserSearchChanged('beta'));
      await tick();
      repo.pending[1].complete(page(2));
      await tick();
      repo.pending[0].complete(page(1));
      await tick();
      expect(bloc.state.items.single.id, 2);
      bloc.add(const UserSearchPaused());
      await tick();
      expect(bloc.state.started, false);
      bloc.add(const UserSearchChanged('beta'));
      await tick();
      expect(bloc.state.items.single.id, 2);
      expect(repo.calls.length, 2);
      expect(repo.cancellations, greaterThanOrEqualTo(3));
      await bloc.close();
    },
  );

  test('close cancels and ignores a late response', () async {
    final repo = Users()..deferred = true;
    final bloc = UserSearchBloc(repository: repo);
    bloc.add(const UserSearchChanged('alpha'));
    await tick();
    final closing = bloc.close();
    repo.pending.single.complete(page(1));
    await closing;
    expect(bloc.state.items, isEmpty);
    expect(repo.cancellations, greaterThanOrEqualTo(2));
  });

  test(
    'paging stops after 100 accessible users and retries only explicitly',
    () async {
      final repo = Users()..deferred = true;
      final bloc = UserSearchBloc(repository: repo);
      bloc.add(const UserSearchChanged('player'));
      await tick();
      for (int p = 1; p <= 5; p++) {
        repo.pending.last.complete(
          UserSearchPage(
            items: [for (int i = 0; i < 20; i++) player(p * 20 + i)],
            total: 999,
          ),
        );
        await tick();
        bloc.add(const UserSearchMore());
        await tick();
      }
      expect(repo.calls.length, 5);
      expect(bloc.state.items.length, 100);
      expect(bloc.state.nextPage, null);
      bloc.add(const UserSearchChanged('limited'));
      await tick();
      repo.pending.last.completeError(
        const UserSearchFailure(UserSearchFailureKind.rateLimited),
      );
      await tick();
      expect(bloc.state.failure, UserSearchFailureKind.rateLimited);
      bloc.add(const UserSearchMore());
      await tick();
      expect(repo.calls.length, 6);
      bloc.add(const UserSearchRetry());
      await tick();
      expect(repo.calls.length, 7);
      repo.pending.last.complete(page(9));
      await tick();
      await bloc.close();
    },
  );

  test(
    'requests use public search; numeric IDs and @names use mode-free lookup',
    () async {
      final calls = <Uri>[];
      final client = HttpRestClient(
        baseUri: Uri.parse('https://osu.ppy.sh/api/v2'),
        client: MockClient((request) async {
          calls.add(request.url);
          final user = {
            'id': 24,
            'username': '123',
            'country_code': 'JP',
            'playmode': 'mania',
          };
          return http.Response(
            jsonEncode(
              request.url.path.endsWith('/search')
                  ? {
                      'user': {
                        'data': [user, user],
                        'total': 1,
                      },
                    }
                  : user,
            ),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.close);
      final repo = UserSearchRepositoryImpl(
        source: UserSearchRemoteSource(client: client),
      );
      final result = await repo.search('name');
      expect(result.items.length, 1);
      expect(result.items.single.ruleset, ProfileRuleset.mania);
      expect(calls.last.queryParameters, {
        'mode': 'user',
        'query': 'name',
        'page': '1',
      });
      await repo.search('24');
      expect(calls.last.path, '/api/v2/users/24');
      await repo.search('@123');
      expect(calls.last.pathSegments.last, '@123');
      expect(calls.last.queryParameters, isEmpty);
      expect((await repo.search('-1')).items, isEmpty);
    },
  );

  Future<void> pumpSearch(
    WidgetTester tester,
    Users users,
    Maps maps, {
    double scale = 1,
    Brightness brightness = Brightness.light,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: brightness == Brightness.light
            ? TracksuTheme.light()
            : TracksuTheme.dark(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: RepositoryProvider<UserSearchRepository>.value(
          value: users,
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => UserSearchBloc(repository: users)),
              BlocProvider(
                create: (_) =>
                    BeatmapSearchBloc(repository: maps, minimumQueryLength: 2),
              ),
            ],
            child: const SearchScreen(
              initialText: '',
              initialTab: SearchTab.players,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'debounce, Enter, clear and tab switch query only the active tab',
    (tester) async {
      final users = Users();
      final maps = Maps();
      await pumpSearch(tester, users, maps);
      expect(users.calls, isEmpty);
      expect(maps.calls, isEmpty);
      await tester.enterText(find.byType(TextField), 'pe');
      await tester.pump(const Duration(milliseconds: 399));
      expect(users.calls, isEmpty);
      await tester.enterText(find.byType(TextField), 'peppy');
      await tester.pump(const Duration(milliseconds: 401));
      await tester.pumpAndSettle();
      expect(users.calls, [('peppy', 1)]);
      expect(maps.calls, isEmpty);
      await tester.tap(find.text('Maps'));
      await tester.pumpAndSettle();
      expect(maps.calls.single.text, 'peppy');
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'peppy',
      );
      await tester.enterText(find.byType(TextField), 'freedom');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(maps.calls.last.text, 'freedom');
      expect(users.calls.length, 1);
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      expect(maps.calls.length, 2);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

  testWidgets('IME commit triggers search without sending composing text', (
    tester,
  ) async {
    final users = Users();
    await pumpSearch(tester, users, Maps());
    await tester.showKeyboard(find.byType(TextField));
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: '日本',
        composing: TextRange(start: 0, end: 2),
      ),
    );
    await tester.pump(const Duration(milliseconds: 450));
    expect(users.calls, isEmpty);
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(text: '日本', composing: TextRange.empty),
    );
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();
    expect(users.calls, [('日本', 1)]);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final brightness in Brightness.values) {
    testWidgets('search AppBar fits phone width at 2x font in $brightness', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await pumpSearch(
        tester,
        Users(),
        Maps(),
        scale: 2,
        brightness: brightness,
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.byIcon(Icons.library_music_outlined));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
