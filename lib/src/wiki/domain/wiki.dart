import 'package:tracksu/src/_shared/content/domain/content_document.dart';

/// Opens a wiki article: `path` as in osu.ppy.sh/wiki/{locale}/{path}.
final class WikiParams {
  WikiParams(String path, {this.locale})
    : path = WikiLinks.cleanPath(path) {
    if (this.path.isEmpty) throw ArgumentError.value(path, 'path');
  }
  final String path;

  /// Preferred article language; null uses the app language.
  final String? locale;
}

/// A rendered wiki article. [locale] is the language actually returned,
/// which falls back to English when no translation exists.
final class WikiArticle {
  WikiArticle({
    required this.path,
    required this.locale,
    required this.title,
    required this.document,
    required List<String> availableLocales,
    this.subtitle,
  }) : availableLocales = List<String>.unmodifiable(availableLocales);
  final String path;
  final String locale;
  final String title;
  final String? subtitle;

  /// Null when the Markdown could not be rendered; the website link remains.
  final ContentDocument? document;
  final List<String> availableLocales;

  Uri get webUri => WikiLinks.web(path, locale);
}

final class WikiSearchHit {
  const WikiSearchHit({
    required this.path,
    required this.title,
    required this.locale,
    this.subtitle,
  });
  final String path;
  final String title;
  final String locale;
  final String? subtitle;
}

final class WikiSearchPage {
  WikiSearchPage({
    required List<WikiSearchHit> items,
    required this.total,
    required this.page,
  }) : items = List<WikiSearchHit>.unmodifiable(items);
  final List<WikiSearchHit> items;
  final int total;
  final int page;
}

enum WikiFailureKind {
  cancelled,
  notFound,
  rateLimited,
  connection,
  invalidResponse,
  unavailable,
}

final class WikiFailure implements Exception {
  const WikiFailure(this.kind);
  final WikiFailureKind kind;
}

/// Wiki URLs on osu.ppy.sh and their in-app paths.
abstract final class WikiLinks {
  static final RegExp _locale = RegExp(r'^[a-z]{2}(-[a-z]{2})?$');

  static String cleanPath(String path) => path
      .split('/')
      .where((String part) => part.isNotEmpty && part != '.' && part != '..')
      .join('/');

  static Uri web(String path, String locale) =>
      Uri.https('osu.ppy.sh', '/wiki/$locale/$path');

  /// Base for relative links and images: osu-web resolves them against the
  /// article URL as a directory (`relative_url_root`).
  static Uri base(String path, String locale) =>
      Uri.https('osu.ppy.sh', '/wiki/$locale/$path/');

  /// In-app article for an osu.ppy.sh wiki link, or null for anything else
  /// (including wiki images and the sitemap's special pages).
  static WikiParams? fromUri(Uri uri) {
    if (uri.host != 'osu.ppy.sh') return null;
    final List<String> parts = uri.pathSegments
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.length < 2 || parts.first != 'wiki' || parts[1] == 'images') {
      return null;
    }
    String? locale;
    List<String> rest = parts.sublist(1);
    if (_locale.hasMatch(rest.first.toLowerCase()) && rest.length > 1) {
      locale = rest.first.toLowerCase();
      rest = rest.sublist(1);
    }
    if (rest.last.contains('.')) return null; // a file, not an article
    try {
      return WikiParams(rest.join('/'), locale: locale);
    } on ArgumentError {
      return null;
    }
  }
}
