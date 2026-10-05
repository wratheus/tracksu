import 'package:flutter_test/flutter_test.dart';
import 'package:tracksu/src/rankings/country_stats/data/repository_impl.dart';
import 'package:tracksu/src/rankings/country_stats/domain/country_ranking.dart';

/// Shape of osu-web CountryStatisticsTransformer with the `country` include.
Map<String, dynamic> _row(String code, {num performance = 1000}) =>
    <String, dynamic>{
      'code': code,
      'active_users': 12345,
      'play_count': 99999,
      'ranked_score': 123456789,
      'performance': performance,
      'country': <String, dynamic>{'code': code, 'name': code},
    };

void main() {
  test('rows keep country, values and table position', () {
    final CountryRankingsPage page = CountryRankingsRepositoryImpl.decode(
      <String, dynamic>{
        'ranking': <Object?>[_row('US', performance: 2e9), _row('JP')],
        'cursor': <String, dynamic>{'page': 3},
        'total': 240,
      },
      2,
    );
    expect(page.items.first.country.value, 'US');
    expect(page.items.first.position, 51);
    expect(page.items.first.activeUsers, 12345);
    expect(page.items.last.position, 52);
    expect(page.nextPage, 3);
  });

  test('broken rows fail loudly', () {
    expect(
      () => CountryRankingsRepositoryImpl.decode(<String, dynamic>{
        'ranking': <Object?>[_row('USA')],
        'cursor': null,
        'total': 1,
      }, 1),
      throwsFormatException,
    );
    expect(
      () => CountryRankingsRepositoryImpl.decode(<String, dynamic>{
        'ranking': <Object?>[_row('US'), _row('US')],
        'cursor': null,
        'total': 2,
      }, 1),
      throwsFormatException,
    );
  });
}
