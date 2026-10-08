part of 'bloc.dart';

/// [article] null until loaded; a failed refresh keeps the article and sets
/// [failure].
final class WikiArticleState {
  const WikiArticleState({this.article, this.loading = true, this.failure});
  final WikiArticle? article;
  final bool loading;
  final WikiFailureKind? failure;
}
