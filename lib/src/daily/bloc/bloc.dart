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
  DailyChallengeBloc({
    required DailyChallengeRepository repository,
    this.withLeaderboard = false,
  }) : _repository = repository,
       super(const DailyChallengeLoading()) {
    // A refresh while one is running is dropped, not queued.
    on<DailyChallengeRequested>(_load, transformer: droppable());
  }

  final DailyChallengeRepository _repository;
  final bool withLeaderboard;

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
      final DailyChallenge? challenge = await _repository.today();
      final List<DailyChallengeScore>? scores =
          withLeaderboard && challenge != null
          ? await _repository.leaderboard(challenge.roomId)
          : null;
      emit(DailyChallengeLoaded(challenge: challenge, scores: scores));
    } on Object catch (error, stackTrace) {
      final DailyChallengeFailureKind kind = error is DailyChallengeFailure
          ? error.kind
          : DailyChallengeFailureKind.unavailable;
      addError(DailyChallengeFailure(kind), stackTrace);
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
