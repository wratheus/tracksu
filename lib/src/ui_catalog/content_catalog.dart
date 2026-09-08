import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/content/data/content_normalizer.dart';
import 'package:tracksu/src/_shared/content/domain/content_document.dart';
import 'package:tracksu/src/_shared/content/widgets/content_frame.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Manual, offline content sample. Links show a snack; no remote images/requests.
final class ContentCatalogSliver extends StatelessWidget {
  const ContentCatalogSliver({super.key});
  static final ContentDocument _document = ContentNormalizer.html(
    '''<div><center><h2>Tracksu · コンテンツ</h2>
<p><b>Playstyle</b> — Tablet<br><span style="color:#ff0066">PP / Performance</span></p>
<p><a href="https://osu.ppy.sh/">osu!</a> · <i>Rich text</i> · <u>Underline</u></p></center>
<div class="bbcode-spoilerbox"><button class="bbcode-spoilerbox__link">Collabs</button>
<div class="bbcode-spoilerbox__body"><p>Hidden until expanded.</p>
<span class="spoiler">Nested spoiler · 隠しテキスト</span>
<img src="data:image/png,blocked" alt="Offline blocked image sample"></div></div>
<blockquote>Quote · Цитата · 引用</blockquote><ul><li>One</li><li>Two</li></ul>
<pre>code &lt;not executable&gt;</pre><iframe src="https://example.com/"></iframe></div>''',
    Uri.https('osu.ppy.sh', '/'),
  );

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.all(UiSpace.lg),
    sliver: SliverMainAxisGroup(
      slivers: <Widget>[
        SliverToBoxAdapter(child: UiText.titleLarge(context.t.profileAbout)),
        ContentFrame.sliver(
          document: _document,
          onOpenLink: (_) async {
            UiFeedback.snack(context, message: context.t.uiCatalogSampleNotice);
            return true;
          },
        ),
      ],
    ),
  );
}
