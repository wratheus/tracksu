/// osu! changelog (`GET /changelog`, no token required): update streams,
/// builds and their entries as on osu.ppy.sh/home/changelog.
final class ChangelogStream {
  const ChangelogStream({
    required this.id,
    required this.name,
    required this.displayName,
    required this.isFeatured,
    this.latestVersion,
    this.userCount,
  });
  final int id;

  /// API name used as the `stream` filter, e.g. `stable40`, `lazer`, `web`.
  final String name;
  final String displayName;
  final bool isFeatured;
  final String? latestVersion;
  final int? userCount;
}

final class ChangelogBuild {
  ChangelogBuild({
    required this.id,
    required this.version,
    required this.createdAt,
    required this.users,
    required List<ChangelogEntry> entries,
    this.streamName,
    this.streamDisplayName,
  }) : entries = List<ChangelogEntry>.unmodifiable(entries);
  final int id;
  final String version;
  final DateTime createdAt;

  /// Active users on this build when the API counted them.
  final int users;
  final String? streamName;
  final String? streamDisplayName;
  final List<ChangelogEntry> entries;
}

/// One change. [type] is `add`, `fix` or `misc`; [major] entries are bold on
/// the website.
final class ChangelogEntry {
  const ChangelogEntry({
    required this.category,
    required this.type,
    required this.major,
    this.title,
    this.messageHtml,
    this.url,
    this.githubUrl,
    this.pullRequest,
    this.repository,
    this.author,
  });
  final String category;
  final String type;
  final bool major;
  final String? title;
  final String? messageHtml;
  final Uri? url;
  final Uri? githubUrl;
  final int? pullRequest;
  final String? repository;
  final String? author;
}

final class ChangelogQuery {
  const ChangelogQuery({this.stream, this.maxId});
  final String? stream;
  final int? maxId;
}

final class ChangelogPage {
  ChangelogPage({
    required List<ChangelogStream> streams,
    required List<ChangelogBuild> builds,
    this.nextMaxId,
  }) : streams = List<ChangelogStream>.unmodifiable(streams),
       builds = List<ChangelogBuild>.unmodifiable(builds);
  final List<ChangelogStream> streams;
  final List<ChangelogBuild> builds;

  /// Next page starts below this build ID; null when the list ended.
  final int? nextMaxId;
}

enum ChangelogFailureKind {
  cancelled,
  rateLimited,
  connection,
  invalidResponse,
  unavailable,
}

final class ChangelogFailure implements Exception {
  const ChangelogFailure(this.kind);
  final ChangelogFailureKind kind;
}

abstract interface class ChangelogRepository {
  Future<ChangelogPage> load(ChangelogQuery query);
  void cancelPending();
}
