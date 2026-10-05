import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/rankings/domain/rankings_repository.dart';
import 'package:tracksu/src/rankings/country_stats/bloc/bloc.dart';
import 'package:tracksu/src/rankings/country_stats/domain/country_ranking.dart';
import 'package:tracksu/src/rankings/domain/countries.dart';
import 'package:tracksu/src/rankings/country_stats/widgets/country_card.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Country ranking list. The ruleset comes from the shared filters above it;
/// tapping a country opens the player table filtered to it. Refresh is
/// pull-to-refresh, progress is the app-bar line.
final class CountryRankingsSection extends StatefulWidget {
  const CountryRankingsSection({
    required this.onOpenCountry,
    required this.performance,
    super.key,
  });
  final ValueChanged<CountryRankingEntry> onOpenCountry;

  /// Shared PP/score view; the order is PP either way (osu! API).
  final bool performance;

  @override
  State<CountryRankingsSection> createState() => _CountryRankingsSectionState();
}

final class _CountryRankingsSectionState extends State<CountryRankingsSection> {
  String? _language;
  Map<String, String> _names = const <String, String>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String language = Localizations.localeOf(context).languageCode;
    if (_language == language) return;
    _language = language;
    context
        .read<RankingCountriesRepository>()
        .load(languageCode: language)
        .then((List<RankingCountryOption> options) {
          if (!mounted || _language != language) return;
          setState(
            () => _names = <String, String>{
              for (final RankingCountryOption o in options)
                o.country.value: o.name,
            },
          );
        }, onError: (Object _) {});
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CountryRankingsBloc, CountryRankingsState>(
        builder: (BuildContext context, CountryRankingsState state) {
          final List<CountryRankingEntry>? items = state.items;
          if (items == null) {
            final RankingsFailureKind? failure = state.failure;
            return SliverToBoxAdapter(
              child: failure != null
                  ? _Error(failure: failure)
                  : UiPageSkeleton.list(label: context.t.rankingsCountries),
            );
          }
          return SliverMainAxisGroup(
            slivers: <Widget>[
              if (state.failure case final RankingsFailureKind failure
                  when state.failedOperation == CountryRankingsOperation.refresh)
                SliverToBoxAdapter(
                  child: _Error(failure: failure, keepingContent: true),
                ),
              if (items.isEmpty)
                SliverToBoxAdapter(
                  child: UiContentState.empty(title: context.t.rankingsEmpty),
                ),
              SliverPadding(
                key: const ValueKey<String>('country-rankings-list'),
                padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg),
                sliver: UiSliverCardList(
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) =>
                      CountryRankingCard(
                        key: ValueKey<String>(items[index].country.value),
                        entry: items[index],
                        name:
                            _names[items[index].country.value] ??
                            items[index].country.value,
                        performance: widget.performance,
                        onTap: () => widget.onOpenCountry(items[index]),
                      ),
                ),
              ),
              if (state.nextPage != null &&
                  state.operation == null &&
                  state.failure == null)
                UiSliverAutoLoad(
                  pageKey: (state.ruleset, state.nextPage),
                  label: context.t.rankingsLoading,
                  onLoad: () => context.read<CountryRankingsBloc>().add(
                    const CountryRankingsMoreRequested(),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: UiSpace.xl),
                  child: switch (state) {
                    CountryRankingsState(
                      operation: CountryRankingsOperation.loadMore,
                    ) =>
                      Padding(
                        padding: const EdgeInsets.all(UiSpace.lg),
                        child: UiLoading(label: context.t.rankingsLoading),
                      ),
                    CountryRankingsState(
                      failure: final RankingsFailureKind failure,
                      failedOperation: CountryRankingsOperation.loadMore,
                    ) =>
                      _Error(failure: failure, more: true),
                    _ when state.nextPage == null && items.isNotEmpty => Center(
                      child: UiText.bodySmall(
                        context.t.rankingsEnd,
                        secondary: true,
                      ),
                    ),
                    _ => const SizedBox.shrink(),
                  },
                ),
              ),
            ],
          );
        },
      );
}

final class _Error extends StatelessWidget {
  const _Error({
    required this.failure,
    this.keepingContent = false,
    this.more = false,
  });
  final RankingsFailureKind failure;
  final bool keepingContent;
  final bool more;

  @override
  Widget build(BuildContext context) => UiContentState.error(
    title: switch (failure) {
      RankingsFailureKind.cancelled => context.t.rankingsCancelled,
      RankingsFailureKind.notFound => context.t.rankingsNotFound,
      RankingsFailureKind.accessDenied => context.t.rankingsAccessDenied,
      RankingsFailureKind.rateLimited => context.t.profileRateLimited,
      RankingsFailureKind.connection => context.t.profileConnectionFailed,
      RankingsFailureKind.invalidResponse => context.t.rankingsInvalidResponse,
      RankingsFailureKind.unavailable => context.t.rankingsUnavailable,
    },
    message: keepingContent ? context.t.rankingsKeepingContent : null,
    actionLabel: context.t.retry,
    onAction: () => context.read<CountryRankingsBloc>().add(
      more
          ? const CountryRankingsMoreRequested()
          : const CountryRankingsRefreshRequested(),
    ),
  );
}
