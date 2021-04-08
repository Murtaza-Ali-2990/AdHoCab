import 'package:adhocab/services/location_auto_complete_service.dart';
import 'package:adhocab/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as Coding;

class LocationPicker extends StatefulWidget {
  final locationType;
  LocationPicker({this.locationType});
  _Picker createState() => _Picker();
}

class _Picker extends State<LocationPicker> {
  final locationType;
  _Picker({this.locationType});

  final Map<String, dynamic> location = {};
  String pattern = '';

  Location _location = new Location();
  List<Coding.Placemark> placemarks;

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(left: 8, right: 8, top: 48, bottom: 12),
          child: Column(
            children: [
              TextFormField(
                initialValue: pattern,
                decoration: textInputDecor.copyWith(
                  hintText: 'Search for Location',
                ),
                onChanged: (value) => setState(() => pattern = value),
              ),
              SizedBox(height: 8),
              ElevatedButton.icon(
                icon: Icon(Icons.location_searching),
                label: Text('Your Current Location'),
                onPressed: () => _getCurrentLocation(),
              ),
              FutureBuilder(
                future: pattern == null || pattern.isEmpty
                    ? null
                    : LocationAutoComplete.getSuggestions(pattern),
                builder: _buildFuture,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _getCurrentLocation() async {
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
    placemarks = await Coding.placemarkFromCoordinates(
        _locationData.latitude, _locationData.longitude);

    location['name'] = placemarks[0].name + ', ' + placemarks[0].subLocality;
    location['lat'] = _locationData.latitude;
    location['lon'] = _locationData.longitude;

    Navigator.of(context).pop(location);
  }

  Widget _buildFuture(BuildContext context, AsyncSnapshot<List> snapshot) {
    if (pattern == null || pattern.isEmpty) return Container();

    if (snapshot.hasError) return Text(snapshot.error.toString());
    if (!snapshot.hasData) return loadingStyle;

    return Expanded(
      child: ListView.builder(
        itemCount: snapshot.data.length,
        itemBuilder: (context, index) =>
            _itemBuilder(context, snapshot.data[index]),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, dynamic data) {
    return ListTile(
      leading: Icon(Icons.location_on),
      title: Text(
          '${data['poi']['name'].toString()}, ${data['address']['freeformAddress'].toString()}'),
      onTap: () {
        location['name'] =
            data['poi']['name'] + ', ' + data['address']['freeformAddress'];
        location['lat'] = data['position']['lat'];
        location['lon'] = data['position']['lon'];

        Navigator.of(context).pop(location);
      },
    );
  }
}
