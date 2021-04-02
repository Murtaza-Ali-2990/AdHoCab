import 'package:adhocab/detail_updates/vehicle_details.dart';
import 'package:adhocab/models/driver.dart';
import 'package:adhocab/models/user_data.dart';
import 'package:adhocab/models/vehicle.dart';
import 'package:adhocab/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adhocab/detail_updates/driver_details.dart';

class NavigationDrawerDriver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'Side menu',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            decoration: BoxDecoration(
              color: Colors.green,
            ),
          ),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Update Details'),
            onTap: () => _navigateToUpdateOwnDetails(context),
          ),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Update Vehicle Details'),
            onTap: () => _navigateToUpdateVehicleDetails(context),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: Icon(Icons.border_color),
            title: Text('Feedback'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () => AuthService().signOut(),
          ),
        ],
      ),
    );
  }

  Future _navigateToUpdateOwnDetails(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (buildContext) {
      final driver = Provider.of<Driver>(context);
      final user = Provider.of<UserData>(context);
      return DriverDetails(driver: driver, uid: user.uid);
    }));
  }

  Future _navigateToUpdateVehicleDetails(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (buildContext) {
      final vehicle = Provider.of<Vehicle>(context);
      final user = Provider.of<UserData>(context);
      return VehicleDetails(vehicle: vehicle, uid: user.uid);
    }));
  }
}
