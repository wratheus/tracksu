part of 'bloc.dart';

/// Every state knows the selected stream and the streams seen so far, so the
/// stream chips stay visible while a stream loads or fails.
sealed class ChangelogState {
  const ChangelogState({this.stream, this.streams = const <ChangelogStream>[]});
  final String? stream;
  final List<ChangelogStream> streams;
}

final class ChangelogInitialState extends ChangelogState {
  const ChangelogInitialState();
}

final class ChangelogLoadingState extends ChangelogState {
  const ChangelogLoadingState({super.stream, super.streams});
}

final class ChangelogFailureState extends ChangelogState {
  const ChangelogFailureState({
    required this.failure,
    super.stream,
    super.streams,
  });
  final ChangelogFailureKind failure;
}

enum ChangelogOperation { refresh, loadMore }

final class ChangelogLoadedState extends ChangelogState {
  ChangelogLoadedState({
    required super.stream,
    required List<ChangelogStream> streams,
    required List<ChangelogBuild> builds,
    required this.nextMaxId,
    this.operation,
    this.failure,
    this.failedOperation,
  }) : builds = List<ChangelogBuild>.unmodifiable(builds),
       super(streams: List<ChangelogStream>.unmodifiable(streams));

  final List<ChangelogBuild> builds;
  final int? nextMaxId;
  final ChangelogOperation? operation;
  final ChangelogFailureKind? failure;
  final ChangelogOperation? failedOperation;
}
