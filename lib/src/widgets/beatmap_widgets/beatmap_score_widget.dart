import 'package:flutter/material.dart';

import '../../utils/color_contrasts.dart' as my_colors;
import '../../models/beatmap_score.dart';
import'../../models/beatmap.dart';

class BeatmapScoreWidget extends StatelessWidget {

  final BeatmapScore _item;
  final int _index;
  final Beatmap _beatmapItem;
  const BeatmapScoreWidget({Key? key, required BeatmapScore item, required int index, required Beatmap beatmapItem})
      :
        _item = item,
        _index = index + 1,
        _beatmapItem = beatmapItem,
        super(key: key);

  @override
  Widget build(BuildContext context) {

    String accuracy = "${_item.accuracy}";
    final List<Image> mods_icons = [];

    if("${_item.accuracy}".length > 5){
      accuracy = "${_item.accuracy * 100}".substring(0,5);
    }
    else if("${_item.accuracy}".length == 5){
      accuracy = "${_item.accuracy * 100}".substring(0,4);
    }
    else {
      accuracy = "${_item.accuracy * 100}";
    }

    if (_item.mods != []) {
      for (int i = 0; i < _item.mods.length; i++) {
        String modeStr = "assets/icon_mods/mod_${_item.mods[i]
            .toLowerCase()}.png";
        mods_icons.add(Image.asset(modeStr, scale: 1));
      }
    }
    if (_item.mods.isEmpty == true) mods_icons.add(Image.asset(
        "assets/icon_mods/mod_nm.png", scale: 1)); // for no-mod score

    if (_item.gainedPP == null) {
      _item.gainedPP = 0;
    }
    return Card(
      color: my_colors.Palette.brown.shade100,
      margin: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 5.0),
      child: Container(
        decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [my_colors.Palette.brown.withOpacity(0.8), my_colors.Palette.purple.withOpacity(0.8)]),
          boxShadow: [
            BoxShadow(
              color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
              offset: Offset(7, 5),
              spreadRadius: 2,
              blurRadius: 3,
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(3.5),
          child: Column(
            children: [
              Column(
                children: [
                  Row(
                      children: [
                        Text(
                        "${_index}",
                          style: TextStyle(
                            fontSize: 11.0,
                            color: my_colors.Palette.red,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Exo 2',
                              shadows: [
                                Shadow(
                                  color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                                  offset: Offset(7, 5),
                                  blurRadius: 10,
                                )
                              ],
                          ),
                        ),
                        const SizedBox(width: 2.0,),
                        Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 35.0,
                                    height: 35.0,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(_item.avatarURL),
                                        fit: BoxFit.cover,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: my_colors.Palette.hotPink.shade900.withOpacity(0.1),
                                          offset: Offset(7, 5),
                                          spreadRadius: 1,
                                          blurRadius: 2,
                                        )
                                      ],
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                ],
                              ),
                            ]
                        ),
                        const SizedBox(width: 2.0,),
                        Expanded(child:
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_item.username,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.0,
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
                              const SizedBox(height: 2.0,),
                              Row(
                                children: [
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
                                    child: Image.asset('assets/icon_country_flags/${_item.countryCode}.png',scale: 5.5),
                                  ),
                                  const SizedBox(width: 3.0,),
                                ],
                              ),
                            ]
                          ),
                        ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    'assets/icon_score_types/grade_' +
                                        "${_item.mapRank}".toLowerCase() +
                                        ".png", scale: 1.25,),
                                ],
                              ),
                              SizedBox(width: 10,),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Gained:",
                                      textAlign: TextAlign.left,
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
                                  Text("Accuracy:",
                                      textAlign: TextAlign.left,
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
                                ]
                        ),
                              const SizedBox(width: 5.0,),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text("${_item.gainedPP.round()}pp",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: my_colors.Palette.hotPink,
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
                                  Text(accuracy + "%",
                                      textAlign: TextAlign.left,
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
                              ]
                        ),
                            ],
                          ),
                        const SizedBox(width: 5.0,),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Combo:",
                                textAlign: TextAlign.left,
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
                            Text("Mods:",
                                textAlign: TextAlign.left,
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
                        const SizedBox(width: 5.0,),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Text("${_item.maxCombo}x ",
                                    textAlign: TextAlign.left,
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
                                _beatmapItem.maxCombo == null ? Container() : Text("(${_beatmapItem.maxCombo}x)",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: my_colors.Palette.red,
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
                            Container(
                              height: 10,
                              child: ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: mods_icons.length,
                                  itemBuilder: (context, index) {
                                    return mods_icons[index];
                                  }),
                            )
                          ],
                        ),
                        const SizedBox(width: 5.0,),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 10,),
                  Text("Date of score:    ",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 8,
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
                  Text("${_item.dateOfScore}".substring(0, 10),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
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
            ],
          )
        ),
      ),
    );
  }
}