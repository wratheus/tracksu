import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:tracksu/src/_shared/media/data/media_cache_repository.dart';
import 'package:tracksu/src/_shared/media/data/media_download.dart';

/// The loader is closed or has no repository (covered/background route); the
/// image is not broken and a new loader loads it on resume. Carries no URL.
final class ContentMediaSuspended implements Exception {
  const ContentMediaSuspended();
}

/// View-local cancellation. Repository owns deduplication and bounded transport.
/// Leaving a view may finish caching its already requested public image.
final class ContentMediaLoader {
  ContentMediaLoader({this.repository});
  final MediaCacheRepository? repository;
  final Set<ContentMediaRequest> _requests = {};
  bool _closed = false;

  ContentMediaRequest load(Uri uri) {
    final request = ContentMediaRequest._();
    if (_closed || repository == null) {
      request._fail(const ContentMediaSuspended());
    } else {
      _requests.add(request);
      unawaited(_load(uri, request));
    }
    return request;
  }

  Future<void> _load(Uri uri, ContentMediaRequest request) async {
    try {
      final Uint8List bytes = await repository!.image(uri);
      if (!request._result.isCompleted) request._result.complete(bytes);
    } on Object catch (error, stackTrace) {
      if (!request._result.isCompleted) {
        request._result.completeError(_classify(error), stackTrace);
      }
    } finally {
      _requests.remove(request);
    }
  }

  /// Keeps an existing typed failure and maps only expected transport errors;
  /// platform messages, hosts and URLs never leave this boundary.
  static MediaDownloadFailure _classify(Object error) => switch (error) {
    MediaDownloadFailure() => error,
    TimeoutException() => const MediaDownloadFailure(
      MediaFailureReason.timeout,
    ),
    SocketException() || TlsException() || HttpException() =>
      const MediaDownloadFailure(MediaFailureReason.connection),
    _ => const MediaDownloadFailure(),
  };

  void close() {
    _closed = true;
    for (final request in _requests) {
      request._fail(const ContentMediaSuspended());
    }
    _requests.clear();
  }
}

final class ContentMediaRequest {
  ContentMediaRequest._();
  final Completer<Uint8List> _result = Completer<Uint8List>();
  Future<Uint8List> get bytes => _result.future;
  void _fail(Exception failure) {
    if (!_result.isCompleted) _result.completeError(failure);
  }

  void cancel() {
    if (!_result.isCompleted) {
      _result.completeError(
        const MediaDownloadFailure(MediaFailureReason.cancelled),
      );
    }
  }
}
