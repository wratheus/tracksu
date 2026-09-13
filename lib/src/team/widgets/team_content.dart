import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/content/content_media_controller.dart';
import 'package:tracksu/src/_shared/content/domain/public_web_link.dart';
import 'package:tracksu/src/_shared/content/widgets/content_frame.dart';
import 'package:tracksu/src/_shared/ui/osu_ui.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/team/bloc/bloc.dart';
import 'package:tracksu/src/team/domain/team.dart';
import 'package:tracksu/src/team/widgets/member_row.dart';
import 'package:tracksu_ui/tracksu_ui.dart';
import 'package:url_launcher/url_launcher.dart';

final class TeamContent extends StatelessWidget {
  const TeamContent({
    required this.data,
    required this.selectedMode,
    required this.mediaPermission,
    super.key,
  });
  final TeamDetails data;
  final ProfileRuleset selectedMode;
  final ContentMediaController mediaPermission;

  Future<bool> _link(String url) async {
    final Uri? uri = PublicWebLink.resolve(url, base: data.uri);
    if (uri == null) return false;
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat number = NumberFormat.decimalPattern(
      context.t.localeName,
    );
    final NumberFormat integer = NumberFormat.decimalPatternDigits(
      locale: context.t.localeName,
      decimalDigits: 0,
    );
    final TeamStatistics stats = data.statistics;
    return SliverPadding(
      padding: const EdgeInsets.all(UiSpace.lg),
      sliver: SliverMainAxisGroup(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: UiSurface.card(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (data.cover case final Uri cover)
                    UiCover(
                      image: NetworkImage(cover.toString()),
                      aspectRatio: 3,
                    ),
                  Padding(
                    padding: const EdgeInsets.all(UiSpace.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: UiSpace.md,
                      children: <Widget>[
                        Row(
                          spacing: UiSpace.md,
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(UiSpace.sm),
                              child: UiImage(
                                image: data.identity.flagUri == null
                                    ? null
                                    : NetworkImage(
                                        data.identity.flagUri.toString(),
                                      ),
                                width: 56,
                                height: 40,
                                fallback: const Icon(Icons.groups_outlined),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  UiText.headlineSmall(data.identity.name),
                                  UiText.titleMedium(
                                    '[${data.identity.shortName}]',
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Wrap(
                          spacing: UiSpace.sm,
                          runSpacing: UiSpace.sm,
                          children: <Widget>[
                            if (data.isOpen)
                              UiBadge.positive(
                                context.t.teamOpen,
                                icon: Icons.person_add_alt,
                              )
                            else
                              UiBadge.neutral(
                                context.t.teamClosed,
                                icon: Icons.lock_outline,
                              ),
                            UiBadge.neutral(
                              context.t.teamMembers(data.members.length + 1),
                              icon: Icons.groups_outlined,
                            ),
                            UiBadge.neutral(
                              context.t.teamSlots(data.emptySlots),
                            ),
                          ],
                        ),
                        UiText.bodySmall(
                          context.t.teamCreated(
                            DateFormat.yMMMd(context.t.localeName)
                                .format(data.createdAt.toLocal()),
                          ),
                          secondary: true,
                        ),
                        UiText.bodySmall(
                          context.t.teamDefaultMode(
                            OsuRulesetSelector.label(
                              context,
                              data.defaultRuleset,
                            ),
                          ),
                          secondary: true,
                        ),
                        UiButton.text(
                          label: context.t.contentOriginal,
                          icon: Icons.open_in_new,
                          onPressed: () async {
                            if (!await _link(data.uri.toString()) &&
                                context.mounted) {
                              UiFeedback.snack(
                                context,
                                message: context.t.contentLinkFailed,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: UiSpace.lg),
              child: Column(
                spacing: UiSpace.md,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  OsuRulesetSelector(
                    selected: selectedMode,
                    onChanged: (ProfileRuleset mode) =>
                        context.read<TeamBloc>().add(TeamModeSelected(mode)),
                  ),
                  if (selectedMode != data.ruleset)
                    UiNotice(
                      message: context.t.profileShowingPreviousData,
                      tone: UiNoticeTone.warning,
                    ),
                  UiSurface.card(
                    child: Column(
                      spacing: UiSpace.md,
                      children: <Widget>[
                        UiMetricGroup(
                          children: <UiMetric>[
                            if (stats.rank case final int rank)
                              UiMetric.compact(
                                label: context.t.profileGlobalRankLabel,
                                value: '#${number.format(rank)}',
                                tone: UiMetricTone.tertiary,
                                icon: Icons.leaderboard_outlined,
                              ),
                            UiMetric.compact(
                              label: 'PP',
                              value: integer.format(stats.performance),
                              tone: UiMetricTone.primary,
                              icon: Icons.bolt_outlined,
                            ),
                          ],
                        ),
                        UiMetric.row(
                          label: context.t.profilePlayCountLabel,
                          value: number.format(stats.playCount),
                          icon: Icons.play_circle_outline,
                        ),
                        UiMetric.row(
                          label: context.t.profileRankedScoreLabel,
                          value: number.format(stats.rankedScore),
                          icon: Icons.scoreboard_outlined,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (data.description case final description?) ...<Widget>[
            _heading(context.t.teamDescription),
            if (description.document case final document?)
              ContentFrame.sliver(
                document: document,
                onOpenLink: _link,
                mediaPermission: mediaPermission,
              )
            else
              SliverToBoxAdapter(
                child: UiButton.text(
                  label: context.t.contentOriginal,
                  onPressed: () => _link(data.uri.toString()),
                ),
              ),
          ],
          _heading(context.t.teamLeader),
          SliverToBoxAdapter(
            child: TeamMemberRow(member: data.leader, mode: data.ruleset),
          ),
          if (data.members.isNotEmpty) ...<Widget>[
            _heading(context.t.teamMembers(data.members.length + 1)),
            UiSliverCardList(
              itemCount: data.members.length,
              itemBuilder: (_, int index) => TeamMemberRow(
                member: data.members[index],
                mode: data.ruleset,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _heading(String text) => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: UiSpace.md),
      child: UiText.titleLarge(text),
    ),
  );
}
