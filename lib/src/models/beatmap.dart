import 'package:flutter/material.dart';

class Beatmap{
  var beatmapSetMapID;
  var beatmapSetID;
  var difficultyRating;
  var OD;
  var AR;
  var CS;
  var HP;
  var BPM;
  int? maxCombo;
  int? countCircles;
  int? countSliders;
  int? countSpinners;
  var beatmapLength;
  String? difficultyName;
  int? playCount;
  int? passCount;
  String? rankedStatus;
  String? mode;
  String? beatmapURL;
  String? artistName;
  String? coversJPG;
  String? mapTitle;
  var mapper;
  int? mapperId;
  int? favouriteCount;
  String? rankedDate;
  String? submittedDate;
  String? beatmapTags;
  Map<String, dynamic>? failCounts;
  String? shortRankedStatus;
  Color? colorOfRankedStatus;

  Beatmap({
    required this.beatmapSetMapID,
    required this.beatmapSetID,
    required this.difficultyRating,
    required this.OD,
    required this.AR,
    required this.CS,
    required this.HP,
    required this.BPM,
    this.maxCombo,
    required this.countCircles,
    required this.countSliders,
    required this.countSpinners,
    required this.beatmapLength,
    required this.difficultyName,
    required this.playCount,
    required this.rankedStatus,
    required this.mode,
    required this.beatmapURL,
    required this.artistName,
    required this.coversJPG,
    required this.mapTitle,
    required this.mapper,
    required this.mapperId,
    this.failCounts,
    required this.favouriteCount,
    required this.beatmapTags,
    required this.passCount,
    required this.rankedDate,
    required this.submittedDate,
  });

  factory Beatmap.fromJson(Map<String, dynamic> json) {
    return Beatmap(
      beatmapSetMapID: json['id'],
      beatmapSetID: json['beatmapset_id'],
      difficultyRating: json['difficulty_rating'],
      OD: json['accuracy'],
      AR: json['ar'],
      CS: json['cs'],
      HP: json['drain'],
      BPM: json['bpm'],
      maxCombo: json['max_combo'],
      countCircles: json['count_circles'],
      countSliders: json['count_sliders'],
      countSpinners: json['count_spinners'],
      beatmapLength: json['total_length'],
      beatmapURL: json['url'],
      mode: json['mode'],
      rankedStatus: json['status'],
      difficultyName: json['version'],
      passCount: json['passcount'],
      playCount: json['playcount'],
      artistName: json['beatmapset']['artist'],
      coversJPG: json['beatmapset']['covers']['cover'],
      mapTitle: json['beatmapset']['title'],
      mapper: json['beatmapset']['creator'],
      mapperId: json['beatmapset']['user_id'],
      favouriteCount: json['beatmapset']['favourite_count'],
      beatmapTags: json['beatmapset']['tags'],
      rankedDate: json['beatmapset']['ranked_date'],
      submittedDate: json['beatmapset']['submitted_date'],
      failCounts: json['failtimes'],
    );
  }
  factory Beatmap.fromUserFromJson(Map<String, dynamic> json) {
    return Beatmap(
      beatmapSetMapID: json['beatmaps'][0]['id'],
      beatmapSetID: json['beatmaps'][0]['beatmapset_id'],
      difficultyRating: json['beatmaps'][0]['difficulty_rating'],
      OD: json['beatmaps'][0]['accuracy'],
      AR: json['beatmaps'][0]['ar'],
      CS: json['beatmaps'][0]['cs'],
      HP: json['beatmaps'][0]['drain'],
      BPM: json['beatmaps'][0]['bpm'],
      countCircles: json['beatmaps'][0]['count_circles'],
      countSliders: json['beatmaps'][0]['count_sliders'],
      countSpinners: json['beatmaps'][0]['count_spinners'],
      beatmapLength: json['beatmaps'][0]['total_length'],
      beatmapURL: json['beatmaps'][0]['url'],
      mode: json['beatmaps'][0]['mode'],
      rankedStatus: json['beatmaps'][0]['status'],
      difficultyName: json['beatmaps'][0]['version'],
      passCount: json['beatmaps'][0]['passcount'],
      playCount: json['beatmaps'][0]['playcount'],
      artistName: json['artist'],
      coversJPG: json['covers']['cover'],
      mapTitle: json['title'],
      mapper: json['creator'],
      mapperId: json['user_id'],
      favouriteCount: json['favourite_count'],
      beatmapTags: json['tags'],
      rankedDate: json['ranked_date'],
      submittedDate: json['submitted_date'],
    );
  }
}
