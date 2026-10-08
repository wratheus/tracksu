part of 'bloc.dart';

final class WikiSearchState {
  const WikiSearchState({
    this.query = '',
    this.items = const <WikiSearchHit>[],
    this.total = 0,
    this.page = 0,
    this.busy = false,
    this.failure,
  });
  final String query;
  final List<WikiSearchHit> items;
  final int total;
  final int page;
  final bool busy;
  final WikiFailureKind? failure;

  bool get started => page > 0 || busy;
  bool get hasMore => items.length < total && page > 0;
}
