part of 'rankings_cubit.dart';

@immutable
abstract class RankingsState {}

class RankingsInitial extends RankingsState {
  final String filterValue;
  final String page;  final Country? countryValue;


  RankingsInitial(this.filterValue, this.page, this.countryValue);
}

class RankingsLoadedState extends RankingsState {
  final List<Rankings> rankingsList;
  final List<Country> countryList;
  final String filterValue;
  final String page;
  final Country? countryValue;

  RankingsLoadedState(this.rankingsList, this.filterValue, this.page, this.countryValue, this.countryList);
}

class RankingsErrorState extends RankingsState {
  final String errorMessage;

  RankingsErrorState(this.errorMessage);
}
