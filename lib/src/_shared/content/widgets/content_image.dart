import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/content/data/content_media_loader.dart';
import 'package:tracksu/src/_shared/content/domain/content_document.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Mounted lazily by ContentFrame. Owns decoding, not transport policy.
final class ContentImageView extends StatefulWidget {
  const ContentImageView({
    required this.image,
    required this.loader,
    super.key,
  });
  final ContentImage image;
  final ContentMediaLoader loader;
  @override
  State<ContentImageView> createState() => _ContentImageViewState();
}

final class _ContentImageViewState extends State<ContentImageView> {
  ContentMediaRequest? _request;
  ui.Image? _image;
  bool _failed = false;
  bool _viewer = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(ContentImageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.loader, widget.loader) && _image == null) {
      _request?.cancel();
      _failed = false;
      _load();
    }
  }

  void _load() {
    final Uri? uri = widget.image.uri;
    if (uri == null) {
      _failed = true;
      return;
    }
    final ContentMediaRequest request = widget.loader.load(uri);
    _request = request;
    unawaited(_decode(request));
  }

  Future<void> _decode(ContentMediaRequest request) async {
    ui.ImmutableBuffer? buffer;
    ui.ImageDescriptor? descriptor;
    ui.Codec? codec;
    try {
      final Uint8List bytes = await request.bytes;
      if (!mounted || _request != request) return;
      buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      final int width = descriptor.width;
      final int height = descriptor.height;
      if (width <= 0 ||
          height <= 0 ||
          width > 8192 ||
          height > 8192 ||
          width * height > 16000000) {
        throw const ContentMediaFailure();
      }
      if (!mounted || _request != request) return;
      final double ratio = math.min(1, 2048 / math.max(width, height));
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
      setState(() => _image = frame.image);
    } on Object {
      if (mounted && _request == request) setState(() => _failed = true);
    } finally {
      codec?.dispose();
      descriptor?.dispose();
      buffer?.dispose();
    }
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

  @override
  Widget build(BuildContext context) {
    final String label = widget.image.alt.isEmpty
        ? context.t.contentImage
        : widget.image.alt;
    return UiSurface.inset(
      onTap: _image == null ? null : _open,
      padding: const EdgeInsets.all(UiSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: UiSpace.sm,
        children: <Widget>[
          // Fixed slot avoids reflow of a long document when images finish.
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _image != null
                ? Semantics(
                    image: true,
                    label: label,
                    child: RawImage(image: _image, fit: BoxFit.contain),
                  )
                : Center(
                    child: _failed
                        ? const Icon(Icons.broken_image_outlined)
                        : const CircularProgressIndicator(),
                  ),
          ),
          UiText.bodySmall(
            _failed
                ? widget.image.uri == null
                      ? context.t.contentImageUnsupported
                      : context.t.contentImageFailed
                : _image == null
                ? context.t.contentImageLoading
                : label,
            secondary: true,
            maxLines: 3,
          ),
          if (_failed && widget.image.uri != null)
            UiButton.text(
              label: context.t.retry,
              onPressed: () {
                setState(() => _failed = false);
                _load();
              },
            ),
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
