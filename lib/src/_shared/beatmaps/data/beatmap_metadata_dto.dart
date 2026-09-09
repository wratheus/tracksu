import 'package:tracksu/src/_core/serialization/json_map_reader.dart';
import 'package:tracksu/src/_shared/beatmaps/domain/beatmap_metadata.dart';

final class BeatmapMetadataDto {
  const BeatmapMetadataDto._({
    this.coverUrl,
    this.bannerUrl,
    this.creator,
    this.status,
    this.plays,
    this.favourites,
  });

  factory BeatmapMetadataDto.fromJson(Map<String, dynamic> json) {
    final JsonMapReader reader = JsonMapReader(json);
    final Map<String, dynamic>? covers = reader.optionalMap('covers');
    final int? plays = reader.optionalInt('play_count');
    final int? favourites = reader.optionalInt('favourite_count');
    if ((plays != null && plays < 0) ||
        (favourites != null && favourites < 0)) {
      throw const FormatException('Negative beatmapset counts.');
    }
    return BeatmapMetadataDto._(
      bannerUrl: covers == null
          ? null
          : (JsonMapReader(covers).optionalString('cover@2x') ??
                JsonMapReader(covers).optionalString('cover')),
      coverUrl: covers == null
          ? null
          : JsonMapReader(covers).optionalString('card'),
      creator: reader.optionalString('creator'),
      status: reader.optionalString('status'),
      plays: plays,
      favourites: favourites,
    );
  }
  final String? coverUrl;
  final String? bannerUrl;
  final String? creator;
  final String? status;
  final int? plays;
  final int? favourites;

  BeatmapMetadata toDomain() {
    final Uri? uri = coverUrl == null ? null : Uri.tryParse(coverUrl!);
    return BeatmapMetadata(
      bannerUri: _mediaUri(bannerUrl),
      coverUri:
          uri != null &&
              uri.isScheme('https') &&
              uri.host.isNotEmpty &&
              uri.userInfo.isEmpty
          ? uri
          : null,
      creator: creator,
      status: status,
      plays: plays,
      favourites: favourites,
    );
  }

  static Uri? _mediaUri(String? value) {
    final Uri? uri = value == null ? null : Uri.tryParse(value);
    return uri != null &&
            uri.scheme == 'https' &&
            uri.host.isNotEmpty &&
            uri.userInfo.isEmpty
        ? uri
        : null;
  }
}
