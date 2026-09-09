import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/ui/osu_badges.dart';
import 'package:tracksu/src/rankings/domain/countries.dart';
import 'package:tracksu/src/rankings/domain/rankings_query.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Draft search is local to the sheet; only selecting a row changes the query.
final class RankingCountryPicker extends StatefulWidget {
  const RankingCountryPicker({
    required this.repository,
    required this.selected,
    super.key,
  });
  final RankingCountriesRepository repository;
  final String? selected;
  @override
  State<RankingCountryPicker> createState() => _RankingCountryPickerState();
}

final class _RankingCountryPickerState extends State<RankingCountryPicker> {
  final TextEditingController _search = TextEditingController();
  late Future<List<RankingCountryOption>> _countries;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _countries = widget.repository.load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _choose(RankingCountry? country) {
    if (ModalRoute.of(context)?.isCurrent ?? false) {
      Navigator.of(context).pop((country: country));
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) => FutureBuilder<List<RankingCountryOption>>(
    future: _countries,
    builder:
        (
          BuildContext context,
          AsyncSnapshot<List<RankingCountryOption>> snapshot,
        ) {
          final List<RankingCountryOption> visible =
              (snapshot.data ?? const <RankingCountryOption>[])
                  .where(
                    (RankingCountryOption item) =>
                        item.country.value.toLowerCase().contains(_query) ||
                        item.name.toLowerCase().contains(_query),
                  )
                  .toList(growable: false);
          return CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg),
                  child: UiSearchField(
                    controller: _search,
                    label: context.t.rankingsCountrySearch,
                    clearLabel: context.t.searchClear,
                    helperText: context.t.rankingsCountryCatalogHint,
                    onChanged: (String value) =>
                        setState(() => _query = value.trim().toLowerCase()),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: UiTile.selection(
                  title: context.t.rankingsWorldwide,
                  leading: const Icon(Icons.public),
                  selected: widget.selected == null,
                  onTap: () => _choose(null),
                ),
              ),
              if (snapshot.connectionState != ConnectionState.done)
                SliverToBoxAdapter(
                  child: UiLoading(label: context.t.rankingsLoading),
                )
              else if (snapshot.hasError)
                SliverToBoxAdapter(
                  child: UiContentState.error(
                    title: context.t.rankingsCountryCatalogFailed,
                    actionLabel: context.t.retry,
                    onAction: () =>
                        setState(() => _countries = widget.repository.load()),
                  ),
                )
              else if (visible.isEmpty)
                SliverToBoxAdapter(
                  child: UiContentState.empty(
                    title: context.t.rankingsCountryNoMatch,
                  ),
                )
              else
                SliverList.builder(
                  itemCount: visible.length,
                  itemBuilder: (BuildContext context, int index) {
                    final RankingCountryOption item = visible[index];
                    return UiTile.selection(
                      key: ValueKey<String>(item.country.value),
                      leading: OsuCountryFlag(
                        code: item.country.value,
                        label: item.name,
                      ),
                      title: item.name,
                      subtitle: item.name == item.country.value
                          ? null
                          : item.country.value,
                      selected: widget.selected == item.country.value,
                      onTap: () => _choose(item.country),
                    );
                  },
                ),
            ],
          );
        },
  );
}
