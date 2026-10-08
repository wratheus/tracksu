import 'package:tracksu/src/_core/serialization/json_map_reader.dart';
import 'package:tracksu/src/_shared/content/data/content_parser.dart';
import 'package:tracksu/src/_shared/content/domain/content_document.dart';
import 'package:tracksu/src/auth/data/oauth_remote_source_exception.dart';
import 'package:tracksu/src/wiki/domain/wiki.dart';
import 'package:tracksu_network/tracksu_network.dart';

/// osu! wiki: `GET /wiki/{locale}/{path}` (no token required, Markdown) and
/// `GET /search?mode=wiki_page` (scope public, 50 per page). A newer read of
/// the same kind cancels the previous one.
final class WikiRepository {
  WikiRepository({required RestClient restClient}) : _client = restClient;
  final RestClient _client;
  RestCancellationToken? _article;
  RestCancellationToken? _search;

  void cancelPending() {
    _article?.cancel();
    _search?.cancel();
    _article = _search = null;
  }

  /// Article in [locale], falling back to English when it is not translated.
  Future<WikiArticle> article(WikiParams params, {required String locale}) =>
      _guard(() async {
        _article?.cancel();
        final RestCancellationToken token = RestCancellationToken();
        _article = token;
        RestResponse response = await _get(params.path, locale, token);
        if (response.statusCode == 404 && locale != 'en') {
          response = await _get(params.path, 'en', token);
        }
        if (token.isCancelled) {
          throw const WikiFailure(WikiFailureKind.cancelled);
        }
        if (response.statusCode != 200) throw _status(response.statusCode);
        final JsonMapReader reader = JsonMapReader(response.payload.asMap());
        final String path = reader.optionalString('path') ?? params.path;
        final String returned = reader.optionalString('locale') ?? locale;
        ContentDocument? document;
        try {
          document = ContentParser.parse(
            _withoutTitle(reader.optionalString('markdown') ?? ''),
            format: ContentFormat.markdown,
            base: WikiLinks.base(path, returned),
          );
        } on FormatException {
          document = null;
        }
        return WikiArticle(
          path: path,
          locale: returned,
          title: reader.optionalString('title') ?? path.split('/').last,
          subtitle: reader.optionalString('subtitle'),
          document: document,
          availableLocales: <String>[
            for (final Object? value
                in reader.optionalList('available_locales') ?? const [])
              if (value is String) value,
          ],
        );
      });

  Future<WikiSearchPage> search(
    String query, {
    required String locale,
    int page = 1,
  }) => _guard(() async {
    _search?.cancel();
    final RestCancellationToken token = RestCancellationToken();
    _search = token;
    final RestResponse response = await _client.get(
      path: '/search',
      queryParameters: <String, Object?>{
        'mode': 'wiki_page',
        'query': query,
        'locale': locale,
        'page': page,
      },
      options: RestClientOptions(cancellationToken: token),
    );
    if (token.isCancelled) throw const WikiFailure(WikiFailureKind.cancelled);
    if (response.statusCode != 200) throw _status(response.statusCode);
    final Map<String, dynamic> body =
        JsonMapReader(response.payload.asMap()).optionalMap('wiki_page') ??
        const <String, dynamic>{};
    final JsonMapReader reader = JsonMapReader(body);
    return WikiSearchPage(
      page: page,
      total: reader.optionalInt('total') ?? 0,
      items: <WikiSearchHit>[
        for (final Object? item in reader.optionalList('data') ?? const [])
          if (item is Map<String, dynamic>)
            if (JsonMapReader(item) case final JsonMapReader hit
                when hit.optionalString('path') != null)
              WikiSearchHit(
                path: hit.optionalString('path')!,
                title:
                    hit.optionalString('title') ?? hit.optionalString('path')!,
                subtitle: hit.optionalString('subtitle'),
                locale: hit.optionalString('locale') ?? locale,
              ),
      ],
    );
  });

  Future<RestResponse> _get(
    String path,
    String locale,
    RestCancellationToken token,
  ) => _client.get(
    path:
        '/wiki/${Uri.encodeComponent(locale)}/'
        '${path.split('/').map(Uri.encodeComponent).join('/')}',
    options: RestClientOptions(cancellationToken: token),
  );

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on WikiFailure {
      rethrow;
    } on OAuthRemoteSourceException catch (error, stackTrace) {
      Error.throwWithStackTrace(_status(error.statusCode), stackTrace);
    } on FormatException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const WikiFailure(WikiFailureKind.invalidResponse),
        stackTrace,
      );
    } on RestRequestCancelledException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const WikiFailure(WikiFailureKind.cancelled),
        stackTrace,
      );
    } on RestClientException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const WikiFailure(WikiFailureKind.connection),
        stackTrace,
      );
    }
  }

  static WikiFailure _status(int status) => WikiFailure(switch (status) {
    404 => WikiFailureKind.notFound,
    429 => WikiFailureKind.rateLimited,
    _ => WikiFailureKind.unavailable,
  });

  /// Articles open with `# Title`; the screen shows the title once in its
  /// header, so the first level-1 heading before any text is dropped.
  static String _withoutTitle(String markdown) => markdown.replaceFirstMapped(
    RegExp(r'^(---\r?\n[\s\S]*?\r?\n---\r?\n)?\s*# [^\n]*\n'),
    (Match match) => match.group(1) ?? '',
  );
}
