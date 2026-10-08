import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/audio/audio_playback_controller.dart';
import 'package:tracksu/src/_shared/content/domain/content_document.dart';
import 'package:tracksu/src/_shared/media/widgets/app_media.dart';
import 'package:tracksu_ui/tracksu_ui.dart';
import 'package:video_player/video_player.dart';

/// Inline player for an osu!-hosted video. Nothing is fetched until the
/// reader taps play; starting the video stops article audio, and leaving the
/// page, the tab or the app pauses it.
final class ContentVideoView extends StatefulWidget {
  const ContentVideoView({
    required this.video,
    required this.onOpenOriginal,
    this.audioController,
    super.key,
  });
  final ContentVideo video;
  final VoidCallback onOpenOriginal;
  final AudioPlaybackController? audioController;

  @override
  State<ContentVideoView> createState() => _ContentVideoViewState();
}

final class _ContentVideoViewState extends State<ContentVideoView>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _failed = false;
  bool _fullscreen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool visible =
        TickerMode.valuesOf(context).enabled &&
        (ModalRoute.isCurrentOf(context) ?? true);
    if (!visible && !_fullscreen) _controller?.pause();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _controller?.pause();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (_controller != null) return;
    final VideoPlayerController controller = VideoPlayerController.networkUrl(
      widget.video.uri,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
    );
    setState(() {
      _controller = controller;
      _failed = false;
    });
    try {
      await controller.initialize();
      if (!mounted) return;
      unawaited(widget.audioController?.stop());
      await controller.play();
    } on Object {
      if (!mounted) return;
      await controller.dispose();
      setState(() {
        _controller = null;
        _failed = true;
      });
    }
  }

  Future<void> _openFullscreen() async {
    final VideoPlayerController? controller = _controller;
    if (controller == null) return;
    setState(() => _fullscreen = true);
    await Navigator.of(context, rootNavigator: true).push<void>(
      PageRouteBuilder<void>(
        opaque: true,
        barrierColor: Colors.black,
        pageBuilder: (_, _, _) => _FullscreenVideo(controller: controller),
        transitionsBuilder: (_, Animation<double> animation, _, Widget child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (mounted) setState(() => _fullscreen = false);
  }

  @override
  Widget build(BuildContext context) {
    final VideoPlayerController? controller = _controller;
    return ClipRRect(
      borderRadius: BorderRadius.circular(UiShape.card),
      child: ColoredBox(
        color: Colors.black,
        child: controller == null
            ? _Idle(
                poster: widget.video.poster,
                failed: _failed,
                onPlay: _start,
                onOpenOriginal: widget.onOpenOriginal,
              )
            : ValueListenableBuilder<VideoPlayerValue>(
                valueListenable: controller,
                builder: (BuildContext context, VideoPlayerValue value, _) =>
                    AspectRatio(
                      aspectRatio: value.isInitialized
                          ? value.aspectRatio
                          : 16 / 9,
                      child: value.isInitialized
                          ? _VideoSurface(
                              controller: controller,
                              onFullscreen: _openFullscreen,
                            )
                          : const Center(
                              child: CircularProgressIndicator(
                                color: UiGlass.onGlass,
                              ),
                            ),
                    ),
              ),
      ),
    );
  }
}

final class _Idle extends StatelessWidget {
  const _Idle({
    required this.poster,
    required this.failed,
    required this.onPlay,
    required this.onOpenOriginal,
  });
  final Uri? poster;
  final bool failed;
  final VoidCallback onPlay;
  final VoidCallback onOpenOriginal;

  @override
  Widget build(BuildContext context) {
    final ImageProvider? image = AppMedia.image(context, poster);
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (image != null) Image(image: image, fit: BoxFit.cover),
          Center(
            child: failed
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: UiSpace.sm,
                    children: <Widget>[
                      UiText.bodyMedium(
                        context.t.contentVideoFailed,
                        color: UiGlass.onGlass,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: UiSpace.sm,
                        children: <Widget>[
                          _GlassButton(
                            icon: Icons.refresh_rounded,
                            label: context.t.retry,
                            onPressed: onPlay,
                          ),
                          _GlassButton(
                            icon: Icons.open_in_new,
                            label: context.t.contentOriginal,
                            onPressed: onOpenOriginal,
                          ),
                        ],
                      ),
                    ],
                  )
                : _GlassButton(
                    icon: Icons.play_arrow_rounded,
                    label: context.t.contentVideoPlay,
                    onPressed: onPlay,
                    large: true,
                  ),
          ),
        ],
      ),
    );
  }
}

/// Video with tap-to-show controls that hide after a moment while playing.
final class _VideoSurface extends StatefulWidget {
  const _VideoSurface({required this.controller, this.onFullscreen});
  final VideoPlayerController controller;

  /// Null inside the fullscreen page, where the button closes it instead.
  final VoidCallback? onFullscreen;

  @override
  State<_VideoSurface> createState() => _VideoSurfaceState();
}

final class _VideoSurfaceState extends State<_VideoSurface> {
  bool _controls = true;
  Timer? _hide;

  @override
  void initState() {
    super.initState();
    _scheduleHide();
  }

  @override
  void dispose() {
    _hide?.cancel();
    super.dispose();
  }

  void _scheduleHide() {
    _hide?.cancel();
    _hide = Timer(const Duration(milliseconds: 2500), () {
      if (mounted && widget.controller.value.isPlaying) {
        setState(() => _controls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _controls = !_controls);
    if (_controls) _scheduleHide();
  }

  void _togglePlay() {
    final VideoPlayerValue value = widget.controller.value;
    if (value.isPlaying) {
      widget.controller.pause();
    } else {
      if (value.position >= value.duration) {
        widget.controller.seekTo(Duration.zero);
      }
      widget.controller.play();
    }
    _scheduleHide();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: _toggleControls,
    child: Stack(
      fit: StackFit.expand,
      children: <Widget>[
        VideoPlayer(widget.controller),
        AnimatedOpacity(
          opacity: _controls ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: !_controls,
            child: _Controls(
              controller: widget.controller,
              onTogglePlay: _togglePlay,
              onFullscreen: widget.onFullscreen,
            ),
          ),
        ),
      ],
    ),
  );
}

final class _Controls extends StatelessWidget {
  const _Controls({
    required this.controller,
    required this.onTogglePlay,
    this.onFullscreen,
  });
  final VideoPlayerController controller;
  final VoidCallback onTogglePlay;
  final VoidCallback? onFullscreen;

  static String _time(Duration value) {
    final int minutes = value.inMinutes;
    final String seconds = (value.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(
    BuildContext context,
  ) => ValueListenableBuilder<VideoPlayerValue>(
    valueListenable: controller,
    builder: (BuildContext context, VideoPlayerValue value, _) {
      final TextStyle? time = Theme.of(context).textTheme.labelSmall?.copyWith(
        color: UiGlass.onGlass,
        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
      );
      return DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Colors.transparent, Color(0x99000000)],
            stops: <double>[.55, 1],
          ),
        ),
        child: Stack(
          children: <Widget>[
            Center(
              child: _GlassButton(
                icon: value.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                label: value.isPlaying
                    ? context.t.contentVideoPause
                    : context.t.contentVideoPlay,
                onPressed: onTogglePlay,
                large: true,
              ),
            ),
            Positioned(
              left: UiSpace.sm,
              right: UiSpace.xs,
              bottom: 0,
              child: Row(
                spacing: UiSpace.sm,
                children: <Widget>[
                  Text(
                    '${_time(value.position)} / ${_time(value.duration)}',
                    style: time,
                  ),
                  Expanded(
                    child: VideoProgressIndicator(
                      controller,
                      allowScrubbing: true,
                      padding: const EdgeInsets.symmetric(vertical: UiSpace.md),
                      colors: VideoProgressColors(
                        playedColor: Theme.of(context).colorScheme.primary,
                        bufferedColor: const Color(0x66FFFFFF),
                        backgroundColor: const Color(0x33FFFFFF),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: onFullscreen == null
                        ? context.t.contentVideoExitFullscreen
                        : context.t.contentVideoFullscreen,
                    color: UiGlass.onGlass,
                    icon: Icon(
                      onFullscreen == null
                          ? Icons.fullscreen_exit_rounded
                          : Icons.fullscreen_rounded,
                    ),
                    onPressed:
                        onFullscreen ?? () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

final class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.large = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool large;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: label,
    child: Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: UiGlass(
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox.square(
            dimension: large ? 56 : 44,
            child: Icon(icon, color: UiGlass.onGlass, size: large ? 32 : 22),
          ),
        ),
      ),
    ),
  );
}

/// Same controller on a black page; rotating the device fills the screen.
final class _FullscreenVideo extends StatefulWidget {
  const _FullscreenVideo({required this.controller});
  final VideoPlayerController controller;

  @override
  State<_FullscreenVideo> createState() => _FullscreenVideoState();
}

final class _FullscreenVideoState extends State<_FullscreenVideo> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(
      child: Center(
        child: AspectRatio(
          aspectRatio: widget.controller.value.aspectRatio,
          child: _VideoSurface(controller: widget.controller),
        ),
      ),
    ),
  );
}
