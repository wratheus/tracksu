import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/ui/osu_badges.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/rankings/bloc/bloc.dart';
import 'package:tracksu/src/rankings/domain/countries.dart';
import 'package:tracksu/src/rankings/domain/rankings_query.dart';
import 'package:tracksu/src/rankings/widgets/country_picker.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class RankingsFilters extends StatelessWidget {
  const RankingsFilters({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: UiSpace.md,
    children: <Widget>[
      BlocSelector<RankingsBloc, RankingsState, RankingsType>(
        selector: (RankingsState state) => state.type,
        builder: (BuildContext context, RankingsType type) => Column(
          spacing: UiSpace.md,
          children: <Widget>[
            OsuRulesetSelector(
              selected: type.ruleset,
              onChanged: (ProfileRuleset ruleset) =>
                  context.read<RankingsBloc>().add(
                    RankingsTypeSelected(
                      RankingsType.select(ruleset, type.sort == 'performance'),
                    ),
                  ),
            ),
            UiSegmentedControl<bool>(
              selected: type.sort == 'performance',
              segments: <UiSegment<bool>>[
                UiSegment<bool>(
                  value: true,
                  label: context.t.profilePpLabel,
                  icon: const Icon(Icons.bolt),
                ),
                UiSegment<bool>(
                  value: false,
                  label: context.t.rankingsScore,
                  icon: const Icon(Icons.leaderboard_outlined),
                ),
              ],
              onChanged: (bool performance) => context.read<RankingsBloc>().add(
                RankingsTypeSelected(
                  RankingsType.select(type.ruleset, performance),
                ),
              ),
            ),
          ],
        ),
      ),
      const _CountryControl(),
      BlocSelector<RankingsBloc, RankingsState, (bool, ManiaVariant)>(
        selector: (RankingsState state) =>
            (state.type.ruleset == ProfileRuleset.mania, state.variant),
        builder: (BuildContext context, (bool, ManiaVariant) selection) =>
            selection.$1
            ? UiSegmentedControl<ManiaVariant>(
                selected: selection.$2,
                segments: <UiSegment<ManiaVariant>>[
                  for (final ManiaVariant variant in ManiaVariant.values)
                    UiSegment<ManiaVariant>(
                      value: variant,
                      label: switch (variant) {
                        ManiaVariant.all => context.t.rankingsAllKeys,
                        ManiaVariant.fourKeys => '4K',
                        ManiaVariant.sevenKeys => '7K',
                      },
                      icon: const Icon(Icons.piano),
                    ),
                ],
                onChanged: (ManiaVariant variant) => context
                    .read<RankingsBloc>()
                    .add(RankingsVariantSelected(variant)),
              )
            : const SizedBox.shrink(),
      ),
    ],
  );
}

final class _CountryControl extends StatefulWidget {
  const _CountryControl();
  @override
  State<_CountryControl> createState() => _CountryControlState();
}

final class _CountryControlState extends State<_CountryControl> {
  bool _choosing = false;
  String? _language;
  Future<List<RankingCountryOption>>? _names;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String language = Localizations.localeOf(context).languageCode;
    if (_language == language) return;
    _language = language;
    _names = context.read<RankingCountriesRepository>().load(
      languageCode: language,
    );
  }

  Future<void> _choose(String? selected) async {
    if (_choosing) return;
    setState(() => _choosing = true);
    final RankingsBloc bloc = context.read<RankingsBloc>();
    final RankingCountriesRepository repository = context
        .read<RankingCountriesRepository>();
    try {
      final ({RankingCountry? country})? choice =
          await UiModal.scrollable<({RankingCountry? country})>(
            context,
            title: context.t.rankingsCountrySelection,
            builder: (_) => RankingCountryPicker(
              repository: repository,
              selected: selected,
            ),
          );
      if (!mounted || bloc.isClosed || choice == null) return;
      bloc.add(RankingsCountrySelected(choice.country));
    } finally {
      if (mounted) setState(() => _choosing = false);
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocSelector<RankingsBloc, RankingsState, String?>(
        selector: (RankingsState state) => state.country?.value,
        builder: (BuildContext context, String? country) =>
            FutureBuilder<List<RankingCountryOption>>(
              future: _names,
              builder:
                  (
                    BuildContext context,
                    AsyncSnapshot<List<RankingCountryOption>> snapshot,
                  ) {
                    final String label = country == null
                        ? context.t.rankingsWorldwide
                        : snapshot.data
                                  ?.where(
                                    (RankingCountryOption item) =>
                                        item.country.value == country,
                                  )
                                  .firstOrNull
                                  ?.name ??
                              country;
                    return UiTile.navigation(
                      title: context.t.rankingsCountrySelection,
                      subtitle: label,
                      leading: country == null
                          ? const Icon(Icons.public)
                          : OsuCountryFlag(code: country, label: label),
                      onTap: _choosing ? null : () => _choose(country),
                    );
                  },
            ),
      );
}
