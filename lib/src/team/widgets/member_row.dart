import 'package:tracksu/src/_shared/media/widgets/app_media.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/ui/osu_ui.dart';
import 'package:tracksu/src/profile/domain/profile_params.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';
import 'package:tracksu/src/team/domain/team.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class TeamMemberRow extends StatefulWidget {
  const TeamMemberRow({required this.member, required this.mode, super.key});
  final TeamMember member;
  final ProfileRuleset mode;
  @override
  State<TeamMemberRow> createState() => _TeamMemberRowState();
}

final class _TeamMemberRowState extends State<TeamMemberRow> {
  bool _opening = false;
  Future<void> _open() async {
    if (_opening || widget.member.deleted) return;
    setState(() => _opening = true);
    try {
      await DepsScope.of(context).appRouter.openProfile(
        context,
        ProfileParams(
          user: ProfileUserId(widget.member.id),
          ruleset: widget.mode,
        ),
      );
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TeamMember member = widget.member;
    return UiSurface.card(
      padding: const EdgeInsets.all(UiSpace.md),
      onTap: _opening || member.deleted ? null : _open,
      child: Row(
        spacing: UiSpace.md,
        children: <Widget>[
          UiAvatar.small(
            name: member.name,
            image: member.avatar == null
                ? null
                : AppMedia.image(context, member.avatar),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: UiSpace.xs,
              children: <Widget>[
                UiText.titleMedium(member.name),
                Wrap(
                  spacing: UiSpace.sm,
                  runSpacing: UiSpace.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    OsuCountryFlag(
                      code: member.country,
                      label: context.t.profileCountry(member.country),
                    ),
                    UiText.bodySmall(
                      member.online
                          ? context.t.profileOnline
                          : context.t.profileOffline,
                      secondary: true,
                    ),
                    if (member.supporter) const Icon(Icons.favorite, size: 16),
                  ],
                ),
                if (member.lastVisit case final DateTime visit
                    when !member.online)
                  UiText.bodySmall(
                    context.t.teamLastVisit(
                      DateFormat.yMMMd(context.t.localeName)
                          .format(visit.toLocal()),
                    ),
                    secondary: true,
                  ),
                if (member.groups.isNotEmpty)
                  Wrap(
                    spacing: UiSpace.xs,
                    runSpacing: UiSpace.xs,
                    children: member.groups
                        .map((group) => UiBadge.neutral(group.name))
                        .toList(),
                  ),
              ],
            ),
          ),
          if (!member.deleted) const Icon(Icons.chevron_right, size: 20),
        ],
      ),
    );
  }
}
