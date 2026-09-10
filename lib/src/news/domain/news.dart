import 'package:tracksu/src/_shared/content/domain/content_document.dart';

final class NewsArticleParams {
  NewsArticleParams(this.id) {
    if (id <= 0) throw ArgumentError.value(id, 'id');
  }
  final int id;
}

final class NewsPost {
  const NewsPost({
    required this.id,
    required this.title,
    required this.author,
    required this.publishedAt,
    required this.uri,
    this.preview,
    this.coverUri,
  });
  final int id;
  final String title;
  final String author;
  final DateTime publishedAt;
  final Uri uri;
  final String? preview;
  final Uri? coverUri;
}

final class NewsArticle {
  const NewsArticle({required this.post, required this.document});
  final NewsPost post;
  final ContentDocument? document;
}

final class NewsPage {
  NewsPage({required List<NewsPost> items, required this.cursor})
    : items = List<NewsPost>.unmodifiable(items);
  final List<NewsPost> items;
  final String? cursor;
}

abstract interface class NewsRepository {
  Future<NewsPage> list({String? cursor});
  Future<NewsArticle> article(NewsArticleParams params);
  void cancelPending();
}

enum NewsFailureKind {
  cancelled,
  notFound,
  accessDenied,
  rateLimited,
  connection,
  invalidResponse,
  unavailable,
}

final class NewsFailure implements Exception {
  const NewsFailure(this.kind);
  final NewsFailureKind kind;
}
