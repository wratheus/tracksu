part of 'bloc.dart';

/// [items] null until the type's first page; a failure keeps the rows and
/// says whether paging ([failedMore]) or the first page failed.
final class BeatmapPacksState {
  const BeatmapPacksState({
    required this.type,
    this.items,
    this.cursor,
    this.busy = false,
    this.loadingMore = false,
    this.failure,
    this.failedMore = false,
  });
  final BeatmapPackType type;
  final List<BeatmapPack>? items;
  final String? cursor;
  final bool busy;

  /// [busy] with the next page (the bar's progress line stays for refresh).
  final bool loadingMore;
  final BeatmapPacksFailureKind? failure;
  final bool failedMore;

  BeatmapPacksState copyWith({required bool busy, bool more = false}) =>
      BeatmapPacksState(
        type: type,
        items: items,
        cursor: cursor,
        busy: busy,
        loadingMore: busy && more,
      );
}
