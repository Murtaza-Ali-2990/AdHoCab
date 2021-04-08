import 'dart:async';

import 'package:adhocab/models/booking_details.dart';
import 'package:adhocab/services/database_service.dart';
import 'package:adhocab/services/route_service.dart';
import 'package:adhocab/utils/loading_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:adhocab/navigation_drawer/driver_navigation_drawer.dart';
import 'package:adhocab/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class DriverHome extends StatefulWidget {
  final uid;
  DriverHome({this.uid});

  _Home createState() => _Home(uid: uid);
}

class _Home extends State<DriverHome> {
  final uid;
  _Home({this.uid});

  GoogleMapController _mapsController;
  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(22.697442, 75.857239),
    zoom: 13,
  );

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  bool _serviceEnabled = false,
      _markersSet = false,
      _pickup = false,
      _drop = false,
      _routeSet = false,
      _active = false;
  PermissionStatus _permissionGranted;
  Location _location = new Location();
  StreamSubscription<LocationData> locationSubscription;
  LatLng driverLocation;

  DatabaseService databaseService;
  BookingDetails bookingDetails;

  initState() {
    super.initState();
    databaseService = DatabaseService(uid: uid);
    _enableLocation();
  }

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
              child: TextButton(
                onPressed: _active ? showMenu : () {},
                child: _active ? Text('Ride Details') : null,
              ),
            )),
      ),
      drawer: NavigationDrawerDriver(),
      appBar: AppBar(
        title: SemiHeadingStyle('Home'),
      ),
      body: StreamBuilder<BookingDetails>(
          stream: databaseService.bookingDetails,
          initialData:
              BookingDetails(driverLocation: GeoPoint(22.697442, 75.857239)),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return Loading();
            }

            if (driverLocation != null && _mapsController != null)
              _mapsController
                  .animateCamera(CameraUpdate.newLatLng(driverLocation));

            if (snapshot.hasData && snapshot.data.customerName != null) {
              _active = true;
              bookingDetails = snapshot.data;

              if (!_markersSet) {
                double sLat = snapshot.data.sourceLocation.latitude;
                double sLon = snapshot.data.sourceLocation.longitude;
                double dLat = snapshot.data.destinationLocation.latitude;
                double dLon = snapshot.data.destinationLocation.longitude;
                markers.add(Marker(
                    markerId: MarkerId('source'),
                    position: LatLng(sLat, sLon)));
                markers.add(Marker(
                    markerId: MarkerId('destination'),
                    position: LatLng(dLat, dLon)));
                _markersSet = true;
              }

              if (!_pickup && !_routeSet) {
                _setRoute(
                    snapshot.data.driverLocation, snapshot.data.sourceLocation);
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
    );
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

  Future<void> _enableLocation() async {
    _serviceEnabled = await _location.serviceEnabled();

    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();

      if (!_serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enable Location access')));
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();

    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();

      if (_permissionGranted != PermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enable Location permission')));
        return;
      }
    }

    _location.changeSettings(interval: 5000);
    locationSubscription = _location.onLocationChanged.listen((event) {
      driverLocation = LatLng(event.latitude, event.longitude);
      databaseService
          .setCurrentLocation(GeoPoint(event.latitude, event.longitude));
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
                    SemiHeadingStyle('Ride Details'),
                    SizedBox(height: 10),
                    if (!_pickup)
                      TextButton(
                        onPressed: () => _onPickup(builder),
                        child: Text('Pickup'),
                      )
                    else if (!_drop)
                      TextButton(
                        onPressed: () => _onDrop(builder),
                        child: Text('Drop'),
                      )
                    else
                      TextButton(
                        onPressed: () => _finishRide(builder),
                        child: Text('Exit'),
                      )
                  ],
                ),
              ));
        });
  }

  Future<void> _onPickup(BuildContext context) async {
    await await databaseService.setPickup(true);
    setState(() {
      _routeSet = false;
      _pickup = true;
    });
    Navigator.pop(context);
  }

  Future<void> _onDrop(BuildContext context) async {
    await await databaseService.setDrop(true);
    setState(() {
      _routeSet = false;
      _drop = true;
    });
    Navigator.pop(context);
  }

  Future<void> _finishRide(BuildContext context) async {
    markers.clear();
    polylineCoordinates.clear();
    polylines.clear();

    await databaseService.setBookingDetails(BookingDetails());
    await databaseService.setPickup(false);
    await databaseService.setDrop(false);

    setState(() {
      _active = false;
      _drop = false;
      _pickup = false;
      _routeSet = false;
      _markersSet = false;
    });
    Navigator.pop(context);
  }

  void dispose() {
    super.dispose();
    locationSubscription.cancel();
    databaseService.removeDriver();
  }
}
