import 'package:adhocab/models/user_data.dart';
import 'package:adhocab/screens/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'loading_screen.dart';

class Wrapper extends StatelessWidget {
  Widget build(BuildContext context) {
    final user = Provider.of<UserData>(context);

    print('User is ${user?.uid} and type is ${user?.type}');

    if (user?.uid == null) {
      return Onboarding();
    }
    if (user?.type == 'Customer') {
      return Text('Customer');
    }
    if (user?.type == 'Driver') {
      return Text('Driver');
    }
    return Loading();
  }
}
