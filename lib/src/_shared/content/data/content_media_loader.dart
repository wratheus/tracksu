import 'dart:async';
import 'dart:typed_data';

import 'package:tracksu/src/_shared/media/data/media_cache_repository.dart';
import 'package:tracksu/src/_shared/media/data/media_download.dart';

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
      request.cancel();
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
    } on Object {
      if (!request._result.isCompleted) {
        request._result.completeError(const MediaDownloadFailure());
      }
    } finally {
      _requests.remove(request);
    }
  }

  void close() {
    _closed = true;
    for (final request in _requests) {
      request.cancel();
    }
    _requests.clear();
  }
}

final class ContentMediaRequest {
  ContentMediaRequest._();
  final Completer<Uint8List> _result = Completer<Uint8List>();
  Future<Uint8List> get bytes => _result.future;
  void cancel() {
    if (!_result.isCompleted) {
      _result.completeError(const MediaDownloadFailure());
    }
  }
}
