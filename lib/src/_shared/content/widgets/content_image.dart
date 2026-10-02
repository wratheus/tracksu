import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/content/data/content_media_loader.dart';
import 'package:tracksu/src/_shared/media/data/media_download.dart';
import 'package:tracksu/src/_shared/content/domain/content_document.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Why an image is not shown. Terminal faults cannot be fixed by Retry.
enum _ImageFault {
  unavailable(retryable: false),
  blocked(retryable: false),
  suspended(retryable: false),
  unsupportedFormat(retryable: false),
  tooLarge(retryable: false),
  network(retryable: true),
  unknown(retryable: true);

  const _ImageFault({required this.retryable});
  final bool retryable;

  static _ImageFault of(Object error) => switch (error) {
    MediaDownloadFailure(:final reason, :final status) => switch (reason) {
      MediaFailureReason.httpStatus => switch (status) {
        404 || 410 => unavailable,
        408 || 429 || != null && >= 500 => network,
        _ => unknown,
      },
      MediaFailureReason.blocked ||
      MediaFailureReason.redirectRejected => blocked,
      MediaFailureReason.tooLarge => tooLarge,
      MediaFailureReason.invalidFormat => unsupportedFormat,
      MediaFailureReason.connection || MediaFailureReason.timeout => network,
      MediaFailureReason.unavailable ||
      MediaFailureReason.redirectLimit ||
      MediaFailureReason.cancelled => unknown,
    },
    ContentMediaSuspended() => suspended,
    _ => unknown,
  };

  String message(BuildContext context) => switch (this) {
    unavailable => context.t.contentImageUnavailable,
    blocked => context.t.contentImageUnsupported,
    suspended => context.t.contentImagePaused,
    unsupportedFormat => context.t.contentImageFormat,
    tooLarge => context.t.contentImageTooLarge,
    network => context.t.contentImageNetwork,
    unknown => context.t.contentImageFailed,
  };
}

/// Mounted lazily by ContentFrame. Owns decoding, not transport policy.
final class ContentImageView extends StatefulWidget {
  const ContentImageView({required this.image, required this.loader, super.key})
    : _preview = false;
  const ContentImageView.preview({
    required this.image,
    required this.loader,
    super.key,
  }) : _preview = true;
  final ContentImage image;
  final ContentMediaLoader loader;
  final bool _preview;
  @override
  State<ContentImageView> createState() => _ContentImageViewState();
}

final class _ContentImageViewState extends State<ContentImageView> {
  ContentMediaRequest? _request;
  ui.Image? _image;

  /// Original raster size before bounded downsampling; defines layout size.
  Size? _intrinsic;
  _ImageFault? _fault;
  bool _viewer = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(ContentImageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image.uri != widget.image.uri) {
      _image?.dispose();
      _image = null;
      _intrinsic = null;
      _load();
      return;
    }
    if (!identical(oldWidget.loader, widget.loader) && _image == null) {
      _load();
    }
  }

  /// Supersedes any previous request before every branch, so an old result or
  /// error can never be applied to the new image.
  void _load() {
    _request?.cancel();
    _request = null;
    _fault = null;
    final Uri? uri = widget.image.uri;
    if (uri == null) {
      _fault = _ImageFault.blocked;
      return;
    }
    final ContentMediaRequest request = widget.loader.load(uri);
    _request = request;
    unawaited(_decode(request, uri));
  }

  void _retry() {
    setState(_load);
  }

  Future<void> _decode(ContentMediaRequest request, Uri uri) async {
    ui.ImmutableBuffer? buffer;
    ui.ImageDescriptor? descriptor;
    ui.Codec? codec;
    // Set only when ImageDescriptor.encoded itself rejects fetched bytes. The
    // public API exposes no typed corruption error, so the stage is the only
    // evidence; buffer allocation, codec/frame creation and context failures
    // stay unknown (retryable) and keep the cache entry.
    bool corrupt = false;
    try {
      final Uint8List bytes;
      try {
        bytes = await request.bytes;
      } on Object catch (error) {
        if (mounted && _request == request) {
          setState(() => _fault = _ImageFault.of(error));
        }
        return;
      }
      if (!mounted || _request != request) return;
      buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      try {
        descriptor = await ui.ImageDescriptor.encoded(buffer);
      } on Exception {
        // Only Exception: an Error (e.g. out of memory) is not corruption. The
        // engine reports opaque failures as Exception, so a transient native
        // failure at this stage is still treated as corrupt (known limit).
        corrupt = true;
        rethrow;
      }
      final int width = descriptor.width;
      final int height = descriptor.height;
      if (width <= 0 ||
          height <= 0 ||
          width > 16384 ||
          height > 16384 ||
          width * height > 40000000) {
        throw const MediaDownloadFailure(MediaFailureReason.tooLarge);
      }
      if (!mounted || _request != request) return;
      final double ratio = _decodeScale(width, height);
      codec = await descriptor.instantiateCodec(
        targetWidth: math.max(1, (width * ratio).round()),
        targetHeight: math.max(1, (height * ratio).round()),
      );
      final ui.FrameInfo frame = await codec.getNextFrame();
      // GIF/WebP animation is intentionally static, including in the viewer.
      if (!mounted || _request != request) {
        frame.image.dispose();
        return;
      }
      setState(() {
        _image = frame.image;
        _intrinsic = Size(width.toDouble(), height.toDouble());
      });
    } on Object catch (error) {
      if (mounted && _request == request) {
        final _ImageFault fault = corrupt
            ? _ImageFault.unsupportedFormat
            : _ImageFault.of(error);
        // Show the failure first: Retry must not decode the same bad bytes, so
        // the cached entry goes, but only for the URI this request fetched.
        setState(() => _fault = fault);
        if (corrupt) {
          try {
            await widget.loader.repository?.evictImage(uri);
          } on Object {
            // A cache eviction failure must not mask the failed image state.
          }
        }
      }
    } finally {
      codec?.dispose();
      descriptor?.dispose();
      buffer?.dispose();
    }
  }

  /// Decode no larger than the biggest possible display (screen box in device
  /// pixels, 2x headroom for the zoom viewer), never above the source and
  /// always under long-side and total-pixel caps.
  double _decodeScale(int width, int height) {
    final Size screen = MediaQuery.sizeOf(context);
    final double dpr = MediaQuery.devicePixelRatioOf(context);
    final double boxWidth = screen.width * dpr;
    double scale = widget._preview
        ? math.max(boxWidth / width, boxWidth * 9 / 16 / height)
        : 2 * math.min(boxWidth / width, screen.height * dpr / height);
    final int longSide = widget._preview ? 1024 : 4096;
    scale = math.min(scale, longSide / math.max(width, height));
    scale = math.min(scale, math.sqrt(8000000 / (width * height)));
    return math.min(1, scale);
  }

  @override
  void dispose() {
    _request?.cancel();
    _image?.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    if (_viewer || _image == null) return;
    _viewer = true;
    try {
      await UiImageViewer.show(
        context,
        image: _image!,
        closeLabel: MaterialLocalizations.of(context).closeButtonTooltip,
        imageLabel: widget.image.alt.isEmpty
            ? context.t.contentImage
            : widget.image.alt,
      );
    } finally {
      _viewer = false;
    }
  }

  /// Downscale-only. The raster keeps its intrinsic aspect ratio; authored
  /// width/height are only maxima and never exceed the intrinsic size, the
  /// column or the screen height. Until decoded, a bounded placeholder
  /// (authored ratio if given) reserves space; the source ratio then takes over.
  Widget _inline(BuildContext context, BoxConstraints box, String label) {
    final ui.Image? image = _image;
    final Size? intrinsic = _intrinsic;
    final int? authoredWidth = widget.image.width;
    final int? authoredHeight = widget.image.height;
    final double maxHeight = MediaQuery.sizeOf(context).height;
    final double maxWidth = box.maxWidth.isFinite
        ? box.maxWidth
        : MediaQuery.sizeOf(context).width;
    if (image == null || intrinsic == null) {
      // A failed image must not reserve the authored or placeholder area.
      if (_fault != null) {
        return const Center(
          heightFactor: 1,
          child: Icon(Icons.broken_image_outlined, size: 32),
        );
      }
      final double aspect = authoredWidth != null && authoredHeight != null
          ? (authoredWidth / authoredHeight).clamp(0.25, 4.0)
          : 16 / 9;
      // Bound both axes before layout; never smaller than the indicator.
      final double width = math.max(
        48,
        math.min(authoredWidth?.toDouble() ?? maxWidth, maxWidth),
      );
      final double height = (width / aspect).clamp(
        48.0,
        math.max(48.0, math.min(maxHeight * 0.5, 320.0)),
      );
      return Center(
        heightFactor: 1,
        child: SizedBox(
          width: math.min(width, math.max(48, height * aspect)),
          height: height,
          child: const Center(
            child: SizedBox.square(
              dimension: 32,
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );
    }
    final double aspect = intrinsic.width / intrinsic.height;
    double width = math.min(intrinsic.width, maxWidth);
    if (authoredWidth != null) {
      width = math.min(width, authoredWidth.toDouble());
    }
    if (authoredHeight != null) {
      width = math.min(width, authoredHeight * aspect);
    }
    if (width / aspect > maxHeight) width = maxHeight * aspect;
    // Integer upscaling of small pixel art stays crisp; downscaling smooths.
    final double scale =
        width * MediaQuery.devicePixelRatioOf(context) / image.width;
    return Center(
      heightFactor: 1,
      child: Semantics(
        image: true,
        label: label,
        child: RawImage(
          image: image,
          width: width,
          height: width / aspect,
          fit: BoxFit.contain,
          filterQuality: scale >= 2 ? FilterQuality.none : FilterQuality.medium,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String label = widget.image.alt.isEmpty
        ? context.t.contentImage
        : widget.image.alt;
    final _ImageFault? fault = _fault;
    if (widget._preview) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          // Placeholder color only until decoded, then a one-off fade-in; no
          // spinner flash for fast cache hits.
          child: _image != null
              ? UiReveal(
                  child: Semantics(
                    image: true,
                    label: label,
                    child: RawImage(image: _image, fit: BoxFit.cover),
                  ),
                )
              : fault != null
              ? Center(
                  child: fault.retryable
                      ? Semantics(
                          label: fault.message(context),
                          child: UiIconButton.standard(
                            tooltip: context.t.retry,
                            icon: Icons.refresh,
                            onPressed: _retry,
                          ),
                        )
                      : Semantics(
                          label: fault.message(context),
                          child: const Icon(Icons.broken_image_outlined),
                        ),
                )
              : Semantics(
                  label: context.t.contentImageLoading,
                  child: const SizedBox.expand(),
                ),
        ),
      );
    }
    return UiSurface.inset(
      onTap: _image == null ? null : _open,
      padding: const EdgeInsets.all(UiSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: UiSpace.sm,
        children: <Widget>[
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints box) =>
                _inline(context, box, label),
          ),
          UiText.bodySmall(
            fault != null
                ? fault.message(context)
                : _image == null
                ? context.t.contentImageLoading
                : label,
            secondary: true,
            maxLines: 3,
          ),
          if (_fault?.retryable ?? false)
            UiButton.text(label: context.t.retry, onPressed: _retry),
          if (_image != null)
            UiButton.text(
              label: context.t.contentImageOpen,
              icon: Icons.zoom_in,
              onPressed: _open,
            ),
        ],
      ),
    );
  }
}
