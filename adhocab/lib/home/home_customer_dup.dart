/*
import 'package:adhocab/home/location_picker.dart';
import 'package:adhocab/navigation_drawer/customer_navigation_drawer.dart';
import 'package:adhocab/services/route_service.dart';
import 'package:adhocab/utils/styles.dart';
import "package:flutter_map/flutter_map.dart";
import 'package:flutter_spinkit/flutter_spinkit.dart';
import "package:latlong/latlong.dart";
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomerHome extends StatefulWidget {
  _Home createState() => _Home();
}

class _Home extends State<CustomerHome> {
  final home = LatLng(22.697442, 75.857239);
  LatLng sourceCoordinates, destinationCoordinates;
  String source, destination;
  int distance, travelTime;

  Map<String, dynamic> route;
  List<Marker> markers = [];

  bool _routeloading = false, _routeDisplay = false;

  TextEditingController sourceController = TextEditingController(text: '');
  TextEditingController destinationController = TextEditingController(text: '');

  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Color(0xff344955),
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            height: 56.0,
            child: Align(
              alignment: Alignment.center,
              child: _routeDisplay
                  ? TextButton(
                      onPressed: showMenu,
                      child: Text('Book Ride'),
                    )
                  : TextButton(
                      onPressed: _showRoute,
                      child: _routeloading
                          ? SpinKitWanderingCubes(color: Colors.greenAccent)
                          : Text('Show Route'),
                    ),
            )),
      ),
      drawer: NavigationDrawerCustomer(),
      appBar: AppBar(title: SemiHeadingStyle('Home')),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            FlutterMap(
              options: new MapOptions(center: home, zoom: 13.0),
              layers: [
                new TileLayerOptions(
                  urlTemplate: "https://api.tomtom.com/map/1/tile/basic/main/"
                      "{z}/{x}/{y}.png?key=$apiKey",
                  additionalOptions: {"apiKey": apiKey},
                ),
                MarkerLayerOptions(
                  markers: markers,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 5),
                TextField(
                  controller: sourceController,
                  decoration: textInputDecor.copyWith(
                    hintText: 'Enter the source location',
                  ),
                  onTap: () => _getLocation('Source'),
                  readOnly: true,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: destinationController,
                  decoration: textInputDecor.copyWith(
                    hintText: 'Enter the destination location',
                  ),
                  onTap: () => _getLocation('Destination'),
                  readOnly: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getLocation(String type) async {
    Map<String, dynamic> result =
        await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => LocationPicker(
                  locationType: type,
                )));
    if (result == null || result.isEmpty) return;

    if (type == 'Source') {
      setState(() {
        source = result['name'];
        sourceController.text = source;
        sourceCoordinates = LatLng(result['lat'], result['lon']);
        _addSourceDestinationMarkers();
      });
    } else {
      setState(() {
        destination = result['name'];
        destinationController.text = destination;
        destinationCoordinates = LatLng(result['lat'], result['lon']);
        _addSourceDestinationMarkers();
      });
    }
  }

  void _addSourceDestinationMarkers() {
    markers.clear();
    _routeDisplay = false;

    if (sourceCoordinates != null)
      markers.add(Marker(
        width: 80.0,
        height: 80.0,
        point: sourceCoordinates,
        builder: (BuildContext context) =>
            const Icon(Icons.location_on, size: 30.0, color: Colors.black),
      ));

    if (destinationCoordinates != null)
      markers.add(Marker(
        width: 80.0,
        height: 80.0,
        point: destinationCoordinates,
        builder: (BuildContext context) =>
            const Icon(Icons.location_on, size: 30.0, color: Colors.black),
      ));
  }

  Future<void> _showRoute() async {
    if (sourceCoordinates == null || destinationCoordinates == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please add source and destination both')));
      return;
    }
    setState(() => _routeloading = true);

    var result =
        await RouteService.getRoute(sourceCoordinates, destinationCoordinates);
    if (result == null || result.isEmpty) {
      print('Could not get routes');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not get routes')));
      setState(() => _routeloading = false);
      return;
    }

    route = result;
    _addSourceDestinationMarkers();

    for (var latlng in route['coordinates']) {
      markers.add(Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(latlng['latitude'], latlng['longitude']),
        builder: (BuildContext context) =>
            const Icon(Icons.circle, size: 10.0, color: Colors.red),
      ));
    }

    print(markers);

    setState(() {
      distance = route['distance'];
      travelTime = route['travelTime'];
      _routeloading = false;
      _routeDisplay = true;
    });
  }

  void showMenu() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (builder) {
          return new Container(
            height: 350.0,
            color: Colors.transparent, //could change this to Color(0xFF737373),
            //so you don't have to change MaterialApp canvasColor
            child: new Container(
                decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(10.0),
                        topRight: const Radius.circular(10.0))),
                child: new Center(
                  child: new Text("This is a modal sheet"),
                )),
          );
        });
  }
}
*/