import 'package:tracksu/src/rankings/domain/rankings_query.dart';

final class RankingCountryOption {
  const RankingCountryOption({required this.country, required this.name});
  final RankingCountry country;
  final String name;
}

abstract interface class RankingCountriesRepository {
  Future<List<RankingCountryOption>> load();
}
