import 'package:adhocab/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SpinKitRotatingCircle(color: mainColor, size: 100.0),
    );
  }
}
