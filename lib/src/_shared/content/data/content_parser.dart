import 'package:tracksu/src/_shared/content/data/bbcode_content.dart';
import 'package:tracksu/src/_shared/content/data/content_normalizer.dart';
import 'package:tracksu/src/_shared/content/data/markdown_content.dart';
import 'package:tracksu/src/_shared/content/domain/content_document.dart';

/// Source formats osu! sends rich text in.
enum ContentFormat {
  /// Rendered by osu! (news, profile pages, beatmap descriptions, comments).
  html,

  /// Raw BBCode when no rendered HTML exists (team descriptions).
  bbcode,

  /// Markdown documents (wiki).
  markdown,
}

/// The single entry to rich content: every format is adapted to HTML, then
/// passes the same [ContentNormalizer] allowlist and renders in
/// `ContentFrame` with the same images, audio, video, links and spoilers.
abstract final class ContentParser {
  static ContentDocument parse(
    String source, {
    required ContentFormat format,
    required Uri base,
    bool markdownInText = false,
  }) => switch (format) {
    ContentFormat.html => ContentNormalizer.html(
      markdownInText ? MarkdownContent.inHtml(source) : source,
      base,
    ),
    ContentFormat.bbcode => BbcodeContent.parse(source, base),
    ContentFormat.markdown => ContentNormalizer.html(
      MarkdownContent.document(source),
      base,
    ),
  };
}
