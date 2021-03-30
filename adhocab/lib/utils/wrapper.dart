import 'package:adhocab/models/user_data.dart';
import 'package:adhocab/screens/onboarding.dart';
import 'package:adhocab/services/auth_service.dart';
import 'package:adhocab/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'loading_screen.dart';

class Wrapper extends StatelessWidget {
  Widget build(BuildContext context) {
    final user = Provider.of<UserData>(context);
    final uid = user?.uid;
    final type = user?.type;

    print('User is $uid and type is $type');

    if (uid == null) {
      return Onboarding();
    } else if (type == 'Customer') {
      return ElevatedButton.icon(
        onPressed: () => AuthService().signOut(),
        icon: Icon(Icons.logout),
        label: ButtonLayout('Customer Log Out'),
      );
    } else if (type == 'Driver') {
      return ElevatedButton.icon(
        onPressed: () => AuthService().signOut(),
        icon: Icon(Icons.logout),
        label: ButtonLayout('Driver Log Out'),
      );
    } else
      return Loading();
  }
}
