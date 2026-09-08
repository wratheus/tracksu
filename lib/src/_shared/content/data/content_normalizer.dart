import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;
import 'package:tracksu/src/_shared/content/domain/content_document.dart';
import 'package:tracksu/src/_shared/content/domain/public_web_link.dart';

/// An allowlist, not a browser/CSS engine. All image URLs leave the HTML path.
final class ContentNormalizer {
  ContentNormalizer._(this._base);
  final Uri _base;
  int _id = 0;
  int _nodes = 0;
  int _media = 0;
  int _cells = 0;

  static ContentDocument html(String source, Uri base) {
    if (source.length > 2000000) {
      throw const FormatException('Content too large.');
    }
    final ContentNormalizer normalizer = ContentNormalizer._(base);
    final DocumentFragment fragment = parser.parseFragment(source);
    normalizer._validate(fragment, 0);
    return ContentDocument(
      uri: base,
      blocks: normalizer._blocks(fragment.nodes, <Element>[]),
    );
  }

  void _validate(Node node, int depth) {
    if (++_nodes > 10000 || depth > 40) {
      throw const FormatException('Content too complex.');
    }
    if (node is Element &&
        const <String>{'td', 'th'}.contains(node.localName) &&
        ++_cells > 256) {
      throw const FormatException('Too many table cells.');
    }
    for (final Node child in node.nodes) {
      _validate(child, depth + 1);
    }
  }

  static const Set<String> _allowed = <String>{
    'p',
    'div',
    'span',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'br',
    'hr',
    'strong',
    'em',
    'b',
    'i',
    'u',
    's',
    'del',
    'blockquote',
    'pre',
    'code',
    'ul',
    'ol',
    'li',
    'a',
    'table',
    'thead',
    'tbody',
    'tr',
    'th',
    'td',
    'center',
  };
  static const Set<String> _drop = <String>{
    'script',
    'style',
    'object',
    'embed',
    'svg',
    'math',
    'form',
    'input',
    'button',
    'textarea',
    'select',
    'source',
    'link',
    'meta',
    'base',
    'template',
    'noscript',
  };
  static const Set<String> _embeds = <String>{'iframe', 'video', 'audio'};

  bool _disclosure(Element element) =>
      element.localName == 'details' ||
      element.classes.any(
        (String name) => const <String>{
          'bbcode-spoilerbox',
          'bbcode-spoiler',
          'spoilerbox',
          'spoiler',
        }.contains(name),
      );

  bool _special(Element element) =>
      element.localName == 'img' ||
      _disclosure(element) ||
      _embeds.contains(element.localName) ||
      element.children.any(_special);

  List<ContentBlock> _blocks(List<Node> nodes, List<Element> wrappers) {
    final List<ContentBlock> result = <ContentBlock>[];
    final DocumentFragment pending = DocumentFragment();
    void flush() {
      if (pending.nodes.isEmpty) return;
      final String value = pending.outerHtml;
      pending.nodes.clear();
      if (value.trim().isEmpty) return;
      if (value.length > 30000) {
        throw const FormatException('Content block too large.');
      }
      Node wrapped = parser.parseFragment(value);
      for (final Element wrapper in wrappers.reversed) {
        final Element outer = _shell(wrapper);
        outer.nodes.add(wrapped);
        wrapped = outer;
      }
      if (++_id > 2000) throw const FormatException('Too many content blocks.');
      final String html = wrapped is Element
          ? wrapped.outerHtml
          : (wrapped as DocumentFragment).outerHtml;
      result.add(
        ContentText(
          _id,
          html,
          horizontal: value.contains('<table') || value.contains('<pre'),
        ),
      );
    }

    for (final Node node in nodes) {
      if (node is! Element) {
        if (node is Text) pending.nodes.add(Text(node.data));
        continue;
      }
      if (_drop.contains(node.localName)) continue;
      if (node.localName == 'img') {
        flush();
        if (++_media > 64) throw const FormatException('Too many images.');
        result.add(
          ContentImage(
            ++_id,
            uri: PublicWebLink.resolve(
              node.attributes['src'] ?? '',
              base: _base,
            ),
            alt: (node.attributes['alt'] ?? '').substring(
              0,
              (node.attributes['alt'] ?? '').length.clamp(0, 300),
            ),
          ),
        );
      } else if (_embeds.contains(node.localName)) {
        flush();
        result.add(ContentUnsupported(++_id));
      } else if (_disclosure(node)) {
        flush();
        final Element? title = node.querySelector(
          'summary, .bbcode-spoilerbox__link, .bbcode-spoilerbox__button',
        );
        final Element? body = node.querySelector('.bbcode-spoilerbox__body');
        final String label = title?.text.trim() ?? '';
        result.add(
          ContentDisclosure(
            ++_id,
            title: label.length > 200 ? label.substring(0, 200) : label,
            children: _blocks(
              body?.nodes ??
                  node.nodes.where((Node n) => !identical(n, title)).toList(),
              wrappers,
            ),
          ),
        );
      } else if (const <String>{'div', 'center'}.contains(node.localName) ||
          _special(node)) {
        flush();
        result.addAll(
          _blocks(node.nodes, <Element>[
            ...wrappers,
            if (_allowed.contains(node.localName)) node,
          ]),
        );
      } else {
        final Node? clean = _clean(node);
        if (clean != null) pending.nodes.add(clean);
        // Keep paragraphs separate even inside a giant profile root container.
        if (const <String>{
          'p',
          'ul',
          'ol',
          'table',
          'pre',
          'blockquote',
          'h1',
          'h2',
          'h3',
          'h4',
          'h5',
          'h6',
        }.contains(node.localName)) {
          flush();
        }
      }
    }
    flush();
    return result;
  }

  Node? _clean(Node node) {
    if (node is Text) return Text(node.data);
    if (node is! Element || _drop.contains(node.localName)) return null;
    // Defense in depth: no native HTML media renderer ever sees a src.
    if (node.localName == 'img' || _embeds.contains(node.localName)) {
      return null;
    }
    final Element result = _shell(node);
    for (final Node child in node.nodes) {
      final Node? clean = _clean(child);
      if (clean != null) result.nodes.add(clean);
    }
    return result;
  }

  Element _shell(Element source) {
    final Element result = Element.tag(
      _allowed.contains(source.localName) ? source.localName! : 'span',
    );
    if (source.localName == 'a') {
      final Uri? uri = PublicWebLink.resolve(
        source.attributes['href'] ?? '',
        base: _base,
      );
      if (uri != null) result.attributes['href'] = uri.toString();
    }
    final Map<String, String> styles = <String, String>{};
    final int? headingScale = const <String, int>{
      'h1': 150,
      'h2': 140,
      'h3': 130,
      'h4': 120,
      'h5': 110,
      'h6': 100,
    }[source.localName];
    if (headingScale != null) {
      result.attributes['data-content-scale'] = '$headingScale';
    }
    if (source.localName == 'center') styles['text-align'] = 'center';
    final String? align = source.attributes['align'];
    if (const <String>{'left', 'center', 'right'}.contains(align)) {
      styles['text-align'] = align!;
    }
    final String rawStyle = source.attributes['style'] ?? '';
    for (final String declaration
        in (rawStyle.length > 2048 ? '' : rawStyle).split(';')) {
      final List<String> pair = declaration.split(':');
      if (pair.length != 2) continue;
      final String key = pair[0].trim().toLowerCase();
      final String value = pair[1].trim().toLowerCase();
      final Set<String>? values = const <String, Set<String>>{
        'text-align': <String>{'left', 'center', 'right'},
        'font-weight': <String>{'normal', 'bold', '400', '700'},
        'font-style': <String>{'normal', 'italic'},
        'text-decoration': <String>{'underline', 'line-through'},
      }[key];
      if (values?.contains(value) ?? false) styles[key] = value;
      if (key == 'font-size') {
        final RegExpMatch? match = RegExp(r'^(\d{1,3})(px|%)$')
            .firstMatch(value);
        if (match != null) {
          final int size = int.parse(match[1]!);
          // Theme-relative once at rendering, never compounded by nesting.
          result.attributes['data-content-scale'] = match[2] == '%'
              ? '${size.clamp(85, 150)}'
              : '${(size / 16 * 100).round().clamp(85, 150)}';
        }
      }
      if (key == 'color') {
        final String color =
            const <String, String>{
              'red': '#ff0000',
              'blue': '#0000ff',
              'green': '#008000',
              'yellow': '#ffff00',
              'white': '#ffffff',
              'black': '#000000',
              'pink': '#ffc0cb',
              'purple': '#800080',
              'orange': '#ffa500',
              'cyan': '#00ffff',
            }[value] ??
            value;
        if (RegExp(r'^#[0-9a-f]{6}$').hasMatch(color)) {
          result.attributes['data-content-color'] = color;
        }
      }
    }
    if (styles.isNotEmpty) {
      result.attributes['style'] = styles.entries
          .map((MapEntry<String, String> e) => '${e.key}:${e.value}')
          .join(';');
    }
    return result;
  }
}
