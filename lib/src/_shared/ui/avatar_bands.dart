import 'package:flutter/material.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Grid for an avatar with text beside it: the text column spans exactly the
/// avatar's height. [top] starts on the avatar's top edge, [bottom] ends on its
/// bottom edge, whatever lies between. Leading above the first line and below
/// the last one is trimmed so glyphs, not line boxes, meet those edges.
///
/// If enlarged text needs more height than the avatar, the column grows and the
/// avatar stays top-aligned; nothing is clipped.
final class OsuAvatarBands extends StatelessWidget {
  const OsuAvatarBands({
    required this.avatar,
    required this.top,
    required this.bottom,
    super.key,
  });
  final Widget avatar;
  final Widget top;
  final Widget bottom;

  @override
  Widget build(BuildContext context) => DefaultTextHeightBehavior(
    textHeightBehavior: const TextHeightBehavior(
      applyHeightToFirstAscent: false,
      applyHeightToLastDescent: false,
    ),
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: UiSpace.md,
        children: <Widget>[
          Align(
            alignment: AlignmentDirectional.topStart,
            widthFactor: 1,
            child: avatar,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[top, bottom],
            ),
          ),
        ],
      ),
    ),
  );
}
