part of 'bloc.dart';

enum OsuEventsOperation { refresh, loadMore }

/// [items] null until the first page arrives; a failed refresh or page keeps
/// the visible rows and records [failure] with its [failedOperation].
final class OsuEventsState {
  const OsuEventsState({
    this.filter = OsuEventFilter.all,
    this.items,
    this.cursor,
    this.operation,
    this.failure,
    this.failedOperation,
  });
  final OsuEventFilter filter;
  final List<OsuEvent>? items;
  final String? cursor;
  final OsuEventsOperation? operation;
  final OsuEventsFailureKind? failure;
  final OsuEventsOperation? failedOperation;

  bool get busy => operation != null;

  /// Rows of the selected group, in feed order.
  List<OsuEvent>? get visible => items
      ?.where((OsuEvent event) => filter.matches(event.kind))
      .toList(growable: false);

  OsuEventsState copyWith({OsuEventFilter? filter}) => OsuEventsState(
    filter: filter ?? this.filter,
    items: items,
    cursor: cursor,
    operation: operation,
    failure: failure,
    failedOperation: failedOperation,
  );
}
