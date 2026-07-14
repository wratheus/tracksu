import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../widgets/user_widgets/user_beatmap_card.dart';
import '../../models/beatmap.dart';
import '../../models/user.dart';
import '../../pages/cubit/user_cubit.dart';
import '../../requests/requests.dart';
import '../../utils/secure_storage.dart';
import 'user_score_card.dart';
import '../../utils/color_contrasts.dart' as my_colors;
import '../../models/scores.dart';

// ignore: must_be_immutable
class UserListTilesElements extends StatefulWidget {
  User _userInstance;
  String _mode;

  UserListTilesElements({Key? key, required User userInstance, required String mode}):
    _userInstance = userInstance,
    _mode = mode,
    super(key: key);

  @override
  State<UserListTilesElements> createState() => _UserListTilesElements(_userInstance, _mode);
}

class _UserListTilesElements extends State<UserListTilesElements> {
  User _userInstance;
  String _mode;
  _UserListTilesElements(User userInstance, String mode)
      :
        _mode = mode,
        _userInstance = userInstance;
  List<Scores> _userBestScoresInstance = [];
  List<Scores> _userFirstScoresInstance = [];
  List<Beatmap> _userFavouriteBeatmapInstance = [];
  List<Beatmap> _userRankedBeatmapInstance = [];
  List<Beatmap> _userGraveyardBeatmapInstance = [];
  List<Beatmap> _userPendingBeatmapInstance = [];
  List<Beatmap> _userLovedBeatmapInstance = [];
  bool _userBestScoresInstanceLoading = false;
  bool _userFirstScoresLoading = false;
  bool _userFavouriteBeatmapLoading = false;
  bool _userRankedBeatmapLoading = false;
  bool _userGraveyardBeatmapLoading = false;
  bool _userPendingBeatmapLoading = false;
  bool _userLovedBeatmapLoading = false;

  Future<void> loadUserElements(String elementType, User userInstance, String mode, bool isOpen) async {
    if(isOpen == true){
      print("loadUserElements with params: $mode, ${userInstance.username}, $elementType");
      if(elementType == "best") {
        setState(() {
          _userBestScoresInstanceLoading = true;
        }
        );
        final List<Scores> userBestScores = await getUserScore((await UserSecureStorage.getTokenFromStorage())!, userInstance.username, '50', '0', 'best', mode);
        setState(() {
          _userBestScoresInstance = userBestScores;
          _userBestScoresInstanceLoading = false;
        });
      }
      if (elementType == "first") {
        setState(() {
          _userFirstScoresLoading = true;
        });
        final List<Scores> userFirstScores = await getUserScore((await UserSecureStorage.getTokenFromStorage())!, userInstance.username, '50', '0', 'firsts', mode);
        setState(() {
          _userFirstScoresInstance = userFirstScores;
          _userFirstScoresLoading = false;
        });
      }
      if (elementType == "favourite") {
        setState(() {
          _userFavouriteBeatmapLoading = true;
        });
        final List<Beatmap> userFavouriteBeatmaps = await getUserBeatmaps((await UserSecureStorage.getTokenFromStorage())!, userInstance.id, elementType);
        setState(() {
          _userFavouriteBeatmapInstance = userFavouriteBeatmaps;
          _userFavouriteBeatmapLoading = false;
          print(_userFavouriteBeatmapInstance.length);
        });
      }
    }
    if (elementType == "ranked") {
      setState(() {
        _userRankedBeatmapLoading = true;
      });
      final List<Beatmap> userRankedBeatmaps = await getUserBeatmaps((await UserSecureStorage.getTokenFromStorage())!, userInstance.id, elementType);
      setState(() {
        _userRankedBeatmapInstance = userRankedBeatmaps;
        for (int i = 0; i<_userRankedBeatmapInstance.length; i++){
          _userRankedBeatmapInstance[i].mapper = _userInstance;
        }
        _userRankedBeatmapLoading = false;
        print(_userRankedBeatmapInstance.length);
      });
    }
    if (elementType == "graveyard") {
      setState(() {
        _userGraveyardBeatmapLoading = true;
      });
      final List<Beatmap> userGraveyardBeatmaps = await getUserBeatmaps((await UserSecureStorage.getTokenFromStorage())!, userInstance.id, elementType);
      setState(() {
        _userGraveyardBeatmapInstance = userGraveyardBeatmaps;
        for (int i = 0; i<_userGraveyardBeatmapInstance.length; i++){
          _userGraveyardBeatmapInstance[i].mapper = _userInstance;
        }
        _userGraveyardBeatmapLoading = false;
        print(_userGraveyardBeatmapInstance.length);
      });
    }
    if (elementType == "pending") {
      setState(() {
        _userPendingBeatmapLoading = true;
      });
      final List<Beatmap> userPendingBeatmaps = await getUserBeatmaps((await UserSecureStorage.getTokenFromStorage())!, userInstance.id, elementType);
      setState(() {
        _userPendingBeatmapInstance = userPendingBeatmaps;
        for (int i = 0; i<_userPendingBeatmapInstance.length; i++){
          _userPendingBeatmapInstance[i].mapper = _userInstance;
        }
        _userPendingBeatmapLoading = false;
        print(_userPendingBeatmapInstance.length);
      });
    }
    if (elementType == "loved") {
      setState(() {
        _userLovedBeatmapLoading = true;
      });
      final List<Beatmap> userLovedBeatmaps = await getUserBeatmaps((await UserSecureStorage.getTokenFromStorage())!, userInstance.id, elementType);
      setState(() {
        _userLovedBeatmapInstance = userLovedBeatmaps;
        for (int i = 0; i<_userLovedBeatmapInstance.length; i++){
          _userLovedBeatmapInstance[i].mapper = _userInstance;
        }
        _userLovedBeatmapLoading = false;
        print(_userLovedBeatmapInstance.length);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
/*    final double height = MediaQuery
        .of(context)
        .size
        .height;
    final double width = MediaQuery
        .of(context)
        .size
        .width;*/

    return Column(
        children: [
          Row(
            children: [
              SizedBox(width: 20,),
              Container(
                height: 20,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: my_colors.Palette.hotPink, spreadRadius: 1)
                    ],
                    color: my_colors.Palette.brown.shade200),
                alignment: Alignment.center,),
              SizedBox(width: 10,),
              Text("User Information",
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Exo 2',
                    shadows: [
                      Shadow(
                        color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                        offset: Offset(7, 5),
                        blurRadius: 10,
                      )
                    ],
                  )
              ),
              SizedBox(height: 50,)
            ],
          ),
          ExpansionTile(
              iconColor: my_colors.Palette.pink,
              collapsedIconColor: my_colors.Palette.pink,
              title: Row(
                  children: [
                    Text("Show custom information",
                        style: TextStyle(
                          fontSize: 16.0,
                          color: my_colors.Palette.pink,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Exo 2',
                          shadows: [
                            Shadow(
                              color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                              offset: Offset(7, 5),
                              blurRadius: 10,
                            )
                          ],
                        )
                    ),
                  ]
              ),
              children: [
                Container(
                    child: Container(
                        margin: EdgeInsets.all(10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: my_colors.Palette.brown.shade200,
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
                        child: HtmlWidget(
                            _userInstance.userPage,
                            textStyle: TextStyle(
                              fontSize: 12.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Exo 2',
                              shadows: [
                                Shadow(
                                  color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                                  offset: Offset(7, 5),
                                  blurRadius: 10,
                                ),
                              ],
                            )
                        )
                    )
                ),
              ]
          ),
          Row(
            children: [
              SizedBox(width: 20,),
              Container(
                height: 20,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: my_colors.Palette.hotPink, spreadRadius: 1)
                    ],
                    color: my_colors.Palette.brown.shade200),
                alignment: Alignment.center,),
              SizedBox(width: 10,),
              Text("Best Performance",
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Exo 2',
                    shadows: [
                      Shadow(
                        color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                        offset: Offset(7, 5),
                        blurRadius: 10,
                      )
                    ],
                  )
              ),
              SizedBox(height: 50,)
            ],
          ),
          ExpansionTile(
            onExpansionChanged: (isOpen) => loadUserElements("best", _userInstance, _mode, isOpen),
            iconColor: my_colors.Palette.pink,
            collapsedIconColor: my_colors.Palette.pink,
            title: Row(
              children: [
                Text("Show best performance scores",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: my_colors.Palette.pink,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Exo 2',
                      shadows: [
                        Shadow(
                          color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                          offset: Offset(7, 5),
                          blurRadius: 10,
                        )
                      ],
                    )
                ),
                SizedBox(height: 50,)
              ],
            ),
            children: [
              SizedBox(height: 10),
              _userBestScoresInstanceLoading == false ? ListView.builder(
                  padding: EdgeInsets.all(0.0),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: _userBestScoresInstance.length,
                  itemBuilder: (context, index) {
                    index += 0;
                    return InkWell(
                        onTap: () => context.read<UserCubit>().loadBeatmapFromUser(_userBestScoresInstance[index], context),
                        child: ScoreCardWidget(
                            item: _userBestScoresInstance[index])
                    );
                  }
              ) : Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: my_colors.Palette.brown.shade200,
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
                  child: Center(child: CircularProgressIndicator())),
            ],
          ),
          ExpansionTile(
            onExpansionChanged: (isOpen) => loadUserElements("first", _userInstance, _mode, isOpen),
            iconColor: my_colors.Palette.pink,
            collapsedIconColor: my_colors.Palette.pink,
            title: Row(
              children: [
                Text("Show first-place scores",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: my_colors.Palette.pink,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Exo 2',
                      shadows: [
                        Shadow(
                          color: my_colors.Palette.hotPink.shade900
                              .withOpacity(0.25),
                          offset: Offset(7, 5),
                          blurRadius: 10,
                        )
                      ],
                    )
                ),
                SizedBox(height: 50,)
              ],
            ),
            children: [
              SizedBox(height: 10),
              _userFirstScoresLoading == false ? ListView.builder(
                  padding: EdgeInsets.all(0.0),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: _userFirstScoresInstance.length,
                  itemBuilder: (context, index) {
                    index += 0;
                    return InkWell(
                        onTap: () => context.read<UserCubit>().loadBeatmapFromUser(_userFirstScoresInstance[index], context),
                        child: ScoreCardWidget(
                            item: _userFirstScoresInstance[index])
                    );
                  }) : Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: my_colors.Palette.brown.shade200,
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
                  child: Center(child: CircularProgressIndicator())),
            ],
          ),
          Row(
            children: [
              SizedBox(width: 20,),
              Container(
                height: 20,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: my_colors.Palette.hotPink, spreadRadius: 1)
                    ],
                    color: my_colors.Palette.brown.shade200),
                alignment: Alignment.center,),
              SizedBox(width: 10,),
              Text("Show beatmaps",
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Exo 2',
                    shadows: [
                      Shadow(
                        color: my_colors.Palette.hotPink.shade900
                            .withOpacity(
                            0.25),
                        offset: Offset(7, 5),
                        blurRadius: 10,
                      )
                    ],
                  )
              ),
              SizedBox(height: 50,)
            ],
          ),
          // favourite tile
          ExpansionTile(
            onExpansionChanged: (isOpen) => loadUserElements("favourite", _userInstance, _mode, isOpen),
            iconColor: my_colors.Palette.pink,
            collapsedIconColor: my_colors.Palette.pink,
            title: Row(
              children: [
                Text("Show favourite beatmaps",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: my_colors.Palette.pink,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Exo 2',
                      shadows: [
                        Shadow(
                          color: my_colors.Palette.hotPink.shade900
                              .withOpacity(0.25),
                          offset: Offset(7, 5),
                          blurRadius: 10,
                        )
                      ],
                    )
                ),
              ],
            ),
            children: [
              _userFavouriteBeatmapLoading == false ? ListView.builder(
                  padding: EdgeInsets.all(0.0),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: _userFavouriteBeatmapInstance.length,
                  itemBuilder: (context, index) {
                    index += 0;
                    return InkWell(
                        onTap: () => context.read<UserCubit>().loadBeatmapFromUser(_userFavouriteBeatmapInstance[index], context),
                        child: BeatmapCardWidget(
                          beatmap: _userFavouriteBeatmapInstance[index],
                        )
                    );
                  }) : Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: my_colors.Palette.brown.shade200,
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
                  child: Center(child: CircularProgressIndicator())),
            ],
          ),
          // ranked tile
          ExpansionTile(
            onExpansionChanged: (isOpen) => loadUserElements("ranked", _userInstance, _mode, isOpen),
            iconColor: my_colors.Palette.pink,
            collapsedIconColor: my_colors.Palette.pink,
            title: Row(
              children: [
                Text("Show ranked beatmaps",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: my_colors.Palette.pink,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Exo 2',
                      shadows: [
                        Shadow(
                          color: my_colors.Palette.hotPink.shade900
                              .withOpacity(0.25),
                          offset: Offset(7, 5),
                          blurRadius: 10,
                        )
                      ],
                    )
                ),
              ],
            ),
            children: [
              _userRankedBeatmapLoading == false ? ListView.builder(
                  padding: EdgeInsets.all(0.0),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: _userRankedBeatmapInstance.length,
                  itemBuilder: (context, index) {
                    index += 0;
                    return InkWell(
                        onTap: () => context.read<UserCubit>().loadBeatmapFromUser(_userRankedBeatmapInstance[index], context),
                        child: BeatmapCardWidget(
                          beatmap: _userRankedBeatmapInstance[index],
                        )
                    );
                  }) : Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: my_colors.Palette.brown.shade200,
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
                  child: Center(child: CircularProgressIndicator())),
            ],
          ),
          // loved Tile
          ExpansionTile(
            onExpansionChanged: (isOpen) => loadUserElements("loved", _userInstance, _mode, isOpen),
            iconColor: my_colors.Palette.pink,
            collapsedIconColor: my_colors.Palette.pink,
            title: Row(
              children: [
                Text("Show loved beatmaps",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: my_colors.Palette.pink,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Exo 2',
                      shadows: [
                        Shadow(
                          color: my_colors.Palette.hotPink.shade900
                              .withOpacity(0.25),
                          offset: Offset(7, 5),
                          blurRadius: 10,
                        )
                      ],
                    )
                ),
              ],
            ),
            children: [
              _userLovedBeatmapLoading == false ? ListView.builder(
                  padding: EdgeInsets.all(0.0),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: _userLovedBeatmapInstance.length,
                  itemBuilder: (context, index) {
                    index += 0;
                    return InkWell(
                        onTap: () => context.read<UserCubit>().loadBeatmapFromUser(_userLovedBeatmapInstance[index], context),
                        child: BeatmapCardWidget(
                          beatmap: _userLovedBeatmapInstance[index],
                        )
                    );
                  }) : Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: my_colors.Palette.brown.shade200,
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
                  child: Center(child: CircularProgressIndicator())),
            ],
          ),
          // pending tile
          ExpansionTile(
            onExpansionChanged: (isOpen) => loadUserElements("pending", _userInstance, _mode, isOpen),
            iconColor: my_colors.Palette.pink,
            collapsedIconColor: my_colors.Palette.pink,
            title: Row(
              children: [
                Text("Show pending beatmaps",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: my_colors.Palette.pink,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Exo 2',
                      shadows: [
                        Shadow(
                          color: my_colors.Palette.hotPink.shade900
                              .withOpacity(0.25),
                          offset: Offset(7, 5),
                          blurRadius: 10,
                        )
                      ],
                    )
                ),
              ],
            ),
            children: [
              _userPendingBeatmapLoading == false ? ListView.builder(
                  padding: EdgeInsets.all(0.0),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: _userPendingBeatmapInstance.length,
                  itemBuilder: (context, index) {
                    index += 0;
                    return InkWell(
                        onTap: () => context.read<UserCubit>().loadBeatmapFromUser(_userPendingBeatmapInstance[index], context),
                        child: BeatmapCardWidget(
                          beatmap: _userPendingBeatmapInstance[index],
                        )
                    );
                  }) : Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: my_colors.Palette.brown.shade200,
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
                  child: Center(child: CircularProgressIndicator())),
            ],
          ),
          // graveyard tile
          ExpansionTile(
            onExpansionChanged: (isOpen) => loadUserElements("graveyard", _userInstance, _mode, isOpen),
            iconColor: my_colors.Palette.pink,
            collapsedIconColor: my_colors.Palette.pink,
            title: Row(
              children: [
                Text("Show graveyard beatmaps",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: my_colors.Palette.pink,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Exo 2',
                      shadows: [
                        Shadow(
                          color: my_colors.Palette.hotPink.shade900
                              .withOpacity(0.25),
                          offset: Offset(7, 5),
                          blurRadius: 10,
                        )
                      ],
                    )
                ),
              ],
            ),
            children: [
              _userGraveyardBeatmapLoading == false ? ListView.builder(
                  padding: EdgeInsets.all(0.0),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: _userGraveyardBeatmapInstance.length,
                  itemBuilder: (context, index) {
                    index += 0;
                    return InkWell(
                        onTap: () => context.read<UserCubit>().loadBeatmapFromUser(_userGraveyardBeatmapInstance[index], context),
                        child: BeatmapCardWidget(
                          beatmap: _userGraveyardBeatmapInstance[index],
                        )
                    );
                  }) : Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: my_colors.Palette.brown.shade200,
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
                  child: Center(child: CircularProgressIndicator())),
            ],
          ),
        ],
      );
    }
}