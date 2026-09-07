import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/rankings/domain/entry.dart';
import 'package:tracksu/src/_shared/ui/osu_ui.dart';

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
  Widget build(BuildContext context) => OsuPlayerCard.compact(
    username: widget.entry.username,
    countryCode: widget.entry.country,
    countryLabel: widget.entry.country,
    performanceLabel: context.t.profilePerformance(widget.entry.pp),
    rankLabel: context.t.rankingsRankedScore(widget.entry.rankedScore),
    onTap: _opening ? null : _open,
  );
}
