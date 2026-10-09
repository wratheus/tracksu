import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/ruleset/ruleset_controller.dart';
import 'package:tracksu/src/_shared/ui/osu_badges.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// The game mode in the app bar (ADR-011): the mode's icon; a tap opens a
/// sheet with the four modes. Replaces the full-width mode rows pages used
/// to carry under the bar.
///
/// [RulesetButton.global] reads and sets the app-wide mode (rankings,
/// spotlights). The plain constructor is page-local, for a player's or a
/// team's page that opens in their own main mode and changes only itself.
final class RulesetButton extends StatelessWidget {
  const RulesetButton({
    required ProfileRuleset this.value,
    required ValueChanged<ProfileRuleset>? this.onChanged,
    super.key,
  });

  const RulesetButton.global({super.key}) : value = null, onChanged = null;

  final ProfileRuleset? value;

  /// Null on a page-local button disables it (e.g. while loading).
  final ValueChanged<ProfileRuleset>? onChanged;

  bool get _global => value == null;

  Future<void> _choose(
    BuildContext context,
    ProfileRuleset selected,
    ValueChanged<ProfileRuleset> apply,
  ) async {
    final ProfileRuleset? chosen = await UiModal.selection<ProfileRuleset>(
      context,
      title: context.t.rulesetTitle,
      selected: selected,
      choices: <UiChoice<ProfileRuleset>>[
        for (final ProfileRuleset ruleset in ProfileRuleset.values)
          UiChoice<ProfileRuleset>(
            value: ruleset,
            label: OsuRulesetSelector.label(context, ruleset),
            leading: OsuRulesetIcon(ruleset: ruleset),
          ),
      ],
    );
    if (chosen != null && chosen != selected) apply(chosen);
  }

  Widget _button(
    BuildContext context,
    ProfileRuleset selected,
    ValueChanged<ProfileRuleset>? apply,
  ) => IconButton(
    tooltip:
        '${context.t.rulesetTitle}: '
        '${OsuRulesetSelector.label(context, selected)}',
    onPressed: apply == null
        ? null
        : () => unawaited(_choose(context, selected, apply)),
    icon: AnimatedSwitcher(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : UiMotion.reveal,
      child: OsuRulesetIcon(
        key: ValueKey<ProfileRuleset>(selected),
        ruleset: selected,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (!_global) return _button(context, value!, onChanged);
    final RulesetController controller = DepsScope.of(
      context,
    ).rulesetController;
    return ValueListenableBuilder<ProfileRuleset>(
      valueListenable: controller,
      builder: (BuildContext context, ProfileRuleset selected, _) => _button(
        context,
        selected,
        (ProfileRuleset ruleset) => unawaited(controller.select(ruleset)),
      ),
    );
  }
}
