part of 'bloc.dart';

sealed class SpotlightsEvent {
  const SpotlightsEvent();
}

final class SpotlightsStarted extends SpotlightsEvent {
  const SpotlightsStarted();
}

final class SpotlightSelected extends SpotlightsEvent {
  const SpotlightSelected(this.id);
  final int id;
}

final class SpotlightRulesetSelected extends SpotlightsEvent {
  const SpotlightRulesetSelected(this.ruleset);
  final ProfileRuleset ruleset;
}

final class SpotlightsRefreshRequested extends SpotlightsEvent {
  const SpotlightsRefreshRequested();
}
