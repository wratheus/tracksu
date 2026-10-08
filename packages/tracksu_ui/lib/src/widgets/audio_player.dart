import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';
import 'package:tracksu_ui/src/widgets/glass.dart';
import 'package:tracksu_ui/src/widgets/text.dart';

/// Presentation only. The host supplies translated labels and owns playback.
///
/// A capsule: one round play/pause control, then — once playback has started —
/// a slim timeline with elapsed/total time. Idle it is just the control, so a
/// cover keeps its artwork. The overlay variant sits on artwork as frosted
/// glass while active (blur is skipped when idle: lists hold many covers).
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
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    final bool active =
        widget.loading || widget.failed || widget.onSeek != null;
    // Idle: an even ring of glass around the disc, i.e. a circle, not an oval.
    final Widget controls = Padding(
      padding: active
          ? const EdgeInsetsDirectional.fromSTEB(
              UiSpace.xs,
              UiSpace.xs,
              UiSpace.md,
              UiSpace.xs,
            )
          : const EdgeInsets.all(UiSpace.xs),
      child: Row(
        mainAxisSize: active ? MainAxisSize.max : MainAxisSize.min,
        spacing: UiSpace.sm,
        children: <Widget>[
          _PlayButton(
            onGlass: widget._overlay,
            icon: widget.actionIcon,
            tooltip: '${widget.actionLabel} · ${widget.title}',
            onPressed: widget.onAction,
            loading: widget.loading,
          ),
          if (active)
            Expanded(
              child: widget.failed
                  ? _Error(message: widget.status, onGlass: widget._overlay)
                  : _Timeline(
                      onGlass: widget._overlay,
                      progress: widget.loading
                          ? null
                          : _scrub ?? widget.progress.clamp(0, 1),
                      positionLabel: widget.positionLabel,
                      durationLabel: widget.durationLabel,
                      seekLabel: widget.seekLabel,
                      onChanged: widget.onSeek == null
                          ? null
                          : (double value) => setState(() => _scrub = value),
                      onChangeEnd: widget.onSeek == null
                          ? null
                          : (double value) {
                              setState(() => _scrub = null);
                              widget.onSeek?.call(value);
                            },
                    ),
            ),
        ],
      ),
    );
    final BorderRadius radius = BorderRadius.circular(UiShape.minTarget);
    final Widget capsule = AnimatedSize(
      duration: reduceMotion ? Duration.zero : UiMotion.reveal,
      curve: UiMotion.revealCurve,
      alignment: AlignmentDirectional.centerStart,
      child: controls,
    );
    // Over artwork: frosted glass in both states.
    final Widget surface = widget._overlay
        ? UiGlass(child: capsule)
        : DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: radius,
            ),
            child: capsule,
          );
    return Semantics(
      container: true,
      label: widget.title,
      value: <String>[
        if (widget.status.isNotEmpty) widget.status,
        if (widget.onSeek != null)
          '${widget.positionLabel} / ${widget.durationLabel}',
      ].join(', '),
      child: Align(
        alignment: AlignmentDirectional.bottomStart,
        heightFactor: 1,
        child: surface,
      ),
    );
  }
}

/// Filled round control; while loading a thin ring spins around the icon.
final class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.onGlass,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.loading,
  });
  final bool onGlass;
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return SizedBox.square(
      dimension: _size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          if (loading)
            SizedBox.square(
              dimension: _size,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                value: MediaQuery.disableAnimationsOf(context) ? .3 : null,
                color: onGlass ? Colors.white : colors.primary,
                backgroundColor: (onGlass ? Colors.white : colors.primary)
                    .withValues(alpha: .24),
              ),
            ),
          Tooltip(
            message: tooltip,
            child: Semantics(
              button: true,
              enabled: onPressed != null,
              child: Material(
                // On glass: a faint lit disc, not an opaque button — the
                // glass itself is the control.
                color: onGlass
                    ? Colors.white.withValues(alpha: loading ? .08 : .16)
                    : colors.primary,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onPressed,
                  child: SizedBox.square(
                    // While loading the disc shrinks inside the spinning ring.
                    dimension: loading ? _size - 10 : _size,
                    child: Icon(
                      icon,
                      size: loading ? 18 : 24,
                      color: onGlass ? UiGlass.onGlass : colors.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// iOS minimum touch target.
  static const double _size = 44;
}

/// Slim rounded track; the thumb only appears while it can be dragged.
final class _Timeline extends StatelessWidget {
  const _Timeline({
    required this.onGlass,
    required this.progress,
    required this.positionLabel,
    required this.durationLabel,
    required this.seekLabel,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final bool onGlass;

  /// Null while loading: an indeterminate bar.
  final double? progress;
  final String positionLabel;
  final String durationLabel;
  final String seekLabel;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final Color content = onGlass ? Colors.white : colors.onSurface;
    final Color inactive = content.withValues(alpha: onGlass ? .3 : .18);
    final Widget track = progress == null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              minHeight: 4,
              value: MediaQuery.disableAnimationsOf(context) ? .35 : null,
              color: colors.primary,
              backgroundColor: inactive,
            ),
          )
        : Semantics(
            label: seekLabel,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                activeTrackColor: colors.primary,
                inactiveTrackColor: inactive,
                disabledActiveTrackColor: colors.primary,
                disabledInactiveTrackColor: inactive,
                thumbColor: colors.primary,
                overlayColor: colors.primary.withValues(alpha: .16),
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 6,
                  disabledThumbRadius: 0,
                ),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                trackShape: const _FlushTrackShape(),
              ),
              child: Slider(
                value: progress!,
                onChanged: onChanged,
                onChangeEnd: onChangeEnd,
              ),
            ),
          );
    return Row(
      spacing: UiSpace.sm,
      children: <Widget>[
        Expanded(child: track),
        ExcludeSemantics(
          child: Text(
            '$positionLabel / $durationLabel',
            style: theme.textTheme.labelMedium?.copyWith(
              color: content,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

/// Rounded track without the default side inset, so it lines up with the
/// time label instead of floating inside the capsule.
final class _FlushTrackShape extends RoundedRectSliderTrackShape {
  const _FlushTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double height = sliderTheme.trackHeight ?? 4;
    final double top = offset.dy + (parentBox.size.height - height) / 2;
    return Rect.fromLTWH(offset.dx, top, parentBox.size.width, height);
  }
}

final class _Error extends StatelessWidget {
  const _Error({required this.message, required this.onGlass});
  final String message;
  final bool onGlass;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Row(
      spacing: UiSpace.xs,
      children: <Widget>[
        Icon(Icons.error_outline_rounded, size: 18, color: colors.error),
        Expanded(
          child: UiText.labelMedium(
            message,
            maxLines: 2,
            color: onGlass ? Colors.white : colors.onSurface,
          ),
        ),
      ],
    );
  }
}
