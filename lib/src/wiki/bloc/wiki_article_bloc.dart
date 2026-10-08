import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tracksu/src/_core/cache/page_cache.dart';
import 'package:tracksu/src/wiki/data/wiki_repository.dart';
import 'package:tracksu/src/wiki/domain/wiki.dart';

final class WikiArticleRequested {
  const WikiArticleRequested();
}

/// [article] null until loaded; a failed refresh keeps the article and sets
/// [failure].
final class WikiArticleState {
  const WikiArticleState({this.article, this.loading = true, this.failure});
  final WikiArticle? article;
  final bool loading;
  final WikiFailureKind? failure;
}

/// One article in the app language (English fallback), session-cached.
final class WikiArticleBloc
    extends Bloc<WikiArticleRequested, WikiArticleState> {
  WikiArticleBloc({
    required this._repository,
    required this._cache,
    required this._params,
    required this._appLocale,
  }) : super(const WikiArticleState()) {
    on<WikiArticleRequested>(_load, transformer: droppable());
  }

  final WikiRepository _repository;
  final PageCache _cache;
  final WikiParams _params;
  final String Function() _appLocale;

  Future<void> _load(
    WikiArticleRequested event,
    Emitter<WikiArticleState> emit,
  ) async {
    final String locale = _params.locale ?? _appLocale();
    final Object key = ('wiki', locale, _params.path);
    final int revision = _cache.revision;
    final WikiArticle? shown = state.article ?? _cache.read<WikiArticle>(key);
    emit(WikiArticleState(article: shown));
    try {
      final WikiArticle article = await _repository.article(
        _params,
        locale: locale,
      );
      _cache.write(key, article, revision: revision);
      emit(WikiArticleState(article: article, loading: false));
    } on Object catch (error, stackTrace) {
      final WikiFailureKind kind = error is WikiFailure
          ? error.kind
          : WikiFailureKind.unavailable;
      addError(WikiFailure(kind), stackTrace);
      emit(WikiArticleState(article: shown, loading: false, failure: kind));
    }
  }

  @override
  Future<void> close() {
    _repository.cancelPending();
    return super.close();
  }
}
