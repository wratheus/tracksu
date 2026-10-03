import 'package:tracksu/src/_shared/media/widgets/app_media.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/ui/avatar_bands.dart';
import 'package:tracksu/src/_shared/ui/osu_ui.dart';
import 'package:tracksu/src/profile/domain/profile_params.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';
import 'package:tracksu/src/profile/domain/profile_details.dart';
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
    // One presence line: online, last seen, or plain offline — not both.
    final String presence = member.online
        ? context.t.profileOnline
        : member.lastVisit == null
        ? context.t.profileOffline
        : context.t.teamLastVisit(
            DateFormat.yMMMd(
              context.t.localeName,
            ).format(member.lastVisit!.toLocal()),
          );
    return UiSurface.card(
      padding: const EdgeInsets.all(UiSpace.md),
      onTap: _opening || member.deleted ? null : _open,
      child: Row(
        spacing: UiSpace.sm,
        children: <Widget>[
          Expanded(
            child: OsuAvatarBands(
              avatar: UiAvatar.medium(
                name: member.name,
                image: member.avatar == null
                    ? null
                    : AppMedia.image(context, member.avatar),
              ),
              // Name, then the supporter heart right beside it, then groups.
              top: Wrap(
                spacing: UiSpace.sm,
                runSpacing: UiSpace.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: UiSpace.xs,
                    children: <Widget>[
                      Flexible(
                        child: UiText.titleMedium(member.name, maxLines: 1),
                      ),
                      if (member.supporter) const OsuSupporterHeart(),
                    ],
                  ),
                  for (final ProfileGroup group in member.groups)
                    UiBadge.neutral(group.name),
                ],
              ),
              bottom: Row(
                spacing: UiSpace.sm,
                children: <Widget>[
                  OsuCountryFlag(
                    code: member.country,
                    label: context.t.profileCountry(member.country),
                  ),
                  Flexible(
                    child: OsuPresence(
                      online: member.online,
                      label: presence,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!member.deleted) const Icon(Icons.chevron_right, size: 20),
        ],
      ),
    );
  }
}
