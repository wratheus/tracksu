import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';

/// Bounded image decoding; no global cache mutation, headers or disk cache.
final class UiImage extends StatelessWidget {
  const UiImage({
    required this.image,
    required this.width,
    required this.height,
    this.fallbackIcon = Icons.image_outlined,
    this.semanticLabel,
    this.fallback,
    this.fit = BoxFit.cover,
    super.key,
  }) : assert(width > 0 && width < double.infinity),
       assert(height > 0 && height < double.infinity),
       _loading = false;

  const UiImage.loading({
    required this.width,
    required this.height,
    this.semanticLabel,
    super.key,
  }) : assert(width > 0 && width < double.infinity),
       assert(height > 0 && height < double.infinity),
       image = null,
       fit = BoxFit.cover,
       fallback = null,
       fallbackIcon = Icons.image_outlined,
       _loading = true;

  final ImageProvider? image;
  final double width;
  final double height;
  final IconData fallbackIcon;
  final String? semanticLabel;
  final Widget? fallback;
  final BoxFit fit;
  final bool _loading;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final double dpr = MediaQuery.devicePixelRatioOf(context);
    final Widget placeholder = ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Center(
        child: fallback ?? Icon(fallbackIcon, color: colors.onSurfaceVariant),
      ),
    );
    final ImageProvider? source = image;
    return Semantics(
      label: semanticLabel,
      image: semanticLabel != null,
      excludeSemantics: true,
      child: SizedBox(
        width: width,
        height: height,
        child: _loading
            ? ColoredBox(color: colors.surfaceContainerHighest)
            : source == null
            ? placeholder
            : Image(
                image: ResizeImage(
                  source,
                  width: (width * dpr).ceil().clamp(1, 2048),
                  height: (height * dpr).ceil().clamp(1, 2048),
                  policy: ResizeImagePolicy.fit,
                ),
                width: width,
                height: height,
                fit: fit,
                excludeFromSemantics: true,
                gaplessPlayback: false,
                errorBuilder: (_, _, _) => placeholder,
                // No byte-progress rebuilds or shimmer timers in image lists.
                frameBuilder: (_, Widget child, int? frame, bool sync) =>
                    sync || frame != null
                    ? child
                    : ColoredBox(color: colors.surfaceContainerHighest),
              ),
      ),
    );
  }
}

final class UiAvatar extends StatelessWidget {
  const UiAvatar.small({required this.name, this.image, super.key}) : size = 40;
  const UiAvatar.medium({required this.name, this.image, super.key})
    : size = 56;
  const UiAvatar.large({required this.name, this.image, super.key}) : size = 88;

  /// Used for a grapheme-safe fallback, not automatically repeated by TalkBack.
  final String name;
  final ImageProvider? image;
  final double size;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(UiShape.card),
    child: UiImage(
      image: image,
      width: size,
      height: size,
      fallbackIcon: Icons.person_outline,
      fallback: name.trim().isEmpty
          ? null
          : Text(
              name.trim().characters.first.toUpperCase(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
    ),
  );
}

/// The parent owns finite width; image never paints behind readable card text.
final class UiCover extends StatelessWidget {
  const UiCover({
    this.image,
    this.semanticLabel,
    this.aspectRatio = 16 / 9,
    super.key,
  }) : assert(aspectRatio > 0 && aspectRatio < double.infinity);
  final ImageProvider? image;
  final String? semanticLabel;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: aspectRatio,
    child: LayoutBuilder(
      builder: (_, BoxConstraints constraints) => UiImage(
        image: image,
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        semanticLabel: semanticLabel,
      ),
    ),
  );
}
