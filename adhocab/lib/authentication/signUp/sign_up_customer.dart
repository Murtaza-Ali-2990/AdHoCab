import 'package:adhocab/authentication/signUp/sign_up_driver.dart';
import 'package:adhocab/services/auth_service.dart';
import 'package:adhocab/utils/loading_screen.dart';
import 'package:adhocab/utils/styles.dart';
import 'package:flutter/material.dart';

class SignUpCustomer extends StatefulWidget {
  _SignUpCustomerState createState() => _SignUpCustomerState();
}

class _SignUpCustomerState extends State<SignUpCustomer> {
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
            Text('Sign Up as a Customer', style: semiHeadingStyle),
            SizedBox(height: 50.0),
            SizedBox(
              width: 400.0,
              child: Form(
                  key: _key,
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: username,
                        keyboardType: TextInputType.emailAddress,
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
              onPressed: _redirectToSignUpDriver,
              child: Text(
                'Sign Up as a Driver',
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

  void _redirectToSignUpDriver() async {
    final result = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => SignUpDriver()));
    if (result == 'exit') Navigator.of(context).pop('exit');
  }

  Future<void> _verifySignUp() async {
    if (_key.currentState.validate()) {
      setState(() => loading = true);
      final type = "Customer";
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
