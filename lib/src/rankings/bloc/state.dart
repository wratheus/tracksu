part of 'bloc.dart';

sealed class RankingsState {
  const RankingsState({required this.type});
  final RankingsType type;
}

final class RankingsInitialState extends RankingsState {
  const RankingsInitialState() : super(type: RankingsType.osuPerformance);
}

final class RankingsLoadingState extends RankingsState {
  const RankingsLoadingState({required super.type});
}

final class RankingsFailureState extends RankingsState {
  const RankingsFailureState({required super.type, required this.failure});
  final RankingsFailureKind failure;
}

enum RankingsOperation { refresh, loadMore }

final class RankingsLoadedState extends RankingsState {
  RankingsLoadedState({
    required super.type,
    required List<RankingEntry> items,
    required this.nextPage,
    this.operation,
    this.failure,
    this.failedOperation,
  }) : items = List<RankingEntry>.unmodifiable(items);

  final List<RankingEntry> items;
  final int? nextPage;
  final RankingsOperation? operation;
  final RankingsFailureKind? failure;
  final RankingsOperation? failedOperation;
}
