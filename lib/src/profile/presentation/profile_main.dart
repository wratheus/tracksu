import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/profile/domain/profile.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/presentation/profile_bloc.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';

final class ProfileMain extends StatelessWidget {
  const ProfileMain({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      create: (BuildContext context) => ProfileBloc(
        repository: DepsScope.of(context).profileRepository,
      )..add(const CurrentProfileLoadRequested(ruleset: ProfileRuleset.osu)),
      child: const ProfileScreen(),
    );
  }
}

final class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

final class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _searchController = TextEditingController();
  var _ruleset = ProfileRuleset.osu;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch(String value) {
    final String query = value.trim();
    if (query.isEmpty) {
      return;
    }

    final int? id = int.tryParse(query);
    final ProfileUserReference user = id == null
        ? ProfileUsername(query)
        : ProfileUserId(id);
    context.read<ProfileBloc>().add(
      ProfileLookupRequested(user: user, ruleset: _ruleset),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.profileTitle),
        actions: <Widget>[
          PopupMenuButton<ProfileRuleset>(
            onSelected: (ProfileRuleset ruleset) {
              setState(() {
                _ruleset = ruleset;
              });
              context.read<ProfileBloc>().add(
                CurrentProfileLoadRequested(ruleset: ruleset),
              );
            },
            itemBuilder: (BuildContext context) => ProfileRuleset.values
                .map(
                  (ProfileRuleset ruleset) => PopupMenuItem<ProfileRuleset>(
                    value: ruleset,
                    child: Text(_rulesetLabel(context, ruleset)),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: _submitSearch,
              decoration: InputDecoration(
                hintText: context.t.profileSearchHint,
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (BuildContext context, ProfileState state) =>
                  switch (state) {
                    ProfileInitialState() || ProfileLoadingState() => Center(
                      child: Text(context.t.profileLoading),
                    ),
                    ProfileFailureState(:final request) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(context.t.profileUnavailable),
                          TextButton(
                            onPressed: () =>
                                context.read<ProfileBloc>().add(request),
                            child: Text(context.t.retry),
                          ),
                        ],
                      ),
                    ),
                    ProfileLoadedState(:final Profile profile) =>
                      CustomScrollView(
                        slivers: <Widget>[
                          SliverPadding(
                            padding: const EdgeInsets.all(24),
                            sliver: SliverList.list(
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage: NetworkImage(
                                    profile.avatarUri.toString(),
                                  ),
                                ),
                                Text(profile.username),
                                Text(context.t.profileId(profile.id)),
                                Text(
                                  context.t.profileCountry(profile.countryCode),
                                ),
                                if (profile.statistics
                                    case final ProfileStatistics statistics)
                                  Text(
                                    context.t.profilePerformance(
                                      statistics.performancePoints,
                                    ),
                                  ),
                                if (profile.statistics
                                    case final ProfileStatistics statistics)
                                  Text(
                                    context.t.profileAccuracy(
                                      statistics.hitAccuracy,
                                    ),
                                  ),
                                if (profile.statistics
                                    case final ProfileStatistics statistics)
                                  Text(
                                    context.t.profilePlayCount(
                                      statistics.playCount,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  },
            ),
          ),
        ],
      ),
    );
  }
}

String _rulesetLabel(BuildContext context, ProfileRuleset ruleset) {
  return switch (ruleset) {
    ProfileRuleset.osu => context.t.rulesetOsu,
    ProfileRuleset.taiko => context.t.rulesetTaiko,
    ProfileRuleset.fruits => context.t.rulesetFruits,
    ProfileRuleset.mania => context.t.rulesetMania,
  };
}
