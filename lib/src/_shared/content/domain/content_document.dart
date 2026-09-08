import 'package:meta/meta.dart';

/// Repository-normalized content. Never carries executable HTML or credentials.
@immutable
final class ContentDocument {
  ContentDocument({required this.uri, required List<ContentBlock> blocks})
    : blocks = List<ContentBlock>.unmodifiable(blocks);
  final Uri uri;
  final List<ContentBlock> blocks;
}

@immutable
sealed class ContentBlock {
  const ContentBlock(this.id);
  final int id;
}

final class ContentText extends ContentBlock {
  const ContentText(super.id, this.html, {this.horizontal = false});
  final String html;
  final bool horizontal;
}

final class ContentImage extends ContentBlock {
  const ContentImage(super.id, {required this.uri, required this.alt});

  /// null preserves a blocked image's position/alternative text without a fetch.
  final Uri? uri;
  final String alt;
}

final class ContentDisclosure extends ContentBlock {
  ContentDisclosure(
    super.id, {
    required this.title,
    required List<ContentBlock> children,
  }) : children = List<ContentBlock>.unmodifiable(children);
  final String title;
  final List<ContentBlock> children;
}

final class ContentUnsupported extends ContentBlock {
  const ContentUnsupported(super.id);
}
