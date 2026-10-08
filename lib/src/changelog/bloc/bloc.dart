import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tracksu/src/_core/cache/page_cache.dart';
import 'package:tracksu/src/changelog/domain/changelog.dart';

part 'event.dart';
part 'state.dart';

/// Changelog builds for all streams or one stream. The first page per stream
/// is session-cached; switching streams supersedes an in-flight read.
final class ChangelogBloc extends Bloc<ChangelogEvent, ChangelogState> {
  ChangelogBloc({required this._repository, required this._cache})
    : super(const ChangelogInitialState()) {
    on<ChangelogEvent>(_onEvent, transformer: concurrent());
  }

  final ChangelogRepository _repository;
  final PageCache _cache;
  int _generation = 0;

  Future<void> _onEvent(
    ChangelogEvent event,
    Emitter<ChangelogState> emit,
  ) async {
    ChangelogLoadedState? previous;
    String? stream = state.stream;
    ChangelogOperation operation = ChangelogOperation.refresh;
    int? maxId;
    final List<ChangelogStream> knownStreams = switch (state) {
      final ChangelogLoadedState loaded => loaded.streams,
      _ => const <ChangelogStream>[],
    };
    switch (event) {
      case ChangelogStarted():
        if (state is! ChangelogInitialState) return;
      case ChangelogStreamSelected(:final String? value):
        if (value == state.stream && state is! ChangelogFailureState) return;
        stream = value;
      case ChangelogRefreshRequested():
        if (state is ChangelogLoadingState) return;
        if (state case final ChangelogLoadedState loaded) {
          if (loaded.operation != null) return;
          previous = loaded;
        }
      case ChangelogMoreRequested():
        if (state case final ChangelogLoadedState loaded
            when loaded.operation == null &&
                loaded.nextMaxId != null &&
                loaded.failedOperation != ChangelogOperation.refresh) {
          previous = loaded;
          maxId = loaded.nextMaxId;
          operation = ChangelogOperation.loadMore;
        } else {
          return;
        }
    }

    final int generation = ++_generation;
    final Object cacheKey = ('changelog', stream);
    final int cacheRevision = _cache.revision;
    if (previous == null) {
      if (_cache.read<ChangelogPage>(cacheKey) case final cached?) {
        previous = ChangelogLoadedState(
          stream: stream,
          streams: cached.streams,
          builds: cached.builds,
          nextMaxId: cached.nextMaxId,
        );
      }
    }
    emit(
      previous == null
          ? ChangelogLoadingState(stream: stream, streams: knownStreams)
          : ChangelogLoadedState(
              stream: stream,
              streams: previous.streams,
              builds: previous.builds,
              nextMaxId: previous.nextMaxId,
              operation: operation,
            ),
    );
    try {
      final ChangelogPage page = await _repository.load(
        ChangelogQuery(stream: stream, maxId: maxId),
      );
      if (generation != _generation || emit.isDone || isClosed) return;
      if (operation == ChangelogOperation.refresh) {
        _cache.write(cacheKey, page, revision: cacheRevision);
      }
      final Map<int, ChangelogBuild> unique = <int, ChangelogBuild>{
        if (operation == ChangelogOperation.loadMore && previous != null)
          for (final ChangelogBuild build in previous.builds) build.id: build,
        for (final ChangelogBuild build in page.builds) build.id: build,
      };
      emit(
        ChangelogLoadedState(
          stream: stream,
          streams: page.streams.isEmpty
              ? (previous?.streams ?? knownStreams)
              : page.streams,
          builds: unique.values.toList(growable: false),
          nextMaxId: page.nextMaxId,
        ),
      );
    } on Object catch (error, stackTrace) {
      if (generation != _generation || emit.isDone || isClosed) return;
      final ChangelogFailureKind kind = error is ChangelogFailure
          ? error.kind
          : ChangelogFailureKind.unavailable;
      addError(ChangelogFailure(kind), stackTrace);
      emit(
        previous == null
            ? ChangelogFailureState(
                stream: stream,
                streams: knownStreams,
                failure: kind,
              )
            : ChangelogLoadedState(
                stream: stream,
                streams: previous.streams,
                builds: previous.builds,
                nextMaxId: previous.nextMaxId,
                failure: kind,
                failedOperation: operation,
              ),
      );
    }
  }

  @override
  Future<void> close() {
    _generation++;
    _repository.cancelPending();
    return super.close();
  }
}
