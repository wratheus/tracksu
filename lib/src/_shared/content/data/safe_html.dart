import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;
import 'package:tracksu/src/_shared/content/domain/public_web_link.dart';

/// Rebuild a text-only allowlisted tree. Never pass server attributes to Flutter.
abstract final class SafeHtml {
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
  };
  static const Set<String> _drop = <String>{
    'script',
    'style',
    'iframe',
    'object',
    'embed',
    'svg',
    'math',
    'form',
    'input',
    'button',
    'textarea',
    'select',
    'video',
    'audio',
    'source',
    'link',
    'meta',
    'base',
    'template',
    'noscript',
  };
  static String sanitize(String source, Uri base) {
    final DocumentFragment output = DocumentFragment();
    void copy(Node node, Node parent, int depth) {
      if (depth > 100) {
        throw const FormatException('HTML is too deeply nested.');
      }
      if (node is Text) {
        parent.nodes.add(Text(node.data));
        return;
      }
      if (node is! Element) return;
      final String tag = node.localName ?? '';
      if (_drop.contains(tag)) return;
      if (tag == 'img') {
        final String? alt = node.attributes['alt'];
        if (alt != null && alt.isNotEmpty) parent.nodes.add(Text(alt));
        return;
      }
      final Node target;
      if (_allowed.contains(tag)) {
        final Element element = Element.tag(tag);
        if (tag == 'a') {
          final Uri? uri = PublicWebLink.resolve(
            node.attributes['href'] ?? '',
            base: base,
          );
          if (uri != null) element.attributes['href'] = uri.toString();
        }
        parent.nodes.add(element);
        target = element;
      } else {
        target = parent;
      }
      for (final Node child in node.nodes) {
        copy(child, target, depth + 1);
      }
    }

    if (source.length > 2000000) {
      throw const FormatException('HTML is too large.');
    }
    for (final Node node in html.parseFragment(source).nodes) {
      copy(node, output, 0);
    }
    return output.outerHtml;
  }
}
