import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:tracksu/src/_shared/content/content_media_controller.dart';
import 'package:tracksu/src/_shared/media/data/media_cache_repository.dart';
import 'package:tracksu/src/_shared/media/data/media_download.dart';

/// Opt-out invalidates all image consumers, including retained shell branches.
final class AppMedia extends InheritedNotifier<ContentMediaController> {
  const AppMedia({
    required ContentMediaController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static ImageProvider? image(BuildContext context, Uri? uri) {
    final ContentMediaController? controller = context
        .dependOnInheritedWidgetOfExactType<AppMedia>()
        ?.notifier;
    if (uri == null || controller == null || !controller.allowed) return null;
    return _CachedMediaImage(uri, controller.repository);
  }
}

final class _CachedMediaImage extends ImageProvider<_CachedMediaImage> {
  const _CachedMediaImage(this.uri, this.repository);
  final Uri uri;
  final MediaCacheRepository repository;

  @override
  Future<_CachedMediaImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<_CachedMediaImage>(this);

  @override
  ImageStreamCompleter loadImage(
    _CachedMediaImage key,
    ImageDecoderCallback decode,
  ) => MultiFrameImageStreamCompleter(codec: _decode(decode), scale: 1);

  Future<ui.Codec> _decode(ImageDecoderCallback decode) async {
    ui.ImageDescriptor? descriptor;
    ui.ImmutableBuffer? buffer;
    bool received = false;
    try {
      final Uint8List bytes = await repository.image(uri);
      received = true;
      buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      if (descriptor.width <= 0 ||
          descriptor.height <= 0 ||
          descriptor.width > 16384 ||
          descriptor.height > 16384 ||
          descriptor.width * descriptor.height > 40000000) {
        throw const MediaDownloadFailure();
      }
      descriptor.dispose();
      descriptor = null;
      final ui.ImmutableBuffer owned = buffer;
      buffer = null; // Flutter's decoder takes ownership of the buffer.
      return await decode(owned);
    } on Object {
      if (received) {
        try {
          await repository.evictImage(uri);
        } on Object {
          // A failed disk cleanup must not hide the original decode failure.
        }
      }
      // Error keys must be evictable on the next resolve/retry.
      scheduleMicrotask(() => PaintingBinding.instance.imageCache.evict(this));
      throw const MediaDownloadFailure();
    } finally {
      descriptor?.dispose();
      buffer?.dispose();
    }
  }

  @override
  bool operator ==(Object other) =>
      other is _CachedMediaImage &&
      other.uri == uri &&
      identical(other.repository, repository);
  @override
  int get hashCode => Object.hash(uri, repository);
}
