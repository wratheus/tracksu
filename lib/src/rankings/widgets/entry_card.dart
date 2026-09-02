import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/rankings/domain/entry.dart';

final class RankingEntryCard extends StatelessWidget {
  const RankingEntryCard({required this.entry, super.key});
  final RankingEntry entry;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 5,
        children: <Widget>[
          Text(entry.username, style: Theme.of(context).textTheme.titleMedium),
          Text(entry.country),
          Text(context.t.profilePerformance(entry.pp)),
          Text(context.t.rankingsRankedScore(entry.rankedScore)),
        ],
      ),
    ),
  );
}
