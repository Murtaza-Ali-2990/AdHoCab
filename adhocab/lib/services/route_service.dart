import 'dart:convert';
import 'package:adhocab/utils/styles.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class RouteService {
  static Future<Map<String, dynamic>> getRoute(
      LatLng source, LatLng destination) async {
    var url =
        'https://api.tomtom.com/routing/1/calculateRoute/${source.latitude},${source.longitude}:${destination.latitude},${destination.longitude}/json?avoid=unpavedRoads&computeBestOrder=true&routeRepresentation=polyline&key=$apiKey';
    print(url);
    final response = await http.get(Uri.parse(url));
    final Map<String, dynamic> route = {};

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      route['coordinates'] = data['routes'][0]['legs'][0]['points'] as List;
      route['distance'] = data['routes'][0]['summary']['lengthInMeters'];
      route['travelTime'] = data['routes'][0]['summary']['travelTimeInSeconds'];
    } else {
      print('Could not find required route');
    }

    return route;
  }
}
