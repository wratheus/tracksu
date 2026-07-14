import 'package:flutter/material.dart';
import '../pages/rankings_page.dart';

import '../utils/color_contrasts.dart' as my_colors;

class RankingsTabPage extends StatelessWidget {
  const RankingsTabPage({Key? key})
      :super(key: key);
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 4,
        child: NestedScrollView(
          headerSliverBuilder: (context, value){
            return [
              SliverAppBar(
                flexibleSpace: Container(
                    decoration: BoxDecoration(
                    gradient: LinearGradient(
                    begin: Alignment.topLeft,
                  end: Alignment.topRight,
                  colors: [my_colors.Palette.brown.withOpacity(0.65), my_colors.Palette.purple.withOpacity(0.65)]))),
                floating: true,
                pinned: false,
                title: Text("Leaderboard",
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
                bottom: TabBar(
                  labelStyle: TextStyle(
                    fontSize: 16.0,
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
                  indicatorColor: my_colors.Palette.hotPink.shade100,
                  tabs: [Tab(text: "osu!", icon: Image.asset('assets/icon_game_mods/mode_osu.png',  scale: 10), iconMargin: EdgeInsets.only(bottom: 0)),
                    Tab(text: "taiko", icon: Image.asset('assets/icon_game_mods/mode_taiko.png', scale: 10), iconMargin: EdgeInsets.only(bottom: 0) ),
                    Tab(text: "catch", icon: Image.asset('assets/icon_game_mods/mode_fruits.png',  scale: 10), iconMargin: EdgeInsets.only(bottom: 0)),
                    Tab(text: "mania", icon: Image.asset('assets/icon_game_mods/mode_mania.png',  scale: 10), iconMargin: EdgeInsets.only(bottom: 0))],
                ),
              )
            ];
          },
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              RankingsPage(mode: 'osu'),
              RankingsPage(mode: 'taiko'),
              RankingsPage(mode: 'fruits'),
              RankingsPage(mode: 'mania')
            ],
          ),
        )
    );
  }
}
