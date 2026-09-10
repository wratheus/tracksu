import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/scores/domain/score.dart';
import 'package:tracksu/src/_shared/scores/domain/score_details.dart';
import 'package:tracksu/src/_shared/scores/widgets/score_details_sheet.dart';
import 'package:tracksu/src/_shared/ui/osu_ui.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class OsuScoreCard extends StatefulWidget {
  const OsuScoreCard({
    required this.score,
    this.onTap,
    this.onOpenPlayer,
    this.playerLabel,
    this.playerAvatar,
    this.coverUri,
    super.key,
  });
  final OsuScore score;

  /// A leaderboard already establishes map context, so lead with the player.
  final String? playerLabel;
  final Uri? playerAvatar;
  final Uri? coverUri;

  /// Optional navigation to the map, offered after inspecting the result.
  final VoidCallback? onTap;
  final VoidCallback? onOpenPlayer;

  @override
  State<OsuScoreCard> createState() => _OsuScoreCardState();
}

final class _OsuScoreCardState extends State<OsuScoreCard> {
  bool _detailsOpen = false;
  OsuScore get score => widget.score;
  VoidCallback? get onTap => widget.onTap;

  Future<void> _showDetails(BuildContext context) async {
    if (_detailsOpen) return;
    _detailsOpen = true;
    try {
      final OsuScore selectedScore = score;
      final VoidCallback? openBeatmap = onTap;
      final VoidCallback? openPlayer = widget.onOpenPlayer;
      final String? playerLabel = widget.playerLabel;
      final ScoreDetailsAction? action =
          await UiModal.scrollable<ScoreDetailsAction>(
            context,
            title: context.t.scoreDetailsTitle,
            cover: (widget.coverUri ?? selectedScore.coverUri) == null
                ? null
                : UiCover(
                    image: NetworkImage(
                      (widget.coverUri ?? selectedScore.coverUri).toString(),
                    ),
                    aspectRatio: 3,
                  ),
            builder: (BuildContext context) => ScoreDetailsSheet(
              score: selectedScore,
              canOpenMap: openBeatmap != null,
              canOpenPlayer: openPlayer != null,
              playerLabel: playerLabel,
              playerAvatar: widget.playerAvatar,
            ),
          );
      if (!context.mounted) return;
      switch (action) {
        case ScoreDetailsAction.beatmap:
          openBeatmap?.call();
        case ScoreDetailsAction.player:
          openPlayer?.call();
        case null:
          break;
      }
    } finally {
      _detailsOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String date = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).add_Hm().format(score.endedAt.toLocal());
    final String locale = Localizations.localeOf(context).toLanguageTag();
    return OsuPlayCard(
      leading: widget.playerLabel == null
          ? null
          : UiAvatar.medium(
              name: widget.playerLabel!,
              image: widget.playerAvatar == null
                  ? null
                  : NetworkImage(widget.playerAvatar.toString()),
            ),
      title:
          widget.playerLabel ??
          score.beatmapTitle ??
          context.t.scoresBeatmap(score.beatmapId),
      artist: score.artist,
      difficulty: score.difficulty,
      grade: score.rank,
      gradeLabel: context.t.scoresGrade(score.rank),
      accuracyLabel: NumberFormat.decimalPercentPattern(
        locale: locale,
        decimalDigits: 2,
      ).format(score.accuracy),
      comboLabel:
          '${NumberFormat.decimalPattern(locale).format(score.maximumCombo)}×',
      performanceLabel: score.performancePoints == null
          ? context.t.scoresNoPp
          : '${NumberFormat.decimalPatternDigits(locale: locale, decimalDigits: 0).format(score.performancePoints)} pp',
      failureLabel: score.passed ? null : context.t.scoresFailedPlay,
      mods: score.mods
          .map((ScoreMod mod) => mod.acronym)
          .toList(growable: false),
      noModsLabel: context.t.scoresNoMods,
      dateLabel: date,
      onTap: () => _showDetails(context),
    );
  }
}
