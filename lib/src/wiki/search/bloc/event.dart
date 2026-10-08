part of 'bloc.dart';

sealed class WikiSearchEvent {
  const WikiSearchEvent();
}

/// The screen debounces typing; the newest query always wins.
final class WikiSearchChanged extends WikiSearchEvent {
  const WikiSearchChanged(this.query);
  final String query;
}

final class WikiSearchMoreRequested extends WikiSearchEvent {
  const WikiSearchMoreRequested();
}
