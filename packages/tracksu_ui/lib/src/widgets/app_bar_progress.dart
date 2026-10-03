import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';

/// The single "working" signal of a page: a 2 px line docked under the app
/// bar (`AppBar.bottom`). It never takes layout space in the content and
/// fades in/out instead of popping. Initial loads keep their skeletons.
final class UiAppBarProgress extends StatelessWidget
    implements PreferredSizeWidget {
  const UiAppBarProgress({
    required this.visible,
    this.semanticsLabel,
    super.key,
  });

  final bool visible;
  final String? semanticsLabel;

  static const double height = 2;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    return SizedBox(
      height: height,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: reduceMotion ? Duration.zero : UiMotion.reveal,
        curve: UiMotion.revealCurve,
        child: visible
            ? LinearProgressIndicator(
                minHeight: height,
                backgroundColor: Colors.transparent,
                semanticsLabel: semanticsLabel,
              )
            : const SizedBox.expand(),
      ),
    );
  }
}

/// [UiAppBarProgress] for an `AppBar.bottom` slot whose visibility comes from
/// a builder (e.g. a Bloc selector), since the slot needs a fixed size.
final class UiAppBarProgressSlot extends StatelessWidget
    implements PreferredSizeWidget {
  const UiAppBarProgressSlot({required this.child, super.key});
  final Widget child;

  @override
  Size get preferredSize => const Size.fromHeight(UiAppBarProgress.height);

  @override
  Widget build(BuildContext context) => child;
}
