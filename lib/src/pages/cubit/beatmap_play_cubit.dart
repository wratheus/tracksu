import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'beatmap_play_state.dart';

class BeatmapPlayCubit extends Cubit<BeatmapPlayState> {

  AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;
  final int _waitTime;
  int _currentWaitTime;
  double _percent;

  BeatmapPlayCubit() :
        _waitTime = 200,
        _currentWaitTime = 200,
        _percent = 1.0,
        super(BeatmapPlayInitial(1.0));



  Future<void> playBeatmap(String BeatmapID) async {
    await _audioPlayer.play(UrlSource("https://b.ppy.sh/preview/$BeatmapID.mp3"));
    if (isClosed == false) {
      emit(BeatmapRunState(_percent));
    }
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) async {
      if (isClosed == true){
        await _audioPlayer.stop();
      }
      _currentWaitTime -= 1;
      _percent = _currentWaitTime / _waitTime;
      if (isClosed == false) {
        emit(BeatmapRunState(_percent));
      }
      if (_currentWaitTime < 0) {
        _currentWaitTime = _waitTime;
        _percent = 1;
        _timer?.cancel();
        stopBeatmap();
        emit(BeatmapPlayInitial(1));
      }
    });
  }
  Future<void> pauseBeatmap() async {
    await _audioPlayer.pause();
    _timer?.cancel();
    emit(BeatmapPauseState(_percent));
  }

  Future<void> stopBeatmap() async {
    await _audioPlayer.stop();
  }

}