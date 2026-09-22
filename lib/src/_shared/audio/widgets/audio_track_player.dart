import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/audio/audio_playback_controller.dart';
import 'package:tracksu/src/_shared/audio/domain/audio_track.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// Inline player with route/branch/lifecycle ownership, not a background player.
final class AudioTrackPlayer extends StatefulWidget {
  const AudioTrackPlayer({
    required this.track,
    required this.controller,
    super.key,
  });
  final AudioTrack track;
  final AudioPlaybackController controller;

  @override
  State<AudioTrackPlayer> createState() => _AudioTrackPlayerState();
}

final class _AudioTrackPlayerState extends State<AudioTrackPlayer>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  final Object _owner = Object();
  bool _visible = false;
  bool _foreground = true;
  bool _keepAlive = false;

  @override
  bool get wantKeepAlive => _keepAlive;

  void _playbackChanged() {
    final bool keepAlive = widget.controller.owns(_owner) &&
        (widget.controller.phase == AudioPlaybackPhase.playing ||
            widget.controller.phase == AudioPlaybackPhase.loading ||
            widget.controller.phase == AudioPlaybackPhase.paused);
    if (keepAlive != _keepAlive) {
      _keepAlive = keepAlive;
      updateKeepAlive();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller.addListener(_playbackChanged);
    _foreground = WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _visible = TickerMode.valuesOf(context).enabled &&
        (ModalRoute.isCurrentOf(context) ?? true);
    if (!_visible) widget.controller.release(_owner);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() => _foreground = state == AppLifecycleState.resumed);
    if (!_foreground) widget.controller.pause(_owner);
  }

  @override
  void didUpdateWidget(AudioTrackPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_playbackChanged);
      widget.controller.addListener(_playbackChanged);
    }
    if (widget.controller != oldWidget.controller ||
        widget.track.uri != oldWidget.track.uri) {
      oldWidget.controller.release(_owner);
      _playbackChanged();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.removeListener(_playbackChanged);
    widget.controller.release(_owner);
    super.dispose();
  }

  static String _time(Duration value) {
    final int seconds = value.inSeconds.clamp(0, 359999);
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListenableBuilder(
    listenable: widget.controller,
    builder: (BuildContext context, _) {
      final controller = widget.controller;
      final bool owned = controller.owns(_owner);
      final AudioPlaybackPhase phase = owned
          ? controller.phase
          : AudioPlaybackPhase.idle;
      final Duration position = owned ? controller.position : Duration.zero;
      final Duration? duration = owned ? controller.duration : null;
      final bool canPause = phase == AudioPlaybackPhase.playing ||
          phase == AudioPlaybackPhase.loading;
      final bool canSeek = duration != null && duration > Duration.zero &&
          (phase == AudioPlaybackPhase.playing ||
              phase == AudioPlaybackPhase.paused);
      final String action = switch (phase) {
        AudioPlaybackPhase.loading => context.t.audioCancel,
        AudioPlaybackPhase.playing => context.t.audioPause,
        AudioPlaybackPhase.completed => context.t.audioReplay,
        AudioPlaybackPhase.failed => context.t.retry,
        _ => context.t.audioPlay,
      };
      return UiAudioPlayer(
        title: widget.track.title.isEmpty
            ? context.t.audioPreview
            : widget.track.title,
        status: switch (phase) {
          AudioPlaybackPhase.loading => context.t.audioLoading,
          AudioPlaybackPhase.playing => context.t.audioPlaying,
          AudioPlaybackPhase.paused => context.t.audioPaused,
          AudioPlaybackPhase.completed => context.t.audioCompleted,
          AudioPlaybackPhase.failed => context.t.audioFailed,
          AudioPlaybackPhase.idle => context.t.audioConnectionNotice,
        },
        actionLabel: action,
        actionIcon: switch (phase) {
          AudioPlaybackPhase.loading => Icons.close,
          AudioPlaybackPhase.playing => Icons.pause_rounded,
          AudioPlaybackPhase.completed => Icons.replay_rounded,
          AudioPlaybackPhase.failed => Icons.refresh_rounded,
          _ => Icons.play_arrow_rounded,
        },
        positionLabel: _time(position),
        durationLabel: duration == null ? '—:—' : _time(duration),
        seekLabel: context.t.audioSeek,
        progress: duration != null && duration > Duration.zero
            ? position.inMilliseconds / duration.inMilliseconds
            : 0,
        loading: phase == AudioPlaybackPhase.loading,
        failed: phase == AudioPlaybackPhase.failed,
        onAction: !_visible || !_foreground ? null : () {
          if (canPause) {
            controller.pause(_owner);
          } else {
            unawaited(controller.play(_owner, widget.track));
          }
        },
        onSeek: !canSeek || !_visible || !_foreground ? null : (double value) {
          unawaited(controller.seek(_owner, Duration(
            milliseconds: (duration.inMilliseconds * value).round(),
          )));
        },
      );
    },
  );
  }
}
