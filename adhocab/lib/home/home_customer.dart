import 'dart:async';

import 'package:adhocab/home/location_picker.dart';
import 'package:adhocab/navigation_drawer/customer_navigation_drawer.dart';
import 'package:adhocab/services/route_service.dart';
import 'package:adhocab/utils/styles.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomerHome extends StatefulWidget {
  _Home createState() => _Home();
}

class _Home extends State<CustomerHome> {
  LatLng sourceCoordinates, destinationCoordinates;
  String source, destination;
  int distance, travelTime;

  Map<String, dynamic> route;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  bool _routeloading = false, _routeDisplay = false;

  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController _mapsController;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(22.697442, 75.857239),
    zoom: 13,
  );

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
            GoogleMap(
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              compassEnabled: true,
              mapType: MapType.normal,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _mapsController = controller;
                _controller.complete(controller);
              },
              markers: markers,
              polylines: polylines,
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
        _mapsController.moveCamera(CameraUpdate.newLatLng(sourceCoordinates));
      });
    } else {
      setState(() {
        destination = result['name'];
        destinationController.text = destination;
        destinationCoordinates = LatLng(result['lat'], result['lon']);
        _addSourceDestinationMarkers();
        _mapsController
            .moveCamera(CameraUpdate.newLatLng(destinationCoordinates));
      });
    }
  }

  void _addSourceDestinationMarkers() {
    markers.clear();
    polylineCoordinates.clear();
    polylines.clear();

    _routeDisplay = false;

    if (sourceCoordinates != null)
      markers.add(Marker(
        markerId: MarkerId('source'),
        position: sourceCoordinates,
      ));

    if (destinationCoordinates != null)
      markers.add(Marker(
        markerId: MarkerId('destination'),
        position: destinationCoordinates,
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
      polylineCoordinates.add(LatLng(latlng['latitude'], latlng['longitude']));
    }

    polylines.add(Polyline(
      polylineId: PolylineId('route'),
      visible: true,
      points: polylineCoordinates,
      width: 4,
      color: Colors.blue,
    ));

    print(polylineCoordinates);

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
        backgroundColor: Colors.transparent,
        context: context,
        builder: (builder) {
          return new Container(
              height: 350.0,
              decoration: new BoxDecoration(
                  color: Colors.white,
                  borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(60.0),
                      topRight: const Radius.circular(60.0))),
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    SizedBox(height: 5),
                    SemiHeadingStyle('Book Ride'),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 5),
                        Text(
                            'Distance: ${distance >= 1000 ? (distance / 1000).toStringAsFixed(1) : distance} ${distance >= 1000 ? 'km' : 'm'}'),
                        Text(
                            'Time: ${travelTime / 60 > 0 ? (travelTime / 60).toStringAsFixed(0) + ' min' : ''} ${travelTime % 60 > 0 ? (travelTime % 60).toString() + ' s' : ''}'),
                        SizedBox(width: 5),
                      ],
                    ),
                  ],
                ),
              ));
        });
  }
}
