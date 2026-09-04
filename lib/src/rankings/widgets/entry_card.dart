import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/rankings/domain/entry.dart';

final class RankingEntryCard extends StatefulWidget {
  const RankingEntryCard({
    required this.entry,
    required this.onOpen,
    super.key,
  });
  final RankingEntry entry;
  final Future<void> Function() onOpen;

  @override
  State<RankingEntryCard> createState() => _RankingEntryCardState();
}

final class _RankingEntryCardState extends State<RankingEntryCard> {
  bool _opening = false;

  Future<void> _open() async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      await widget.onOpen();
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: _opening ? null : _open,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5,
          children: <Widget>[
            Text(
              widget.entry.username,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(widget.entry.country),
            Text(context.t.profilePerformance(widget.entry.pp)),
            Text(context.t.rankingsRankedScore(widget.entry.rankedScore)),
          ],
        ),
      ),
    ),
  );
}
