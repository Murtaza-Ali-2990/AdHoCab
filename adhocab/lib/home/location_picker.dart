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
        child: Column(
          children: [
            SizedBox(height: 50),
            TextFormField(
              initialValue: pattern,
              decoration: textInputDecor.copyWith(
                hintText: 'Search for Location',
              ),
              onChanged: (value) => setState(() => pattern = value),
            ),
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


/*import 'package:adhocab/services/location_auto_complete_service.dart';
import 'package:adhocab/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as Coding;

class LocationPicker extends StatefulWidget {
  final String header;
  LocationPicker({this.header});
  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  double w, h;
  String origin;
  Map<String, double> originCoordinates = {'latitude': 0.0, 'longitude': 0.0};

  dynamic places;

  String pattern = "";
  final TextEditingController _typeAheadController1 = TextEditingController();

  Location location = new Location();
  List<Coding.Placemark> placemarks;

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;
  var currentLocation = [];

  @override
  void initState() {
    super.initState();
  }

  currentLoc() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await location.getLocation();
    placemarks = await Coding.placemarkFromCoordinates(
        _locationData.latitude, _locationData.longitude);
    await addData();
  }

  addData() async {
    currentLocation.insert(
        0, placemarks[0].name + ', ' + placemarks[0].subLocality);
    currentLocation.insert(1, placemarks[0].locality);
    currentLocation.insert(2, _locationData.latitude);
    currentLocation.insert(3, _locationData.longitude);
    currentLocation.insert(4, placemarks[0].subAdministrativeArea);
    currentLocation.insert(5, placemarks[0].administrativeArea);
    currentLocation.insert(6, placemarks[0].postalCode);
    print(currentLocation);
    currentLocation.length == 7
        ? Navigator.pop(context, currentLocation)
        : addData();
  }

  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.header ?? 'No header',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.3),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.20,
                child: null),
          ),
          Container(
            margin:
                EdgeInsets.only(left: 0.1 * w, right: 0.1 * w, top: 0.05 * h),
            decoration: new BoxDecoration(
              boxShadow: [
                new BoxShadow(
                    color: mainColor, blurRadius: 15.0, spreadRadius: -5),
              ],
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                  child: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter your location here",
                        hintStyle: TextStyle(color: mainColor, fontSize: 18)),
                    controller: this._typeAheadController1,
                    onChanged: (value) {
                      setState(() {
                        pattern = value;
                      });
                    },
                  )),
            ),
          ),
          currentLocation.length != 3
              ? GestureDetector(
                  onTap: () => {currentLoc()},
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_searching),
                        Text(" Your current location")
                      ],
                    ),
                  ),
                )
              : SpinKitDoubleBounce(
                  color: mainColor,
                  size: 50.0,
                ),
          FutureBuilder(
            future: pattern == ""
                ? null
                : LocationAutoComplete.getSuggestions(pattern),
            builder: (context, snapshot) => pattern == ""
                ? Container()
                : snapshot.hasData
                    ? Expanded(
                        child: ListView.builder(
                        itemBuilder: (context, index) => GestureDetector(
                          onTap: () {
                            setState(() {
                              currentLocation.insert(
                                  0,
                                  snapshot.data[index]['poi']['name']
                                          .toString() +
                                      ', ' +
                                      snapshot.data[index]['address']
                                              ['streetName']
                                          .toString());
                              currentLocation.insert(
                                  1,
                                  snapshot.data[index]['address']
                                              ['municipalitySubdivision']
                                          .toString() +
                                      ', ' +
                                      snapshot.data[index]['address']
                                              ['municipality']
                                          .toString());
                              currentLocation.insert(
                                  2, snapshot.data[index]['position']['lat']);
                              currentLocation.insert(
                                  3, snapshot.data[index]['position']['lon']);
                              currentLocation.insert(
                                  4,
                                  snapshot.data[index]['address']
                                      ['municipality']);
                              currentLocation.insert(
                                  5,
                                  snapshot.data[index]['address']
                                      ['countrySubdivision']);
                              currentLocation.insert(
                                  6,
                                  snapshot.data[index]['address']
                                      ['postalCode']);
                            });
                            print(currentLocation);
                            Navigator.pop(context, currentLocation);
                          },
                          child: Container(
                              padding: EdgeInsets.all(15),
                              child: Text(
                                  snapshot.data[index]['poi']['name']
                                          .toString() +
                                      ', ' +
                                      snapshot.data[index]['address']
                                              ['freeformAddress']
                                          .toString(),
                                  style: TextStyle(fontSize: 16))),
                        ),
                        itemCount: snapshot.data.length,
                      ))
                    : SpinKitThreeBounce(
                        color: mainColor,
                        size: 50.0,
                      ),
          )
        ],
      ),
    );
  }
}*/
