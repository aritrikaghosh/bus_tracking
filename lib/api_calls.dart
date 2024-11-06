import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:vit_bus_tracking/model/place.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'keys/keys.dart';

// log hello
class ApiCalls {
  Future<String> getTokensFromSharedPrefs() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? accessToken = pref.getString("access_token");
    String? time = pref.getString("time");

    if (accessToken == null ||
        time == null ||
        DateTime.now().difference(DateTime.parse(time)).inSeconds > 30000) {
      await getTokensFromWeb();
    }

    accessToken = pref.getString("access_token");
    if (accessToken != null) return accessToken;
    return "";
  }

  Future<void> getTokensFromWeb() async {
    log("getting the tokens from the web ma");

    String url =
        "https://outpost.mappls.com/api/security/oauth/token?grant_type=client_credentials&client_id=${Keys().clientId}&client_secret=${Keys().clientSecret}";
    final responce = await http.post(Uri.parse(url));

    if (responce.statusCode == 200) {
      final decoded = jsonDecode(responce.body);
      final accessToken = decoded["access_token"];
      final clientId = decoded["client_id"];

      final SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.setString("access_token", accessToken);
      await pref.setString("client_id", clientId);
      await pref.setString("time", DateTime.now().toString());

      log("saved data -> OAuth -> $accessToken");
    } else {
      log("Issue in getting OAuth 2.0 tokens");
    }
  }

  Future<List<Place>> getCitiesName({required placeName}) async {
    final accessToken = await getTokensFromSharedPrefs();
    final url =
        "https://atlas.mapmyindia.com/api/places/geocode?address=$placeName&itemCount=15";

    final responce = await http.get(
      Uri.parse(url),
      headers: {"Authorization": "bearer $accessToken"},
    );

    log("getting cities name ${responce.body}");

    final decodedResponce = jsonDecode(responce.body);
    if (responce.statusCode != 200) {
      if (decodedResponce["error"] == "invalid_token") {
        getTokensFromWeb();
        return await getCitiesName(placeName: placeName);
      } else {
        return [];
      }
    } else {
      List<dynamic> data = decodedResponce["copResults"];
      final placesList = data
          .map((e) => Place(name: "${e["formattedAddress"]}", eloc: e["eLoc"]))
          .toList();
      return placesList;
    }
  }
}
