import 'package:adhocab/authentication/signUp/sign_up_customer.dart';
import 'package:adhocab/services/auth_service.dart';
import 'package:adhocab/utils/loading_screen.dart';
import 'package:adhocab/utils/styles.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
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
            HeadingStyle('Log In'),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: Icon(
                    Icons.login,
                    color: Colors.white,
                  ),
                  label: ButtonLayout('Log In'),
                  style: buttonStyle,
                  onPressed: _verifyLogin,
                ),
                SizedBox(width: 30.0),
                ElevatedButton(
                  style: buttonStyle,
                  child: ButtonLayout('Sign Up'),
                  onPressed: _redirectToSignUp,
                ),
              ],
            ),
            SizedBox(height: 20.0),
            if (error == 1) ErrorTextStyle('E-mail is Invalid'),
            if (error == 2) ErrorTextStyle('Wrong Password. Please try again.'),
            if (error == 3) ErrorTextStyle('Weak Password'),
            if (error == 4) ErrorTextStyle('User not Found'),
          ],
        ),
      ),
    );
  }

  void _redirectToSignUp() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => SignUpCustomer()));
  }

  Future<void> _verifyLogin() async {
    if (_key.currentState.validate()) {
      setState(() => loading = true);
      final user = await AuthService().signIn(username, password);
      if (user == 'invalid-email')
        error = 1;
      else if (user == 'wrong-password')
        error = 2;
      else if (user == 'weak-password')
        error = 3;
      else if (user == 'user-not-found')
        error = 4;
      else
        error = 0;
      if (error != 0) setState(() => loading = false);
    }
  }
}
