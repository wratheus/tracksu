import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/ui/osu_ui.dart';
import 'package:tracksu/src/profile/bloc/bloc.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/widgets/profile_content.dart';
import 'package:tracksu/src/profile/widgets/profile_error_message.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: BlocSelector<ProfileBloc, ProfileState, String?>(
        selector: (ProfileState state) =>
            state is ProfileLoadedState ? state.profile.username : null,
        builder: (BuildContext context, String? username) => UiText.titleLarge(
          username ?? context.t.profileTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      actions: <Widget>[
        BlocSelector<ProfileBloc, ProfileState, bool>(
          selector: (ProfileState state) =>
              state is ProfileInitialState ||
              state is ProfileLoadingState ||
              (state is ProfileLoadedState && state.isBusy),
          builder: (BuildContext context, bool busy) => UiIconButton.standard(
            tooltip: context.t.profileRefresh,
            icon: Icons.refresh,
            onPressed: busy
                ? null
                : () => context.read<ProfileBloc>().add(
                    const ProfileRefreshRequested(),
                  ),
          ),
        ),
      ],
    ),
    body: SafeArea(
      top: false,
      child: Column(
        children: <Widget>[
          BlocSelector<ProfileBloc, ProfileState, ProfileRuleset>(
            selector: (ProfileState state) => switch (state) {
              ProfileLoadedState(:final requestedRuleset) =>
                requestedRuleset ?? state.ruleset,
              _ => state.ruleset,
            },
            builder: (BuildContext context, ProfileRuleset selected) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg),
              child: OsuRulesetSelector(
                selected: selected,
                onChanged: (ProfileRuleset mode) => context
                    .read<ProfileBloc>()
                    .add(ProfileRulesetSelected(mode)),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (BuildContext context, ProfileState state) =>
                  switch (state) {
                    ProfileInitialState() || ProfileLoadingState() => Center(
                      child: UiContentState.loading(
                        title: context.t.profileLoading,
                      ),
                    ),
                    ProfileFailureState(:final failure) => Center(
                      child: ProfileErrorMessage(failure: failure),
                    ),
                    ProfileLoadedState() => ProfileContent(
                      key: ValueKey<int>(state.profile.id),
                      state: state,
                    ),
                  },
            ),
          ),
        ],
      ),
    ),
  );
}
