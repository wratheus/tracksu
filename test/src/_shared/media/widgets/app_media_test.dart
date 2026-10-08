import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracksu/src/_shared/content/content_media_controller.dart';
import 'package:tracksu/src/_shared/media/data/media_cache_repository.dart';
import 'package:tracksu/src/_shared/media/data/media_download.dart';
import 'package:tracksu/src/_shared/media/widgets/app_media.dart';
import 'package:tracksu_storage/tracksu_storage.dart';

/// Lets a test make the engine image decoder fail like an opaque native error.
final class _DecoderBinding extends AutomatedTestWidgetsFlutterBinding {
  Object? failure;

  @override
  Future<ui.Codec> instantiateImageCodecWithSize(
    ui.ImmutableBuffer buffer, {
    ui.TargetImageSizeCallback? getTargetSize,
  }) {
    final Object? failure = this.failure;
    if (failure == null) {
      return super.instantiateImageCodecWithSize(
        buffer,
        getTargetSize: getTargetSize,
      );
    }
    buffer.dispose();
    return Future<ui.Codec>.error(failure);
  }
}

final class _Store implements ContentMediaStore {
  @override
  Future<bool?> readPermission() async => null;

  @override
  Future<void> writePermission(bool allowed) async {}
}

final Uint8List _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

/// Valid 1x1 GIF whose logical screen claims 20000 px of width.
final Uint8List _wideGif = Uint8List.fromList(<int>[
  ...ascii.encode('GIF89a'),
  0x20, 0x4E, 0x01, 0x00, 0x80, 0x00, 0x00, //
  0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, //
  0x2C, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, //
  0x02, 0x02, 0x44, 0x01, 0x00, 0x3B,
]);

void main() {
  final _DecoderBinding binding = _DecoderBinding();
  late Directory root;
  late MediaCacheRepository repository;
  late ContentMediaController controller;

  setUp(() {
    root = Directory.systemTemp.createTempSync('tracksu_app_media_test');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall call) async => root.path,
        );
    repository = MediaCacheRepository();
    controller = ContentMediaController(
      store: _Store(),
      repository: repository,
    );
  });

  tearDown(() {
    binding.failure = null;
    PaintingBinding.instance.imageCache.clear();
    controller.dispose();
    repository.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
    root.deleteSync(recursive: true);
  });

  File seed(Uri uri, List<int> bytes) {
    final Directory directory = Directory('${root.path}/tracksu_media_v1')
      ..createSync(recursive: true);
    return File(
      '${directory.path}/${sha256.convert(utf8.encode(uri.toString()))}.image',
    )..writeAsBytesSync(bytes);
  }

  Future<ImageProvider> provider(WidgetTester tester, Uri uri) async {
    ImageProvider? image;
    await tester.pumpWidget(
      AppMedia(
        controller: controller,
        child: Builder(
          builder: (BuildContext context) {
            image = AppMedia.image(context, uri);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    return image!;
  }

  /// Null when the image decoded; otherwise the reported error.
  Future<Object?> resolve(ImageProvider image) async {
    final Completer<Object?> result = Completer<Object?>();
    final ImageStream stream = image.resolve(ImageConfiguration.empty);
    final ImageStreamListener listener = ImageStreamListener(
      (ImageInfo info, bool _) {
        info.dispose();
        if (!result.isCompleted) result.complete(null);
      },
      onError: (Object error, StackTrace? _) {
        if (!result.isCompleted) result.complete(error);
      },
    );
    stream.addListener(listener);
    try {
      return await result.future.timeout(const Duration(seconds: 10));
    } finally {
      stream.removeListener(listener);
    }
  }

  testWidgets('a healthy cached image decodes from disk', (
    WidgetTester tester,
  ) async {
    final Uri uri = Uri.parse('https://a.ppy.sh/1');
    seed(uri, _png);
    final ImageProvider image = await provider(tester, uri);

    final Object? error = await tester.runAsync<Object?>(() => resolve(image));

    expect(error, isNull);
  });

  for (final (String name, Object failure) in <(String, Object)>[
    ('Exception', Exception('opaque native codec failure')),
    ('Error', StateError('opaque native codec failure')),
  ]) {
    testWidgets('decoder $name keeps healthy disk bytes and is safe', (
      WidgetTester tester,
    ) async {
      final Uri uri = Uri.parse('https://a.ppy.sh/2?$name');
      final File file = seed(uri, _png);
      final ImageProvider image = await provider(tester, uri);
      binding.failure = failure;

      final Object? error = await tester.runAsync<Object?>(
        () => resolve(image),
      );

      expect(
        error,
        isA<MediaDownloadFailure>().having(
          (MediaDownloadFailure failure) => failure.reason,
          'reason',
          MediaFailureReason.unavailable,
        ),
      );
      expect('$error', isNot(contains('opaque')));
      expect('$error', isNot(contains('ppy.sh')));
      expect(file.existsSync(), isTrue);
      expect(file.readAsBytesSync(), _png);
      expect(repository.sizeBytes, _png.length);
    });
  }

  testWidgets('oversized dimensions fail as tooLarge without eviction', (
    WidgetTester tester,
  ) async {
    final Uri uri = Uri.parse('https://a.ppy.sh/3');
    final File file = seed(uri, _wideGif);
    final ImageProvider image = await provider(tester, uri);

    final Object? error = await tester.runAsync<Object?>(() => resolve(image));

    expect(
      error,
      isA<MediaDownloadFailure>().having(
        (MediaDownloadFailure failure) => failure.reason,
        'reason',
        MediaFailureReason.tooLarge,
      ),
    );
    expect(file.existsSync(), isTrue);
    expect(repository.sizeBytes, _wideGif.length);
  });

  testWidgets('an upstream typed failure is surfaced unchanged', (
    WidgetTester tester,
  ) async {
    final Uri uri = Uri.parse('https://a.ppy.sh/4');
    final File file = seed(uri, _png);
    final ImageProvider image = await provider(tester, uri);
    repository.setImagesAllowed(false);

    final Object? error = await tester.runAsync<Object?>(() => resolve(image));

    expect(identical(error, const MediaDownloadFailure()), isTrue);
    expect(file.existsSync(), isTrue);
  });
}
