import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;
import 'package:markdown/markdown.dart' as md;

/// Markdown → HTML for the one content pipeline (format adapter →
/// [ContentNormalizer] allowlist → `ContentFrame`). Output is never trusted:
/// raw HTML inside Markdown is still filtered by the normalizer.
abstract final class MarkdownContent {
  static const int _maxSource = 500000;

  /// A whole Markdown document (osu! wiki): GitHub-flavoured tables, lists,
  /// code, strikethrough and autolinks. YAML front matter is dropped; osu!
  /// containers (`::: Infobox`, `::: Notice`) become quote boxes.
  static String document(String source) {
    if (source.length > _maxSource) {
      throw const FormatException('Markdown too large.');
    }
    final String body = source
        .replaceFirst(RegExp(r'^---\r?\n[\s\S]*?\r?\n---\r?\n'), '');
    return md.markdownToHtml(
      _containers(body),
      extensionSet: md.ExtensionSet.gitHubFlavored,
    );
  }

  static final RegExp _fence = RegExp(r'^\s{0,3}(```|~~~)');
  static final RegExp _container = RegExp(r'^\s{0,3}:::\s*(\S.*)?$');

  /// osu! wiki containers are `::: Name` … `:::` blocks. Each open block
  /// prefixes its lines with `> `, so the content pipeline renders a quote
  /// box; fenced code is left alone and unclosed blocks end with the text.
  static String _containers(String source) {
    final List<String> lines = source.split('\n');
    final StringBuffer output = StringBuffer();
    int depth = 0;
    bool code = false;
    for (final String raw in lines) {
      final String line = raw.endsWith('\r')
          ? raw.substring(0, raw.length - 1)
          : raw;
      final RegExpMatch? container = code ? null : _container.firstMatch(line);
      if (container != null) {
        if (container.group(1) != null) {
          if (depth < 4) depth += 1;
        } else if (depth > 0) {
          depth -= 1;
        }
        output.writeln(depth > 0 ? '> ' * depth : '');
        continue;
      }
      if (_fence.hasMatch(line)) code = !code;
      final String text = code ? line : _osuInline(line);
      output.writeln(depth > 0 ? '${'> ' * depth}$text' : text);
    }
    return output.toString();
  }

  // osu! inline containers (osu-web CustomContainerInline):
  // `::{ flag=NL }::`, `::{ user=2 }peppy::` or `::peppy::{ user=2 }`;
  // other attributes keep only the text.
  static final RegExp _inlineBefore = RegExp(r'::\{([^}\n]*)\}(.*?)::');
  static final RegExp _inlineAfter = RegExp(r'::([^:\n]+?)::\{([^}\n]*)\}');
  static final RegExp _attribute = RegExp(r'([a-z]+)=([^\s}]+)');

  static String _osuInline(String line) {
    if (!line.contains('::')) return line;
    return line
        .replaceAllMapped(
          _inlineBefore,
          (Match match) => _inlineContainer(match.group(1)!, match.group(2)!),
        )
        .replaceAllMapped(
          _inlineAfter,
          (Match match) => _inlineContainer(match.group(2)!, match.group(1)!),
        );
  }

  /// A flag becomes its emoji (regional indicators, no image request); a
  /// user becomes a profile link the app opens natively.
  static String _inlineContainer(String attributes, String text) {
    final Map<String, String> values = <String, String>{
      for (final RegExpMatch match in _attribute.allMatches(attributes))
        match.group(1)!: match.group(2)!,
    };
    final String? flag = values['flag']?.toUpperCase();
    if (flag != null && RegExp(r'^[A-Z]{2}$').hasMatch(flag)) {
      final String emoji = String.fromCharCodes(<int>[
        for (final int unit in flag.codeUnits) 0x1F1E6 + unit - 0x41,
      ]);
      return text.trim().isEmpty ? emoji : '$emoji $text';
    }
    final String? user = values['user'];
    if (user != null && RegExp(r'^[1-9][0-9]{0,11}$').hasMatch(user)) {
      return '[${text.trim().isEmpty ? user : text}]'
          '(https://osu.ppy.sh/users/$user)';
    }
    return text;
  }

  static final RegExp _hint = RegExp(
    r'(\*\*|__|~~|`|\]\(https?://|^\s*#{1,6}\s|^\s*[-*+]\s|^\s*>\s|^\s*\d{1,3}[.)]\s)',
    multiLine: true,
  );

  /// Markdown typed as plain text inside HTML that osu! rendered from
  /// BBCode (profile "About me"): osu! shows `**bold**` or `# Title`
  /// literally. Lines are split at `<br>`; line-start syntax becomes
  /// headings, quotes and lists, inline syntax applies to text outside links
  /// and code. HTML without Markdown hints is returned unchanged.
  static String inHtml(String html) {
    if (html.length > _maxSource) return html;
    final DocumentFragment fragment = parser.parseFragment(html);
    if (!_hint.hasMatch(_textWithBreaks(fragment))) return html;
    _apply(fragment);
    return fragment.outerHtml;
  }

  static String _textWithBreaks(Node node) {
    final StringBuffer buffer = StringBuffer();
    void walk(Node current) {
      if (current is Text) buffer.write(current.data);
      if (current is Element && current.localName == 'br') buffer.write('\n');
      current.nodes.forEach(walk);
    }

    walk(node);
    return buffer.toString();
  }

  static const Set<String> _verbatim = <String>{'a', 'code', 'pre'};

  static final RegExp _heading = RegExp(r'^\s*(#{1,6})\s+');
  static final RegExp _quote = RegExp(r'^\s*>\s?');
  static final RegExp _bullet = RegExp(r'^\s*[-*+]\s+');
  static final RegExp _ordered = RegExp(r'^\s*\d{1,3}[.)]\s+');
  static final RegExp _rule = RegExp(r'^\s*([-*_])(\s*\1){2,}\s*$');

  static void _apply(Node parent) {
    for (final Node child in parent.nodes.toList()) {
      if (child is Element && !_verbatim.contains(child.localName)) {
        _apply(child);
      }
    }
    if (parent is Element && _verbatim.contains(parent.localName)) return;

    // Lines of inline nodes separated by <br>; block children stay as they are.
    final List<Node> source = parent.nodes.toList();
    final List<Node> output = <Node>[];
    Element? list;
    List<Node> line = <Node>[];

    void closeList() => list = null;

    void emitLine({required bool br}) {
      final Text? first = line.isNotEmpty && line.first is Text
          ? line.first as Text
          : null;
      final String start = first?.data ?? '';
      Element? block;
      RegExp? marker;
      if (first != null && _rule.hasMatch(start) && line.length == 1) {
        closeList();
        output.add(Element.tag('hr'));
        line = <Node>[];
        return;
      }
      if (first != null) {
        if (_heading.firstMatch(start) case final RegExpMatch match) {
          block = Element.tag('h${match.group(1)!.length.clamp(2, 6)}');
          marker = _heading;
        } else if (_quote.hasMatch(start)) {
          block = Element.tag('blockquote');
          marker = _quote;
        } else if (_bullet.hasMatch(start) || _ordered.hasMatch(start)) {
          final bool ordered = _ordered.hasMatch(start);
          final String tag = ordered ? 'ol' : 'ul';
          if (list == null || list!.localName != tag) {
            list = Element.tag(tag);
            output.add(list!);
          }
          block = Element.tag('li');
          marker = ordered ? _ordered : _bullet;
          first.data = start.replaceFirst(marker, '');
          _inline(line);
          block.nodes.addAll(line);
          list!.nodes.add(block);
          line = <Node>[];
          return;
        }
      }
      closeList();
      if (block != null && marker != null) {
        first!.data = start.replaceFirst(marker, '');
        _inline(line);
        block.nodes.addAll(line);
        output.add(block);
      } else {
        _inline(line);
        output.addAll(line);
        if (br) output.add(Element.tag('br'));
      }
      line = <Node>[];
    }

    for (final Node node in source) {
      node.remove();
      if (node is Element && node.localName == 'br') {
        emitLine(br: true);
      } else if (node is Element && _isBlock(node)) {
        if (line.isNotEmpty) emitLine(br: false);
        closeList();
        output.add(node);
      } else {
        line.add(node);
      }
    }
    if (line.isNotEmpty) emitLine(br: false);
    parent.nodes.addAll(output);
  }

  static bool _isBlock(Element element) => const <String>{
    'div',
    'p',
    'ul',
    'ol',
    'li',
    'blockquote',
    'pre',
    'table',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'hr',
    'center',
    'details',
  }.contains(element.localName);

  /// Inline Markdown on the plain text nodes of one line.
  static void _inline(List<Node> line) {
    for (int i = 0; i < line.length; i++) {
      final Node node = line[i];
      if (node is! Text || !_hint.hasMatch(node.data)) continue;
      // The inline renderer trims; spaces next to other nodes must survive.
      final String data = node.data;
      final String lead = RegExp(r'^\s*').firstMatch(data)!.group(0)!;
      final String trail = RegExp(r'\s*$').firstMatch(data)!.group(0)!;
      final String html = md.markdownToHtml(
        data.trim(),
        inlineOnly: true,
        extensionSet: md.ExtensionSet.gitHubFlavored,
      );
      final List<Node> parsed = <Node>[
        if (lead.isNotEmpty) Text(lead),
        ...parser.parseFragment(html).nodes,
        if (trail.isNotEmpty) Text(trail),
      ];
      for (final Node part in parsed) {
        part.remove();
      }
      line
        ..removeAt(i)
        ..insertAll(i, parsed);
      i += parsed.length - 1;
    }
  }
}
