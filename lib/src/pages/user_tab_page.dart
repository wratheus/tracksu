import 'package:flutter/material.dart';
import 'package:tracksu/src/pages/user_page.dart';

import '../utils/color_contrasts.dart' as my_colors;
import '../widgets/user_widgets/user_search_widget.dart';

// ignore: must_be_immutable
class UserTabPage extends StatefulWidget {
  String? _username;
  UserTabPage({Key? key, username})
      :
        _username = username,
        super(key: key);

  @override
  State<UserTabPage> createState() => _UserTabPageState();
}
class _UserTabPageState extends State<UserTabPage> {
  bool searchWidgetIsOpen = false;
  @override
  Widget build(BuildContext context) {
     return DefaultTabController(
      length: 4,
      child: NestedScrollView(
        headerSliverBuilder: (context, value){
          return [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                flexibleSpace: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.topRight,
                            colors: [my_colors.Palette.brown.withOpacity(0.65), my_colors.Palette.purple.withOpacity(0.65)])
                    )
                ),
                floating: true,
                snap: true,
                actions: [
                      Container(
                        padding: EdgeInsets.all(10),
                        child: UserSearchWidget(),
                  )
                ],
                backgroundColor: my_colors.Palette.purple,
                  bottom: TabBar(
                    splashBorderRadius: BorderRadius.circular(10),
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
                    tabs: [
                      Tab(text: "osu!", icon: Image.asset('assets/icon_game_mods/mode_osu.png',  scale: 10), iconMargin: EdgeInsets.only(bottom: 0)),
                      Tab(text: "taiko", icon: Image.asset('assets/icon_game_mods/mode_taiko.png', scale: 10), iconMargin: EdgeInsets.only(bottom: 0) ),
                      Tab(text: "catch", icon: Image.asset('assets/icon_game_mods/mode_fruits.png',  scale: 10), iconMargin: EdgeInsets.only(bottom: 0)),
                      Tab(text: "mania", icon: Image.asset('assets/icon_game_mods/mode_mania.png',  scale: 10), iconMargin: EdgeInsets.only(bottom: 0))],
                  ),
              ),
            )
          ];
        },
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            UserPage(username: widget._username, mode: 'osu'),
            UserPage(username: widget._username, mode: 'taiko'),
            UserPage(username: widget._username, mode: 'fruits'),
            UserPage(username: widget._username, mode: 'mania')
          ],
        ),
      )
    );
  }
}