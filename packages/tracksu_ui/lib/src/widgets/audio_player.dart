import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';
import 'package:tracksu_ui/src/widgets/icon_button.dart';
import 'package:tracksu_ui/src/widgets/text.dart';

/// Presentation only. The host supplies translated labels and owns playback.
/// Controls only: title, status and time are announced, but only an error is
/// rendered as text. No own card/background; the parent owns the surface.
final class UiAudioPlayer extends StatefulWidget {
  const UiAudioPlayer({
    required this.title,
    required this.status,
    required this.actionLabel,
    required this.actionIcon,
    required this.positionLabel,
    required this.durationLabel,
    required this.seekLabel,
    required this.onAction,
    this.progress = 0,
    this.onSeek,
    this.loading = false,
    this.failed = false,
    super.key,
  }) : _overlay = false;

  /// Placed over artwork: tracks and the error get their own contrast.
  const UiAudioPlayer.overlay({
    required this.title,
    required this.status,
    required this.actionLabel,
    required this.actionIcon,
    required this.positionLabel,
    required this.durationLabel,
    required this.seekLabel,
    required this.onAction,
    this.progress = 0,
    this.onSeek,
    this.loading = false,
    this.failed = false,
    super.key,
  }) : _overlay = true;
  final bool _overlay;
  final String title;
  final String status;
  final String actionLabel;
  final IconData actionIcon;
  final String positionLabel;
  final String durationLabel;
  final String seekLabel;
  final VoidCallback? onAction;
  final double progress;
  final ValueChanged<double>? onSeek;
  final bool loading;
  final bool failed;

  @override
  State<UiAudioPlayer> createState() => _UiAudioPlayerState();
}

final class _UiAudioPlayerState extends State<UiAudioPlayer> {
  double? _scrub;

  @override
  void didUpdateWidget(UiAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onSeek == null) _scrub = null;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    // Over artwork the inactive track must stay visible on any image.
    final Color? track = widget._overlay
        ? colors.surface.withValues(alpha: .72)
        : null;
    return Semantics(
      container: true,
      label: widget.title,
      value: <String>[
        if (widget.status.isNotEmpty) widget.status,
        if (widget.onSeek != null)
          '${widget.positionLabel} / ${widget.durationLabel}',
      ].join(', '),
      child: Row(
        spacing: UiSpace.xs,
        children: <Widget>[
          UiIconButton.filled(
            tooltip: '${widget.actionLabel} · ${widget.title}',
            icon: widget.actionIcon,
            onPressed: widget.onAction,
          ),
          Expanded(
            child: widget.loading
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: UiSpace.sm),
                    child: LinearProgressIndicator(
                      value: MediaQuery.disableAnimationsOf(context)
                          ? .35
                          : null,
                      backgroundColor: track,
                    ),
                  )
                : widget.failed
                ? Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: _Error(
                      message: widget.status,
                      overlay: widget._overlay,
                    ),
                  )
                : widget.onSeek == null
                ? const SizedBox.shrink()
                : Semantics(
                    label: widget.seekLabel,
                    child: SliderTheme(
                      data: SliderTheme.of(context)
                          .copyWith(inactiveTrackColor: track),
                      child: Slider(
                        value: _scrub ?? widget.progress.clamp(0, 1),
                        onChanged: (double value) =>
                            setState(() => _scrub = value),
                        onChangeEnd: (double value) {
                          setState(() => _scrub = null);
                          widget.onSeek?.call(value);
                        },
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

final class _Error extends StatelessWidget {
  const _Error({required this.message, required this.overlay});
  final String message;
  final bool overlay;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Widget text = UiText.labelMedium(
      message,
      maxLines: 2,
      color: overlay ? colors.onErrorContainer : colors.error,
    );
    if (!overlay) return text;
    // The only text over artwork; an error must stay readable on any image.
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(UiShape.control),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UiSpace.sm,
          vertical: UiSpace.xs,
        ),
        child: text,
      ),
    );
  }
}
