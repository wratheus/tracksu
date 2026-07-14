import 'package:flutter/material.dart';
import 'package:tracksu/src/pages/rankings_tab_page.dart';
import 'package:tracksu/src/pages/user_tab_page.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart'; // add animated navigation bar
import 'package:tracksu/src/widgets/drawer_widgets/drawer.dart';

import '../utils/color_contrasts.dart' as my_colors;
import '../pages/last_news_page.dart';

// Home page is navigation bar(User page selected by default
// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  int? _pageIndex;
  String? _username;
  HomePage({Key? key, int? pageIndex, String? username}) :
        _pageIndex = pageIndex,
        _username = username,
        super(key: key);
  @override
  State<HomePage> createState() => _HomePageState(_pageIndex, _username);
}

class _HomePageState extends State<HomePage> {
  int? _pageIndex;
  String? _username;
  _HomePageState(pageIndex, username) :
      _pageIndex = pageIndex,
      _username = username;
  GlobalKey bottomNavigationKey = GlobalKey();
  List<Widget> pageList = <Widget>[
    LastNewsPage(),
    UserTabPage(),
    RankingsTabPage(),
  ];
  @override
  Widget build(BuildContext context) {
      if (_pageIndex == null) {
        _pageIndex = 1;
      }// default page is User page
      if (_username != null) pageList[1] = UserTabPage(username: _username); // i// f username provided -> open that userpage
      return Scaffold(
          drawer: NavigationDrawer(),
          backgroundColor: my_colors.Palette.purple,
          body: pageList.elementAt(_pageIndex!),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.topRight,
                    colors: [my_colors.Palette.brown.withOpacity(0.65), my_colors.Palette.purple.withOpacity(0.65)])),
            child: CurvedNavigationBar(
                height: 50,
                key: bottomNavigationKey,
                backgroundColor: Colors.transparent,
                buttonBackgroundColor: Colors.brown.shade600,
                color: Colors.transparent,
                animationDuration: Duration(milliseconds: 450),
                animationCurve: Curves.linear,
                onTap: (value){
                  setState(() {
                    _pageIndex = value;});},
                index: _pageIndex!,
                items: [
                  Icon(Icons.newspaper, size: 35, color: Colors.white),
                  Icon(Icons.person, size: 35, color: Colors.white),
                  Icon(Icons.leaderboard, size: 35, color: Colors.white),
                ]
            ),
          )
      );
    }
}
