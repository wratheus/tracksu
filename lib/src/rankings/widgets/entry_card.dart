import 'package:flutter/material.dart';
import 'package:tracksu/src/_shared/navigation/team_navigation.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/l10n/localized_count.dart';
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
  Widget build(BuildContext context) {
    final LocalizedCount score = LocalizedCount(
      widget.entry.rankedScore,
      locale: Localizations.localeOf(context).toLanguageTag(),
    );
    final Widget card = TeamNavigation(
      teamId: widget.entry.team?.id,
      builder: (VoidCallback? openTeam) => OsuRankingRow(
        team: widget.entry.team,
        onTeamTap: openTeam,
        username: widget.entry.username,
        country: widget.entry.country,
        avatar: widget.entry.avatarUri == null
            ? null
            : NetworkImage(widget.entry.avatarUri.toString()),
        value: widget.type.sort == 'performance'
            ? NumberFormat.decimalPatternDigits(
                locale: context.t.localeName,
                decimalDigits: 0,
              ).format(widget.entry.pp)
            : score.compact,
        valueLabel: widget.type.sort == 'performance'
            ? 'PP'
            : context.t.profileRankedScoreLabel,
        position:
            '#${NumberFormat.decimalPattern(context.t.localeName).format(widget.entry.position)}',
        onTap: _opening ? null : _open,
      ),
    );
    return widget.type.sort == 'performance'
        ? card
        : Tooltip(
            message: '${context.t.profileRankedScoreLabel}: ${score.exact}',
            child: card,
          );
  }
}
