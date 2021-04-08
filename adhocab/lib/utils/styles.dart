import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

final mainColor = Color(0xFFFF9977);
final bgColor = Color(0xFFFFBBAA);

final apiKey = 'Rf01sgkDlBo10y6SXBNfHJ5GzAG162Ta';

final textInputDecor = InputDecoration(
  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  hintText: '',
  fillColor: Colors.white,
  filled: true,
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: mainColor, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: mainColor, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
);

final headingStyle = TextStyle(
  fontSize: 48.0,
  letterSpacing: 2,
  fontFamily: 'Monoton',
  shadows: [
    Shadow(
      color: Color(0x44000000),
      offset: Offset.fromDirection(pi * 1 / 4, 4),
      blurRadius: 8,
    ),
  ],
);

final semiHeadingStyle = TextStyle(
  fontSize: 36.0,
  fontWeight: FontWeight.bold,
);

final miniHeadingStyle = TextStyle(
  fontSize: 20.0,
  fontWeight: FontWeight.bold,
);

final buttonTextStyle = TextStyle(
  fontSize: 24.0,
  color: Colors.white,
  fontFamily: 'Raleway',
);

final errorTextStyle = TextStyle(
  fontSize: 16.0,
  color: Colors.red,
);

final loadingStyle = SpinKitRotatingCircle(
  color: mainColor,
  size: 100.0,
);

final buttonStyle = ButtonStyle(
  backgroundColor: MaterialStateProperty.all<Color>(mainColor),
);

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
    return Container(
      alignment: Alignment.center,
      width: 280,
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Text(text, style: buttonTextStyle),
    );
  }
}

bool isNumeric(String s) {
  if (s == null) return false;
  return double.tryParse(s) != null;
}
