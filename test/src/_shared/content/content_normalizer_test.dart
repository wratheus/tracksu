import 'package:flutter_test/flutter_test.dart';
import 'package:tracksu/src/_shared/content/data/content_normalizer.dart';
import 'package:tracksu/src/_shared/content/domain/content_document.dart';

final Uri _base = Uri.https('osu.ppy.sh', '/home/news/2026-10-03-x');

List<ContentBlock> _blocks(String html) =>
    ContentNormalizer.html(html, _base).blocks;

void main() {
  test('featured artist audio and the showcase video become players', () {
    final List<ContentBlock> blocks = _blocks('''
<div align="center"><video width="95%" controls>
  <source src="https://assets.ppy.sh/artists/571/release_showcase.mp4" type="video/mp4">
</video></div>
<audio controls>
  <source src="https://assets.ppy.sh/artists/571/Songs/adamyes%20-%20Just%20Disappear.mp3">
</audio>''');
    final ContentVideo video = blocks.whereType<ContentVideo>().single;
    expect(video.uri.path, '/artists/571/release_showcase.mp4');
    final ContentAudio audio = blocks.whereType<ContentAudio>().single;
    expect(audio.track.title, 'adamyes - Just Disappear');
  });

  test('track updates with more than 32 previews still open', () {
    final String html = List<String>.generate(
      40,
      (int i) =>
          '<audio controls><source src="https://assets.ppy.sh/artists/1/t$i.mp3"></audio>',
    ).join();
    expect(_blocks(html).whereType<ContentAudio>(), hasLength(40));
  });

  test('YouTube iframes open the watch page, other embeds their URL', () {
    final List<ContentBlock> blocks = _blocks(
      '<iframe src="https://www.youtube.com/embed/dQw4w9WgXcQ?rel=0"></iframe>'
      '<iframe src="https://player.twitch.tv/?video=1&parent=osu.ppy.sh"></iframe>',
    );
    final List<ContentEmbed> embeds = blocks.whereType<ContentEmbed>().toList();
    expect(embeds.first.youtubeId, 'dQw4w9WgXcQ');
    expect(
      embeds.first.uri,
      Uri.parse('https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
    );
    expect(
      embeds.first.thumbnail,
      Uri.parse('https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg'),
    );
    expect(embeds.last.youtubeId, isNull);
    expect(embeds.last.uri.host, 'player.twitch.tv');
  });

  test('videos outside assets.ppy.sh are not played inline', () {
    final List<ContentBlock> blocks = _blocks(
      '<video src="https://example.com/a.mp4"></video>'
      '<video src="http://assets.ppy.sh/a.mp4"></video>',
    );
    expect(blocks.whereType<ContentVideo>(), isEmpty);
    expect(blocks.whereType<ContentUnsupported>(), hasLength(2));
  });
}
