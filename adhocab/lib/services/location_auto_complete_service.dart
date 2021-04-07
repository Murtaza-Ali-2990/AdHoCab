import 'dart:convert';
import 'package:adhocab/utils/styles.dart';
import 'package:http/http.dart' as http;

class LocationAutoComplete {
  static Future<List> getSuggestions(String query) async {
    var url =
        "https://api.tomtom.com/search/2/search/$query.json?limit=5&idxSet=POI&countrySet=IN&key=$apiKey";
    print(url);
    final response = await http.get(Uri.parse(url));
    var list = [];

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      list = data['results'] as List;
    }
    return list;
  }
}
