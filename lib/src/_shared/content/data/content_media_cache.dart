import 'dart:collection';
import 'dart:typed_data';

/// Validated raster bytes only, memory-only LRU shared by consent-aware readers.
final class ContentMediaCache {
  final LinkedHashMap<Uri, ({Uint8List bytes, DateTime saved})> _entries =
      LinkedHashMap<Uri, ({Uint8List bytes, DateTime saved})>();
  int _bytes = 0;
  int _revision = 0;
  int get revision => _revision;

  Uint8List? read(Uri uri) {
    final entry = _entries.remove(uri);
    if (entry == null) return null;
    if (DateTime.now().difference(entry.saved) > const Duration(minutes: 30)) {
      _bytes -= entry.bytes.length;
      return null;
    }
    _entries[uri] = entry;
    return entry.bytes;
  }

  void write(Uri uri, Uint8List bytes, {required int revision}) {
    if (revision != _revision || bytes.length > 8 * 1024 * 1024) return;
    _bytes -= _entries.remove(uri)?.bytes.length ?? 0;
    _entries[uri] = (bytes: bytes.asUnmodifiableView(), saved: DateTime.now());
    _bytes += bytes.length;
    while (_bytes > 24 * 1024 * 1024 || _entries.length > 100) {
      _bytes -= _entries.remove(_entries.keys.first)!.bytes.length;
    }
  }

  void clear() {
    _revision++;
    _entries.clear();
    _bytes = 0;
  }

  void remove(Uri uri) {
    _bytes -= _entries.remove(uri)?.bytes.length ?? 0;
  }
}
