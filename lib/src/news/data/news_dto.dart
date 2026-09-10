import 'package:tracksu/src/_core/serialization/json_map_reader.dart';
import 'package:tracksu/src/_shared/content/domain/public_web_link.dart';
import 'package:tracksu/src/news/domain/news.dart';

final class NewsPostDto {
  const NewsPostDto._(this._post);
  factory NewsPostDto.fromJson(
    Map<String, dynamic> json, {
    bool previewRequired = false,
  }) {
    final JsonMapReader reader = JsonMapReader(json);
    final String slug = reader.requiredString('slug');
    if (slug == '.' || slug == '..' || slug.contains('/')) {
      throw const FormatException('Invalid news slug.');
    }
    final DateTime date = DateTime.parse(reader.requiredString('published_at'));
    final Uri uri = Uri(
      scheme: 'https',
      host: 'osu.ppy.sh',
      pathSegments: <String>['home', 'news', slug],
    );
    Uri? coverUri;
    for (final String key in <String>['first_image@2x', 'first_image']) {
      final String? value = reader.optionalString(key);
      if (value == null) continue;
      coverUri = PublicWebLink.resolve(value, base: uri);
      if (coverUri != null) break;
    }
    final Object? preview = json['preview'];
    if ((previewRequired && preview is! String) ||
        (preview != null && preview is! String)) {
      throw const FormatException('Invalid news preview.');
    }
    return NewsPostDto._(
      NewsPost(
        id: reader.requiredInt('id', positive: true),
        title: reader.requiredString('title'),
        author: reader.requiredString('author'),
        publishedAt: date,
        uri: uri,
        coverUri: coverUri,
        preview: preview as String?,
      ),
    );
  }
  final NewsPost _post;
  NewsPost toDomain() => _post;
}
