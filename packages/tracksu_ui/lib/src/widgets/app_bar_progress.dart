import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';

/// The single "working" signal of a page: a 2 px line docked under the app
/// bar (`AppBar.bottom`). It never takes layout space in the content and
/// fades in/out instead of popping. Initial loads keep their skeletons.
///
/// Quick work shows nothing: the line appears only after
/// [UiMotion.progressDelay] of continuous work, and then stays at least
/// [UiMotion.progressMinVisible] so it does not blink.
final class UiAppBarProgress extends StatefulWidget
    implements PreferredSizeWidget {
  const UiAppBarProgress({
    required this.visible,
    this.semanticsLabel,
    super.key,
  });

  /// Whether work is in progress; the line itself follows with a delay.
  final bool visible;
  final String? semanticsLabel;

  static const double height = 2;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  State<UiAppBarProgress> createState() => _UiAppBarProgressState();
}

final class _UiAppBarProgressState extends State<UiAppBarProgress> {
  bool _shown = false;
  DateTime? _shownAt;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.visible) _scheduleShow();
  }

  @override
  void didUpdateWidget(UiAppBarProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visible == widget.visible) return;
    _timer?.cancel();
    _timer = null;
    if (widget.visible) {
      if (!_shown) _scheduleShow();
    } else if (_shown) {
      final Duration elapsed = DateTime.now().difference(_shownAt!);
      final Duration rest = UiMotion.progressMinVisible - elapsed;
      if (rest <= Duration.zero) {
        _hide();
      } else {
        _timer = Timer(rest, _hide);
      }
    }
  }

  void _scheduleShow() {
    _timer = Timer(UiMotion.progressDelay, () {
      if (!mounted) return;
      setState(() {
        _shown = true;
        _shownAt = DateTime.now();
      });
    });
  }

  void _hide() {
    if (mounted) setState(() => _shown = false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    return SizedBox(
      height: UiAppBarProgress.height,
      child: AnimatedOpacity(
        opacity: _shown ? 1 : 0,
        duration: reduceMotion ? Duration.zero : UiMotion.reveal,
        curve: UiMotion.revealCurve,
        child: _shown
            ? LinearProgressIndicator(
                minHeight: UiAppBarProgress.height,
                backgroundColor: Colors.transparent,
                semanticsLabel: widget.semanticsLabel,
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
