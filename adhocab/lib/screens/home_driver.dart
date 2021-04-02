import 'package:adhocab/detail_updates/driver_details.dart';
import 'package:adhocab/models/driver.dart';
import 'package:adhocab/models/user_data.dart';
import 'package:adhocab/services/auth_service.dart';
import 'package:adhocab/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DriverHome extends StatefulWidget {
  _Home createState() => _Home();
}

class _Home extends State<DriverHome> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (buildContext) {
                  final driver = Provider.of<Driver>(context);
                  final user = Provider.of<UserData>(context);
                  return DriverDetails(driver: driver, uid: user.uid);
                }))),
        actions: [
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => AuthService().signOut()),
        ],
        title: SemiHeadingStyle('Home'),
      ),
      body: Container(),
    );
  }
}
