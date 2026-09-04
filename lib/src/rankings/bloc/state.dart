part of 'bloc.dart';

sealed class RankingsState {
  const RankingsState({
    required this.type,
    this.country,
    this.variant = ManiaVariant.all,
  });
  final RankingsType type;
  final RankingCountry? country;
  final ManiaVariant variant;
}

final class RankingsInitialState extends RankingsState {
  const RankingsInitialState() : super(type: RankingsType.osuPerformance);
}

final class RankingsLoadingState extends RankingsState {
  const RankingsLoadingState({
    required super.type,
    super.country,
    super.variant,
  });
}

final class RankingsFailureState extends RankingsState {
  const RankingsFailureState({
    required super.type,
    required this.failure,
    super.country,
    super.variant,
  });
  final RankingsFailureKind failure;
}

enum RankingsOperation { refresh, loadMore }

final class RankingsLoadedState extends RankingsState {
  RankingsLoadedState({
    required super.type,
    super.country,
    super.variant,
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
