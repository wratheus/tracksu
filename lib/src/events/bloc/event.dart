part of 'bloc.dart';

sealed class OsuEventsEvent {
  const OsuEventsEvent();
}

/// Requests that read the API; handled one at a time.
sealed class OsuEventsLoadEvent extends OsuEventsEvent {
  const OsuEventsLoadEvent();
}

final class OsuEventsStarted extends OsuEventsLoadEvent {
  const OsuEventsStarted();
}

final class OsuEventsRefreshRequested extends OsuEventsLoadEvent {
  const OsuEventsRefreshRequested();
}

final class OsuEventsMoreRequested extends OsuEventsLoadEvent {
  const OsuEventsMoreRequested();
}

/// Client-side grouping; the loaded feed is kept, only the view changes.
final class OsuEventsFilterSelected extends OsuEventsEvent {
  const OsuEventsFilterSelected(this.filter);
  final OsuEventFilter filter;
}
