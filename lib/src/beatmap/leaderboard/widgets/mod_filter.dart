import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/ui/osu_badges.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Mods a leaderboard can be filtered by, per ruleset, as on osu.ppy.sh.
/// `NM` (no mods) excludes every other choice.
List<String> leaderboardFilterMods(ProfileRuleset ruleset) => <String>[
  'NM',
  'EZ',
  'NF',
  'HT',
  'HR',
  'SD',
  'PF',
  'DT',
  'NC',
  'HD',
  if (ruleset == ProfileRuleset.mania) 'FI',
  'FL',
  if (ruleset == ProfileRuleset.osu) ...<String>['SO', 'TD'],
  if (ruleset == ProfileRuleset.mania) ...<String>[
    'MR',
    '4K',
    '5K',
    '6K',
    '7K',
    '8K',
    '9K',
  ],
];

/// One line above the leaderboard: the active mod filter (or "All") that
/// opens a sheet of mod chips.
final class LeaderboardModFilter extends StatelessWidget {
  const LeaderboardModFilter({
    required this.ruleset,
    required this.selected,
    required this.onChanged,
    super.key,
  });
  final ProfileRuleset ruleset;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  Future<void> _choose(BuildContext context) async {
    final List<String>? mods = await UiModal.scrollable<List<String>>(
      context,
      title: context.t.leaderboardModsTitle,
      builder: (_) =>
          _ModSheet(options: leaderboardFilterMods(ruleset), initial: selected),
    );
    if (context.mounted && mods != null) onChanged(mods);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: context.t.leaderboardModsTitle,
      child: UiSurface.tonal(
        onTap: () => _choose(context),
        padding: const EdgeInsets.symmetric(
          horizontal: UiSpace.md,
          vertical: UiSpace.sm,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 32),
          child: Row(
            spacing: UiSpace.sm,
            children: <Widget>[
              Icon(Icons.tune_rounded, size: 20, color: colors.primary),
              Expanded(
                child: selected.isEmpty
                    ? UiText.labelLarge(context.t.leaderboardModsAll)
                    : Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: OsuMods(
                          mods: selected,
                          emptyLabel: context.t.scoresNoMods,
                        ),
                      ),
              ),
              Icon(Icons.expand_more_rounded, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

final class _ModSheet extends StatefulWidget {
  const _ModSheet({required this.options, required this.initial});
  final List<String> options;
  final List<String> initial;

  @override
  State<_ModSheet> createState() => _ModSheetState();
}

final class _ModSheetState extends State<_ModSheet> {
  late final Set<String> _selected = <String>{...widget.initial};

  void _toggle(String mod) => setState(() {
    if (_selected.remove(mod)) return;
    if (mod == 'NM') {
      _selected.clear();
    } else {
      _selected.remove('NM');
      for (final Set<String> group in <Set<String>>[
        {'EZ', 'HR'},
        {'HT', 'DT', 'NC'},
        {'NF', 'SD', 'PF'},
        {'HD', 'FI'},
        {'4K', '5K', '6K', '7K', '8K', '9K'},
      ]) {
        if (group.contains(mod)) _selected.removeAll(group);
      }
    }
    _selected.add(mod);
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return ListView(
      primary: true,
      padding: const EdgeInsets.fromLTRB(
        UiSpace.lg,
        UiSpace.sm,
        UiSpace.lg,
        UiSpace.lg,
      ),
      children: <Widget>[
        Wrap(
          spacing: UiSpace.sm,
          runSpacing: UiSpace.sm,
          children: <Widget>[
            for (final String mod in widget.options)
              FilterChip(
                selected: _selected.contains(mod),
                showCheckmark: false,
                avatar: mod == 'NM'
                    ? const OsuModIcon.none()
                    : OsuModIcon(acronym: mod),
                label: Text(mod == 'NM' ? context.t.scoresNoMods : mod),
                tooltip: OsuModInfo.of(mod)?.name ?? mod,
                selectedColor: colors.primaryContainer,
                onSelected: (_) => _toggle(mod),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: UiSpace.lg),
          child: Row(
            spacing: UiSpace.sm,
            children: <Widget>[
              Expanded(
                child: UiButton.secondary(
                  label: context.t.leaderboardModsReset,
                  onPressed: () => Navigator.of(context).pop(const <String>[]),
                ),
              ),
              Expanded(
                child: UiButton.primary(
                  label: context.t.leaderboardModsApply,
                  onPressed: () => Navigator.of(context).pop(<String>[
                    for (final String mod in widget.options)
                      if (_selected.contains(mod)) mod,
                  ]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
