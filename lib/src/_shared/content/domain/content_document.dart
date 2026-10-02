import 'package:meta/meta.dart';
import 'package:tracksu/src/_shared/audio/domain/audio_track.dart';

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
  const ContentImage(
    super.id, {
    required this.uri,
    required this.alt,
    this.width,
    this.height,
  }) : assert(width == null || width > 0),
       assert(height == null || height > 0);

  /// null preserves a blocked image's position/alternative text without a fetch.
  final Uri? uri;
  final String alt;

  /// Authored layout size in CSS px (bounded by the normalizer), not the
  /// decoded raster size. null means the intrinsic image size applies.
  final int? width;
  final int? height;
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

final class ContentAudio extends ContentBlock {
  const ContentAudio(super.id, this.track);
  final AudioTrack track;
}
