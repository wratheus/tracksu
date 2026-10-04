import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/content/domain/content_document.dart';
import 'package:tracksu/src/_shared/media/widgets/app_media.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Card for a third-party player the app does not embed. YouTube gets its
/// thumbnail (when images are allowed) and opens in the YouTube app or the
/// browser; other players show their host and open the embed page.
final class ContentEmbedCard extends StatelessWidget {
  const ContentEmbedCard({
    required this.embed,
    required this.onOpenLink,
    super.key,
  });
  final ContentEmbed embed;
  final Future<bool> Function(String url) onOpenLink;

  @override
  Widget build(BuildContext context) {
    final bool youtube = embed.youtubeId != null;
    final String label = youtube
        ? context.t.contentEmbedYoutube
        : context.t.contentEmbedOpen(embed.uri.host);
    if (!youtube) {
      return UiSurface.inset(
        child: UiTile.navigation(
          leading: const Icon(Icons.smart_display_outlined),
          title: label,
          onTap: () => onOpenLink(embed.uri.toString()),
        ),
      );
    }
    final ImageProvider? thumbnail = AppMedia.image(context, embed.thumbnail);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(UiShape.card),
        child: Material(
          color: Colors.black,
          child: InkWell(
            onTap: () => onOpenLink(embed.uri.toString()),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  if (thumbnail != null)
                    Image(image: thumbnail, fit: BoxFit.cover),
                  Center(
                    child: UiGlass(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: UiSpace.lg,
                          vertical: UiSpace.sm,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: UiSpace.sm,
                          children: <Widget>[
                            const Icon(
                              Icons.play_arrow_rounded,
                              color: UiGlass.onGlass,
                            ),
                            UiText.labelLarge(label, color: UiGlass.onGlass),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
