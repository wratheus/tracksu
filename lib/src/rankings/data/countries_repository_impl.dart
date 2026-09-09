import 'package:tracksu/src/_core/serialization/json_map_reader.dart';
import 'package:tracksu/src/rankings/data/countries_local_source.dart';
import 'package:tracksu/src/rankings/domain/countries.dart';
import 'package:tracksu/src/rankings/domain/rankings_query.dart';

final class RankingCountriesRepositoryImpl
    implements RankingCountriesRepository {
  factory RankingCountriesRepositoryImpl({
    required RankingCountriesLocalSource source,
  }) => RankingCountriesRepositoryImpl._(source);
  RankingCountriesRepositoryImpl._(this._source);
  final RankingCountriesLocalSource _source;
  Future<List<RankingCountryOption>>? _pending;

  @override
  Future<List<RankingCountryOption>> load() => _pending ??= _load();

  Future<List<RankingCountryOption>> _load() async {
    try {
      final JsonMapReader reader = JsonMapReader(await _source.load());
      final Map<String, String> names = <String, String>{};
      for (final Object? item in reader.requiredList('names')) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Invalid country name entry.');
        }
        final JsonMapReader row = JsonMapReader(item);
        final String code = RankingCountry(row.requiredString('code')).value;
        if (names.containsKey(code)) {
          throw const FormatException('Duplicate country name.');
        }
        names[code] = row.requiredString('name');
      }
      final Set<String> codes = <String>{...names.keys};
      for (final Object? item in reader.requiredList('codes')) {
        if (item is! String) {
          throw const FormatException('Invalid country code.');
        }
        codes.add(RankingCountry(item).value);
      }
      final List<RankingCountryOption> result =
          <RankingCountryOption>[
            for (final String code in codes)
              RankingCountryOption(
                country: RankingCountry(code),
                name: names[code] ?? code,
              ),
          ]..sort(
            (RankingCountryOption a, RankingCountryOption b) =>
                a.name.compareTo(b.name),
          );
      return List<RankingCountryOption>.unmodifiable(result);
    } on Object {
      // A failed bundle read can be retried; never cache a failed Future forever.
      _pending = null;
      rethrow;
    }
  }
}
