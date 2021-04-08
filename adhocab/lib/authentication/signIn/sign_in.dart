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
        margin: EdgeInsets.only(top: 24),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('Log In', style: semiHeadingStyle),
            SizedBox(height: 50.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
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
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  child: ButtonLayout('Log In'),
                  style: buttonStyle,
                  onPressed: _verifyLogin,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  child: ButtonLayout('Sign Up'),
                  style: buttonStyle,
                  onPressed: _redirectToSignUp,
                ),
              ],
            ),
            SizedBox(height: 20.0),
            if (error == 1) Text('E-mail is Invalid', style: errorTextStyle),
            if (error == 2)
              Text('Wrong Password. Please try again.', style: errorTextStyle),
            if (error == 3) Text('Weak Password', style: errorTextStyle),
            if (error == 4) Text('User not Found', style: errorTextStyle),
          ],
        ),
      ),
    );
  }

  void _redirectToSignUp() async {
    final result = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => SignUpCustomer()));
    if (result == 'exit') Navigator.of(context).pop();
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
      else {
        error = 0;
        Navigator.of(context).pop();
      }
      if (error != 0) setState(() => loading = false);
    }
  }
}
