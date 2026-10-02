import 'dart:typed_data';

import 'package:audio_decode/audio_decode.dart';
import 'package:tracksu/src/_shared/media/data/media_download.dart';

/// Upper bound of decoded 16-bit PCM, checked before native decode starts.
/// stb_vorbis grows its output buffer by doubling, so the transient native
/// peak stays within about three times this value plus the encoded input.
const int _maxPcmBytes = 16 * 1024 * 1024;

/// Beatmap previews are about ten seconds; longer streams are rejected.
const int _maxSeconds = 45;

const MediaDownloadFailure _invalid = MediaDownloadFailure(
  MediaFailureReason.invalidFormat,
);
const MediaDownloadFailure _tooLarge = MediaDownloadFailure(
  MediaFailureReason.tooLarge,
);

/// Converts an Ogg Vorbis payload to a 16-bit PCM WAV file for players without
/// a Vorbis decoder (iOS AVFoundation). Synchronous native work: run it in a
/// background isolate. It cannot be cancelled once started; callers discard a
/// stale result instead. Throws [MediaDownloadFailure] only.
Uint8List vorbisToWav(Uint8List ogg) {
  if (ogg.length > MediaDownload.maxAudioBytes) throw _tooLarge;
  final _VorbisStream stream = _VorbisStream.parse(ogg);
  final PcmAudio pcm;
  try {
    pcm = decodeOgg(ogg);
  } on AudioDecodeException {
    throw _invalid;
  }
  if (pcm.channels != stream.channels ||
      pcm.sampleRate != stream.rate ||
      pcm.frameCount <= 0 ||
      pcm.samples.lengthInBytes > stream.pcmBytes) {
    throw _invalid;
  }
  // The end granule is only a claim; enforce the duration on the real output.
  if (pcm.frameCount > stream.rate * _maxSeconds) throw _tooLarge;
  return encodeWav(pcm);
}

/// Structural preflight of the whole payload, not a decoder: exactly one
/// complete logical Vorbis stream (no chaining/multiplexing, no trailing data),
/// so the decoded size can be bounded before stb_vorbis allocates it.
final class _VorbisStream {
  const _VorbisStream(this.channels, this.rate, this.pcmBytes);
  final int channels;
  final int rate;

  /// Conservative ceiling of decoded PCM bytes.
  final int pcmBytes;

  static _VorbisStream parse(Uint8List bytes) {
    final ByteData data = ByteData.sublistView(bytes);
    int offset = 0;
    int sequence = 0;
    int serial = 0;
    int packets = 0;
    int channels = 0;
    int rate = 0;
    int longBlock = 0;
    int granule = 0;
    // The previous page ended inside a packet that this page must continue.
    bool open = false;
    bool ended = false;
    while (offset < bytes.length) {
      if (ended ||
          bytes.length - offset < 27 ||
          bytes[offset] != 0x4f ||
          bytes[offset + 1] != 0x67 ||
          bytes[offset + 2] != 0x67 ||
          bytes[offset + 3] != 0x53 ||
          bytes[offset + 4] != 0) {
        throw _invalid;
      }
      final int flags = bytes[offset + 5];
      final bool first = sequence == 0;
      if (flags & ~0x07 != 0 ||
          (flags & 0x01 != 0) != open ||
          (flags & 0x02 != 0) != first) {
        throw _invalid;
      }
      final int pageSerial = data.getUint32(offset + 14, Endian.little);
      if (first) {
        serial = pageSerial;
      } else if (pageSerial != serial) {
        throw _invalid;
      }
      if (data.getUint32(offset + 18, Endian.little) != sequence) {
        throw _invalid;
      }
      final int segments = bytes[offset + 26];
      // stb_vorbis keeps the previous page's lacing on an empty page and
      // decodes a phantom packet from it, which this count would not bound.
      if (segments == 0) throw _invalid;
      final int table = offset + 27;
      int end = table + segments;
      if (end > bytes.length) throw _invalid;
      for (int i = 0; i < segments; i++) {
        end += bytes[table + i];
      }
      if (end > bytes.length) throw _invalid;
      int position = table + segments;
      for (int i = 0; i < segments; i++) {
        final int lace = bytes[table + i];
        if (!open && packets == 0) {
          // stb_vorbis requires the identification header alone on page 0.
          if (segments != 1 || lace != 30) throw _invalid;
          final int log0 = bytes[position + 28] & 0x0f;
          final int log1 = bytes[position + 28] >> 4;
          channels = bytes[position + 11];
          rate = data.getUint32(position + 12, Endian.little);
          if (!_header(bytes, position, 1) ||
              data.getUint32(position + 7, Endian.little) != 0 ||
              channels < 1 ||
              channels > 2 ||
              rate < 8000 ||
              rate > 48000 ||
              log0 < 6 ||
              log1 > 13 ||
              log0 > log1 ||
              bytes[position + 29] & 0x01 == 0) {
            throw _invalid;
          }
          longBlock = 1 << log1;
        } else if (!open && packets < 3) {
          // Comment and setup headers start with type 3 and 5.
          if (lace < 7 || !_header(bytes, position, packets * 2 + 1)) {
            throw _invalid;
          }
        }
        position += lace;
        open = lace == 255;
        if (!open) packets++;
      }
      if (flags & 0x04 != 0) {
        ended = true;
        granule = data.getInt64(offset + 6, Endian.little);
      }
      offset = end;
      sequence++;
    }
    final int audioPackets = packets - 3;
    if (!ended || open || audioPackets < 1 || granule <= 0) throw _invalid;
    if (granule > rate * _maxSeconds) throw _tooLarge;
    // stb_vorbis returns right - left frames per packet; left >= 0 and right
    // <= (3 * blocksize_1 - blocksize_0) / 4 (vorbis_decode_initial), so
    // 3/4 of the long block bounds every packet, including forged flags.
    final int pcmBytes = audioPackets * (longBlock * 3 ~/ 4) * channels * 2;
    if (pcmBytes > _maxPcmBytes) throw _tooLarge;
    return _VorbisStream(channels, rate, pcmBytes);
  }

  /// Header packet type byte followed by the `vorbis` signature.
  static bool _header(Uint8List bytes, int position, int type) =>
      bytes[position] == type &&
      String.fromCharCodes(bytes, position + 1, position + 7) == 'vorbis';
}
