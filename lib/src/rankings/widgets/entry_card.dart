import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/rankings/domain/entry.dart';
import 'package:tracksu/src/_shared/ui/osu_ui.dart';
import 'package:tracksu/src/rankings/domain/rankings_query.dart';

final class RankingEntryCard extends StatefulWidget {
  const RankingEntryCard({
    required this.entry,
    required this.onOpen,
    required this.type,
    super.key,
  });
  final RankingEntry entry;
  final RankingsType type;
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
    avatar: widget.entry.avatarUri == null
        ? null
        : NetworkImage(widget.entry.avatarUri.toString()),
    performanceLabel: widget.type.sort == 'performance'
        ? context.t.profilePerformance(widget.entry.pp)
        : context.t.rankingsRankedScore(widget.entry.rankedScore),
    rankLabel: context.t.rankingsPosition(widget.entry.position),
    onTap: _opening ? null : _open,
  );
}
