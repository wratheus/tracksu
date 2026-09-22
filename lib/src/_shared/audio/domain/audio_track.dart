/// Only osu!-hosted MP3s are playable in-app. Other embeds keep their original
/// page link. No arbitrary hosts, credentials, manifests, scripts or local URLs.
final class AudioTrack {
  const AudioTrack._(this.uri, this.title);
  final Uri uri;
  final String title;

  static AudioTrack? resolve(String source, {Uri? base, String title = ''}) {
    if (source.isEmpty || source.length > 2048) return null;
    final Uri? parsed = Uri.tryParse(source.trim());
    if (parsed == null) return null;
    final Uri uri = base == null ? parsed : base.resolveUri(parsed);
    if (uri.scheme != 'https' ||
        uri.userInfo.isNotEmpty ||
        uri.port != 443 ||
        uri.hasQuery ||
        uri.hasFragment) {
      return null;
    }
    final List<String> parts = uri.pathSegments;
    if (parts.any((String part) =>
        part == '..' || part == '.' || part.contains('\\'))) {
      return null;
    }
    final bool preview = uri.host == 'b.ppy.sh' &&
        RegExp(r'^/preview/[1-9][0-9]*\.mp3$').hasMatch(uri.path);
    final bool artist = uri.host == 'assets.ppy.sh' &&
        parts.length >= 3 &&
        parts.first == 'artists' &&
        RegExp(r'^[1-9][0-9]*$').hasMatch(parts[1]) &&
        parts.last.toLowerCase().endsWith('.mp3');
    if (!preview && !artist) return null;
    final String label = title.trim().isNotEmpty
        ? title.trim()
        : artist
        ? parts.last.substring(0, parts.last.length - 4)
        : '';
    return AudioTrack._(uri, label.substring(0, label.length.clamp(0, 200)));
  }
}
