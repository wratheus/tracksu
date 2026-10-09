part of 'bloc.dart';

sealed class RankingsEvent {
  const RankingsEvent();
}

final class RankingsStarted extends RankingsEvent {
  /// [type] is the first table, e.g. PP in the app's game mode.
  const RankingsStarted({this.type});
  final RankingsType? type;
}

final class RankingsCountrySelected extends RankingsEvent {
  const RankingsCountrySelected(this.value);
  final RankingCountry? value;
}

final class RankingsVariantSelected extends RankingsEvent {
  const RankingsVariantSelected(this.value);
  final ManiaVariant value;
}

final class RankingsTypeSelected extends RankingsEvent {
  const RankingsTypeSelected(this.value);
  final RankingsType value;
}

final class RankingsRefreshRequested extends RankingsEvent {
  const RankingsRefreshRequested();
}

final class RankingsMoreRequested extends RankingsEvent {
  const RankingsMoreRequested();
}
