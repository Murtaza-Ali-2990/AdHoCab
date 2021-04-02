import 'package:adhocab/detail_updates/customer_details.dart';
import 'package:adhocab/models/customer.dart';
import 'package:adhocab/models/user_data.dart';
import 'package:adhocab/services/auth_service.dart';
import 'package:adhocab/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomerHome extends StatefulWidget {
  _Home createState() => _Home();
}

class _Home extends State<CustomerHome> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (buildContext) {
                  final customer = Provider.of<Customer>(context);
                  final user = Provider.of<UserData>(context);
                  return CustomerDetails(customer: customer, uid: user.uid);
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
