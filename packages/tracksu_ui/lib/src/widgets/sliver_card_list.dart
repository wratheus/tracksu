import 'package:flutter/widgets.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';

/// Lazy card lists share one rhythm without imposing margins on every surface.
final class UiSliverCardList extends StatelessWidget {
  const UiSliverCardList({
    required this.itemCount,
    required this.itemBuilder,
    super.key,
  });
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) => SliverList.builder(
    itemCount: itemCount,
    itemBuilder: (BuildContext context, int index) => Padding(
      padding: EdgeInsets.only(bottom: index + 1 < itemCount ? UiSpace.md : 0),
      child: itemBuilder(context, index),
    ),
  );
}
