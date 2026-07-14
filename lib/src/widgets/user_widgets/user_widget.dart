import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../utils/color_contrasts.dart' as my_colors;
import 'package:fluttericon/font_awesome5_icons.dart';

class UserInfoWidget extends StatelessWidget {

  final User _user;

  const UserInfoWidget({Key? key, required User user}):
        _user = user,
        super(key: key);


  @override
  Widget build(BuildContext context) {
/*    final double height = MediaQuery
        .of(context)
        .size
        .height;*/
    final double width = MediaQuery
        .of(context)
        .size
        .width;

    // Commented code is Desktop version UserPage, work in progress
// (Platform.isIOS || Platform.isAndroid == true) ?  Container(
    return Container(
      width: width/1.05,
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 100.0,
                                height: 100.0,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(_user.avatarURL),
                                    fit: BoxFit.cover,
                                    opacity: 1
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                                      offset: Offset(7, 5),
                                      spreadRadius: 2,
                                      blurRadius: 3,
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              ],
                            ),
                            SizedBox(width: 5),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${_user.username}",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      shadows: [
                                        Shadow(
                                          color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                                          offset: Offset(7, 5),
                                          blurRadius: 10,
                                        )
                                      ],
                                      color: Colors.white,
                                      fontFamily: 'Exo 2',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${_user.defaultGroup}",
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      shadows: [
                                        Shadow(
                                          color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                                          offset: Offset(7, 5),
                                          blurRadius: 10,
                                        )
                                      ],
                                      color: Colors.white,
                                      fontFamily: 'Exo 2',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${_user.title}",
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      shadows: [
                                        Shadow(
                                          color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                                          offset: Offset(7, 5),
                                          blurRadius: 10,
                                        )
                                      ],
                                      color: Colors.white,
                                      fontFamily: 'Exo 2',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text("${_user.globalRank}",
                                      style: TextStyle(
                                        color: my_colors.Palette.yellow,
                                        fontSize: 14.0,
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
                                  Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                                            offset: Offset(7, 5),
                                            spreadRadius: 2,
                                            blurRadius: 3,
                                          )
                                        ],
                                      ),
                                      child: Image.asset('assets/icon_country_flags/${_user.countryCode}.png',scale: 3.5)
                                  ),
                                ],
                              ),
                            ),
                            Text("Last online\n${_user.lastVisit}",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 14,
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
                    ),
                  ],
                ),
                // User information bloc
                SizedBox(height: 15.0,),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: my_colors.Palette.brown.shade200,
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [my_colors.Palette.brown.withOpacity(0.5), my_colors.Palette.purple.withOpacity(0.5)]),
                        image: DecorationImage(
                          image: (_user.customCoverURL == null) ? NetworkImage("${_user.defaultCoverURL}") : NetworkImage("${_user.customCoverURL}"),
                          fit: BoxFit.fill,
                          opacity: 1,
                          colorFilter: ColorFilter.mode(
                              Colors.white.withOpacity(0.24), BlendMode.dstATop),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                            offset: Offset(7, 5),
                            spreadRadius: 2,
                            blurRadius: 3,
                          )
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Ranked Score:",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
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
                                Text("Hit Accuracy:",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
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
                                Text("Play Count:",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: my_colors.Palette.yellow,
                                      fontSize: 14,
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
                                Text("Total Hits:",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: my_colors.Palette.yellow,
                                      fontSize: 14,
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
                                Text("Maximum Combo:",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: my_colors.Palette.yellow,
                                      fontSize: 14,
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
                                Text("Replay count:",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: my_colors.Palette.yellow,
                                      fontSize: 14,
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
                              ],
                            ),
                          ),
                          Spacer(),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("${_user.rankedScore}",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
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
                              Text("${_user.hitAccuracy}%",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
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
                              Text("${_user.playCount}",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: my_colors.Palette.yellow,
                                    fontSize: 14,
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
                              Text("${_user.totalHits}",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: my_colors.Palette.yellow,
                                    fontSize: 14,
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
                              Text("${_user.maximumCombo}",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: my_colors.Palette.yellow,
                                    fontSize: 14,
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
                              Text("${_user.replaysWatched}",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: my_colors.Palette.yellow,
                                    fontSize: 14,
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
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // colored strips under user statistics
                SizedBox(height: 20,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Container(
                          width: width/3.5,
                          height: 1,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: my_colors.Palette.hotPink,
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
                        ),
                        SizedBox(height: 5,),
                        Text("Total Play Time",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
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
                        SizedBox(height: 5,),
                        Text("${(_user.playTime / 3600).ceil()} hours",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
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
                      ]),
                    ),
                    SizedBox(width: 20,),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Container(
                          width: width/3.5,
                          height: 1,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: my_colors.Palette.red.shade300,
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
                        ),
                        SizedBox(height: 5,),
                        Text("Performance Points",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
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
                        SizedBox(height: 5,),
                        Text("${(_user.totalPP).round()}",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
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
                      ]),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // score-types bloc
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(children: [
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: my_colors.Palette.hotPink.shade900.withOpacity(0.1),
                              offset: Offset(7, 5),
                              spreadRadius: 1,
                              blurRadius: 2,
                            )
                          ],
                        ),
                        child: Image.asset(
                            'assets/icon_score_types/grade_xh.png',),),
                      SizedBox(height: 5,),
                      Text("${_user.amountOfSSH}",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
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
                    ]),
                    SizedBox(width: 10,),
                    Column(children: [
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: my_colors.Palette.hotPink.shade900.withOpacity(0.1),
                              offset: Offset(7, 5),
                              spreadRadius: 1,
                              blurRadius: 2,
                            )
                          ],
                        ),
                        child: Image.asset(
                            'assets/icon_score_types/grade_x.png'),),
                      SizedBox(height: 5,),
                      Text("${_user.amountOfSS}",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
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
                    ]),
                    SizedBox(width: 10,),
                    Column(children: [
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: my_colors.Palette.hotPink.shade900.withOpacity(0.1),
                              offset: Offset(7, 5),
                              spreadRadius: 1,
                              blurRadius: 2,
                            )
                          ],
                        ),
                        child: Image.asset(
                            'assets/icon_score_types/grade_sh.png'),),
                      SizedBox(height: 5,),
                      Text("${_user.amountOfSh}",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
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
                    ]),
                    SizedBox(width: 10,),
                    Column(children: [
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: my_colors.Palette.hotPink.shade900.withOpacity(0.1),
                              offset: Offset(7, 5),
                              spreadRadius: 1,
                              blurRadius: 2,
                            )
                          ],
                        ),
                        child: Image.asset('assets/icon_score_types/grade_s.png'),),
                      SizedBox(height: 5,),
                      Text("${_user.amountOfS}",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
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
                    ]),
                    SizedBox(width: 10,),
                    Column(children: [
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: my_colors.Palette.hotPink.shade900.withOpacity(0.1),
                              offset: Offset(7, 5),
                              spreadRadius: 1,
                              blurRadius: 2,
                            )
                          ],
                        ),
                        child: Image.asset('assets/icon_score_types/grade_a.png'),),
                      SizedBox(height: 5,),
                      Text("${_user.amountOfA}",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Exo 2',
                            shadows: [
                              Shadow(
                                color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                                offset: Offset(7, 5),
                                blurRadius: 10,
                              )
                            ],)
                      ),
                    ]),
                  ],
                ),

                // ranking in the world and country bloc
                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                        Container(
                          width: width/3.5,
                          height: 1,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.cyanAccent,
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
                        ),
                        SizedBox(height: 5,),
                        Text("World rank",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
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
                        SizedBox(height: 5,),
                        Text("${_user.globalRank}",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: my_colors.Palette.yellow,
                              fontSize: 14,
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
                      ]),
                    ),
                    SizedBox(width: 20,),
                    Expanded(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                        Container(
                          width: width/3.5,
                          height: 1,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.lightGreenAccent,
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
                        ),
                        SizedBox(height: 5,),
                        Text("Country rank",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
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
                        SizedBox(height: 5,),
                        Text("${_user.countryRank}",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: my_colors.Palette.yellow,
                              fontSize: 14,
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
                      ]),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 10,),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: width/1.3,
                            height: 1,
                            decoration: BoxDecoration(
                              color: Colors.deepOrangeAccent,
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
                          ),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(FontAwesome5.discord, size: 10, color: Colors.white,),
                              Text("  ${_user.discord}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
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
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(FontAwesome5.twitter, size: 10, color: Colors.white),
                              Text("  ${_user.twitter}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
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
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(FontAwesome5.link, size: 10, color: Colors.white),
                              Text("  ${_user.website}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
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
                            ],
                          ),
                        ],
                      ),
                    ),
                    ]
                ),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: width/1.5,
                              height: 1,
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
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
                            ),
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(FontAwesome5.location_arrow, size: 10, color: Colors.white),
                                Text("  ${_user.location}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
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
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(FontAwesome5.heart, size: 10, color: Colors.white),
                              Text("  ${_user.interests}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
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
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(FontAwesome5.houzz, size: 10, color: Colors.white),
                              Text("  ${_user.occupation}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
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
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),

              ]
          ),
        ],
        ),
      ); /*:
    Container(
      width: width/1.1,
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 200.0,
                                    height: 200.0,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage(_user.avatarURL),
                                          fit: BoxFit.cover,
                                          opacity: 1
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                                          offset: Offset(7, 5),
                                          spreadRadius: 2,
                                          blurRadius: 3,
                                        )
                                      ],
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 15,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${_user.username}",
                                    style: TextStyle(
                                      fontSize: 30.0,
                                      shadows: [
                                        Shadow(
                                          color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                                          offset: Offset(7, 5),
                                          blurRadius: 10,
                                        )
                                      ],
                                      color: Colors.white,
                                      fontFamily: 'Exo 2',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${_user.defaultGroup}",
                                    style: TextStyle(
                                      fontSize: 24.0,
                                      shadows: [
                                        Shadow(
                                          color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                                          offset: Offset(7, 5),
                                          blurRadius: 10,
                                        )
                                      ],
                                      color: Colors.white,
                                      fontFamily: 'Exo 2',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${_user.title}",
                                    style: TextStyle(
                                      fontSize: 24.0,
                                      shadows: [
                                        Shadow(
                                          color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                                          offset: Offset(7, 5),
                                          blurRadius: 10,
                                        )
                                      ],
                                      color: Colors.white,
                                      fontFamily: 'Exo 2',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text("${_user.globalRank}",
                                      style: TextStyle(
                                        color: my_colors.Palette.yellow,
                                        fontSize: 26.0,
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
                                  Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                                            offset: Offset(7, 5),
                                            spreadRadius: 2,
                                            blurRadius: 3,
                                          )
                                        ],
                                      ),
                                      child: Image.asset('assets/icon_country_flags/${_user.countryCode}.png',scale: 1.5)
                                  ),
                                ],
                              ),
                            ),
                            Text("Last online\n${_user.lastVisit}",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 24,
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
                    ),
                  ],
                ),
                // User information bloc
                SizedBox(height: 15.0,),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: my_colors.Palette.brown.shade200,
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [my_colors.Palette.brown.withOpacity(0.5), my_colors.Palette.purple.withOpacity(0.5)]),
                        image: DecorationImage(
                          image: (_user.customCoverURL == null) ? NetworkImage("${_user.defaultCoverURL}") : NetworkImage("${_user.customCoverURL}"),
                          fit: BoxFit.fill,
                          opacity: 1,
                          colorFilter: ColorFilter.mode(
                              Colors.white.withOpacity(0.24), BlendMode.dstATop),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                            offset: Offset(7, 5),
                            spreadRadius: 2,
                            blurRadius: 3,
                          )
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Ranked Score:",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
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
                                Text("Hit Accuracy:",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
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
                                Text("Play Count:",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: my_colors.Palette.yellow,
                                      fontSize: 24,
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
                                Text("Total Hits:",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: my_colors.Palette.yellow,
                                      fontSize: 24,
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
                                Text("Maximum Combo:",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: my_colors.Palette.yellow,
                                      fontSize: 24,
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
                                Text("Replay count:",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: my_colors.Palette.yellow,
                                      fontSize: 24,
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
                              ],
                            ),
                          ),
                          Spacer(),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("${_user.rankedScore}",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
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
                              Text("${_user.hitAccuracy}%",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
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
                              Text("${_user.playCount}",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: my_colors.Palette.yellow,
                                    fontSize: 24,
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
                              Text("${_user.totalHits}",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: my_colors.Palette.yellow,
                                    fontSize: 24,
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
                              Text("${_user.maximumCombo}",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: my_colors.Palette.yellow,
                                    fontSize: 24,
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
                              Text("${_user.replaysWatched}",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: my_colors.Palette.yellow,
                                    fontSize: 24,
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
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // colored strips under user statistics
                SizedBox(height: 20,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: width/7,
                              height: 1,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: my_colors.Palette.hotPink,
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
                            ),
                            SizedBox(height: 5,),
                            Text("Total Play Time",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
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
                            SizedBox(height: 5,),
                            Text("${(_user.playTime / 3600).ceil()} hours",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
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
                          ]),
                    ),
                    SizedBox(width: 20,),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: width/7,
                              height: 1,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: my_colors.Palette.red.shade300,
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
                            ),
                            SizedBox(height: 5,),
                            Text("Performance Points",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
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
                            SizedBox(height: 5,),
                            Text("${(_user.totalPP).round()}",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
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
                          ]),
                    ),
                    Expanded(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: width/7,
                              height: 1,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.cyanAccent,
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
                            ),
                            SizedBox(height: 5,),
                            Text("World rank",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
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
                            SizedBox(height: 5,),
                            Text("${_user.globalRank}",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: my_colors.Palette.yellow,
                                  fontSize: 24,
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
                          ]),
                    ),
                    SizedBox(width: 20,),
                    Expanded(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: width/7,
                              height: 1,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.lightGreenAccent,
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
                            ),
                            SizedBox(height: 5,),
                            Text("Country rank",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
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
                            SizedBox(height: 5,),
                            Text("${_user.countryRank}",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: my_colors.Palette.yellow,
                                  fontSize: 24,
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
                          ]),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // score-types bloc
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(children: [
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: my_colors.Palette.hotPink.shade900.withOpacity(0.1),
                              offset: Offset(7, 5),
                              spreadRadius: 1,
                              blurRadius: 2,
                            )
                          ],
                        ),
                        child: Image.asset(
                          'assets/icon_score_types/grade_xh.png',),),
                      SizedBox(height: 5,),
                      Text("${_user.amountOfSSH}",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
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
                    ]),
                    SizedBox(width: 10,),
                    Column(children: [
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: my_colors.Palette.hotPink.shade900.withOpacity(0.1),
                              offset: Offset(7, 5),
                              spreadRadius: 1,
                              blurRadius: 2,
                            )
                          ],
                        ),
                        child: Image.asset(
                            'assets/icon_score_types/grade_x.png'),),
                      SizedBox(height: 5,),
                      Text("${_user.amountOfSS}",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
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
                    ]),
                    SizedBox(width: 10,),
                    Column(children: [
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: my_colors.Palette.hotPink.shade900.withOpacity(0.1),
                              offset: Offset(7, 5),
                              spreadRadius: 1,
                              blurRadius: 2,
                            )
                          ],
                        ),
                        child: Image.asset(
                            'assets/icon_score_types/grade_sh.png'),),
                      SizedBox(height: 5,),
                      Text("${_user.amountOfSh}",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
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
                    ]),
                    SizedBox(width: 10,),
                    Column(children: [
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: my_colors.Palette.hotPink.shade900.withOpacity(0.1),
                              offset: Offset(7, 5),
                              spreadRadius: 1,
                              blurRadius: 2,
                            )
                          ],
                        ),
                        child: Image.asset('assets/icon_score_types/grade_s.png'),),
                      SizedBox(height: 5,),
                      Text("${_user.amountOfS}",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
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
                    ]),
                    SizedBox(width: 10,),
                    Column(children: [
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: my_colors.Palette.hotPink.shade900.withOpacity(0.1),
                              offset: Offset(7, 5),
                              spreadRadius: 1,
                              blurRadius: 2,
                            )
                          ],
                        ),
                        child: Image.asset('assets/icon_score_types/grade_a.png'),),
                      SizedBox(height: 5,),
                      Text("${_user.amountOfA}",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Exo 2',
                            shadows: [
                              Shadow(
                                color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                                offset: Offset(7, 5),
                                blurRadius: 10,
                              )
                            ],)
                      ),
                    ]),
                  ],
                ),

                // ranking in the world and country bloc
                SizedBox(height: 20),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 10,),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: width/3,
                              height: 1,
                              decoration: BoxDecoration(
                                color: Colors.deepOrangeAccent,
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
                            ),
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(FontAwesome5.discord, size: 20, color: Colors.white,),
                                Text("  ${_user.discord}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
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
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(FontAwesome5.twitter, size: 20, color: Colors.white),
                                Text("  ${_user.twitter}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
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
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(FontAwesome5.link, size: 20, color: Colors.white),
                                Text("  ${_user.website}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
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
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: width/4.5,
                              height: 1,
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
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
                            ),
                            SizedBox(height: 20,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(FontAwesome5.location_arrow, size: 10, color: Colors.white),
                                Text("  ${_user.location}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
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
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(FontAwesome5.heart, size: 20, color: Colors.white),
                                Text("  ${_user.interests}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
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
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(FontAwesome5.houzz, size: 20, color: Colors.white),
                                Text("  ${_user.occupation}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
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
                              ],
                            ),
                          ],
                        ),
                      ),
                    ]
                ),
                SizedBox(height: 10,),
              ]
          ),
        ],
      ),
    );*/
    }
  }
