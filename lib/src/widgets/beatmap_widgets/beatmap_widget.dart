import 'package:flutter/material.dart';
import 'package:tracksu/src/pages/home_page.dart';

import '../../widgets/beatmap_widgets/beatmap_play_widget.dart';
import '../../models/beatmap.dart';
import '../../utils/color_contrasts.dart' as my_colors;

class BeatmapInfoWidget extends StatelessWidget {

  final Beatmap _beatmap;

  const BeatmapInfoWidget({Key? key, required Beatmap beatmap})
      :
        _beatmap = beatmap,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    var minuteStr = (_beatmap.beatmapLength ~/ 60).toString().padLeft(2, '0');
    var secondStr = (_beatmap.beatmapLength % 60).toString().padLeft(2, '0');
    var _timeStr = '$minuteStr:$secondStr';
    final double width = MediaQuery
        .of(context)
        .size
        .width;
    final double height = MediaQuery
        .of(context)
        .size
        .height;
    return Column(
      children: [
        SizedBox(height: 7,),
        Text(
          "${_beatmap.mapTitle}",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.0,
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
        Text(
          "[${_beatmap.difficultyName}]",
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 12.0,
            color: my_colors.Palette.yellow,
            fontFamily: 'Exo 2',
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                offset: Offset(7, 5),
                blurRadius: 10,
              )
            ],
          ),),
        Text(
          "by ${_beatmap.artistName}",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.0,
            color: my_colors.Palette.red,
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
        Container(
            margin: EdgeInsets.all(10.0),
            padding: EdgeInsets.all(5.0),
            height: height / 6.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [my_colors.Palette.brown.withOpacity(0.4), my_colors.Palette.purple.withOpacity(0.4)]),
            color: my_colors.Palette.brown.shade100,
            image: DecorationImage(
              image: NetworkImage("${_beatmap.coversJPG}"),
              fit: BoxFit.fill,
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
          child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BeatmapPlayWidget(beatmap: _beatmap),
                        Spacer(),
                        InkWell(
                          onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(pageIndex: 1, username: _beatmap.mapper.username!))),
                          child: Container(
                            child: Row(
                              children: [
                                Container(
                                  width:  45.0,
                                  height: 45.0,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                                        offset: Offset(7, 5),
                                        spreadRadius: 2,
                                        blurRadius: 3,
                                      )
                                    ],
                                    image: DecorationImage(
                                      image: NetworkImage("${_beatmap.mapper.avatarURL}"),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),

                                  ),
                                ),
                                SizedBox(width: 6,),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 10,),
                                      Text(
                                        "Submitted: ${_beatmap.submittedDate}".substring(0, 20),
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 10.0,
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
                                      Text(
                                        "${_beatmap.rankedStatus}",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 10.0,
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
                                      Text(
                                        "mapped by ${_beatmap.mapper.username}",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 11.0,
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
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 80,
                          padding: EdgeInsets.only(top: 2, bottom: 2),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                            boxShadow: [BoxShadow(color: _beatmap.colorOfRankedStatus!.withOpacity(0.75), spreadRadius: 1)],
                              color: Colors.black.withOpacity(0.30),),
                          child: Text(
                            "${_beatmap.shortRankedStatus}".toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.0,
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
                        ),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Image.asset(
                                'assets/utils/yellow_star.png',
                                color: my_colors.Palette.yellow,
                                scale: 2.9),
                            SizedBox(width: 5,),
                            Text(
                              "${_beatmap.difficultyRating}",
                              style: TextStyle(
                                fontSize: 12.0,
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
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Image.asset(
                                'assets/utils/heart-solid.png',
                                color: my_colors.Palette.hotPink,
                                scale: 42),
                            SizedBox(width: 5,),
                            Text(
                              "${_beatmap.favouriteCount}",
                              style: TextStyle(
                                fontSize: 12.0,
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
                        ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Image.asset(
                                'assets/utils/play-circle-solid.png',
                                color: my_colors.Palette.yellow,
                                scale: 42),
                            SizedBox(width: 5,),
                            Text(
                              "${_beatmap.playCount}",
                              style: TextStyle(
                                fontSize: 12.0,
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
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
          ),
    ),
              SizedBox(height: 5,),
              Container(
                width: width,
                height: 90,
                margin: EdgeInsets.only(left:10.0, right: 10.0, bottom: 5.0),
                padding: EdgeInsets.all(5.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [my_colors.Palette.brown.withOpacity(0.8), my_colors.Palette.purple.withOpacity(0.8)]),
                  color: my_colors.Palette.brown.shade100,
                  boxShadow: [
                    BoxShadow(
                      color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                      offset: Offset(7, 5),
                      spreadRadius: 2,
                      blurRadius: 3,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text("Length",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: my_colors.Palette.red,
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
                            Text("${_timeStr}",
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
                          ],
                        ),
                        SizedBox(width: 10,),
                        Column(
                          children: [
                            Text("BPM",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: my_colors.Palette.red,
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
                            Text("${_beatmap.BPM.round()}",
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
                          ],
                        ),
                        SizedBox(width: 10,),
                        Column(
                          children: [
                            Text("Circles",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: my_colors.Palette.red,
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
                            Text("${_beatmap.countCircles}",
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
                          ],
                        ),
                        SizedBox(width: 10,),
                        Column(
                          children: [
                            Text("Sliders",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: my_colors.Palette.red,
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
                            Text("${_beatmap.countSliders}",
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

                      ],
                    ),
                        SizedBox(width: 10,),
                        Column(
                          children: [
                            Text("Spinners",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: my_colors.Palette.red,
                                    fontSize: 14,
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
                            Text("${_beatmap.countSpinners}",
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

                          ],
                        ),

                ],
              ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text("CS",
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
                                  ],)
                            ),
                            Text("${_beatmap.CS}",
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
                          ],
                        ),
                        SizedBox(width: 10,),
                        Column(
                          children: [
                            Text("HP",
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
                                  ],)
                            ),
                            Text("${_beatmap.HP}",
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
                                  ],)
                            ),
                          ],
                        ),
                        SizedBox(width: 10,),
                        Column(
                          children: [
                            Text("OD",
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
                            Text("${_beatmap.OD}",
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
                          ],
                        ),
                        SizedBox(width: 10,),
                        Column(
                          children: [
                            Text("AR",
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
                            Text("${_beatmap.AR}",
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

                          ],
                        ),

                      ],
                    ),
                  ],
                ),
              ),
      ],
    );
  }
}