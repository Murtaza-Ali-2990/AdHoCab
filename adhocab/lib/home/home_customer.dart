import 'package:adhocab/navigation_drawer/customer_navigation_drawer.dart';
import 'package:adhocab/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomerHome extends StatefulWidget {
  _Home createState() => _Home();
}

class _Home extends State<CustomerHome> {
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawerCustomer(),
      appBar: AppBar(
        title: SemiHeadingStyle('Home'),
      ),
      body: Container(),
    );
  }
}
