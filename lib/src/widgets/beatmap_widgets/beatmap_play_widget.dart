import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/pages/cubit/beatmap_play_cubit.dart';

import '../../models/beatmap.dart';
import '../../utils/color_contrasts.dart' as my_colors;

class BeatmapPlayWidget extends StatelessWidget {
  final Beatmap _beatmap;

  const BeatmapPlayWidget({Key? key, required Beatmap beatmap})
      :
        _beatmap = beatmap,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BeatmapPlayCubit(),
      child: new _BeatmapPlayWidget(beatmap: _beatmap));
  }
}

class _BeatmapPlayWidget extends StatelessWidget {
  final Beatmap _beatmap;

  const _BeatmapPlayWidget({Key? key, required Beatmap beatmap})
      :
        _beatmap = beatmap,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BeatmapPlayCubit, BeatmapPlayState>(builder: (context, state) {
      if (state is BeatmapPlayInitial) {
        return FloatingActionButton(
          heroTag: "${_beatmap.beatmapSetMapID}",
          mini: true,
        backgroundColor: my_colors.Palette.pink,
        onPressed: () => context.read<BeatmapPlayCubit>().playBeatmap("${_beatmap.beatmapSetID}"),
            child: Stack(
              alignment: Alignment.center,
            children: [
              Icon(Icons.play_arrow),
              CircularProgressIndicator(
                value: state.percent,
                backgroundColor: my_colors.Palette.yellow,
                color: my_colors.Palette.pink,
              ),
            ],
        ),
        );
      };
      if (state is BeatmapRunState) {
        return FloatingActionButton(
          heroTag: "${_beatmap.beatmapSetID}",
          mini: true,
          backgroundColor: my_colors.Palette.pink,
            onPressed: () => context.read<BeatmapPlayCubit>().pauseBeatmap(),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.pause),
                CircularProgressIndicator(
                  value: state.percent,
                  backgroundColor: my_colors.Palette.yellow,
                  color: my_colors.Palette.pink,
                ),
              ],
            ),
        );
      };
      if (state is BeatmapPauseState){
        return FloatingActionButton(
          heroTag: "${_beatmap.mapper.username}",
          mini: true,
            backgroundColor: my_colors.Palette.pink,
            onPressed: () => context.read<BeatmapPlayCubit>().playBeatmap("${_beatmap.beatmapSetID}"),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.play_arrow),
                CircularProgressIndicator(
                  value: state.percent,
                  backgroundColor: my_colors.Palette.yellow,
                  color: my_colors.Palette.pink,
                ),
              ],
            ),
        );
      }
      else return Container();
      });
  }
}