import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

final mainColor = Color(0xFFFF9977);
final bgColor = Color(0xFFFFBBAA);

final apiKey = 'Rf01sgkDlBo10y6SXBNfHJ5GzAG162Ta';

final textInputDecor = InputDecoration(
    hintText: '',
    fillColor: Colors.white,
    filled: true,
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: mainColor, width: 4.0),
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
    ),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: mainColor, width: 4.0),
        borderRadius: BorderRadius.all(Radius.circular(10.0))));

final headingStyle = TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold);
final semiHeadingStyle = TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold);
final miniHeadingStyle = TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold);
final buttonTextStyle = TextStyle(fontSize: 16.0, color: Colors.white);
final errorTextStyle = TextStyle(fontSize: 16.0, color: Colors.red);

final loadingStyle = SpinKitRotatingCircle(color: mainColor, size: 100.0);

final buttonStyle =
    ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(mainColor));

Widget detailsAppBar(String title) {
  return AppBar(
    title: Text(
      title,
      style: semiHeadingStyle,
    ),
    backgroundColor: mainColor,
  );
}

class ButtonLayout extends StatelessWidget {
  final text;
  ButtonLayout(this.text);

  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
      child: Text(text, style: buttonTextStyle),
    );
  }
}

class HeadingStyle extends StatelessWidget {
  final text;
  HeadingStyle(this.text);

  Widget build(BuildContext context) {
    return Text(text, style: headingStyle);
  }
}

class SemiHeadingStyle extends StatelessWidget {
  final text;
  SemiHeadingStyle(this.text);

  Widget build(BuildContext context) {
    return Text(text, style: semiHeadingStyle);
  }
}

class MiniHeadingStyle extends StatelessWidget {
  final text;
  MiniHeadingStyle(this.text);

  Widget build(BuildContext context) {
    return Text(text, style: miniHeadingStyle);
  }
}

class ErrorTextStyle extends StatelessWidget {
  final text;
  ErrorTextStyle(this.text);

  Widget build(BuildContext context) {
    return Text(text, style: errorTextStyle);
  }
}

bool isNumeric(String s) {
  if (s == null) {
    return false;
  }
  return double.tryParse(s) != null;
}
