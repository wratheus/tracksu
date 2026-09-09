import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/sharing/share_destination.dart';
import 'package:tracksu/src/_shared/sharing/share_target.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Local preview only: selecting a destination is the first external action.
final class ShareSheet extends StatelessWidget {
  const ShareSheet({required this.target, super.key});
  final ShareTarget target;

  void _choose(BuildContext context, ShareDestination destination) {
    if (ModalRoute.of(context)?.isCurrent == true) {
      Navigator.of(context).pop(destination);
    }
  }

  @override
  Widget build(BuildContext context) => CustomScrollView(
    slivers: <Widget>[
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          UiSpace.lg,
          0,
          UiSpace.lg,
          UiSpace.xl,
        ),
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: UiSpace.lg,
            children: <Widget>[
              UiSurface.inset(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: UiSpace.sm,
                  children: <Widget>[
                    UiText.titleMedium(target.title),
                    UiText.bodySmall(
                      target.uri.toString(),
                      secondary: true,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) =>
                    Wrap(
                      spacing: UiSpace.md,
                      runSpacing: UiSpace.md,
                      children: <Widget>[
                        for (final (
                              ShareDestination destination,
                              String label,
                              IconData icon,
                            )
                            in <(ShareDestination, String, IconData)>[
                              (
                                ShareDestination.telegram,
                                'Telegram',
                                Icons.send_outlined,
                              ),
                              (
                                ShareDestination.whatsapp,
                                'WhatsApp',
                                Icons.chat_outlined,
                              ),
                              (
                                ShareDestination.facebook,
                                'Facebook',
                                Icons.public,
                              ),
                              (
                                ShareDestination.x,
                                'X / Twitter',
                                Icons.edit_outlined,
                              ),
                            ])
                          SizedBox(
                            width: constraints.maxWidth < 300
                                ? constraints.maxWidth
                                : (constraints.maxWidth - UiSpace.md) / 2,
                            child: UiButton.secondary(
                              label: label,
                              icon: icon,
                              onPressed: () => _choose(context, destination),
                            ),
                          ),
                      ],
                    ),
              ),
              UiButton.primary(
                label: context.t.shareSystem,
                icon: Icons.apps,
                onPressed: () => _choose(context, ShareDestination.system),
              ),
              UiButton.text(
                label: context.t.shareCopy,
                icon: Icons.copy_outlined,
                onPressed: () => _choose(context, ShareDestination.copy),
              ),
              UiText.bodySmall(
                context.t.shareDestinationNotice,
                secondary: true,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
