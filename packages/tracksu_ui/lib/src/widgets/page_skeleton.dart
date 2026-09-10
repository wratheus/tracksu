import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';
import 'package:tracksu_ui/src/widgets/content_state.dart';
import 'package:tracksu_ui/src/widgets/surface.dart';

/// Initial load only. Never replaces usable content during revalidation.
/// Static placeholders avoid perpetual shimmer and respect reduced motion.
final class UiPageSkeleton extends StatelessWidget {
  const UiPageSkeleton.profile({required this.label, super.key})
    : _profile = true;
  const UiPageSkeleton.list({required this.label, super.key})
    : _profile = false;
  final String label;
  final bool _profile;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    liveRegion: true,
    child: Padding(
      padding: const EdgeInsets.all(UiSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: UiSpace.md,
        children: <Widget>[
          if (_profile) const UiSkeleton.block(height: 160),
          for (int i = 0; i < 3; i++)
            UiSurface.card(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: UiSpace.md,
                children: <Widget>[
                  const UiSkeleton.block(height: 56, width: 56),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: UiSpace.md,
                      children: <Widget>[
                        UiSkeleton.line(),
                        FractionallySizedBox(
                          widthFactor: 0.65,
                          alignment: AlignmentDirectional.centerStart,
                          child: UiSkeleton.line(),
                        ),
                        FractionallySizedBox(
                          widthFactor: 0.4,
                          alignment: AlignmentDirectional.centerStart,
                          child: UiSkeleton.line(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}
