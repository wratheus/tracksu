import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/rankings/bloc/bloc.dart';
import 'package:tracksu/src/rankings/domain/rankings_query.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class RankingsFilters extends StatelessWidget {
  const RankingsFilters({super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 10,
    children: <Widget>[
      BlocSelector<RankingsBloc, RankingsState, String?>(
        selector: (RankingsState state) => state.country?.value,
        builder: (BuildContext context, String? country) =>
            _CountryField(key: ValueKey<String?>(country), country: country),
      ),
      BlocSelector<RankingsBloc, RankingsState, (bool, ManiaVariant)>(
        selector: (RankingsState state) =>
            (state.type.ruleset == ProfileRuleset.mania, state.variant),
        builder: (BuildContext context, (bool, ManiaVariant) selection) =>
            selection.$1
            ? Wrap(
                spacing: 10,
                children: <Widget>[
                  for (final ManiaVariant variant in ManiaVariant.values)
                    ChoiceChip(
                      selected: variant == selection.$2,
                      label: Text(switch (variant) {
                        ManiaVariant.all => context.t.rankingsAllKeys,
                        ManiaVariant.fourKeys => '4K',
                        ManiaVariant.sevenKeys => '7K',
                      }),
                      onSelected: (_) => context.read<RankingsBloc>().add(
                        RankingsVariantSelected(variant),
                      ),
                    ),
                ],
              )
            : const SizedBox.shrink(),
      ),
    ],
  );
}

final class _CountryField extends StatefulWidget {
  const _CountryField({required this.country, super.key});
  final String? country;
  @override
  State<_CountryField> createState() => _CountryFieldState();
}

final class _CountryFieldState extends State<_CountryField> {
  late final TextEditingController _controller;
  bool _invalid = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.country ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _apply() {
    final String text = _controller.text.trim();
    final RankingCountry? country;
    try {
      country = text.isEmpty ? null : RankingCountry(text);
    } on FormatException {
      setState(() => _invalid = true);
      return;
    }
    _controller.text = country?.value ?? '';
    setState(() => _invalid = false);
    FocusScope.of(context).unfocus();
    context.read<RankingsBloc>().add(RankingsCountrySelected(country));
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 5,
    children: <Widget>[
      UiSearchField(
        controller: _controller,
        label: context.t.rankingsCountry,
        clearLabel: context.t.rankingsWorldwide,
        helperText: context.t.rankingsCountryHint,
        errorText: _invalid ? context.t.rankingsCountryInvalid : null,
        onSubmitted: (_) => _apply(),
      ),
      Wrap(
        spacing: 10,
        children: <Widget>[
          UiButton.text(label: context.t.rankingsApply, onPressed: _apply),
          UiButton.text(
            onPressed: () {
              _controller.clear();
              _apply();
            },
            label: context.t.rankingsWorldwide,
          ),
        ],
      ),
    ],
  );
}
