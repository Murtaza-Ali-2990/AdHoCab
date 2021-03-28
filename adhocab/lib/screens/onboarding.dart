import 'package:adhocab/authentication/signIn/sign_in.dart';
import 'package:adhocab/authentication/signUp/sign_up_customer.dart';
import 'package:adhocab/utils/styles.dart';
import 'package:flutter/material.dart';

class Onboarding extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage('assets/images/Onboarding.png'),
        fit: BoxFit.cover,
      )),
      margin: EdgeInsets.only(top: 20.0),
      alignment: Alignment.center,
      child: Column(
        children: [
          HeadingStyle('AdHoCab'),
          SizedBox(height: 50.0),
          ElevatedButton.icon(
            icon: Icon(
              Icons.login,
              color: Colors.white,
            ),
            label: ButtonLayout('Log In'),
            style: buttonStyle,
            onPressed: () => _redirectToLogin(context),
          ),
          SizedBox(height: 10.0),
          ElevatedButton(
            style: buttonStyle,
            child: ButtonLayout('Sign Up'),
            onPressed: () => _redirectToSignUp(context),
          ),
        ],
      ),
    ));
  }

  void _redirectToSignUp(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => SignUpCustomer()));
  }

  void _redirectToLogin(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => SignIn()));
  }
}
