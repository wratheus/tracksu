import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

import '../utils/color_contrasts.dart' as my_colors;
import '../authentication.dart' as auth;
import '../models/user.dart';
import '../models/scores.dart';
import '../models/news.dart';
import '../models/beatmap.dart';
import '../models/rankings.dart';
import '../models/beatmap_score.dart';
import '../models/country.dart';
import '../utils/secure_storage.dart';
/*  Before you go, you need to create your own <authentication.dart> file in /src folder
and put there your personal Osu! API oAuth2 as listed below:  | (you can get oath2 data here https://osu.ppy.sh/home/account/edit)
const clientSecret = 'your oAuth2 pass';
const clientId = 'your id'; */


// Token Request from user Auth
// puts token to UserSecureStorage
Future<bool> getTokenAsAuthorize(String? code) async{
  String body = "grant_type=authorization_code&client_id=${auth.clientId}&client_secret=${auth.clientSecret}&code=${code}&redirect_uri=https://wratheus.github.io/tracksu";
  Map<String, String> headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/x-www-form-urlencoded',
    'Access-Control-Allow-Origin': '*' // http://osu.ppy.sh
  };
  http.Response tokenRequestResponse = await http.post(
      Uri.https('osu.ppy.sh', '/oauth/token'),
      headers: headers,
      body: body
  );
  if (tokenRequestResponse.statusCode == 200) {
    // If the server did return a 200 CREATED response,
    final token = convert.jsonDecode(tokenRequestResponse.body) as Map<String, dynamic>;
    await UserSecureStorage.setTokenInStorage(token['access_token']!);
    await UserSecureStorage.setRefreshTokenFromStorage(token['refresh_token']!);
    print('new request token = ' + token['access_token']);
    print('new refresh token = ' + token['refresh_token']);
    return true;
  }
   if(tokenRequestResponse.statusCode == 400){
     print("Token request response code = ${tokenRequestResponse.statusCode}, trying to request new token with refresh token");
      //refresh token
      try {

        String body = "grant_type=refresh_token&refresh_token=${await UserSecureStorage
            .getRefreshTokenFromStorage()}&client_id=${auth.clientId}&client_secret=${auth.clientSecret}";
        http.Response tokenRequestResponse = await http.post(
            Uri.https('osu.ppy.sh', '/oauth/token'),
            headers: headers,
            body: body
        );
        final token = convert.jsonDecode(tokenRequestResponse.body) as Map<String, dynamic>;
        // print('old token =' + (await UserSecureStorage.getTokenFromStorage())!);
        await UserSecureStorage.setTokenInStorage(token['access_token']);
        await UserSecureStorage.setRefreshTokenFromStorage(token['refresh_token']);
        print('updated token = ' + token['access_token']);
        print('updated refresh token = ' + token['refresh_token']);

        return true;
      }catch(e) {
        throw Exception("Error requesting new Token with refresh token (${await UserSecureStorage.getRefreshTokenFromStorage()})");
      }
    }
  else {
    // If the server did not return a 200 CREATED response,
    var statusCode = tokenRequestResponse.statusCode;
    throw Exception('Failed to get TOKEN response. Status code = $statusCode');
  }
}
//Token request with client credential
Future<bool> getTokenAsGuestWithClientCredential() async{
  String body = "grant_type=client_credentials&client_id=${auth.clientId}&client_secret=${auth.clientSecret}&scope=public";
  Map<String, String> headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/x-www-form-urlencoded',
  };
  http.Response tokenRequestResponse = await http.post(
      Uri.https('osu.ppy.sh', '/oauth/token'),
      headers: headers,
      body: body
  );
  if (tokenRequestResponse.statusCode == 200) {
    // If the server did return a 200 CREATED response,
    final token = convert.jsonDecode(tokenRequestResponse.body) as Map<String, dynamic>;
    await UserSecureStorage.setTokenInStorage(token['access_token']!);
    print('new request token = ' + token['access_token']);
    return true;
  }
  else {
    // If the server did not return a 200 CREATED response,
    var statusCode = tokenRequestResponse.statusCode;
    throw Exception('Failed to get TOKEN response. Status code = $statusCode');
  }
}
// User request
// returns a user class object
Future <User> getUser(String token, String username, [String mode = 'osu', bool mapper = false]) async{

  final body = {
    'key': 'username'
  };
  final Uri userUrl = Uri.https('osu.ppy.sh', 'api/v2/users/$username/$mode', body);
  final Map<String, String> headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Authorization": "Bearer $token"
  };
  final http.Response userGetResponse = await http.get(userUrl, headers: headers);

  if (userGetResponse.statusCode == 200) {
    // If the server did return a 200 CREATED response,
    if (mapper == true) {return User.fromMapperFromJson(convert.jsonDecode(userGetResponse.body)); } // short version
    return User.fromJson(convert.jsonDecode(userGetResponse.body));
  }
  else {
    // If the server did not return a 200 CREATED response,
    var statusCode = userGetResponse.statusCode;
    throw Exception('Failed to get USER response. Status code = $statusCode');
  }
}

// User request
// returns a self user class object for logged user
Future <User> getUserMe(String token, [String? mode = 'osu']) async{

  final Uri userUrl = Uri.https('osu.ppy.sh', 'api/v2/me/$mode');
  final Map<String, String> headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Authorization": "Bearer $token"
  };
  final http.Response userGetResponse = await http.get(userUrl, headers: headers);

  if (userGetResponse.statusCode == 200) {
    // If the server did return a 200 CREATED response,
    return User.fromJson(convert.jsonDecode(userGetResponse.body));
  }
  else {
    // If the server did not return a 200 CREATED response,
    var statusCode = userGetResponse.statusCode;
    throw Exception('Failed to get USER response. Status code = $statusCode');
  }
}

// User Score list Request
// returns a list with 100 (by default) user's scores-model
Future <List <Scores>> getUserScore(String token, String username, String numberOfRequestedScores, String offset, String scoresType, String mode) async{

  if (int.parse(numberOfRequestedScores) > 100 || int.parse(numberOfRequestedScores) <= 0){ throw Exception('wrong ScoreNumber'); }
  User player = await getUser(token, username, mode);
  final userID = player.id;
  final body = {
    'include_fails': '1',
    'mode': mode,
    'limit': numberOfRequestedScores,
    'offset': offset
  };
  final Uri userScoresUrl = Uri.https('osu.ppy.sh', 'api/v2/users/$userID/scores/$scoresType', body);
  final Map<String, String> headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Authorization": "Bearer $token"
  };
  final http.Response userScoresUrlResponse = await http.get(userScoresUrl, headers: headers);
  int scoreNumber = int.parse(numberOfRequestedScores);
  if (userScoresUrlResponse.statusCode == 200) {
      var json = convert.jsonDecode(userScoresUrlResponse.body);
      List<Scores>  myList = List.empty(growable: true);
      if (json.length < 100) {
        scoreNumber = json.length;
      };
      for (int i = 0; i < scoreNumber; i++){
      myList.add(Scores.fromJson(json[i]));
    }
      return myList;
  }
  else {
    // If the server did not return a 200 CREATED response,
    var statusCode = userScoresUrlResponse.statusCode;
    throw Exception('Failed to get USER SCORES response. Status code = $statusCode');
  }
}

// News request
// returns a list with News-model
Future <List<News>> getNews(String token) async{
  String numberOfNews = "21";
  final body = {
    "limit": numberOfNews,
  };
  final Uri newsUrl = Uri.https('osu.ppy.sh', 'api/v2/news', body);
  final Map<String, String> headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Authorization": "Bearer $token"
  };
  final http.Response newsUrlResponse = await http.get(newsUrl, headers: headers);

  if (newsUrlResponse.statusCode == 200) {
    List<News> myList = List.empty(growable: true);
    var json = convert.jsonDecode(newsUrlResponse.body);
    for (int i = 0; i < int.parse(numberOfNews); i++){
      myList.add(News.fromJson(json["news_posts"][i]));
    }
    return myList;
  }
  else {
    // If the server did not return a 200 CREATED response,
    var statusCode = newsUrlResponse.statusCode;
    throw Exception('Failed to get NEWS response. Status code = $statusCode');
  }
}

// Beatmap request
// returns a beatmap object
Future <Beatmap> getBeatmap(String token, String beatmapID, [User? beatmapMapper]) async{
  final Uri beatmapUrl = Uri.https('osu.ppy.sh', 'api/v2/beatmaps/$beatmapID');
  final Map<String, String> headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Authorization": "Bearer $token"
  };
  final http.Response beatmapUrlResponse = await http.get(beatmapUrl, headers: headers);

  if (beatmapUrlResponse.statusCode == 200) {
    Beatmap BeatmapObject = Beatmap.fromJson(convert.jsonDecode(beatmapUrlResponse.body));
    if (beatmapMapper != null){
      BeatmapObject.mapper = beatmapMapper;
      BeatmapObject.shortRankedStatus = "${BeatmapObject.rankedStatus}";
      BeatmapObject.colorOfRankedStatus = BeatmapObject.rankedStatus == 'ranked' ? Colors.greenAccent : BeatmapObject.rankedStatus == "loved" ? my_colors.Palette.hotPink : BeatmapObject.rankedStatus == "graveyard" ? Colors.black54 : BeatmapObject.rankedStatus == "pending" ? Colors.yellow : BeatmapObject.rankedStatus == "wip" ? Colors.yellow : BeatmapObject.rankedStatus == "approved" ? Colors.yellow : BeatmapObject.rankedStatus == "qualified" ? Colors.green : Colors.black54;
      if (BeatmapObject.rankedDate != null){
        BeatmapObject.rankedStatus  = "${BeatmapObject.rankedStatus}: " + "${BeatmapObject.rankedDate}".substring(0, 10);
      }
    }
    else {
      BeatmapObject.mapper = getUser(token, "${BeatmapObject.mapper}", 'osu', true);
      BeatmapObject.shortRankedStatus = "${BeatmapObject.rankedStatus}";
      BeatmapObject.colorOfRankedStatus = BeatmapObject.rankedStatus == 'ranked' ? Colors.greenAccent : BeatmapObject.rankedStatus == "loved" ? my_colors.Palette.hotPink : BeatmapObject.rankedStatus == "graveyard" ? Colors.black54 : BeatmapObject.rankedStatus == "pending" ? Colors.yellow : BeatmapObject.rankedStatus == "wip" ? Colors.yellow : BeatmapObject.rankedStatus == "approved" ? Colors.yellow : BeatmapObject.rankedStatus == "qualified" ? Colors.green : Colors.black54;
      if (BeatmapObject.rankedDate != null){
        BeatmapObject.rankedStatus  = "${BeatmapObject.rankedStatus}: " + "${BeatmapObject.rankedDate}".substring(0, 10);
      }
    }
    return BeatmapObject;
  }
  else {
    // If the server did not return a 200 CREATED response,
    var statusCode = beatmapUrlResponse.statusCode;
    throw Exception('Failed to get BEATMAP response. Status code = $statusCode');
  }
}

// Beatmap top-50 request
// returns a list with beatmap top 50 best performance scores-models
Future <List<BeatmapScore>> getBeatmapScores(String token, String beatmapID, [List<String>? mods]) async {
  int count = 0;
  final Uri beatmapUrl = Uri.https('osu.ppy.sh', 'api/v2/beatmaps/$beatmapID/scores');
  final Map<String, String> headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Authorization": "Bearer $token"
  };
  final http.Response beatmapScoresUrlResponse = await http.get(
      beatmapUrl, headers: headers);

  if (beatmapScoresUrlResponse.statusCode == 200) {
    if (mods != null) {
      List<BeatmapScore> myList = List.empty(growable: true);
      var json = convert.jsonDecode(beatmapScoresUrlResponse.body);
      for (int i = 0; i < json['scores'].length; i++) {
        BeatmapScore tmp = BeatmapScore.fromJson(json['scores'][i]); // calculate scores with selected mods in response
        if (tmp.mods.length == mods.length) {
          for (int j = 0; j < mods.length; j++) {
            if (mods[j] == tmp.mods[j]) {
              count++;
            }
          }
          if (count == mods.length) {
            myList[i] = tmp;
          }
        }
        count = 0;
      }
      return myList;
    }
    else {
      List<BeatmapScore> myList = List.empty(growable: true);
      var json = convert.jsonDecode(beatmapScoresUrlResponse.body);
      for (int i = 0; i < json['scores'].length; i++) {
        myList.add(BeatmapScore.fromJson(json['scores'][i]));
      }
      return myList;
    }
  }
  else {
    // If the server did not return a 200 CREATED response,
    var statusCode = beatmapScoresUrlResponse.statusCode;
    throw Exception('Failed to get BEATMAP SCORES response. Status code = $statusCode');
  }
}
// Country asset list request
Future<List<Country>> generateCountriesList() async {
  final String response = await rootBundle.loadString('assets/models/countries.json');
  final data = await convert.json.decode(response);
  List<Country>  countryList = List.empty(growable: true);
  for (int i = 0; i < data.length; i++){
    countryList.add(Country.fromJson(data[i]));
  }
  return countryList;
}
// Ranking request
Future <List<Rankings>> getRankings(String token,  String filter, String page,
    [String? mode = "osu", Country? country, String type = "performance"]) async {
  if (int.parse(page) > 200 || int.parse(page) < 1) {
    throw Exception('Failed to get RANKINGS response. Wrong page');
  }
  final Map<String, dynamic> body;
  final Map<String, String> headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Authorization": "Bearer $token"
  };
  if (country == null){
    body = {
      "filter": filter,
      "cursor[page]": "${page}",
    };
  }
  else {
    body = {
      "filter": filter,
      "cursor[page]": "${page}",
      "country": country.code
    };
  }
  final Uri rankingsUrl = Uri.https('osu.ppy.sh', 'api/v2/rankings/$mode/$type', body);
  final http.Response getRankingsResponse = await http.get(rankingsUrl, headers: headers);

  if (getRankingsResponse.statusCode == 200) {
      final List<Rankings> myList = List.empty(growable: true);
      var json = convert.jsonDecode(getRankingsResponse.body);
      for (int i = 0; i < json["ranking"].length-1; i++) {
        myList.add(Rankings.fromJson(json["ranking"][i]));
      }
      return myList;
    }
  else {
    // If the server did not return a 200 CREATED response,
    var statusCode = getRankingsResponse.statusCode;
    throw Exception('Failed to get RANKINGS response. Status code = $statusCode');
  }
}

Future <List<Beatmap>> getUserBeatmaps(String token, int userID, String type) async {
  final body = {
    "limit": "30",
  };
  final Uri userScoresUrl = Uri.https('osu.ppy.sh', 'api/v2/users/$userID/beatmapsets/$type', body);
  final Map<String, String> headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Authorization": "Bearer $token"
  };
  final http.Response userBeatmapsUrlResponse = await http.get(userScoresUrl, headers: headers);
  if (userBeatmapsUrlResponse.statusCode == 200) {
    var json = convert.jsonDecode(userBeatmapsUrlResponse.body);
    List<Beatmap>  myList = List.empty(growable: true);
    for (int i = 0; i < json.length; i++){
      Beatmap BeatmapObject = Beatmap.fromUserFromJson(json[i]);
      BeatmapObject.shortRankedStatus = "${BeatmapObject.rankedStatus}";
      BeatmapObject.colorOfRankedStatus = BeatmapObject.rankedStatus == 'ranked' ? Colors.greenAccent : BeatmapObject.rankedStatus == "loved" ? my_colors.Palette.hotPink : BeatmapObject.rankedStatus == "graveyard" ? Colors.black54 : BeatmapObject.rankedStatus == "pending" ? Colors.yellow : BeatmapObject.rankedStatus == "wip" ? Colors.yellow : BeatmapObject.rankedStatus == "approved" ? Colors.yellow : BeatmapObject.rankedStatus == "qualified" ? Colors.green : Colors.black54;
      if (BeatmapObject.rankedDate != null){
        BeatmapObject.rankedStatus  = "${BeatmapObject.rankedStatus}: " + "${BeatmapObject.rankedDate}".substring(0, 10);
      }
      myList.add(BeatmapObject);
    }
    if (type == "favourite") {
      for (int i = 0; i < myList.length; i++) {
        myList[i].mapper = getUser(token, "${myList[i].mapper}", 'osu', true);
      }
      for (int i = 0; i < myList.length; i++) {
        myList[i].mapper = await myList[i].mapper;
      }
    }
    return myList;
  }
  else {
    // If the server did not return a 200 CREATED response,
    var statusCode = userBeatmapsUrlResponse.statusCode;
    throw Exception('Failed to get $type BEATMAPS response. Status code = $statusCode');
  }
}

/*
// For future changelog requests;
Future <List<Changelog>> getChangelogOsu(String token) async {
  final Uri ChangelogUrl = Uri.https('osu.ppy.sh', 'api/v2/changelog');
  final Map<String, String> headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Authorization": "Bearer $token"
  };
  final http.Response changelogUrlResponse = await http.get(ChangelogUrl, headers: headers);
  if (changelogUrlResponse.statusCode == 200) {
    var json = convert.jsonDecode(changelogUrlResponse.body);
    ChangelogInstance = Changelog.fromJson(json);
    print(ChangelogInstance);
    return ChangelogInstance;
  }
  else {
    // If the server did not return a 200 CREATED response,
    var statusCode = changelogUrlResponse.statusCode;
    throw Exception('Failed to get changelog response. Status code = $statusCode');
  }
}*/
