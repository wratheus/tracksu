import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:meta/meta.dart';
import 'package:tracksu/src/rankings/domain/rankings_repository.dart';
import 'package:tracksu/src/rankings/kudosu/domain/kudosu_ranking.dart';

sealed class KudosuRankingEvent {
  const KudosuRankingEvent();
}

/// Start (once) and pull-to-refresh.
final class KudosuRankingRequested extends KudosuRankingEvent {
  const KudosuRankingRequested();
}

final class KudosuRankingMoreRequested extends KudosuRankingEvent {
  const KudosuRankingMoreRequested();
}

enum KudosuRankingOperation { refresh, loadMore }

@immutable
final class KudosuRankingState {
  KudosuRankingState({
    List<KudosuRankingEntry>? items,
    this.nextPage,
    this.operation,
    this.failure,
    this.failedOperation,
  }) : items = items == null ? null : List.unmodifiable(items);
  final List<KudosuRankingEntry>? items;
  final int? nextPage;
  final KudosuRankingOperation? operation;
  final RankingsFailureKind? failure;
  final KudosuRankingOperation? failedOperation;
}

/// Kudosu table; refresh keeps rows until the new first page lands, paging
/// never duplicates a user.
final class KudosuRankingBloc
    extends Bloc<KudosuRankingEvent, KudosuRankingState> {
  KudosuRankingBloc({required this._repository}) : super(KudosuRankingState()) {
    on<KudosuRankingEvent>(_onEvent, transformer: droppable());
  }

  final KudosuRankingRepository _repository;

  Future<void> _onEvent(
    KudosuRankingEvent event,
    Emitter<KudosuRankingState> emit,
  ) async {
    final bool more = event is KudosuRankingMoreRequested;
    if (more && (state.items == null || state.nextPage == null)) return;
    final KudosuRankingOperation operation = more
        ? KudosuRankingOperation.loadMore
        : KudosuRankingOperation.refresh;
    final List<KudosuRankingEntry>? previous = state.items;
    final int? previousNext = state.nextPage;
    emit(
      KudosuRankingState(
        items: previous,
        nextPage: previousNext,
        operation: operation,
      ),
    );
    try {
      final KudosuRankingPage page = await _repository.load(
        more ? previousNext! : 1,
      );
      final Map<int, KudosuRankingEntry> unique = <int, KudosuRankingEntry>{
        if (more)
          for (final KudosuRankingEntry e
              in previous ?? const <KudosuRankingEntry>[])
            e.userId: e,
      };
      for (final KudosuRankingEntry e in page.items) {
        unique.putIfAbsent(e.userId, () => e);
      }
      emit(
        KudosuRankingState(
          items: unique.values.toList(growable: false),
          nextPage: page.nextPage,
        ),
      );
    } on Object catch (error, stackTrace) {
      final RankingsFailureKind kind = error is RankingsFailure
          ? error.kind
          : RankingsFailureKind.unavailable;
      addError(RankingsFailure(kind), stackTrace);
      emit(
        KudosuRankingState(
          items: previous,
          nextPage: previousNext,
          failure: kind,
          failedOperation: operation,
        ),
      );
    }
  }
}
