import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';
import 'package:tracksu_ui/src/widgets/icon_button.dart';
import 'package:tracksu_ui/src/widgets/surface.dart';
import 'package:tracksu_ui/src/widgets/text.dart';

/// Presentation only. The host supplies translated labels and owns playback.
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
  Widget build(BuildContext context) => widget._overlay
      ? _overlay(context)
      : UiSurface.tonal(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: UiSpace.sm,
            children: <Widget>[
              Row(
                spacing: UiSpace.md,
                children: <Widget>[
                  UiIconButton.filled(
                    tooltip: widget.actionLabel,
                    icon: widget.actionIcon,
                    onPressed: widget.onAction,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: UiSpace.xs,
                      children: <Widget>[
                        UiText.titleSmall(widget.title),
                        if (widget.status.isNotEmpty)
                          UiText.bodySmall(
                            widget.status,
                            secondary: !widget.failed,
                            color: widget.failed
                                ? Theme.of(context).colorScheme.error
                                : null,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (widget.loading)
                LinearProgressIndicator(
                  value: MediaQuery.disableAnimationsOf(context) ? .35 : null,
                )
              else
                Semantics(
                  label: widget.seekLabel,
                  child: Slider(
                    value: _scrub ?? widget.progress.clamp(0, 1),
                    onChanged: widget.onSeek == null
                        ? null
                        : (double value) => setState(() => _scrub = value),
                    onChangeEnd: widget.onSeek == null
                        ? null
                        : (double value) {
                            setState(() => _scrub = null);
                            widget.onSeek!(value);
                          },
                  ),
                ),
              Row(
                children: <Widget>[
                  Expanded(child: UiText.labelSmall(widget.positionLabel)),
                  UiText.labelSmall(widget.durationLabel, secondary: true),
                ],
              ),
            ],
          ),
        );

  Widget _overlay(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface.withValues(alpha: .94),
    borderRadius: BorderRadius.circular(UiShape.control),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: UiSpace.xs),
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
                ? LinearProgressIndicator(
                    value: MediaQuery.disableAnimationsOf(context) ? .35 : null,
                  )
                : widget.onSeek == null
                ? UiText.labelMedium(
                    widget.failed ? widget.status : widget.actionLabel,
                    maxLines: 2,
                    color: widget.failed
                        ? Theme.of(context).colorScheme.error
                        : null,
                  )
                : Semantics(
                    label: widget.seekLabel,
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
          if (widget.onSeek != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: UiSpace.sm),
              child: UiText.labelSmall(widget.positionLabel),
            ),
        ],
      ),
    ),
  );
}
