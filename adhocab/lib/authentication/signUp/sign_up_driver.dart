import 'package:adhocab/services/auth_service.dart';
import 'package:adhocab/utils/loading_screen.dart';
import 'package:adhocab/utils/styles.dart';
import 'package:flutter/material.dart';

class SignUpDriver extends StatefulWidget {
  _SignUpDriverState createState() => _SignUpDriverState();
}

class _SignUpDriverState extends State<SignUpDriver> {
  String username, password;
  int error = 0;
  bool loading = false;
  final _key = GlobalKey<FormState>();

  Widget build(BuildContext context) {
    if (loading) return Loading();

    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 20.0),
        alignment: Alignment.center,
        child: Column(
          children: [
            Text('Sign Up as a Driver', style: semiHeadingStyle),
            SizedBox(height: 50.0),
            SizedBox(
              width: 400.0,
              child: Form(
                  key: _key,
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: username,
                        decoration:
                            textInputDecor.copyWith(hintText: 'Username'),
                        validator: (value) =>
                            value.isEmpty ? 'Enter Username' : null,
                        onChanged: (value) => setState(() => username = value),
                      ),
                      SizedBox(height: 20.0),
                      TextFormField(
                        initialValue: password,
                        obscureText: true,
                        decoration:
                            textInputDecor.copyWith(hintText: 'Password'),
                        validator: (value) =>
                            value.isEmpty ? 'Enter a Password' : null,
                        onChanged: (value) => setState(() => password = value),
                      ),
                    ],
                  )),
            ),
            SizedBox(height: 30.0),
            ElevatedButton(
              style: buttonStyle,
              child: ButtonLayout('Sign Up'),
              onPressed: _verifySignUp,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _redirectToSignUpCustomer,
              child: Text(
                'Sign Up as a Customer',
                style: TextStyle(color: mainColor),
              ),
            ),
            SizedBox(height: 20.0),
            if (error == 1)
              Text('E-mail already in use', style: errorTextStyle),
            if (error == 2) Text('Weak Password', style: errorTextStyle),
            if (error == 3) Text('Invalid Email Format', style: errorTextStyle),
          ],
        ),
      ),
    );
  }

  void _redirectToSignUpCustomer() {
    Navigator.of(context).pop();
  }

  Future<void> _verifySignUp() async {
    if (_key.currentState.validate()) {
      setState(() => loading = true);
      final type = "Driver";
      final user = await AuthService().signUp(username, password, type);
      if (user == 'email-already-in-use')
        error = 1;
      else if (user == 'weak-password')
        error = 2;
      else if (user == 'invalid-email')
        error = 3;
      else {
        error = 0;
        Navigator.of(context).pop('exit');
      }
      if (error != 0) setState(() => loading = false);
    }
  }
}
