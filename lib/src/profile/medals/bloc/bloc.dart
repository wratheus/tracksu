import 'package:bloc/bloc.dart';
import 'package:tracksu/src/profile/medals/domain/medal.dart';
import 'package:tracksu/src/profile/medals/domain/repository.dart';

part 'event.dart';
part 'state.dart';

final class MedalsBloc extends Bloc<MedalsEvent, MedalsState> {
  factory MedalsBloc({
    required MedalsRepository repository,
    required int userId,
  }) => MedalsBloc._(repository, userId);

  MedalsBloc._(this._repository, this._userId) : super(const MedalsLoading()) {
    on<MedalsEvent>(_onEvent);
  }
  final MedalsRepository _repository;
  final int _userId;
  bool _busy = false;

  Future<void> _onEvent(MedalsEvent event, Emitter<MedalsState> emit) async {
    // One read at a time; repeated refresh taps never queue network work.
    if (_busy) return;
    switch (event) {
      case MedalsLoadRequested():
        break;
    }
    _busy = true;
    final MedalsLoaded? previous = switch (state) {
      final MedalsLoaded value => value,
      _ => null,
    };
    emit(
      previous == null
          ? const MedalsLoading()
          : MedalsLoaded(previous.medals, refreshing: true),
    );
    try {
      final List<EarnedMedal> medals = await _repository.load(_userId);
      if (isClosed || emit.isDone) return;
      emit(MedalsLoaded(medals));
    } on Object catch (_, stackTrace) {
      if (isClosed || emit.isDone) return;
      // Never forward an upstream HTML body or decoded content to telemetry.
      addError(StateError('Medal collection unavailable.'), stackTrace);
      emit(
        previous == null
            ? const MedalsError()
            : MedalsLoaded(previous.medals, refreshFailed: true),
      );
    } finally {
      _busy = false;
    }
  }

  @override
  Future<void> close() {
    _repository.cancelPending();
    return super.close();
  }
}
