// Score includes beatmap class to avoid beatmap request
import 'package:flutter/material.dart';

class BeatmapScore{
  int? scoreID;
  List<dynamic> mods = [];
  var scorePoints;
  var accuracy;
  int? maxCombo;
  Map<dynamic, dynamic>? mapStatistics;
  String? mapRank;
  String? dateOfScore;
  int? bestScoreOnMapID;
  var gainedPP;
  var avatarURL;
  var userID;
  var username;
  var coverURL;
  var countryCode;
  String? shortRankedStatus;
  Color? colorOfRankedStatus;

  BeatmapScore({
    required this.scoreID,
    required this.accuracy,
    required this.mods,
    required this.scorePoints,
    required this.maxCombo,
    required this.mapStatistics,
    required this.mapRank,
    required this.dateOfScore,
    required this.bestScoreOnMapID,
    required this.gainedPP,
    required this.avatarURL,
    required this.userID,
    required this.username,
    required this.coverURL,
    required this.countryCode,
  });
  factory BeatmapScore.fromJson(Map<String, dynamic> json){
    return BeatmapScore(
      scoreID: json['id'],
      accuracy: json['accuracy'],
      mods: json['mods'],
      scorePoints: json['score'],
      maxCombo: json['max_combo'],
      mapStatistics: json['statistics'],
      mapRank: json['rank'],
      dateOfScore: json['created_at'],
      bestScoreOnMapID: json['best_id'],
      gainedPP: json['pp'],
      userID: json['user_id'],
      avatarURL: json['user']['avatar_url'],
      username: json['user']['username'],
      coverURL: json['user']['cover']['url'],
      countryCode: json['user']['country_code']
    );
  }
}