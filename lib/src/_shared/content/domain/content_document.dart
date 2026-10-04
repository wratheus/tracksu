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

/// A video file hosted by osu! (`assets.ppy.sh`), played inline on request.
final class ContentVideo extends ContentBlock {
  const ContentVideo(super.id, {required this.uri, this.poster});
  final Uri uri;

  /// Optional still frame from the `poster` attribute.
  final Uri? poster;

  /// Accepts only https files on assets.ppy.sh in formats both platforms
  /// decode natively; anything else stays an embed link or is unsupported.
  static Uri? resolve(String source, {required Uri base}) {
    if (source.isEmpty || source.length > 2048) return null;
    final Uri? parsed = Uri.tryParse(source.trim());
    if (parsed == null) return null;
    final Uri uri = base.resolveUri(parsed);
    if (uri.scheme != 'https' ||
        uri.host != 'assets.ppy.sh' ||
        uri.userInfo.isNotEmpty ||
        uri.hasPort && uri.port != 443 ||
        uri.hasQuery ||
        uri.hasFragment ||
        uri.pathSegments.any(
          (String part) => part == '..' || part == '.' || part.contains('\\'),
        ) ||
        !RegExp(r'\.(mp4|m4v|mov)$', caseSensitive: false).hasMatch(uri.path)) {
      return null;
    }
    return uri;
  }
}

/// A third-party player (YouTube, Twitch, …) that the app does not embed:
/// shown as a card that opens the page outside the app.
final class ContentEmbed extends ContentBlock {
  const ContentEmbed(super.id, {required this.uri, this.youtubeId});

  /// Page to open: the YouTube watch page for YouTube, else the embed URL.
  final Uri uri;
  final String? youtubeId;

  Uri? get thumbnail => youtubeId == null
      ? null
      : Uri.https('i.ytimg.com', '/vi/$youtubeId/hqdefault.jpg');

  static final RegExp _youtubeHost = RegExp(
    r'^(www\.)?(youtube\.com|youtube-nocookie\.com)$',
  );
  static final RegExp _youtubeId = RegExp(r'^[A-Za-z0-9_-]{11}$');

  static ContentEmbed? resolve(int id, Uri? source) {
    if (source == null) return null;
    final List<String> parts = source.pathSegments;
    if (_youtubeHost.hasMatch(source.host) &&
        parts.length == 2 &&
        parts.first == 'embed' &&
        _youtubeId.hasMatch(parts.last)) {
      return ContentEmbed(
        id,
        uri: Uri.https('www.youtube.com', '/watch', <String, String>{
          'v': parts.last,
        }),
        youtubeId: parts.last,
      );
    }
    return ContentEmbed(id, uri: source);
  }
}
