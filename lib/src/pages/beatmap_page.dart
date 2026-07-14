import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/pages/home_page.dart';
import 'package:tracksu/src/pages/home_page_desktop.dart';
import 'package:tracksu/src/widgets/drawer_widgets/drawer.dart';

import '../models/beatmap.dart';
import '../pages/cubit/beatmap_cubit.dart';
import '../pages/error_page.dart';
import '../models/scores.dart';
import '../utils/color_contrasts.dart' as my_colors;
import '../widgets/beatmap_widgets/beatmap_score_widget.dart';
import '../widgets/beatmap_widgets/beatmap_widget.dart';

class BeatmapPage extends StatelessWidget {
  final Object? _item; // [Score or Beatmap] object from UserPage contains information about map ID and map Name for future requests
  const BeatmapPage({Key? key, item}):
        _item = item,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BeatmapCubit(),
      child: new _BeatmapPage(item: _item),);
  }
}

class _BeatmapPage extends StatelessWidget {
  final Object? _item;
  const _BeatmapPage({Key? key, required item}) :
        _item = item,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BeatmapCubit, BeatmapState>(builder: (context, state) {
      if (state is BeatmapInitial) { // test if Object is Score-class or Beatmap
          try {
            context.read<BeatmapCubit>().loadBeatmap(
                (_item as Beatmap).beatmapSetMapID,
                (_item as Beatmap).mapTitle,
                (_item as Beatmap).mapper);
          }catch(e){
            context.read<BeatmapCubit>().loadBeatmap(
                (_item as Scores).beatmapSetMapID,
                (_item as Scores).mapTitle);
          }
            return Scaffold(
              body: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [my_colors.Palette.brown, my_colors.Palette.brown.shade200])),
                  child: const Center(child: CircularProgressIndicator())),
             );
          }
        if (state is BeatmapErrorState) { // Throw error if state is UserError
          return ErrorPage(
              exceptionPageName: BeatmapPage(item: _item),
              errorMessage: state.errorMessage);
        }
        if (state is BeatmapLoadedState) { // Reload News if state is UserReload (wheel page down)
          return (Platform.isIOS || Platform.isAndroid == true) ? RefreshIndicator(
            backgroundColor: my_colors.Palette.brown.shade100,
            child: Scaffold(
              drawer: NavigationDrawer(),
                body: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [my_colors.Palette.brown, my_colors.Palette.brown.shade200])),
                  child: Center(
                    child: CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          flexibleSpace: Container(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.topRight,
                                      colors: [my_colors.Palette.brown.withOpacity(0.65), my_colors.Palette.purple.withOpacity(0.65)]))),
                          floating: true,
                          title: Text("Beatmap",
                            style: TextStyle(
                              fontSize: 22.0,
                              color: Colors.white,
                              fontFamily: 'Exo 2',
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                                  offset: Offset(7, 5),
                                  blurRadius: 10,
                                )
                              ],
                            ),
                          ),
                          backgroundColor: my_colors.Palette.purple,
                        ),
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              BeatmapInfoWidget(beatmap: state.beatmapInstance),
                              SizedBox(height: 5,),
                              ListView.builder(
                                  padding: EdgeInsets.all(0.0),
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: state.beatmapLeaderboard.length,
                                  itemBuilder: (context, index){
                                    return InkWell(
                                        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => (Platform.isAndroid || Platform.isIOS == true) ? HomePage(pageIndex: 1, username: state.beatmapLeaderboard[index].username) : HomePageDesktop(pageIndex: 1, username: state.beatmapLeaderboard[index].username))),
                                        child: BeatmapScoreWidget(item: state.beatmapLeaderboard[index], index: index, beatmapItem: state.beatmapInstance,)
                                    );}
                              )
                            ]
                          ),
                        )
                      ],
                    ),
                  ),
                )
            ),
            onRefresh: () => context.read<BeatmapCubit>().reloadBeatmap(),
          ) :
          RefreshIndicator(
            backgroundColor: my_colors.Palette.brown.shade100,
            child: Scaffold(
              backgroundColor: my_colors.Palette.brown.shade100,
                body: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.topRight,
                        colors: [my_colors.Palette.brown.withOpacity(0.65), my_colors.Palette.purple.withOpacity(0.65)])),
                  child: Center(
                    child: CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          flexibleSpace: Container(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [my_colors.Palette.purple, my_colors.Palette.purple.shade200]))),
                          floating: true,
                          title: Text("Beatmap",
                            style: TextStyle(
                              fontSize: 22.0,
                              color: Colors.white,
                              fontFamily: 'Exo 2',
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                                  offset: Offset(7, 5),
                                  blurRadius: 10,
                                )
                              ],
                            ),
                          ),
                          backgroundColor: my_colors.Palette.purple,
                        ),
                        SliverToBoxAdapter(
                          child: Column(
                              children: [
                                BeatmapInfoWidget(beatmap: state.beatmapInstance),
                                SizedBox(height: 5,),
                                ListView.builder(
                                    padding: EdgeInsets.all(0.0),
                                    physics: NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    itemCount: state.beatmapLeaderboard.length,
                                    itemBuilder: (context, index){
                                      return InkWell(
                                          onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => (Platform.isAndroid || Platform.isIOS == true) ? HomePage(pageIndex: 1, username: state.beatmapLeaderboard[index].username) : HomePageDesktop(pageIndex: 1, username: state.beatmapLeaderboard[index].username))),
                                          child: BeatmapScoreWidget(item: state.beatmapLeaderboard[index], index: index, beatmapItem: state.beatmapInstance,)
                                      );}
                                )
                              ]
                          ),
                        )
                      ],
                    ),
                  ),
                )
            ),
            onRefresh: () => context.read<BeatmapCubit>().reloadBeatmap(),
          );
        }
        else return Container();
      }
    );
  }
}