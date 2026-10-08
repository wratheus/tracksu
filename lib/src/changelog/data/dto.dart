import 'package:tracksu/src/_core/serialization/json_map_reader.dart';
import 'package:tracksu/src/changelog/domain/changelog.dart';

/// Maps `GET /changelog`. Builds are 21 per call; a full page means more.
abstract final class ChangelogDto {
  static const int pageSize = 21;

  static ChangelogPage page(Map<String, dynamic> json) {
    final JsonMapReader reader = JsonMapReader(json);
    final List<ChangelogStream> streams = <ChangelogStream>[
      for (final Object? item in reader.optionalList('streams') ?? const [])
        _stream(JsonMapReader(JsonMapReader.asMap(item))),
    ];
    final List<ChangelogBuild> builds = <ChangelogBuild>[
      for (final Object? item in reader.requiredList('builds'))
        _build(JsonMapReader(JsonMapReader.asMap(item))),
    ];
    return ChangelogPage(
      streams: streams,
      builds: builds,
      nextMaxId: builds.length >= pageSize && builds.last.id > 1
          ? builds.last.id - 1
          : null,
    );
  }

  static ChangelogStream _stream(JsonMapReader reader) {
    final Map<String, dynamic>? latest = reader.optionalMap('latest_build');
    final String name = reader.requiredString('name');
    return ChangelogStream(
      id: reader.requiredInt('id'),
      name: name,
      displayName: reader.optionalString('display_name') ?? name,
      isFeatured: reader.requiredBool('is_featured'),
      latestVersion: latest == null
          ? null
          : JsonMapReader(latest).optionalString('display_version'),
      userCount: reader.optionalInt('user_count'),
    );
  }

  static ChangelogBuild _build(JsonMapReader reader) {
    final Map<String, dynamic>? stream = reader.optionalMap('update_stream');
    final JsonMapReader? streamReader = stream == null
        ? null
        : JsonMapReader(stream);
    return ChangelogBuild(
      id: reader.requiredInt('id', positive: true),
      version: reader.requiredString('display_version'),
      createdAt: DateTime.parse(reader.requiredString('created_at')),
      users: reader.optionalInt('users') ?? 0,
      streamName: streamReader?.optionalString('name'),
      streamDisplayName:
          streamReader?.optionalString('display_name') ??
          streamReader?.optionalString('name'),
      entries: <ChangelogEntry>[
        for (final Object? item
            in reader.optionalList('changelog_entries') ?? const [])
          _entry(JsonMapReader(JsonMapReader.asMap(item))),
      ],
    );
  }

  static ChangelogEntry _entry(JsonMapReader reader) {
    final Map<String, dynamic>? user = reader.optionalMap('github_user');
    final String? html = reader.optionalString('message_html');
    return ChangelogEntry(
      category: reader.optionalString('category') ?? '',
      type: reader.optionalString('type') ?? 'misc',
      major: reader.optionalBool('major') ?? false,
      title: reader.optionalString('title'),
      messageHtml: html == null || html.trim().isEmpty ? null : html,
      url: _uri(reader.optionalString('url')),
      githubUrl: _uri(reader.optionalString('github_url')),
      pullRequest: reader.optionalInt('github_pull_request_id'),
      repository: reader.optionalString('repository'),
      author: user == null
          ? null
          : JsonMapReader(user).optionalString('display_name'),
    );
  }

  /// Only https links leave the app.
  static Uri? _uri(String? value) {
    final Uri? uri = value == null ? null : Uri.tryParse(value);
    return uri != null && uri.isScheme('https') ? uri : null;
  }
}
