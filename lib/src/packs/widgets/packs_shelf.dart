import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/packs/domain/packs.dart';
import 'package:tracksu/src/packs/widgets/pack_type_style.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Home shelf: one tile per pack type, swiped sideways; a tile opens that
/// type's packs. Static (no request), so Home stays light.
final class BeatmapPacksShelf extends StatelessWidget {
  const BeatmapPacksShelf({super.key});

  static const double _tileWidth = 156;
  static const double _height = 124;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: UiSpace.md,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg),
        child: UiText.titleMedium(context.t.packsTitle),
      ),
      SizedBox(
        height: _height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg),
          itemCount: BeatmapPackType.values.length,
          separatorBuilder: (_, _) => const SizedBox(width: UiSpace.md),
          itemBuilder: (BuildContext context, int index) => SizedBox(
            width: _tileWidth,
            child: _TypeTile(type: BeatmapPackType.values[index]),
          ),
        ),
      ),
    ],
  );
}

final class _TypeTile extends StatelessWidget {
  const _TypeTile({required this.type});
  final BeatmapPackType type;

  static const BeveledRectangleBorder _shape = BeveledRectangleBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(UiSpace.md),
      bottomRight: Radius.circular(UiSpace.md),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color accent = type.accent;
    return Semantics(
      button: true,
      label: '${type.label(context)}. ${type.hint(context)}',
      excludeSemantics: true,
      child: Material(
        shape: _shape,
        clipBehavior: Clip.antiAlias,
        color: colors.surfaceContainerLow,
        child: InkWell(
          onTap: () => unawaited(
            DepsScope.of(context).appRouter.openPacks(context, type),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  accent.withValues(alpha: 0.28),
                  accent.withValues(alpha: 0.04),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(UiSpace.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(type.icon, color: accent, size: 26),
                  const Spacer(),
                  UiText.titleSmall(
                    type.label(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  UiText.bodySmall(
                    type.hint(context),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    secondary: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
