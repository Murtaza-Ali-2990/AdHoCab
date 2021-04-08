import 'package:adhocab/authentication/signIn/sign_in.dart';
import 'package:adhocab/authentication/signUp/sign_up_customer.dart';
import 'package:adhocab/utils/styles.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class Onboarding extends StatelessWidget {
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/Onboarding.png'),
              fit: BoxFit.cover,
            ),
          ),
          alignment: Alignment.center,
          child: Column(
            children: [
              SizedBox(height: 80),
              Text(
                'AdHoCab',
                style: headingStyle.copyWith(
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Color(0xFFFF9977),
                      offset: Offset.fromDirection(pi * 1 / 4, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 240),
              ElevatedButton(
                child: ButtonLayout('Log In'),
                style: buttonStyle,
                onPressed: () => _redirectToLogin(context),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                child: ButtonLayout('Sign Up'),
                style: buttonStyle,
                onPressed: () => _redirectToSignUp(context),
              ),
            ],
          ),
        ),
      ),
    );
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
