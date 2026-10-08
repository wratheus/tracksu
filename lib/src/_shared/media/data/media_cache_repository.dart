import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tracksu/src/_shared/audio/domain/audio_track.dart';
import 'package:tracksu/src/_shared/media/data/media_download.dart';
import 'package:tracksu/src/_shared/media/data/vorbis_wav.dart';

/// On-disk audio containers in lookup order. WAV is only ever written by the
/// local Vorbis decoder; a downloaded payload must be MP3 or Ogg Vorbis.
enum _AudioFile { wav, mp3, ogg }

/// App-owned public media only. Atomic disk writes, coalesced requests, bounded
/// concurrency and LRU; no API payloads, tokens, URL index or cookies on disk.
final class MediaCacheRepository extends ChangeNotifier {
  static const int capacityBytes = 128 * 1024 * 1024;
  static const Duration maxAge = Duration(days: 7);

  /// Previews are replayed within a session, rarely days later, and decoded
  /// Ogg → WAV files are large: audio keeps a short life and its own budget.
  static const int audioCapacityBytes = 24 * 1024 * 1024;
  static const Duration audioMaxAge = Duration(hours: 12);

  static bool _isAudioFile(String name) => _audioSuffix.hasMatch(name);

  static bool _expired(String name, DateTime modified) =>
      DateTime.now().difference(modified) >
      (_isAudioFile(name) ? audioMaxAge : maxAge);

  int get _audioBytes => _entries.entries
      .where((e) => _isAudioFile(e.key))
      .fold<int>(0, (int sum, e) => sum + e.value.size);

  bool get _overBudget =>
      _bytes > capacityBytes ||
      _entries.length > 500 ||
      _audioBytes > audioCapacityBytes;

  /// iOS AVFoundation has no Vorbis decoder: there an Ogg payload is stored as
  /// locally decoded PCM WAV. Other platforms play Ogg natively.
  static final bool _decodesVorbis = Platform.isIOS;
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
  Future<void> _decoding = Future<void>.value();
  int get sizeBytes => _bytes;

  /// Off: images stay in memory only, and an audio file lives on disk just
  /// while it plays (decoded Ogg needs a file) and is deleted afterwards.
  bool _diskCacheEnabled = true;
  bool get diskCacheEnabled => _diskCacheEnabled;

  /// Turning the cache off deletes what is stored; the caller stops playback
  /// first, as for [clear].
  Future<void> setDiskCacheEnabled(bool enabled) async {
    if (enabled == _diskCacheEnabled) return;
    _diskCacheEnabled = enabled;
    if (!enabled) await clear();
    _changed();
  }
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
          if (!RegExp(r'^[a-f0-9]{64}\.(image|mp3|ogg|wav)(\.part)?$')
              .hasMatch(name)) {
            continue;
          }
          final FileStat stat = await entity.stat();
          if (name.endsWith('.part') ||
              stat.size == 0 ||
              !_diskCacheEnabled ||
              _expired(name, stat.modified)) {
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

  /// Logical identity (pins, coalescing, downloads). Audio files on disk carry
  /// a format suffix, so use [_logical] to map a file name back to this key.
  static String _key(Uri uri, bool audio) =>
      '${sha256.convert(utf8.encode(uri.toString()))}.${audio ? 'audio' : 'image'}';

  static final RegExp _audioSuffix = RegExp(r'\.(mp3|ogg|wav)$');

  static String _logical(String fileName) =>
      fileName.replaceFirst(_audioSuffix, '.audio');

  static String _audioFile(String key, _AudioFile file) =>
      '${key.substring(0, key.length - 'audio'.length)}${file.name}';

  /// Existing entry for a logical audio key, whichever container it holds.
  String? _audioEntry(String key) {
    for (final _AudioFile file in _AudioFile.values) {
      final String name = _audioFile(key, file);
      if (_entries.containsKey(name)) return name;
    }
    return null;
  }

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
      return CachedAudio._(data.file?.path, data.format, () => _unpin(key));
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
    if (!_diskCacheEnabled && count <= 0 && !_closed && !_clearing) {
      unawaited(
        _serial(() async {
          final String? name = _audioEntry(key);
          if (name == null || _pins.containsKey(key)) return;
          try {
            await _remove(name);
          } on FileSystemException {
            // Startup cleanup deletes leftovers while the cache is off.
          } finally {
            _changed();
          }
        }),
      );
      return;
    }
    if (!_closed && !_clearing && _overBudget) {
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
        throw const MediaDownloadFailure(MediaFailureReason.cancelled);
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
    final ({File file, MediaAudioFormat? format, bool playable})? cached =
        !diskAvailable
        ? null
        : await _serial(() async {
            check();
            final String? name = audio ? _audioEntry(key) : key;
            final entry = name == null ? null : _entries[name];
            if (name == null || entry == null) return null;
            final FileStat stat = await entry.file.stat();
            if (stat.type != FileSystemEntityType.file ||
                _expired(name, stat.modified)) {
              await _remove(name);
              _changed();
              return null;
            }
            final bool wav = audio && name.endsWith('.wav');
            // Older builds named every audio payload `.mp3`: trust bytes only.
            final MediaAudioFormat? format = !audio
                ? null
                : wav
                ? MediaAudioFormat.ogg
                : MediaDownload.detectAudio(await _head(entry.file));
            if (audio && format == null) {
              await _remove(name);
              _changed();
              return null;
            }
            _entries.remove(name);
            _entries[name] = entry;
            // Keep write time for absolute expiry; reading must not make an avatar
            // immortal. In-process access order is maintained by the linked map.
            return (
              file: entry.file,
              format: format,
              playable:
                  wav || format != MediaAudioFormat.ogg || !_decodesVorbis,
            );
          });
    if (cached != null && cached.playable) {
      return _MediaData.disk(cached.file, cached.format);
    }
    return _slot(() async {
      check();
      ({Uint8List bytes, MediaAudioFormat? format})? payload;
      if (cached != null) {
        if (await _readPayload(cached.file) case final Uint8List bytes) {
          payload = (bytes: bytes, format: cached.format);
        }
        check();
      }
      payload ??= await _download(uri, key, audio: audio, check: check);
      check();
      return _store(
        key,
        payload,
        audio: audio,
        diskAvailable: diskAvailable,
        check: check,
      );
    });
  }

  /// Bounds full payloads held at once: a slot covers the cached read or
  /// download, the queued Vorbis decode and the atomic write. Holders never
  /// wait for another slot, and [_serial]/[_decoding] work never takes one.
  Future<T> _slot<T>(Future<T> Function() action) async {
    if (_active >= 4) {
      final Completer<void> slot = Completer<void>();
      _waiting.add(slot);
      await slot.future;
    } else {
      _active++;
    }
    try {
      return await action();
    } finally {
      if (_waiting.isNotEmpty) {
        _waiting.removeFirst().complete();
      } else {
        _active--;
      }
    }
  }

  Future<_MediaData> _store(
    String key,
    ({Uint8List bytes, MediaAudioFormat? format}) payload, {
    required bool audio,
    required bool diskAvailable,
    required void Function() check,
  }) async {
    final MediaAudioFormat? format = payload.format;
    final bool decode = format == MediaAudioFormat.ogg && _decodesVorbis;
    Uint8List bytes = payload.bytes;
    if (decode) {
      // The remote Vorbis URL is not playable either: no local file, no audio.
      if (!diskAvailable) throw const MediaDownloadFailure();
      bytes = await _decodeVorbis(bytes, check);
      check();
    }
    if (!diskAvailable || !audio && !_diskCacheEnabled) {
      return _MediaData.memory(bytes);
    }
    // The file suffix follows the validated payload, never the URL.
    final String name = format == null
        ? key
        : _audioFile(
            key,
            decode
                ? _AudioFile.wav
                : switch (format) {
                    MediaAudioFormat.mp3 => _AudioFile.mp3,
                    MediaAudioFormat.ogg => _AudioFile.ogg,
                  },
          );
    return _serial(() async {
      check();
      final File partial = File('${_directory!.path}/$name.part');
      try {
        // The OS may reclaim its cache directory during a running session.
        await _directory!.create(recursive: true);
        await partial.writeAsBytes(bytes, flush: true);
        check();
        if (audio) {
          // A stale sibling container for the same identity must not linger.
          for (final _AudioFile other in _AudioFile.values) {
            final String sibling = _audioFile(key, other);
            if (sibling != name) await _remove(sibling);
          }
        }
        final File file = await partial.rename('${_directory!.path}/$name');
        _bytes -= _entries.remove(name)?.size ?? 0;
        _entries[name] = (file: file, size: bytes.length);
        _bytes += bytes.length;
        try {
          await _trim(protect: key);
        } on FileSystemException {
          // Keep a usable new file and report real bytes if eviction failed.
        }
        _changed();
        return _MediaData.disk(file, format);
      } on FileSystemException {
        // Images use the validated bytes and MP3/native Ogg falls back to
        // streaming; decoded Vorbis has no playable remote equivalent.
        if (decode) throw const MediaDownloadFailure();
        return _MediaData.memory(bytes);
      } finally {
        try {
          if (await partial.exists()) await partial.delete();
        } on FileSystemException {
          // Startup cleanup retries orphaned partial files.
        }
      }
    });
  }

  Future<({Uint8List bytes, MediaAudioFormat? format})> _download(
    Uri uri,
    String key, {
    required bool audio,
    required void Function() check,
  }) async {
    MediaDownload? download;
    try {
      check();
      download = MediaDownload(uri, audio: audio);
      _downloads[key] = download;
      final Uint8List bytes = await download.load().timeout(
        const Duration(seconds: 40),
        onTimeout: () {
          download?.cancel();
          throw const MediaDownloadFailure(MediaFailureReason.timeout);
        },
      );
      return (bytes: bytes, format: download.audioFormat);
    } finally {
      download?.cancel();
      _downloads.remove(key);
    }
  }

  /// One native decode at a time, off the UI isolate. A started decode cannot
  /// be cancelled: [clear] awaits it through [_pending] and the caller's
  /// revision check discards its result, so nothing obsolete is written.
  Future<Uint8List> _decodeVorbis(Uint8List ogg, void Function() check) {
    final Future<Uint8List> result = _decoding.then((_) {
      check();
      return compute(vorbisToWav, ogg, debugLabel: 'Tracksu Vorbis decode');
    });
    _decoding = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  /// Enough leading bytes for [MediaDownload.detectAudio]; unreadable is empty.
  static Future<Uint8List> _head(File file) async {
    try {
      final RandomAccessFile handle = await file.open();
      try {
        return await handle.read(512);
      } finally {
        await handle.close();
      }
    } on FileSystemException {
      return Uint8List(0);
    }
  }

  /// Whole cached payload sized from the open file, never more than the
  /// download cap. Null when unreadable or oversized: download it again and
  /// let the new file replace the entry.
  static Future<Uint8List?> _readPayload(File file) async {
    try {
      final RandomAccessFile handle = await file.open();
      try {
        final int length = await handle.length();
        if (length > MediaDownload.maxAudioBytes) return null;
        return await handle.read(length);
      } finally {
        await handle.close();
      }
    } on FileSystemException {
      return null;
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
    // Oldest audio first while audio alone exceeds its budget.
    int audioBytes = _audioBytes;
    for (final String key in _entries.keys.toList()) {
      if (audioBytes <= audioCapacityBytes) break;
      if (!_isAudioFile(key)) continue;
      final String logical = _logical(key);
      if (logical == protect ||
          _pins.containsKey(logical) ||
          _pending.containsKey(logical)) {
        continue;
      }
      audioBytes -= _entries[key]!.size;
      await _remove(key);
    }
    for (final String key in _entries.keys.toList()) {
      if (_bytes <= capacityBytes && _entries.length <= 500) break;
      final String logical = _logical(key);
      if (logical == protect ||
          _pins.containsKey(logical) ||
          _pending.containsKey(logical)) {
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
  CachedAudio._(this.path, this.format, this._release);

  /// Null means disk storage was unavailable; playback may stream the URL.
  /// Never null for Vorbis on iOS, where [path] is a locally decoded WAV.
  final String? path;

  /// Payload container validated from the downloaded bytes.
  final MediaAudioFormat? format;
  final VoidCallback _release;
  bool _released = false;
  void release() {
    if (_released) return;
    _released = true;
    _release();
  }
}

final class _MediaData {
  const _MediaData.disk(this.file, this.format) : bytes = null;
  const _MediaData.memory(this.bytes) : file = null, format = null;
  final File? file;
  final MediaAudioFormat? format;
  final Uint8List? bytes;
}
