import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:tracksu/src/_shared/audio/domain/audio_track.dart';

/// Cancellable queued/active fetch; failure deliberately excludes remote URLs.
final class MediaDownload {
  MediaDownload(this._uri, {this.audio = false});
  final bool audio;
  final Uri _uri;
  HttpClient? _client;
  ConnectionTask<Socket>? _socket;
  Socket? _transport;
  bool _cancelled = false;
  void cancel() => _stop();

  void _stop() {
    if (_cancelled) return;
    _cancelled = true;
    _socket?.cancel();
    _transport?.destroy();
    _client?.close(force: true);
  }

  Future<Uint8List> load() async {
    final HttpClient client = HttpClient()
      ..autoUncompress = true
      ..connectionTimeout = const Duration(seconds: 5)
      ..findProxy = (_) => 'DIRECT';
    _client = client;
    // First-party CDNs use normal platform DNS/TLS, including VPN DNS.
    // Arbitrary rich-content hosts retain IP pinning against private targets.
    if (!_trustedHost(_uri.host)) {
      client.connectionFactory = (Uri uri, String? proxyHost, int? proxyPort) async {
        _checkUri(uri);
        if (_cancelled || proxyHost != null) {
          throw const MediaDownloadFailure();
        }
        final List<InternetAddress> addresses = await InternetAddress.lookup(
          uri.host,
        );
        // Validate the whole answer, then connect to the IP, not another DNS lookup.
        if (_cancelled ||
            addresses.isEmpty ||
            addresses.any((InternetAddress a) => !_publicAddress(a))) {
          throw const MediaDownloadFailure();
        }
        // A custom factory replaces HttpClient's TLS setup, not just DNS.
        // Pin the checked IP, but validate the certificate and SNI by hostname.
        return ConnectionTask.fromSocket(_connect(uri, addresses), () {
          _socket?.cancel();
          _transport?.destroy();
        });
      };
    }
    Uri uri = _uri;
    for (int redirect = 0; redirect <= 3; redirect++) {
      _checkUri(uri);
      if (audio && AudioTrack.resolve(uri.toString()) == null) {
        throw const MediaDownloadFailure();
      }
      if (_cancelled) throw const MediaDownloadFailure();
      final HttpClientRequest request = await client.getUrl(uri);
      request.followRedirects = false;
      request.headers.set(
        HttpHeaders.acceptHeader,
        audio
            ? 'audio/mpeg,application/octet-stream'
            : 'image/png,image/jpeg,image/webp,image/gif,*/*;q=0.5',
      );
      final HttpClientResponse response = await request.close();
      if (const <int>{301, 302, 303, 307, 308}.contains(response.statusCode)) {
        final String? location = response.headers.value(
          HttpHeaders.locationHeader,
        );
        if (location == null || redirect == 3) {
          throw const MediaDownloadFailure();
        }
        uri = uri.resolve(location);
        // A trusted request cannot redirect into an arbitrary/private host.
        if (_trustedHost(_uri.host) && !_trustedHost(uri.host)) {
          throw const MediaDownloadFailure();
        }
        // Do not download a redirect body of unbounded size.
        await response.listen((_) {}).cancel();
        continue;
      }
      final int maxBytes = (audio ? 24 : 16) * 1024 * 1024;
      if (response.statusCode != 200 || response.contentLength > maxBytes) {
        throw const MediaDownloadFailure();
      }
      final BytesBuilder builder = BytesBuilder(copy: false);
      await for (final List<int> chunk in response) {
        if (_cancelled || builder.length + chunk.length > maxBytes) {
          throw const MediaDownloadFailure();
        }
        builder.add(chunk);
      }
      final Uint8List bytes = builder.takeBytes();
      if (audio ? !_mp3(bytes) : !_raster(bytes)) {
        throw const MediaDownloadFailure();
      }
      return bytes;
    }
    throw const MediaDownloadFailure();
  }

  Future<Socket> _connect(Uri uri, List<InternetAddress> addresses) async {
    for (final InternetAddress address in addresses) {
      if (_cancelled) throw const MediaDownloadFailure();
      final Socket raw;
      try {
        final ConnectionTask<Socket> task = await Socket.startConnect(
          address,
          443,
        );
        _socket = task;
        if (_cancelled) task.cancel();
        raw = await task.socket.timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            task.cancel();
            throw const SocketException('Media connection timed out.');
          },
        );
      } on SocketException {
        // An unreachable IPv6 answer must not prevent using a checked IPv4 IP.
        continue;
      }
      _transport = raw;
      if (_cancelled) {
        raw.destroy();
        throw const MediaDownloadFailure();
      }
      final SecureSocket secure;
      try {
        secure = await SecureSocket.secure(raw, host: uri.host);
      } on Object {
        raw.destroy();
        rethrow;
      }
      _transport = secure;
      if (_cancelled) {
        secure.destroy();
        throw const MediaDownloadFailure();
      }
      return secure;
    }
    throw const MediaDownloadFailure();
  }

  static void _checkUri(Uri uri) {
    final String host = uri.host.toLowerCase();
    if (uri.scheme != 'https' ||
        uri.toString().length > 8192 ||
        host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.port != 443 ||
        !host.contains('.') && !host.contains(':') ||
        host.endsWith('.localhost') ||
        host.endsWith('.local') ||
        host.endsWith('.internal') ||
        host.endsWith('.home.arpa')) {
      throw const MediaDownloadFailure();
    }
  }

  static bool _publicAddress(InternetAddress address) {
    final Uint8List b = address.rawAddress;
    if (address.type == InternetAddressType.IPv6) {
      // Global unicast only; exclude special transition/documentation ranges.
      return b[0] & 0xe0 == 0x20 &&
          !(b[0] == 0x20 &&
              b[1] == 0x01 &&
              (b[2] <= 1 || b[2] == 0x0d && b[3] == 0xb8)) &&
          !(b[0] == 0x20 && b[1] == 0x02) &&
          !(b[0] == 0x3f && b[1] == 0xff);
    }
    final int a = b[0];
    final int c = b[1];
    return !(a == 0 ||
        a == 10 ||
        a == 127 ||
        a >= 224 ||
        a == 100 && c >= 64 && c <= 127 ||
        a == 169 && c == 254 ||
        a == 172 && c >= 16 && c <= 31 ||
        a == 192 && (c == 168 || c == 0 || c == 88 && b[2] == 99) ||
        a == 198 && (c == 18 || c == 19 || c == 51 && b[2] == 100) ||
        a == 203 && c == 0 && b[2] == 113);
  }

  static bool _trustedHost(String host) => const <String>{
    'osu.ppy.sh',
    'assets.ppy.sh',
    'a.ppy.sh',
    'b.ppy.sh',
    'i.ppy.sh',
  }.contains(host);

  static bool _mp3(Uint8List bytes) =>
      bytes.length >= 3 &&
      (String.fromCharCodes(bytes.take(3)) == 'ID3' ||
          bytes[0] == 0xff && bytes[1] & 0xe0 == 0xe0);

  static bool _raster(Uint8List bytes) => const <String>[
    'image/png',
    'image/jpeg',
    'image/webp',
    'image/gif',
  ].any((String mime) => _matchesFormat(bytes, mime));

  static bool _matchesFormat(Uint8List bytes, String mime) {
    if (bytes.length < 12) return false;
    return switch (mime) {
      'image/png' =>
        bytes[0] == 137 &&
            bytes[1] == 80 &&
            bytes[2] == 78 &&
            bytes[3] == 71 &&
            bytes[4] == 13 &&
            bytes[5] == 10 &&
            bytes[6] == 26 &&
            bytes[7] == 10,
      'image/jpeg' => bytes[0] == 255 && bytes[1] == 216 && bytes[2] == 255,
      'image/gif' =>
        String.fromCharCodes(bytes.take(6)) == 'GIF87a' ||
            String.fromCharCodes(bytes.take(6)) == 'GIF89a',
      'image/webp' =>
        String.fromCharCodes(bytes.take(4)) == 'RIFF' &&
            String.fromCharCodes(bytes.skip(8).take(4)) == 'WEBP',
      _ => false,
    };
  }
}

final class MediaDownloadFailure implements Exception {
  const MediaDownloadFailure();
}
