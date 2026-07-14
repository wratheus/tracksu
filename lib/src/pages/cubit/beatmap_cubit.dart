import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../../models/beatmap_score.dart';
import '../../models/user.dart';
import '../../requests/requests.dart';
import '../../utils/secure_storage.dart';
import '../../models/beatmap.dart';

part 'beatmap_state.dart';

class BeatmapCubit extends Cubit<BeatmapState> {

  BeatmapCubit() : super(BeatmapInitial());

  Future<void> informInitial() async {
    print('BeatmapPage loaded');
  }

  Future<void> loadBeatmap(int? itemBeatmapId, String? itemBeatmapName, [User? ItemMapper]) async {
    print("in LoadBeatmap : ${itemBeatmapId}");
    print("in LoadBeatmap : ${itemBeatmapName}");
    print("in LoadBeatmap : ${ItemMapper?.username}");
    try {
      if (isClosed == false) {
        Beatmap beatmapInstance = await getBeatmap((await UserSecureStorage.getTokenFromStorage())!, "${itemBeatmapId}", ItemMapper);
        List<BeatmapScore> beatmapScoresInstance = await getBeatmapScores((await UserSecureStorage.getTokenFromStorage())!, "${itemBeatmapId}");
        beatmapInstance.mapper = await beatmapInstance.mapper;
        emit(BeatmapLoadedState(beatmapInstance, beatmapScoresInstance));
      }
      print('beatmap $itemBeatmapName loaded');
    } catch (e) {
      if (isClosed == false) {
        emit(BeatmapErrorState('Failed Beatmap Load $e'));
      }
    }
  }
  Future<void> reloadBeatmap() async {
    if (isClosed == false) {
      emit(BeatmapInitial());
    }
  }
}