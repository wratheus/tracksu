import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/ui/osu_ui.dart';
import 'package:tracksu/src/guest/widgets/account_actions.dart';
import 'package:tracksu/src/profile/domain/profile_params.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Guest landing: query/ruleset stay here while profiles open as detail pages.
final class SearchHome extends StatefulWidget {
  const SearchHome({super.key});

  @override
  State<SearchHome> createState() => _SearchHomeState();
}

final class _SearchHomeState extends State<SearchHome> {
  final TextEditingController _query = TextEditingController();
  ProfileRuleset _ruleset = ProfileRuleset.osu;
  bool _invalid = false;
  bool _opening = false;

  Future<void> _submit() async {
    if (_opening) return;
    final String value = _query.text.trim();
    final ProfileUserReference user;
    try {
      user = ProfileUserReference.fromInput(value);
    } on ArgumentError {
      setState(() => _invalid = true);
      return;
    }
    setState(() {
      _invalid = false;
      _opening = true;
    });
    FocusScope.of(context).unfocus();
    try {
      await DepsScope.of(context).appRouter
          .openProfile(context, ProfileParams(user: user, ruleset: _ruleset));
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: UiText.titleLarge(context.t.appTitle),
      actions: const <Widget>[AccountActions()],
    ),
    body: SafeArea(
      top: false,
      child: CustomScrollView(
        key: const PageStorageKey<String>('search_home'),
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.all(UiSpace.lg),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: UiSpace.lg,
                children: <Widget>[
                  UiText.headlineMedium(context.t.profileSearch),
                  UiText.bodyLarge(context.t.profileSearchIntroduction),
                  UiSurface.card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: UiSpace.lg,
                      children: <Widget>[
                        OsuRulesetSelector(
                          selected: _ruleset,
                          onChanged: (ProfileRuleset value) =>
                              setState(() => _ruleset = value),
                        ),
                        UiSearchField(
                          controller: _query,
                          label: context.t.profileSearchHint,
                          helperText: context.t.profileSearchHelp,
                          clearLabel: context.t.searchClear,
                          errorText: _invalid
                              ? context.t.profileSearchInvalid
                              : null,
                          onSubmitted: (_) => _submit(),
                          onChanged: (_) {
                            if (_invalid) setState(() => _invalid = false);
                          },
                        ),
                        UiButton.primary(
                          label: context.t.profileSearch,
                          icon: Icons.search,
                          onPressed: _opening ? null : _submit,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
