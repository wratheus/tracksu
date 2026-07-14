import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

import '../../models/country.dart';
import '../../pages/cubit/rankings_cubit.dart';
import '../../utils/color_contrasts.dart' as my_colors;

// ignore: must_be_immutable
class RankingsSearchFiltersWidget extends StatefulWidget {
  String? _mode = "osu";
  String _filterValue;
  String _page;
  Country? _countryValue;
  Object? _dropdownValue;
  Object? _dropdownCountryValue;
  List<Country> _countryList;

  RankingsSearchFiltersWidget(String filterValue, String? mode, List<Country> countryList, Country? countryValue, String page)
      :
        _filterValue = filterValue,
        _countryValue = countryValue,
        _mode = mode,
        _countryList = countryList,
        _page = page;

  @override
  State<RankingsSearchFiltersWidget> createState() => _RankingsSearchFiltersWidgetState();
}

class _RankingsSearchFiltersWidgetState extends State<RankingsSearchFiltersWidget> {
  void _OnPressedArrow(Country? _countryValue, String _filterValue, String page, String? mode, String operand) {
  if(int.parse(page) == 1 && operand == "sub") () => {};
  else {
    if (operand == "sum") {
      context.read<RankingsCubit>().loadRankings(
          widget._countryValue, widget._filterValue,
          (int.parse(widget._page) + 1).toString(), widget._mode);
    };
    if (operand == "sub") {
      context.read<RankingsCubit>().loadRankings(
          widget._countryValue, widget._filterValue,
          (int.parse(widget._page) - 1).toString(), widget._mode);
    };
  }
}
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {

/*    final double width = MediaQuery
        .of(context)
        .size
        .width;*/

    widget._dropdownValue = widget._filterValue;
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("Country: ", style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Exo 2',
                  shadows: [
                    Shadow(
                      color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                      offset: Offset(7, 5),
                      blurRadius: 10,
                    )
                  ],
                  color: Colors.white),),
              DropdownButton(
                  dropdownColor: my_colors.Palette.brown,
                  // countryItem is Iter throw mapped countryList, gave this widget from cubit state
                  items: widget._countryList.map((countryItem) =>
                      DropdownMenuItem(
                        value: countryItem,
                        child: Row(
                          children: [
                            Image.asset('assets/icon_country_flags/${countryItem.code}.png',scale: 4.5),
                            SizedBox(width: 10),
                            Text(countryItem.name, style: TextStyle(
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
                                color: Colors.white
                            )),
                          ],
                        )
                      )
                  ).toList(),
                value: widget._dropdownCountryValue,
                  onChanged: (value) => setState(() {
                    widget._dropdownCountryValue = value as Country?;
                    widget._countryValue = value;
                    print("selected : ${widget._dropdownCountryValue}");
                    context.read<RankingsCubit>().loadRankings(widget._countryValue, widget._filterValue, widget._page, widget._mode);
                  }),
              ),
              SizedBox(width: 10),
              DropdownButton(
                dropdownColor: my_colors.Palette.brown,
                  value: widget._dropdownValue,
                  items: [
                    DropdownMenuItem(child: Text("All", style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Exo 2',
                        shadows: [
                          Shadow(
                            color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                            offset: Offset(7, 5),
                            blurRadius: 10,
                          )
                        ],
                        color: Colors.white)), value: "all",),
                    DropdownMenuItem(child: Text("Friends", style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Exo 2',
                        shadows: [
                          Shadow(
                            color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                            offset: Offset(7, 5),
                            blurRadius: 10,
                          )
                        ],
                        color: Colors.white)), value: "friends",),
                 ],
                  onChanged: (value) => setState(() {
                    widget._dropdownValue = value;
                    widget._filterValue = "$value";
                    context.read<RankingsCubit>().loadRankings(widget._countryValue, widget._filterValue, widget._page, widget._mode);
                  })),
            ],
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Select page:", style:  TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Exo 2',
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                      offset: Offset(7, 5),
                      blurRadius: 10,
                    )
                  ],
                ),
                ),
                SizedBox(width: 10,),
                Container(
                    width: 45,
                    height: 25,
                    decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [my_colors.Palette.brown, my_colors.Palette.brown.shade200]),
                      boxShadow: [
                        BoxShadow(
                          color: my_colors.Palette.hotPink.shade900.withOpacity(0.1),
                          offset: Offset(7, 5),
                          spreadRadius: 5,
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: TextField(
                      textAlign: TextAlign.start,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: my_colors.Palette.brown.shade200.withOpacity(0.25),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),

                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Exo 2',
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                            offset: Offset(7, 5),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      keyboardType: TextInputType.text,
                      controller: _textController,
                      onSubmitted: (_) => context.read<RankingsCubit>().loadRankings(widget._countryValue, widget._filterValue, _textController.text.trim(), widget._mode), // filter by page
                    )
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _OnPressedArrow(widget._countryValue, widget._filterValue, widget._page, widget._mode, "sub"),
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all(6.0),
                    backgroundColor: MaterialStateProperty.all(my_colors.Palette.brown.shade50)
                  ),
                  child: Row(
                    children: [
                      Text("Back", style:  TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Exo 2',
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                            offset: Offset(7, 5),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      )
                    ],
                  ),
                ),
                SizedBox(width: 5),
                ElevatedButton(
                  onPressed: () => _OnPressedArrow(widget._countryValue, widget._filterValue, widget._page, widget._mode, "sum"),
                  style: ButtonStyle(
                      elevation: MaterialStateProperty.all(6.0),
                      backgroundColor: MaterialStateProperty.all(my_colors.Palette.brown.shade50)
                  ),
                  child: Row(
                    children: [
                      Text("Next", style:  TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Exo 2',
                        color: Colors.white,
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
                Spacer()
              ],
            ),
          ),
          SizedBox(height: 10,)
        ],
      ),
    );

  }
}