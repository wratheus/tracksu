// Score includes beatmap class to avoid beatmap request
import 'package:flutter/material.dart';

class Scores{
  int? scoreId;
  List<dynamic> mods = [];
  var scorePoints;
  var accuracy;
  int? maxCombo;
  Map<String, dynamic>?mapStatistics;
  String? mapRank;
  String? dateOfScore;
  int? bestScoreOnMapID;
  var gainedPP;
  int? beatmapSetID;
  int? beatmapSetMapID;
  var difficultyRating;
  var beatmapLength;
  String? difficultyName;
  var OD;
  var AR;
  var BPM;
  var CS;
  var HP;
  String? beatmapURL;
  String? artistName;
  String? coversJPG;
  String? mapTitle;
  String? mapperName;
  int? mapperId;
  String? shortRankedStatus;
  Color? colorOfRankedStatus;

  Scores({
    required this.scoreId,
    required this.accuracy,
    required this.mods,
    required this.scorePoints,
    required this.maxCombo,
    required this.mapStatistics,
    required this.mapRank,
    required this.dateOfScore,
    required this.bestScoreOnMapID,
    required this.gainedPP,
    required this.beatmapSetID,
    required this.beatmapSetMapID,
    required this.difficultyRating,
    required this.beatmapLength,
    required this.difficultyName,
    required this.OD,
    required this.AR,
    required this.BPM,
    required this.CS,
    required this.HP,
    required this.beatmapURL,
    required this.artistName,
    required this.coversJPG,
    required this.mapTitle,
    required this.mapperName,
    required this.mapperId
  });
  factory Scores.fromJson(Map<String, dynamic> json){
    return Scores(
      scoreId: json['id'],
      accuracy: json['accuracy'],
      mods: json['mods'],
      scorePoints: json['score'],
      maxCombo: json['max_combo'],
      mapStatistics: json['statistics'],
      mapRank: json['rank'],
      dateOfScore: json['created_at'],
      bestScoreOnMapID: json['best_id'],
      gainedPP: json['pp'],
      difficultyName: json['beatmap']['version'],
      beatmapSetID: json['beatmap']['beatmapset_id'],
      difficultyRating: json['beatmap']['difficulty_rating'],
      beatmapSetMapID: json['beatmap']['id'],
      beatmapLength: json['beatmap']['total_length'],
      OD: json['beatmap']['accuracy'],
      AR: json['beatmap']['ar'],
      BPM: json['beatmap']['bpm'],
      CS: json['beatmap']['cs'],
      HP: json['beatmap']['drain'],
      beatmapURL: json['beatmap']['url'],
      artistName: json['beatmapset']['artist'],
      coversJPG: json['beatmapset']['covers']['cover@2x'],
      mapTitle: json['beatmapset']['title'],
      mapperName: json['beatmapset']['creator'],
      mapperId: json['beatmapset']['user_id'],
    );
  }
}