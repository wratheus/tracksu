import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tracksu/src/pages/rankings_tab_page.dart';
import 'package:tracksu/src/pages/user_tab_page.dart';

import '../utils/color_contrasts.dart' as my_colors;
import '../pages/last_news_page.dart';
import '../utils/secure_storage.dart';

// Home page is navigation bar(User page selected by default
// ignore: must_be_immutable
class HomePageDesktop extends StatefulWidget {
  int? _pageIndex;
  String? _username;
  String? _userMeAvatar;
  String? _userMeUsername;
  HomePageDesktop({Key? key, int? pageIndex, String? username}) :
        _pageIndex = pageIndex,
        _username = username,
        super(key: key);
  @override
  State<HomePageDesktop> createState() => _HomePageDesktopState(_pageIndex, _username);
}

class _HomePageDesktopState extends State<HomePageDesktop> {
  int? _pageIndex;
  String? _username;
  _HomePageDesktopState(pageIndex, username) :
      _pageIndex = pageIndex,
      _username = username;
  GlobalKey bottomNavigationKey = GlobalKey();
  List<Widget> pageList = <Widget>[
    LastNewsPage(),
    UserTabPage(),
    RankingsTabPage(),
  ];
  // need to be late final bool userMeFromStorageLoaded; to avoid navigation bug!!!
  bool userMeFromStorageLoaded = false;
  void getUserFromSecureStorage() async {
    String? userMeAvatarInstance = await UserSecureStorage.getUserMeAvatarFromStorage();
    String? userMeUsernameInstance = await UserSecureStorage.getUserMeUsernameFromStorage();
    setState((){
      widget._userMeAvatar = userMeAvatarInstance;
      widget._userMeUsername = userMeUsernameInstance;
      userMeFromStorageLoaded = true;
    });
  }
  @override
  Widget build(BuildContext context) {
      if (widget._userMeAvatar == null) getUserFromSecureStorage();
      if (_pageIndex == null) {
        _pageIndex = 1;
      }// default page is User page
      if (_username != null) pageList[1] = UserTabPage(username: _username); // i// f username provided -> open that userpage

      return (widget._userMeAvatar != null) ? Scaffold(
          backgroundColor: my_colors.Palette.purple,
          body: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                flex: 3,
                child: ListView(
                    children: [
                      buildHeader(context),
                      buildMenuItems(context)
                    ],
                  ),

              ),
                Flexible(
                  flex: 16,
                  child: Center(
                    child: pageList.elementAt(_pageIndex!),
                  ),
                ),
            ],
          ),
      ) :
      Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [my_colors.Palette.purple.withOpacity(0.15), my_colors.Palette.purple.shade200.withOpacity(0.15)]),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                offset: Offset(7, 5),
                spreadRadius: 2,
                blurRadius: 3,
              )
            ],
          ),
          child: Center(child: CircularProgressIndicator()));
    }
    // drawer part
  Widget buildHeader(BuildContext context) =>
      InkWell(
        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePageDesktop(pageIndex: 1, username: widget._userMeUsername))
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaY: 15, sigmaX: 15),
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      width: 1,
                      color: Colors.black26.withOpacity(0.05)
                  ),
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [my_colors.Palette.purple.withOpacity(0.15), my_colors.Palette.purple.shade200.withOpacity(0.15)]
                  )
              ),
              padding: EdgeInsets.only(
                top: 24 + MediaQuery
                    .of(context)
                    .padding
                    .top,
                bottom: 24+ MediaQuery
                    .of(context)
                    .padding
                    .bottom,
              ),
              child: Column(
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundImage: NetworkImage(widget._userMeAvatar!),
                    ),
                    SizedBox(height: 12,),
                    Text(widget._userMeUsername!,
                      style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: my_colors.Palette.hotPink.shade900
                                  .withOpacity(0.25),
                              offset: Offset(7, 5),
                              blurRadius: 10,
                            )
                          ]
                      ),
                    ),
                  ]),
            ),
          ),
        ),
      );
  Widget buildMenuItems(BuildContext context) =>
      ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: (MediaQuery
                .of(context)
                .size
                .height ),
            decoration: BoxDecoration(
                border: Border.all(
                    width: 1,
                    color: Colors.transparent
                ),
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [my_colors.Palette.purple.withOpacity(1), my_colors.Palette.purple.shade200.withOpacity(1)]
                )
            ),
            padding: EdgeInsets.all(10),
            child: Wrap(
              runSpacing: 2,
              children: [
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.white,),
                  title: Text(
                    "Home",
                    style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: my_colors.Palette.hotPink.shade900
                                .withOpacity(0.25),
                            offset: Offset(7, 5),
                            blurRadius: 10,
                          )
                        ]
                    ),),
                  onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePageDesktop(pageIndex: 1))),
                ),
                Divider(color: Colors.transparent),
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.white,),
                  title: Text(
                    "User",
                    style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: my_colors.Palette.hotPink.shade900
                                .withOpacity(0.25),
                            offset: Offset(7, 5),
                            blurRadius: 10,
                          )
                        ]
                    ),
                  ),
                  onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePageDesktop(pageIndex: 1))
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.leaderboard, color: Colors.white,),
                  title: Text(
                    "Rankings",
                    style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: my_colors.Palette.hotPink.shade900
                                .withOpacity(0.25),
                            offset: Offset(7, 5),
                            blurRadius: 10,
                          )
                        ]
                    ),
                  ),
                  onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePageDesktop(pageIndex: 2))
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.white,),
                  title: Text(
                    "Favourites (later updates)",
                    style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: my_colors.Palette.hotPink.shade900
                                .withOpacity(0.25),
                            offset: Offset(7, 5),
                            blurRadius: 10,
                          )
                        ]
                    ),
                  ),
                  onTap: () {},
                ),
                Divider(color: Colors.transparent),
                ListTile(
                  leading: const Icon(Icons.chat, color: Colors.white,),
                  title: Text(
                    "Chat (later updates)",
                    style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: my_colors.Palette.hotPink.shade900
                                .withOpacity(0.25),
                            offset: Offset(7, 5),
                            blurRadius: 10,
                          )
                        ]
                    ),
                  ),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.forum, color: Colors.white,),
                  title: Text(
                    "Forum (later updates)",
                    style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: my_colors.Palette.hotPink.shade900
                                .withOpacity(0.25),
                            offset: Offset(7, 5),
                            blurRadius: 10,
                          )
                        ]
                    ),
                  ),
                  onTap: () {},
                ),
                Divider(color: Colors.transparent),
                ListTile(
                  leading: const Icon(Icons.newspaper, color: Colors.white,),
                  title: Text(
                    "News",
                    style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: my_colors.Palette.hotPink.shade900
                                .withOpacity(0.25),
                            offset: Offset(7, 5),
                            blurRadius: 10,
                          )
                        ]
                    ),
                  ),
                  onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePageDesktop(pageIndex: 0))),
                ),
                ListTile(
                  leading: const Icon(Icons.update, color: Colors.white,),
                  title: Text(
                    "Updates",
                    style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: my_colors.Palette.hotPink.shade900
                                .withOpacity(0.25),
                            offset: Offset(7, 5),
                            blurRadius: 10,
                          )
                        ]
                    ),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );
}
