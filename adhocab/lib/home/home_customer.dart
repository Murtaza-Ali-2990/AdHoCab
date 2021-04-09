import 'dart:async';

import 'package:adhocab/home/location_picker.dart';
import 'package:adhocab/models/booking_details.dart';
import 'package:adhocab/models/customer.dart';
import 'package:adhocab/navigation_drawer/customer_navigation_drawer.dart';
import 'package:adhocab/payment/payment.dart';
import 'package:adhocab/services/database_service.dart';
import 'package:adhocab/services/route_service.dart';
import 'package:adhocab/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomerHome extends StatefulWidget {
  _Home createState() => _Home();
}

class _Home extends State<CustomerHome> {
  LatLng sourceCoordinates, destinationCoordinates;
  String source, destination;
  int distance, travelTime;
  double cost;
  BookingDetails bookingDetails = BookingDetails();

  DatabaseService databaseService;

  Map<String, dynamic> route;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  bool _routeloading = false,
      _routeDisplay = false,
      _streamCreated = false,
      _rideComplete = false,
      _pickup = false,
      _drop = false,
      _routeSet = false,
      _alreadySet = false;

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
      appBar: AppBar(title: Text('Home', style: semiHeadingStyle)),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            if (!_streamCreated)
              GoogleMap(
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                compassEnabled: true,
                mapType: MapType.normal,
                initialCameraPosition: _kGooglePlex,
                onMapCreated: (GoogleMapController controller) {
                  _mapsController = controller;
                },
                markers: markers,
                polylines: polylines,
              )
            else
              StreamBuilder<BookingDetails>(
                  stream: databaseService.bookingDetails,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print(snapshot.error);
                      return loadingStyle;
                    }

                    if (snapshot.hasData &&
                        snapshot.data.customerName != null) {
                      bookingDetails = snapshot.data;
                      _pickup = bookingDetails.pickup;
                      _drop = bookingDetails.drop;

                      print(bookingDetails.customerName);

                      _setDriverMarker(bookingDetails.driverLocation);

                      if (_pickup && !_alreadySet) {
                        _routeSet = false;
                        _alreadySet = true;
                      }

                      if (_drop) _rideCompleted();

                      if (!_pickup && !_routeSet) {
                        _setRoute(snapshot.data.driverLocation,
                            snapshot.data.sourceLocation);
                      } else if (!_drop && !_routeSet) {
                        _setRoute(snapshot.data.sourceLocation,
                            snapshot.data.destinationLocation);
                      }
                    }

                    return GoogleMap(
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      compassEnabled: true,
                      mapType: MapType.normal,
                      initialCameraPosition: _kGooglePlex,
                      onMapCreated: (GoogleMapController controller) {
                        _mapsController = controller;
                      },
                      markers: markers,
                      polylines: polylines,
                    );
                  }),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextField(
                    controller: sourceController,
                    decoration: textInputDecor.copyWith(
                      hintText: 'Enter the source location',
                    ),
                    onTap: () => _getLocation('Source'),
                    readOnly: true,
                  ),
                  SizedBox(height: 8),
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
            ),
          ],
        ),
      ),
    );
  }

  _setDriverMarker(GeoPoint geoPoint) {
    markers.clear();

    markers.add(Marker(
        markerId: MarkerId('driver'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        position: LatLng(geoPoint.latitude, geoPoint.longitude)));

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
      cost = (distance).toDouble() / 155.7 + 10;
      _routeloading = false;
      _routeDisplay = true;
    });
  }

  Future<void> _setRoute(GeoPoint source, GeoPoint destination) async {
    polylineCoordinates.clear();
    polylines.clear();

    LatLng sourceCor = LatLng(source.latitude, source.longitude);
    LatLng destinationCor = LatLng(destination.latitude, destination.longitude);
    var result = await RouteService.getRoute(sourceCor, destinationCor);

    for (var latlng in result['coordinates']) {
      polylineCoordinates.add(LatLng(latlng['latitude'], latlng['longitude']));
    }

    polylines.add(Polyline(
      polylineId: PolylineId('route'),
      visible: true,
      points: polylineCoordinates,
      width: 4,
      color: Colors.blue,
    ));

    setState(() {
      _routeSet = true;
    });
  }

  Future<void> _rideCompleted() async {
    markers.clear();
    polylineCoordinates.clear();
    polylines.clear();

    sourceController.clear();
    destinationController.clear();

    sourceCoordinates = null;
    destinationCoordinates = null;

    source = null;
    destination = null;

    setState(() {
      _routeloading = false;
      _routeDisplay = false;
      _streamCreated = false;
      _pickup = false;
      _drop = false;
      _routeSet = false;
      _alreadySet = false;
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
                      topLeft: const Radius.circular(32.0),
                      topRight: const Radius.circular(32.0))),
              child: Column(
                children: [
                  SizedBox(height: 24),
                  Text('Book Ride', style: semiHeadingStyle),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 1),
                      Text(
                          'Distance: ${distance >= 1000 ? (distance / 1000).toStringAsFixed(1) : distance} ${distance >= 1000 ? 'km' : 'm'}',
                          style: miniHeadingStyle),
                      Text(
                          'Time: ${travelTime / 60 > 0 ? (travelTime / 60).toStringAsFixed(0) + ' min' : ''} ${travelTime % 60 > 0 ? (travelTime % 60).toString() + ' s' : ''}',
                          style: miniHeadingStyle),
                      SizedBox(width: 1),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 1),
                      Text('Cost: Rs. ${cost.toStringAsFixed(2)}',
                          style: miniHeadingStyle),
                      SizedBox(width: 1),
                    ],
                  ),
                  SizedBox(height: 60),
                  ElevatedButton(
                    onPressed: () => _streamCreated ? null : _bookRide(),
                    child: ButtonLayout('Book Ride'),
                    style: buttonStyle,
                  ),
                ],
              ));
        });
  }

  Future<void> _bookRide() async {
    Map<String, dynamic> result =
        await Navigator.of(context).push(MaterialPageRoute(
            builder: (buildContext) => Payment(
                  customer: Provider.of<Customer>(context),
                  source: source,
                  destination: destination,
                  sourceCor: GeoPoint(
                      sourceCoordinates.latitude, sourceCoordinates.longitude),
                  destinationCor: GeoPoint(destinationCoordinates.latitude,
                      destinationCoordinates.longitude),
                  distance: distance,
                  time: travelTime,
                  cost: cost,
                )));
    if (result == null || result.isEmpty) {
      return;
    }

    print(result);

    setState(() {
      databaseService = DatabaseService(uid: result['driverID']);
      _streamCreated = true;
    });
  }
}
