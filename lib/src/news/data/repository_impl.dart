import 'package:tracksu/src/_core/serialization/json_map_reader.dart';
import 'package:tracksu/src/auth/data/oauth_remote_source_exception.dart';
import 'package:tracksu/src/news/domain/news.dart';
import 'package:tracksu/src/news/data/remote_source.dart';
import 'package:tracksu/src/news/data/news_dto.dart';
import 'package:tracksu/src/_shared/content/data/safe_html.dart';
import 'package:tracksu_network/tracksu_network.dart';

final class NewsRepositoryImpl implements NewsRepository {
  NewsRepositoryImpl({required NewsRemoteSource remoteSource})
    : _source = remoteSource;
  final NewsRemoteSource _source;
  RestCancellationToken? _pending;
  @override
  void cancelPending() {
    _pending?.cancel();
    _pending = null;
  }

  @override
  Future<NewsPage> list({String? cursor}) => _read(
    (RestClientOptions options) =>
        _source.list(cursor: cursor, options: options),
    (Map<String, dynamic> raw) {
      final List<NewsPost> items = <NewsPost>[];
      for (final Object? item in JsonMapReader(
        raw,
      ).requiredList('news_posts')) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Invalid news post.');
        }
        items.add(NewsPostDto.fromJson(item, previewRequired: true).toDomain());
      }
      final Object? next = raw['cursor_string'];
      if (next != null && (next is! String || next.isEmpty || next == cursor)) {
        throw const FormatException('Invalid or non-advancing news cursor.');
      }
      return NewsPage(items: items, cursor: next as String?);
    },
  );

  @override
  Future<NewsArticle> article(NewsArticleParams params) => _read(
    (RestClientOptions options) => _source.article(params, options: options),
    (Map<String, dynamic> raw) {
      final NewsPost post = NewsPostDto.fromJson(raw).toDomain();
      if (post.id != params.id) {
        throw const FormatException('News ID mismatch.');
      }
      final Object? content = raw['content'];
      if (content is! String) {
        throw const FormatException('Invalid news content.');
      }
      return NewsArticle(
        post: post,
        safeHtml: SafeHtml.sanitize(content, post.uri),
      );
    },
  );

  Future<T> _read<T>(
    Future<Map<String, dynamic>> Function(RestClientOptions) request,
    T Function(Map<String, dynamic>) decode,
  ) async {
    cancelPending();
    final RestCancellationToken token = RestCancellationToken();
    _pending = token;
    try {
      final Map<String, dynamic> raw = await request(
        RestClientOptions(cancellationToken: token),
      );
      if (token.isCancelled) {
        throw const NewsFailure(NewsFailureKind.cancelled);
      }
      return decode(raw);
    } on NewsRemoteException catch (error, stackTrace) {
      Error.throwWithStackTrace(_statusFailure(error.statusCode), stackTrace);
    } on OAuthRemoteSourceException catch (error, stackTrace) {
      Error.throwWithStackTrace(_statusFailure(error.statusCode), stackTrace);
    } on FormatException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const NewsFailure(NewsFailureKind.invalidResponse),
        stackTrace,
      );
    } on RestRequestCancelledException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const NewsFailure(NewsFailureKind.cancelled),
        stackTrace,
      );
    } on RestClientException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const NewsFailure(NewsFailureKind.connection),
        stackTrace,
      );
    } finally {
      if (identical(_pending, token)) {
        _pending = null;
      }
    }
  }

  NewsFailure _statusFailure(int status) => NewsFailure(switch (status) {
    404 => NewsFailureKind.notFound,
    401 || 403 => NewsFailureKind.accessDenied,
    429 => NewsFailureKind.rateLimited,
    _ => NewsFailureKind.unavailable,
  });
}
