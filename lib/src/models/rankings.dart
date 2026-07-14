class Rankings{
  var globalRank;
  var PP;
  var rankedScore;
  var hitAccuracy;
  var playCount;
  int? playTime;
  var totalScore;
  int? totalHits;
  var maximumCombo;
  var replaysWatchedByOthers;
  Map <String, dynamic>? gradeCounts;
  String username;
  String country;
  String countryCode;
  String avatarURL;

  Rankings({
    required this.globalRank,
    required this.PP,
    required this.rankedScore,
    required this.hitAccuracy,
    required this.playCount,
    required this.playTime,
    required this.totalScore,
    required this.totalHits,
    required this.maximumCombo,
    required this.replaysWatchedByOthers,
    required this.gradeCounts,
    required this.username,
    required this.country,
    required this.avatarURL,
    required this.countryCode,
  });

  factory Rankings.fromJson(Map<String, dynamic> json) {
    return Rankings(
      globalRank: json['global_rank'],
      PP: json['pp'],
      rankedScore: json['ranked_score'],
      hitAccuracy: json['hit_accuracy'],
      playCount: json['play_count'],
      playTime: json['play_time'],
      totalScore: json['total_score'],
      totalHits: json['total_hits'],
      maximumCombo: json['maximum_combo'],
      replaysWatchedByOthers: json['replays_watched_by_others'],
      gradeCounts: json['grade_counts'],
      username: json['user']['username'],
      country: json['user']['country']['name'],
      avatarURL: json['user']['avatar_url'],
      countryCode: json['user']['country_code']
    );
  }
}