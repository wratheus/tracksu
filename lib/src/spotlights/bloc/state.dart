part of 'bloc.dart';

sealed class SpotlightsState {
  const SpotlightsState();
}

final class SpotlightsInitialState extends SpotlightsState {
  const SpotlightsInitialState();
}

final class SpotlightsLoadingState extends SpotlightsState {
  const SpotlightsLoadingState();
}

final class SpotlightsFailureState extends SpotlightsState {
  const SpotlightsFailureState(this.failure);
  final RankingsFailureKind failure;
}

final class SpotlightsLoadedState extends SpotlightsState {
  SpotlightsLoadedState({
    required List<Spotlight> catalog,
    required this.ruleset,
    this.selectedId,
    this.details,
    this.loading = false,
    this.failure,
    this.rulesetUnavailable = false,
  }) : catalog = List<Spotlight>.unmodifiable(catalog);
  final List<Spotlight> catalog;
  final ProfileRuleset ruleset;
  final int? selectedId;
  final SpotlightDetails? details;
  final bool loading;
  final RankingsFailureKind? failure;

  /// The selected chart has no ranking table for [ruleset].
  final bool rulesetUnavailable;
}
