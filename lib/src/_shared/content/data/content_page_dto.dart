import 'dart:convert';

import 'package:tracksu/src/_core/serialization/json_map_reader.dart';
import 'package:tracksu/src/_shared/content/data/content_normalizer.dart';
import 'package:tracksu/src/_shared/content/domain/content_page.dart';

/// Explicit wire contracts, not content-type guessing or a second BBCode parser.
final class ContentPageDto {
  const ContentPageDto._({this.html, this.raw, this.invalid = false});
  const ContentPageDto.unavailable() : this._(invalid: true);
  factory ContentPageDto.profile(Map<String, dynamic> json) =>
      ContentPageDto._read(json, htmlKey: 'html', rawKey: 'raw');
  factory ContentPageDto.beatmap(Map<String, dynamic> json) =>
      ContentPageDto._read(json, htmlKey: 'description');
  factory ContentPageDto._read(
    Map<String, dynamic> json, {
    required String htmlKey,
    String? rawKey,
  }) {
    final JsonMapReader reader = JsonMapReader(json);
    try {
      return ContentPageDto._(
        html: reader.optionalString(htmlKey),
        raw: rawKey == null ? null : reader.optionalString(rawKey),
      );
    } on FormatException {
      return const ContentPageDto.unavailable();
    }
  }
  final String? html;
  final String? raw;
  final bool invalid;

  ContentPage? toDomain(Uri uri) {
    if (invalid ||
        (html?.length ?? 0) > 2000000 ||
        (raw?.length ?? 0) > 2000000) {
      return ContentPage(uri: uri, document: null);
    }
    final String? rendered = html?.trim();
    final String? plain = raw?.trim();
    if ((rendered == null || rendered.isEmpty) &&
        (plain == null || plain.isEmpty)) {
      return null;
    }
    try {
      final String content = rendered != null && rendered.isNotEmpty
          ? rendered
          : '<p>${const HtmlEscape().convert(plain!).replaceAll('\n', '<br>')}</p>';
      return ContentPage(
        uri: uri,
        document: ContentNormalizer.html(content, uri),
      );
    } on FormatException {
      // Optional rich content must not hide profile stats or map leaderboards.
      return ContentPage(uri: uri, document: null);
    }
  }
}
