import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:meta/meta.dart';
import 'package:tracksu/src/daily/domain/daily_challenge.dart';

sealed class DailyChallengeEvent {
  const DailyChallengeEvent();
}

/// Initial load and pull-to-refresh are the same request.
final class DailyChallengeRequested extends DailyChallengeEvent {
  const DailyChallengeRequested();
}

@immutable
sealed class DailyChallengeState {
  const DailyChallengeState();
}

final class DailyChallengeLoading extends DailyChallengeState {
  const DailyChallengeLoading();
}

/// [challenge] null: no active daily challenge right now (not an error).
final class DailyChallengeLoaded extends DailyChallengeState {
  DailyChallengeLoaded({
    required this.challenge,
    List<DailyChallengeScore>? scores,
    this.refreshing = false,
    this.failure,
  }) : scores = scores == null ? null : List.unmodifiable(scores);
  final DailyChallenge? challenge;

  /// Loaded only when the bloc was created with `withLeaderboard`.
  final List<DailyChallengeScore>? scores;
  final bool refreshing;

  /// A failed refresh keeps the previous content.
  final DailyChallengeFailureKind? failure;
}

final class DailyChallengeFailed extends DailyChallengeState {
  const DailyChallengeFailed(this.failure);
  final DailyChallengeFailureKind failure;
}

final class DailyChallengeBloc
    extends Bloc<DailyChallengeEvent, DailyChallengeState> {
  /// [pastRoomId] shows a finished day instead of today's challenge;
  /// [past] is that day when the caller already has it (history list).
  DailyChallengeBloc({
    required this._repository,
    this.withLeaderboard = false,
    this.pastRoomId,
    this._past,
  }) : super(const DailyChallengeLoading()) {
    // A refresh while one is running is dropped, not queued.
    on<DailyChallengeRequested>(_load, transformer: droppable());
  }

  final DailyChallengeRepository _repository;
  final bool withLeaderboard;
  final int? pastRoomId;
  DailyChallenge? _past;

  /// The requested past day: from the caller, else looked up in the newest
  /// 250 finished rooms (the furthest the rooms index reaches).
  Future<DailyChallenge?> _challenge() async {
    final int? id = pastRoomId;
    if (id == null) return _repository.today();
    if (_past case final DailyChallenge past) return past;
    for (final DailyChallenge day in await _repository.history(limit: 250)) {
      if (day.roomId == id) return _past = day;
    }
    return null;
  }

  Future<void> _load(
    DailyChallengeRequested event,
    Emitter<DailyChallengeState> emit,
  ) async {
    final DailyChallengeState previous = state;
    if (previous is DailyChallengeLoaded) {
      emit(
        DailyChallengeLoaded(
          challenge: previous.challenge,
          scores: previous.scores,
          refreshing: true,
        ),
      );
    } else {
      emit(const DailyChallengeLoading());
    }
    try {
      final DailyChallenge? challenge = await _challenge();
      final List<DailyChallengeScore>? scores =
          withLeaderboard && challenge != null
          ? await _repository.leaderboard(challenge.roomId)
          : null;
      emit(DailyChallengeLoaded(challenge: challenge, scores: scores));
    } on Object catch (error, stackTrace) {
      final DailyChallengeFailureKind kind = error is DailyChallengeFailure
          ? error.kind
          : DailyChallengeFailureKind.unavailable;
      addError(
        error is DailyChallengeFailure
            ? error
            : DailyChallengeFailure(kind, cause: error),
        stackTrace,
      );
      emit(
        previous is DailyChallengeLoaded
            ? DailyChallengeLoaded(
                challenge: previous.challenge,
                scores: previous.scores,
                failure: kind,
              )
            : DailyChallengeFailed(kind),
      );
    }
  }
}

sealed class DailyHistoryEvent {
  const DailyHistoryEvent();
}

/// Initial load and pull-to-refresh.
final class DailyHistoryRequested extends DailyHistoryEvent {
  const DailyHistoryRequested();
}

final class DailyHistoryRetryRequested extends DailyHistoryEvent {
  const DailyHistoryRetryRequested();
}

final class DailyHistoryMoreRequested extends DailyHistoryEvent {
  const DailyHistoryMoreRequested();
}

/// [items] is null until the first load lands.
@immutable
final class DailyHistoryState {
  DailyHistoryState({
    List<DailyChallenge>? items,
    this.limit = DailyHistoryBloc.step,
    this.busy = false,
    this.done = false,
    this.failure,
    this.failedEvent,
  }) : items = items == null ? null : List.unmodifiable(items);
  final List<DailyChallenge>? items;
  final int limit;
  final bool busy;

  /// No older days are available (fewer rows than asked, or the 250 cap).
  final bool done;
  final DailyChallengeFailureKind? failure;
  final DailyHistoryEvent? failedEvent;
}

/// Past daily challenges. The rooms index returns a plain array without a
/// cursor, so "more" asks again with a larger limit (30, 60, … 250) and
/// keeps the rows it already shows on failure.
final class DailyHistoryBloc
    extends Bloc<DailyHistoryEvent, DailyHistoryState> {
  DailyHistoryBloc({required this._repository}) : super(DailyHistoryState()) {
    on<DailyHistoryEvent>(_onEvent, transformer: droppable());
  }

  static const int step = 30;
  static const int max = 250;
  final DailyChallengeRepository _repository;

  Future<void> _onEvent(
    DailyHistoryEvent event,
    Emitter<DailyHistoryState> emit,
  ) async {
    if (event is DailyHistoryRetryRequested) {
      final DailyHistoryEvent? failed = state.failedEvent;
      if (failed == null) return;
      event = failed;
    }
    final DailyHistoryState previous = state;
    final int limit = switch (event) {
      DailyHistoryRequested() => state.items == null ? step : state.limit,
      DailyHistoryMoreRequested() =>
        state.items == null || state.done
            ? -1
            : (state.limit + step).clamp(step, max),
      DailyHistoryRetryRequested() => -1,
    };
    if (limit < 0) return;
    emit(
      DailyHistoryState(
        items: previous.items,
        limit: previous.limit,
        done: previous.done,
        busy: true,
      ),
    );
    try {
      final List<DailyChallenge> days = await _repository.history(limit: limit);
      emit(
        DailyHistoryState(
          items: days,
          limit: limit,
          done: days.length < limit || limit >= max,
        ),
      );
    } on Object catch (error, stackTrace) {
      final DailyChallengeFailureKind kind = error is DailyChallengeFailure
          ? error.kind
          : DailyChallengeFailureKind.unavailable;
      addError(
        error is DailyChallengeFailure
            ? error
            : DailyChallengeFailure(kind, cause: error),
        stackTrace,
      );
      emit(
        DailyHistoryState(
          items: previous.items,
          limit: previous.limit,
          done: previous.done,
          failure: kind,
          failedEvent: event,
        ),
      );
    }
  }
}
