enum SearchTab { players, maps, wiki }

final class SearchParams {
  const SearchParams({this.text = '', this.tab = SearchTab.players});
  final String text;
  final SearchTab tab;
}
