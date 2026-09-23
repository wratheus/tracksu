import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tracksu/src/_shared/audio/domain/audio_track.dart';
import 'package:tracksu/src/_shared/media/data/media_download.dart';

/// App-owned public media only. Atomic disk writes, coalesced requests, bounded
/// concurrency and LRU; no API payloads, tokens, URL index or cookies on disk.
final class MediaCacheRepository extends ChangeNotifier {
  static const int capacityBytes = 128 * 1024 * 1024;
  static const Duration maxAge = Duration(days: 7);
  final LinkedHashMap<String, ({File file, int size})> _entries =
      LinkedHashMap();
  final Map<String, Future<_MediaData>> _pending = {};
  final Map<String, MediaDownload> _downloads = {};
  final Map<String, int> _pins = {};
  final Queue<Completer<void>> _waiting = Queue();
  int _active = 0;
  int _revision = 0;
  int _bytes = 0;
  bool _closed = false;
  bool _clearing = false;
  bool _imagesAllowed = true;
  Directory? _directory;
  Future<void>? _initializing;
  Future<void> _operations = Future<void>.value();
  int get sizeBytes => _bytes;
  int get revision => _revision;

  Future<T> _serial<T>(Future<T> Function() action) {
    final Future<T> result = _operations.then((_) => action());
    _operations = result.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return result;
  }

  Future<void> initialize() => _initializing ??=
      _serial(() async {
        final Directory root = await getApplicationCacheDirectory();
        final Directory directory = Directory('${root.path}/tracksu_media_v1');
        await directory.create(recursive: true);
        _directory = directory;
        final List<({File file, FileStat stat})> files = [];
        await for (final FileSystemEntity entity in directory.list(
          followLinks: false,
        )) {
          if (entity is! File) continue;
          final String name = entity.uri.pathSegments.last;
          if (!RegExp(r'^[a-f0-9]{64}\.(image|mp3)(\.part)?$').hasMatch(name)) {
            continue;
          }
          final FileStat stat = await entity.stat();
          if (name.endsWith('.part') ||
              stat.size == 0 ||
              DateTime.now().difference(stat.modified) > maxAge) {
            await entity.delete();
          } else {
            files.add((file: entity, stat: stat));
          }
        }
        files.sort((a, b) => a.stat.modified.compareTo(b.stat.modified));
        _entries.clear();
        _bytes = 0;
        for (final entry in files) {
          _entries[entry.file.uri.pathSegments.last] = (
            file: entry.file,
            size: entry.stat.size,
          );
          _bytes += entry.stat.size;
        }
        await _trim();
        _changed();
      }).onError((Object error, StackTrace stack) {
        _initializing = null;
        Error.throwWithStackTrace(error, stack);
      });

  static String _key(Uri uri, bool audio) =>
      '${sha256.convert(utf8.encode(uri.toString()))}.${audio ? 'mp3' : 'image'}';

  Future<Uint8List> image(Uri uri) async {
    if (!_imagesAllowed || _closed) throw const MediaDownloadFailure();
    final int revision = _revision;
    final String key = _key(uri, false);
    _pins.update(key, (int count) => count + 1, ifAbsent: () => 1);
    try {
      final _MediaData data = await _load(uri, audio: false);
      return await _serial(() async {
        if (!_imagesAllowed || revision != _revision || _closed) {
          throw const MediaDownloadFailure();
        }
        if (data.bytes case final Uint8List bytes) return bytes;
        try {
          return await data.file!.readAsBytes();
        } on FileSystemException {
          await _remove(key);
          rethrow;
        }
      });
    } finally {
      _unpin(key);
    }
  }

  /// A playing decoder pins its file until it has been disposed.
  Future<CachedAudio> audio(AudioTrack track) async {
    final String key = _key(track.uri, true);
    _pins.update(key, (int count) => count + 1, ifAbsent: () => 1);
    try {
      final _MediaData data = await _load(track.uri, audio: true);
      return CachedAudio._(data.file?.path, () => _unpin(key));
    } on Object {
      _unpin(key);
      rethrow;
    }
  }

  void _unpin(String key) {
    final int count = (_pins[key] ?? 1) - 1;
    if (count <= 0) {
      _pins.remove(key);
    } else {
      _pins[key] = count;
    }
    if (!_closed &&
        !_clearing &&
        (_bytes > capacityBytes || _entries.length > 500)) {
      unawaited(
        _serial(() async {
          try {
            await _trim();
          } on FileSystemException {
            // A later cache operation retries cleanup; keep the actual byte count.
          } finally {
            _changed();
          }
        }),
      );
    }
  }

  Future<_MediaData> _load(Uri uri, {required bool audio}) {
    if (_closed || _clearing || !audio && !_imagesAllowed) {
      return Future<_MediaData>.error(const MediaDownloadFailure());
    }
    final String key = _key(uri, audio);
    return _pending[key] ??= _fetch(uri, key, audio: audio).whenComplete(() {
      _pending.remove(key);
    });
  }

  Future<_MediaData> _fetch(Uri uri, String key, {required bool audio}) async {
    final int revision = _revision;
    void check() {
      if (_closed ||
          _clearing ||
          revision != _revision ||
          !audio && !_imagesAllowed) {
        throw const MediaDownloadFailure();
      }
    }

    bool diskAvailable = true;
    try {
      await initialize();
    } on FileSystemException {
      // Cache storage is an optimization, not a prerequisite for displaying media.
      diskAvailable = false;
    }
    check();
    final File? cached = !diskAvailable
        ? null
        : await _serial(() async {
            check();
            final entry = _entries[key];
            if (entry == null) return null;
            final FileStat stat = await entry.file.stat();
            if (stat.type != FileSystemEntityType.file ||
                DateTime.now().difference(stat.modified) > maxAge) {
              await _remove(key);
              _changed();
              return null;
            }
            _entries.remove(key);
            _entries[key] = entry;
            // Keep write time for absolute expiry; reading must not make an avatar
            // immortal. In-process access order is maintained by the linked map.
            return entry.file;
          });
    if (cached != null) return _MediaData.disk(cached);
    if (_active >= 4) {
      final Completer<void> slot = Completer<void>();
      _waiting.add(slot);
      await slot.future;
    } else {
      _active++;
    }
    MediaDownload? download;
    try {
      check();
      download = MediaDownload(uri, audio: audio);
      _downloads[key] = download;
      final Uint8List bytes = await download.load().timeout(
        const Duration(seconds: 40),
        onTimeout: () {
          download?.cancel();
          throw const MediaDownloadFailure();
        },
      );
      check();
      if (!diskAvailable) return _MediaData.memory(bytes);
      return await _serial(() async {
        check();
        final File partial = File('${_directory!.path}/$key.part');
        try {
          // The OS may reclaim its cache directory during a running session.
          await _directory!.create(recursive: true);
          await partial.writeAsBytes(bytes, flush: true);
          check();
          final File file = await partial.rename('${_directory!.path}/$key');
          _bytes -= _entries.remove(key)?.size ?? 0;
          _entries[key] = (file: file, size: bytes.length);
          _bytes += bytes.length;
          try {
            await _trim(protect: key);
          } on FileSystemException {
            // Keep a usable new file and report real bytes if eviction failed.
          }
          _changed();
          return _MediaData.disk(file);
        } on FileSystemException {
          // Images can use the validated bytes; audio falls back to streaming.
          return _MediaData.memory(bytes);
        } finally {
          try {
            if (await partial.exists()) await partial.delete();
          } on FileSystemException {
            // Startup cleanup retries orphaned partial files.
          }
        }
      });
    } finally {
      download?.cancel();
      _downloads.remove(key);
      if (_waiting.isNotEmpty) {
        _waiting.removeFirst().complete();
      } else {
        _active--;
      }
    }
  }

  Future<void> _remove(String key) async {
    final entry = _entries[key];
    if (entry == null) return;
    if (await entry.file.exists()) await entry.file.delete();
    _entries.remove(key);
    _bytes -= entry.size;
  }

  Future<void> _trim({String? protect}) async {
    for (final String key in _entries.keys.toList()) {
      if (_bytes <= capacityBytes && _entries.length <= 500) break;
      if (key == protect ||
          _pins.containsKey(key) ||
          _pending.containsKey(key)) {
        continue;
      }
      await _remove(key);
    }
  }

  Future<void> evictImage(Uri uri) async {
    await initialize();
    await _serial(() async {
      await _remove(_key(uri, false));
      _changed();
    });
  }

  void setImagesAllowed(bool allowed) {
    _imagesAllowed = allowed;
    if (!allowed) {
      for (final entry in _downloads.entries) {
        if (entry.key.endsWith('.image')) entry.value.cancel();
      }
    }
  }

  /// Caller stops playback first. Revision invalidation prevents stale writes.
  Future<void> clear() async {
    if (_clearing) return;
    _clearing = true;
    try {
      _revision++;
      for (final MediaDownload download in _downloads.values) {
        download.cancel();
      }
      await Future.wait(
        _pending.values.toList().map((Future<_MediaData> future) async {
          try {
            await future;
          } on Object {
            /* Cancelled obsolete download. */
          }
        }),
      );
      await initialize();
      await _serial(() async {
        try {
          for (final String key in _entries.keys.toList()) {
            await _remove(key);
          }
        } finally {
          _changed();
        }
      });
    } finally {
      _clearing = false;
    }
  }

  void _changed() {
    if (!_closed) notifyListeners();
  }

  @override
  void dispose() {
    _closed = true;
    _revision++;
    for (final MediaDownload download in _downloads.values) {
      download.cancel();
    }
    super.dispose();
  }
}

final class CachedAudio {
  CachedAudio._(this.path, this._release);

  /// Null means disk storage was unavailable; playback may stream the URL.
  final String? path;
  final VoidCallback _release;
  bool _released = false;
  void release() {
    if (_released) return;
    _released = true;
    _release();
  }
}

final class _MediaData {
  const _MediaData.disk(this.file) : bytes = null;
  const _MediaData.memory(this.bytes) : file = null;
  final File? file;
  final Uint8List? bytes;
}
