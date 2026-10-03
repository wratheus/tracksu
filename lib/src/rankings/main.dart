import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:flutter/material.dart';
import 'package:tracksu/src/_shared/navigation/shell_reselect.dart';
import 'package:tracksu/src/_shared/preferences/settings_button.dart';
import 'package:tracksu/src/_shared/sharing/share_button.dart';
import 'package:tracksu/src/_shared/sharing/share_target.dart';
import 'package:tracksu/src/rankings/domain/rankings_query.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/rankings/bloc/bloc.dart';
import 'package:tracksu/src/rankings/data/rankings_remote_source.dart';
import 'package:tracksu/src/rankings/data/rankings_repository_impl.dart';
import 'package:tracksu/src/rankings/data/countries_local_source.dart';
import 'package:tracksu/src/rankings/data/countries_repository_impl.dart';
import 'package:tracksu/src/rankings/domain/countries.dart';
import 'package:tracksu/src/rankings/widgets/rankings_section.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Owns this route's repository and Bloc.
final class RankingsMain extends StatelessWidget {
  const RankingsMain({super.key});

  @override
  Widget build(BuildContext context) =>
      RepositoryProvider<RankingCountriesRepository>(
        create: (_) => RankingCountriesRepositoryImpl(
          source: const AssetRankingCountriesLocalSource(),
        ),
        child: BlocProvider<RankingsBloc>(
          create: (_) => RankingsBloc(
            cache: DepsScope.of(context).pageCache,
            repository: RankingsRepositoryImpl(
              remoteSource: OsuRankingsRemoteSource(
                restClient: DepsScope.of(context).publicRestClient,
              ),
            ),
          )..add(const RankingsStarted()),
          child: Scaffold(
            appBar: AppBar(
              title: UiText.titleLarge(context.t.rankingsTitle),
              actions: <Widget>[
                const SettingsButton(),
                BlocBuilder<RankingsBloc, RankingsState>(
                  builder: (BuildContext context, RankingsState state) =>
                      ShareButton.icon(
                        target: ShareTarget.rankings(
                          RankingsQuery(
                            type: state.type,
                            country: state.country,
                            variant: state.variant,
                          ),
                          context.t.rankingsTitle,
                        ),
                      ),
                ),
              ],
              bottom: UiAppBarProgressSlot(
                child: BlocSelector<RankingsBloc, RankingsState, bool>(
                  selector: (RankingsState state) =>
                      state is RankingsLoadedState &&
                      state.operation == RankingsOperation.refresh,
                  builder: (BuildContext context, bool busy) =>
                      UiAppBarProgress(
                        visible: busy,
                        semanticsLabel: context.t.rankingsLoading,
                      ),
                ),
              ),
            ),
            body: const SafeArea(child: _RankingsBody()),
          ),
        ),
      );
}

final class _RankingsBody extends StatefulWidget {
  const _RankingsBody();
  @override
  State<_RankingsBody> createState() => _RankingsBodyState();
}

final class _RankingsBodyState extends State<_RankingsBody> {
  final ScrollController _scroll = ScrollController();
  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<RankingsBloc, RankingsState>(
        listenWhen: (RankingsState before, RankingsState after) =>
            (before.type, before.country?.value, before.variant) !=
            (after.type, after.country?.value, after.variant),
        listener: (_, _) {
          if (_scroll.hasClients) _scroll.jumpTo(0);
        },
        child: UiScrollToTop(
          tooltip: context.t.scrollToTop,
          controller: _scroll,
          scrollRequests: ShellReselectScope.maybeOf(
            context,
            ShellTab.rankings,
          ),
          // Pull down to refresh; the spinner retracts at once and progress
          // continues on the app-bar line instead of a button and a loader.
          child: RefreshIndicator(
            onRefresh: () async {
              final RankingsBloc bloc = context.read<RankingsBloc>();
              if (bloc.state is RankingsLoadedState) {
                bloc.add(const RankingsRefreshRequested());
              }
            },
            child: CustomScrollView(
              controller: _scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[
                const RankingsSection(),
                UiSliverScrollToTopSpace(tooltip: context.t.scrollToTop),
              ],
            ),
          ),
        ),
      );
}
