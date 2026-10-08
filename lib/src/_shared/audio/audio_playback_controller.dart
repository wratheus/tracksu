import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tracksu/src/_shared/audio/domain/audio_track.dart';
import 'package:tracksu/src/_shared/media/data/media_cache_repository.dart';
import 'package:tracksu/src/_shared/media/data/media_download.dart';

enum AudioPlaybackPhase { idle, loading, playing, paused, completed, failed }

/// User-facing category of a failed attempt; never carries URLs or platform
/// text. A decoder rejection is not a connection problem and must not say so.
enum AudioPlaybackFailure {
  /// Connection, timeout or a transient server status: retry may help.
  network,

  /// The source is gone (404/410) or not an allowed media location.
  unavailable,

  /// Bytes arrived but this device cannot decode them, or they are too large.
  unsupported,

  /// Another app holds audio focus.
  focus,
  unknown;

  static AudioPlaybackFailure of(Object error) => switch (error) {
    MediaDownloadFailure(:final reason, :final status) => switch (reason) {
      MediaFailureReason.httpStatus => switch (status) {
        404 || 410 => unavailable,
        408 || 429 || != null && >= 500 => network,
        _ => unknown,
      },
      MediaFailureReason.connection ||
      MediaFailureReason.timeout ||
      MediaFailureReason.cancelled => network,
      MediaFailureReason.unavailable ||
      MediaFailureReason.blocked ||
      MediaFailureReason.redirectRejected ||
      MediaFailureReason.redirectLimit => unavailable,
      MediaFailureReason.invalidFormat ||
      MediaFailureReason.tooLarge => unsupported,
    },
    IOException() || TimeoutException() => network,
    // just_audio reports codec/container rejections as PlayerException
    // (iOS -11800 for Ogg was one); the bytes were already downloaded.
    PlayerException() => unsupported,
    _ => unknown,
  };
}

/// Application-owned, credential-free foreground playback. Each view has an
/// identity token: an old route cannot stop a new route's player. Every resume
/// prepares a fresh decoder at the saved position; pause frees decoder buffers.
/// Already requested public media may finish caching after its view is released.
final class AudioPlaybackController extends ChangeNotifier {
  factory AudioPlaybackController({required MediaCacheRepository repository}) =>
      AudioPlaybackController._(repository);
  AudioPlaybackController._(this._repository);
  final MediaCacheRepository _repository;
  CachedAudio? _cachedAudio;
  Object? _owner;
  Uri? _uri;
  AudioPlayer? _player;
  AudioSession? _session;
  Future<void>? _configuration;
  Future<void> _retiring = Future<void>.value();
  Future<bool>? _activation;
  Timer? _loadingTimeout;
  final List<StreamSubscription<Object?>> _subscriptions = [];
  final List<StreamSubscription<Object?>> _sessionSubscriptions = [];
  bool _configured = false;
  int _generation = 0;
  bool _disposed = false;
  bool _notificationPending = false;
  AudioPlaybackPhase _phase = AudioPlaybackPhase.idle;
  AudioPlaybackFailure? _failure;
  Duration _position = Duration.zero;
  Duration? _duration;

  bool owns(Object owner) => identical(_owner, owner);
  AudioPlaybackPhase get phase => _phase;

  /// Set only while [phase] is [AudioPlaybackPhase.failed].
  AudioPlaybackFailure? get failure =>
      _phase == AudioPlaybackPhase.failed ? _failure : null;
  Duration get position => _position;
  Duration? get duration => _duration;

  Future<void> _configure() async {
    final AudioSession session = await AudioSession.instance;
    if (_disposed) return;
    _session = session;
    await session.configure(const AudioSessionConfiguration.music());
    if (_disposed) return;
    _configured = true;
    _sessionSubscriptions.addAll([
      session.interruptionEventStream.listen((AudioInterruptionEvent event) {
        // Never resume automatically after a call or transient focus loss.
        if (event.begin) _pauseCurrent();
      }),
      session.becomingNoisyEventStream.listen((_) => _pauseCurrent()),
    ]);
  }

  Future<void> play(Object owner, AudioTrack track) async {
    if (_disposed) return;
    if (owns(owner) &&
        _uri == track.uri &&
        (_phase == AudioPlaybackPhase.loading ||
            _phase == AudioPlaybackPhase.playing)) {
      return;
    }
    final Duration start =
        owns(owner) && _uri == track.uri && _phase == AudioPlaybackPhase.paused
        ? _position
        : Duration.zero;
    _retire();
    final int generation = _generation;
    _owner = owner;
    _uri = track.uri;
    _position = start;
    _duration = null;
    _phase = AudioPlaybackPhase.loading;
    _watchLoading(generation);
    _changed();
    try {
      await _retiring;
      if (!_current(generation)) return;
      final CachedAudio audio = await _repository.audio(track);
      if (!_current(generation)) {
        audio.release();
        return;
      }
      _cachedAudio = audio;
      await (_configuration ??= _configure());
      if (!_current(generation)) return;
      final AudioPlayer player = AudioPlayer(
        handleInterruptions: false,
        handleAudioSessionActivation: false,
        useProxyForRequestHeaders: false,
      );
      _player = player;
      _subscriptions.addAll([
        player.playerStateStream.listen((PlayerState state) {
          if (!_current(generation)) return;
          switch (state.processingState) {
            case ProcessingState.completed:
              _position = _duration ?? player.position;
              _phase = AudioPlaybackPhase.completed;
              _retire();
            case ProcessingState.loading:
            case ProcessingState.buffering:
              _phase = AudioPlaybackPhase.loading;
              _watchLoading(generation);
            case ProcessingState.ready:
              if (state.playing) {
                _phase = AudioPlaybackPhase.playing;
                _loadingTimeout?.cancel();
                _loadingTimeout = null;
              }
            case ProcessingState.idle:
              break;
          }
          _changed();
        }),
        player
            .createPositionStream(
              minPeriod: const Duration(milliseconds: 250),
              maxPeriod: const Duration(milliseconds: 500),
            )
            .listen((Duration value) {
              if (!_current(generation)) return;
              _position = value;
              _changed();
            }),
        player.durationStream.listen((Duration? value) {
          if (!_current(generation)) return;
          _duration = value;
          _changed();
        }),
        player.errorStream.listen((PlayerException error) {
          _fail(generation, error);
        }),
      ]);
      final Future<Duration?> prepared = audio.path == null
          ? player.setUrl(track.uri.toString(), initialPosition: start)
          : player.setFilePath(audio.path!, initialPosition: start);
      await prepared.timeout(const Duration(seconds: 25));
      if (!_current(generation)) return;
      final Future<bool> activation = _session!.setActive(true);
      _activation = activation;
      final bool activated = await activation;
      if (!_current(generation)) return;
      _activation = null;
      if (!activated) {
        _fail(generation, 'focus denied', failure: AudioPlaybackFailure.focus);
        return;
      }
      // play's future completes on pause/end, not on start.
      unawaited(_play(player, generation));
    } on Object catch (error, stackTrace) {
      // Plugin failures may contain source URLs. Surface a localized state,
      // never log raw platform exceptions or feed them to OAuth error handling.
      if (!_configured) _configuration = null;
      _fail(generation, error, stackTrace: stackTrace);
    }
  }

  Future<void> _play(AudioPlayer player, int generation) async {
    try {
      await player.play();
    } on Object catch (error, stackTrace) {
      _fail(generation, error, stackTrace: stackTrace);
    }
  }

  Future<void> seek(Object owner, Duration value) async {
    final Duration? duration = _duration;
    if (!owns(owner) || duration == null || duration <= Duration.zero) return;
    if (_phase != AudioPlaybackPhase.playing &&
        _phase != AudioPlaybackPhase.paused) {
      return;
    }
    final int generation = _generation;
    _position = Duration(
      milliseconds: value.inMilliseconds.clamp(0, duration.inMilliseconds),
    );
    _changed();
    try {
      await _player?.seek(_position);
    } on Object catch (error, stackTrace) {
      _fail(generation, error, stackTrace: stackTrace);
    }
  }

  void pause(Object owner) {
    if (owns(owner)) _pauseCurrent();
  }

  void _pauseCurrent() {
    if (_owner == null || _disposed) return;
    if (_phase != AudioPlaybackPhase.loading &&
        _phase != AudioPlaybackPhase.playing) {
      return;
    }
    _position = _player?.position ?? _position;
    _retire();
    _phase = AudioPlaybackPhase.paused;
    _changed();
  }

  void release(Object owner) {
    if (!owns(owner)) return;
    _retire();
    _owner = null;
    _uri = null;
    _phase = AudioPlaybackPhase.idle;
    _position = Duration.zero;
    _duration = null;
    _changed();
  }

  bool _current(int generation) => !_disposed && generation == _generation;

  void _watchLoading(int generation) {
    _loadingTimeout ??= Timer(const Duration(seconds: 60), () {
      _fail(
        generation,
        'loading timeout',
        failure: AudioPlaybackFailure.network,
      );
    });
  }

  /// Stage and category only: platform messages may contain source URLs.
  static String _cause(Object error) => switch (error) {
    MediaDownloadFailure() => 'source $error',
    IOException() => 'source network ${error.runtimeType}',
    PlayerException(:final int code) => 'decoder code $code',
    PlayerInterruptedException() => 'decoder interrupted',
    TimeoutException() => 'decoder prepare timeout',
    _ => 'platform ${error.runtimeType}',
  };

  /// [error] is either a caught exception or a short internal cause label;
  /// labels pass their [failure] explicitly.
  void _fail(
    int generation,
    Object error, {
    StackTrace? stackTrace,
    AudioPlaybackFailure? failure,
  }) {
    if (!_current(generation)) return;
    _retire();
    _phase = AudioPlaybackPhase.failed;
    _failure = failure ?? AudioPlaybackFailure.of(error);
    final String cause = error is String ? error : _cause(error);
    // Reported once per attempt: a retired generation cannot report again.
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: StateError('Audio playback failed: $cause.'),
        stack: stackTrace,
        library: 'Tracksu audio',
      ),
    );
    _changed();
  }

  void _retire() {
    _generation++;
    _loadingTimeout?.cancel();
    _loadingTimeout = null;
    final AudioPlayer? player = _player;
    _player = null;
    final CachedAudio? cachedAudio = _cachedAudio;
    _cachedAudio = null;
    final Future<bool>? activation = _activation;
    _activation = null;
    final List<Future<void>> cancellations = [
      for (final subscription in _subscriptions) subscription.cancel(),
    ];
    _subscriptions.clear();
    final Future<void> previous = _retiring;
    _retiring = () async {
      await previous;
      try {
        await Future.wait(cancellations);
      } on Object {
        // Teardown must still dispose the decoder if a subscription fails.
      }
      try {
        await player?.dispose();
      } on Object {
        // Best-effort native teardown; the source is no longer owned.
      } finally {
        cachedAudio?.release();
      }
      try {
        await activation;
        if (player != null) await _session?.setActive(false);
      } on Object {
        // Best-effort focus release; a platform may already have revoked it.
      }
    }();
  }

  Future<void> stop() async {
    if (_owner case final Object owner) release(owner);
    await _retiring;
  }

  void _changed() {
    if (_disposed || _notificationPending) return;
    _notificationPending = true;
    scheduleMicrotask(() {
      _notificationPending = false;
      if (!_disposed) notifyListeners();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _retire();
    for (final subscription in _sessionSubscriptions) {
      unawaited(subscription.cancel());
    }
    _sessionSubscriptions.clear();
    super.dispose();
  }
}
