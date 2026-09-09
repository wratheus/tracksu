import 'package:flutter/material.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Public group/team identity. Server colour is an accent, never text contrast.
final class OsuAffiliationTile extends StatelessWidget {
  const OsuAffiliationTile({
    required this.name,
    required this.subtitle,
    required this.icon,
    this.colour,
    this.image,
    this.onTap,
    super.key,
  });
  final String name;
  final String subtitle;
  final IconData icon;
  final Color? colour;
  final ImageProvider? image;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => UiSurface.outlined(
    onTap: onTap,
    child: Row(
      spacing: UiSpace.md,
      children: <Widget>[
        if (image != null)
          UiAvatar.small(name: name, image: image)
        else
          Icon(icon, color: colour ?? Theme.of(context).colorScheme.primary),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: UiSpace.xs,
            children: <Widget>[
              UiText.titleSmall(name),
              UiText.bodySmall(subtitle, secondary: true),
            ],
          ),
        ),
        if (onTap != null) const Icon(Icons.open_in_new, size: 20),
      ],
    ),
  );
}
