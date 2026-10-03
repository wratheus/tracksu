import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/spotlights/domain/spotlight.dart';
import 'package:tracksu/src/spotlights/widgets/facts.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Search is local and transient; only choosing a result changes the Bloc query.
final class SpotlightCatalogPicker extends StatefulWidget {
  const SpotlightCatalogPicker({
    required this.catalog,
    required this.selectedId,
    super.key,
  });
  final List<Spotlight> catalog;
  final int? selectedId;
  @override
  State<SpotlightCatalogPicker> createState() => _SpotlightCatalogPickerState();
}

final class _SpotlightCatalogPickerState extends State<SpotlightCatalogPicker> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Chart names carry their year ("Best of 2012"); dates are staff-entered
    // labels and may belong to the following year, so they are not searched.
    final List<Spotlight> visible = widget.catalog
        .where(
          (Spotlight item) =>
              item.name.toLowerCase().contains(_query) ||
              item.id.toString() == _query,
        )
        .toList(growable: false);
    return CustomScrollView(
      primary: true,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              UiSpace.lg,
              0,
              UiSpace.lg,
              UiSpace.md,
            ),
            child: UiSearchField(
              controller: _search,
              label: context.t.spotlightsSearch,
              clearLabel: context.t.searchClear,
              onChanged: (String value) =>
                  setState(() => _query = value.trim().toLowerCase()),
            ),
          ),
        ),
        if (visible.isEmpty)
          SliverToBoxAdapter(
            child: UiContentState.empty(title: context.t.spotlightsNoMatch),
          ),
        SliverPadding(
          padding: const EdgeInsets.only(bottom: UiSpace.lg),
          sliver: SliverList.builder(
            itemCount: visible.length,
            itemBuilder: (BuildContext context, int index) {
              final Spotlight item = visible[index];
              return UiTile.selection(
                key: ValueKey<int>(item.id),
                title: item.name,
                subtitle: spotlightKindLabel(context, item.kind),
                leading: const Icon(Icons.collections_bookmark_outlined),
                selected: item.id == widget.selectedId,
                onTap: () {
                  if (ModalRoute.of(context)?.isCurrent == true) {
                    Navigator.of(context).pop(item.id);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
