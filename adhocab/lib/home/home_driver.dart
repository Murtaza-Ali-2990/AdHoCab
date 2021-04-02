import 'package:adhocab/navigation_drawer/driver_navigation_drawer.dart';
import 'package:adhocab/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DriverHome extends StatefulWidget {
  _Home createState() => _Home();
}

class _Home extends State<DriverHome> {
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawerDriver(),
      appBar: AppBar(
        title: SemiHeadingStyle('Home'),
      ),
      body: Container(),
    );
  }
}
