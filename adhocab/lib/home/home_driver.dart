import 'dart:async';

import 'package:adhocab/utils/loading_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:adhocab/navigation_drawer/driver_navigation_drawer.dart';
import 'package:adhocab/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class DriverHome extends StatefulWidget {
  _Home createState() => _Home();
}

class _Home extends State<DriverHome> {
  GoogleMapController _mapsController;

  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(22.697442, 75.857239),
    zoom: 13,
  );

  bool _serviceEnabled, _loadingLocation;
  PermissionStatus _permissionGranted;
  LocationData _locationData;
  Location _location = new Location();

  LatLng driverLocation;

  initState() {
    super.initState();
    _loadingLocation = true;

    _enableLocation();
  }

  Widget build(BuildContext context) {
    if (_loadingLocation) return Loading();

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
                onPressed: showMenu,
                child: Text('Book Ride'),
              ),
            )),
      ),
      drawer: NavigationDrawerDriver(),
      appBar: AppBar(
        title: SemiHeadingStyle('Home'),
      ),
      body: GoogleMap(
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        compassEnabled: true,
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _mapsController = controller;
        },
      ),
    );
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

    _locationData = await _location.getLocation();
    driverLocation = LatLng(_locationData.latitude, _locationData.longitude);

    _kGooglePlex = CameraPosition(target: driverLocation, zoom: 13);

    setState(() => _loadingLocation = false);
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
                  ],
                ),
              ));
        });
  }
}
