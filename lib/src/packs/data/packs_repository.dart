import 'package:tracksu/src/auth/data/oauth_remote_source_exception.dart';
import 'package:tracksu/src/packs/domain/packs.dart';
import 'package:tracksu/src/profile/beatmaps/data/beatmap_dto.dart';
import 'package:tracksu/src/profile/beatmaps/domain/beatmap.dart';
import 'package:tracksu/src/profile/beatmaps/domain/beatmaps_query.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu_network/tracksu_network.dart';

/// osu! beatmap packs (osu-web `BeatmapPacksController`, scope public).
/// A newer read cancels the previous one.
final class BeatmapPacksRepository {
  BeatmapPacksRepository({required RestClient restClient})
    : _client = restClient;
  final RestClient _client;
  RestCancellationToken? _pending;

  void cancelPending() {
    _pending?.cancel();
    _pending = null;
  }

  /// `GET /beatmaps/packs?type=&cursor_string=`.
  Future<BeatmapPacksPage> list(BeatmapPackType type, {String? cursor}) =>
      _read(
        '/beatmaps/packs',
        <String, Object?>{'type': type.apiValue, 'cursor_string': ?cursor},
        (Map<String, dynamic> json) {
          final Object? next = json['cursor_string'];
          return BeatmapPacksPage(
            items: <BeatmapPack>[
              for (final Object? item in _list(json['beatmap_packs']))
                _pack(item),
            ],
            cursor: next is String && next.isNotEmpty ? next : null,
          );
        },
      );

  /// `GET /beatmaps/packs/{tag}` with its beatmapsets.
  Future<BeatmapPack> pack(String tag) {
    if (!BeatmapPackLinks.tagPattern.hasMatch(tag)) {
      throw ArgumentError.value(tag, 'tag');
    }
    return _read(
      '/beatmaps/packs/${Uri.encodeComponent(tag)}',
      const <String, Object?>{'legacy_only': 0},
      (Map<String, dynamic> json) => _pack(json, withSets: true),
    );
  }

  Future<T> _read<T>(
    String path,
    Map<String, Object?> query,
    T Function(Map<String, dynamic> json) decode,
  ) async {
    cancelPending();
    final RestCancellationToken token = RestCancellationToken();
    _pending = token;
    try {
      final RestResponse response = await _client.get(
        path: path,
        queryParameters: query,
        options: RestClientOptions(cancellationToken: token),
      );
      if (token.isCancelled) {
        throw const BeatmapPacksFailure(BeatmapPacksFailureKind.cancelled);
      }
      if (response.statusCode != 200) throw _status(response.statusCode);
      return decode(response.payload.asMap());
    } on OAuthRemoteSourceException catch (error, stackTrace) {
      Error.throwWithStackTrace(_status(error.statusCode), stackTrace);
    } on FormatException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const BeatmapPacksFailure(BeatmapPacksFailureKind.invalidResponse),
        stackTrace,
      );
    } on TypeError catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const BeatmapPacksFailure(BeatmapPacksFailureKind.invalidResponse),
        stackTrace,
      );
    } on RestRequestCancelledException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const BeatmapPacksFailure(BeatmapPacksFailureKind.cancelled),
        stackTrace,
      );
    } on RestClientException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const BeatmapPacksFailure(BeatmapPacksFailureKind.connection),
        stackTrace,
      );
    } finally {
      if (identical(_pending, token)) _pending = null;
    }
  }

  static BeatmapPacksFailure _status(int status) =>
      BeatmapPacksFailure(switch (status) {
        404 => BeatmapPacksFailureKind.notFound,
        429 => BeatmapPacksFailureKind.rateLimited,
        _ => BeatmapPacksFailureKind.unavailable,
      });

  static List<Object?> _list(Object? value) => switch (value) {
    null => const <Object?>[],
    final List<dynamic> list => list,
    _ => throw const FormatException('Expected a list.'),
  };

  static BeatmapPack _pack(Object? value, {bool withSets = false}) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Expected a pack.');
    }
    final Object? ruleset = value['ruleset_id'];
    final Object? date = value['date'];
    return BeatmapPack(
      tag: switch (value['tag']) {
        final String tag when BeatmapPackLinks.tagPattern.hasMatch(tag) => tag,
        _ => throw const FormatException('Expected a pack tag.'),
      },
      name: value['name'] as String,
      author: (value['author'] as String?) ?? '',
      date: date is String ? DateTime.tryParse(date) : null,
      // osu! ruleset ids follow the enum order: osu, taiko, fruits, mania.
      ruleset: ruleset is int && ruleset >= 0 && ruleset < 4
          ? ProfileRuleset.values[ruleset]
          : null,
      noDiffReduction: value['no_diff_reduction'] == true,
      beatmapsets: withSets
          ? <ProfileBeatmap>[
              for (final Object? set in _list(value['beatmapsets']))
                if (set is Map<String, dynamic>)
                  ProfileBeatmapDto.fromJson(
                    set,
                    type: ProfileBeatmapsType.ranked,
                  ).toDomain(),
            ]
          : null,
    );
  }
}
