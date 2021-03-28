import 'package:adhocab/models/user_data.dart';
import 'package:adhocab/services/auth_service.dart';
import 'package:adhocab/utils/loading_screen.dart';
import 'package:adhocab/utils/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(AdHoCab());
}

class AdHoCab extends StatelessWidget {
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialize(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return MaterialApp(
              home: Scaffold(
                body: Text(snapshot.error.toString()),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            return StreamProvider<UserData>.value(
              value: AuthService().user,
              initialData: UserData(null),
              child: MaterialApp(
                home: Wrapper(),
              ),
            );
          }

          return MaterialApp(home: Loading());
        });
  }

  Future<FirebaseApp> _initialize() async {
    return await Firebase.initializeApp();
  }
}
