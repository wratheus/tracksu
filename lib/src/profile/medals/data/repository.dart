import 'dart:convert';

import 'package:html/parser.dart' as html;
import 'package:html/dom.dart';
import 'package:tracksu/src/_core/serialization/json_map_reader.dart';
import 'package:tracksu/src/profile/medals/data/remote_source.dart';
import 'package:tracksu/src/profile/medals/domain/medal.dart';
import 'package:tracksu/src/profile/medals/domain/repository.dart';
import 'package:tracksu_network/tracksu_network.dart';

final class MedalsRepositoryImpl implements MedalsRepository {
  MedalsRepositoryImpl(this.source);
  final MedalsRemoteSource source;
  RestCancellationToken? _pending;

  @override
  void cancelPending() {
    _pending?.cancel();
    _pending = null;
  }

  @override
  Future<List<EarnedMedal>> load(int userId) async {
    cancelPending();
    final RestCancellationToken token = RestCancellationToken();
    _pending = token;
    try {
      return await _load(userId, token);
    } finally {
      if (identical(_pending, token)) _pending = null;
    }
  }

  Future<List<EarnedMedal>> _load(
    int userId,
    RestCancellationToken token,
  ) async {
    final String page = await source.load(userId, token);
    final Document document = html.parse(page);
    Map<String, dynamic>? data;
    for (final Element element in document.querySelectorAll(
      '[data-initial-data]',
    )) {
      final Object? decoded;
      try {
        decoded = jsonDecode(element.attributes['data-initial-data']!);
      } on FormatException {
        // Other widgets on this HTML page can use unrelated bootstrap formats.
        continue;
      }
      if (decoded is Map<String, dynamic> &&
          decoded['achievements'] is List<dynamic>) {
        data = decoded;
        break;
      }
    }
    if (data == null) throw const FormatException('Medal bootstrap changed.');
    final JsonMapReader bootstrap = JsonMapReader(data);
    final JsonMapReader user = JsonMapReader(
      bootstrap.optionalMap('user') ?? const <String, dynamic>{},
    );
    if (user.requiredInt('id') != userId) {
      throw const FormatException('Unexpected medal owner.');
    }
    final List<dynamic> catalogue = bootstrap.requiredList('achievements');
    final List<dynamic> awards = user.requiredList('user_achievements');
    if (catalogue.length > 5000 || awards.length > 5000) {
      throw const FormatException('Unexpected medal catalogue size.');
    }
    final Map<int, _MedalDto> byId = <int, _MedalDto>{};
    for (final dynamic item in catalogue) {
      final _MedalDto medal = _MedalDto.fromJson(JsonMapReader.asMap(item));
      byId[medal.id] = medal;
    }
    final List<EarnedMedal> result = <EarnedMedal>[];
    final Set<int> seen = <int>{};
    for (final dynamic item in awards) {
      final JsonMapReader award = JsonMapReader(JsonMapReader.asMap(item));
      final int id = award.requiredInt('achievement_id', positive: true);
      if (!seen.add(id)) continue;
      final _MedalDto? medal = byId[id];
      result.add(
        EarnedMedal(
          id: id,
          earnedAt: DateTime.parse(award.requiredString('achieved_at')),
          name: medal?.name,
          description: medal?.description,
          imageUri: medal?.imageUri,
        ),
      );
    }
    result.sort(
      (EarnedMedal a, EarnedMedal b) => b.earnedAt.compareTo(a.earnedAt),
    );
    return List.unmodifiable(result);
  }
}

final class _MedalDto {
  const _MedalDto({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUri,
  });
  factory _MedalDto.fromJson(Map<String, dynamic> json) {
    final JsonMapReader reader = JsonMapReader(json);
    final String? image = reader.optionalString('icon_url');
    final Uri? uri = image == null ? null : Uri.tryParse(image);
    return _MedalDto(
      id: reader.requiredInt('id', positive: true),
      name: reader.requiredString('name'),
      description: reader.optionalString('description'),
      imageUri:
          uri != null &&
              uri.scheme == 'https' &&
              uri.userInfo.isEmpty &&
              uri.port == 443 &&
              (uri.host == 'assets.ppy.sh' || uri.host == 's.ppy.sh')
          ? uri
          : null,
    );
  }
  final int id;
  final String name;
  final String? description;
  final Uri? imageUri;
}
