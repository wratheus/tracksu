import 'dart:convert';

import 'package:tracksu/src/_shared/content/data/content_normalizer.dart';
import 'package:tracksu/src/_shared/content/domain/content_document.dart';

/// Bounded BBCode adapter. All output passes through the existing allowlist;
/// never interpret raw HTML, scripts, CSS or embedded players from user input.
abstract final class BbcodeContent {
  static ContentDocument parse(String source, Uri base) {
    if (source.length > 200000) {
      throw const FormatException('BBCode too large.');
    }
    final StringBuffer output = StringBuffer();
    final List<({String tag, String close})> stack = [];
    final RegExp tokens = RegExp(
      r'\[(/?)([a-z*]+)(?:=([^\]]*))?\]',
      caseSensitive: false,
    );
    final List<RegExpMatch> matches = tokens.allMatches(source).toList();
    if (matches.length > 4000) {
      throw const FormatException('Too many BBCode tags.');
    }
    // Index closing tokens once, using original string offsets (Unicode case
    // conversion can change string length). Malformed tags must not cause
    // repeated full-document searches on the UI isolate.
    final Map<String, List<int>> endings = <String, List<int>>{};
    final Map<String, int> cursors = <String, int>{};
    for (final RegExpMatch match in matches) {
      if (match[1] == '/' && match[3] == null) {
        endings
            .putIfAbsent(match[2]!.toLowerCase(), () => <int>[])
            .add(match.start);
      }
    }
    String escape(String value) => const HtmlEscape().convert(value);
    void text(String value) =>
        output.write(escape(value).replaceAll('\n', '<br>'));
    int offset = 0;
    for (int i = 0; i < matches.length; i++) {
      final RegExpMatch match = matches[i];
      if (match.start < offset) continue;
      text(source.substring(offset, match.start));
      offset = match.end;
      final String tag = match[2]!.toLowerCase();
      final String? arg = match[3];
      if (match[1] == '/') {
        if (stack.isNotEmpty && stack.last.tag == tag) {
          output.write(stack.removeLast().close);
        } else {
          text(match[0]!);
        }
        continue;
      }
      // URL/image/code bodies are consumed as data, never recursively parsed.
      if (tag == 'img' || tag == 'code' || (tag == 'url' && arg == null)) {
        final List<int> positions = endings[tag] ?? const <int>[];
        int cursor = cursors[tag] ?? 0;
        while (cursor < positions.length && positions[cursor] < offset) {
          cursor++;
        }
        cursors[tag] = cursor;
        final int end = cursor < positions.length ? positions[cursor] : -1;
        if (end < 0) {
          text(match[0]!);
          continue;
        }
        final String body = source.substring(offset, end);
        output.write(switch (tag) {
          'img' => '<img src="${escape(body.trim())}" alt="">',
          'url' => '<a href="${escape(body.trim())}">${escape(body)}</a>',
          _ => '<pre><code>${escape(body)}</code></pre>',
        });
        offset = end + tag.length + 3;
        continue;
      }
      final (String, String)? pair = switch (tag) {
        'b' => ('<strong>', '</strong>'),
        'i' => ('<em>', '</em>'),
        'u' => ('<u>', '</u>'),
        's' => ('<s>', '</s>'),
        'center' => ('<center>', '</center>'),
        'quote' => ('<blockquote>', '</blockquote>'),
        'url' when arg != null => ('<a href="${escape(arg)}">', '</a>'),
        'color' when arg != null => (
          '<span style="color:${escape(arg)}">',
          '</span>',
        ),
        'size' when arg != null && int.tryParse(arg) != null => (
          '<span style="font-size:${int.parse(arg).clamp(85, 150)}%">',
          '</span>',
        ),
        'spoiler' || 'box' => (
          '<details><summary>${escape(arg ?? '')}</summary>',
          '</details>',
        ),
        'list' when arg == '1' => ('<ol>', '</ol>'),
        'list' => ('<ul>', '</ul>'),
        _ => null,
      };
      if (tag == '*' && stack.isNotEmpty && stack.last.tag == 'list') {
        // HTML list-item end tags are optional: the parser closes each item
        // at the next <li> or its parent list, including nested BBCode lists.
        output.write('<li>');
      } else if (pair != null) {
        if (stack.length >= 24) {
          throw const FormatException('BBCode nesting too deep.');
        }
        output.write(pair.$1);
        stack.add((tag: tag, close: pair.$2));
      } else {
        text(match[0]!);
      }
    }
    text(source.substring(offset));
    for (final entry in stack.reversed) {
      output.write(entry.close);
    }
    return ContentNormalizer.html(output.toString(), base);
  }
}
