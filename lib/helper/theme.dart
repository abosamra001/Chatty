import 'package:flutter/material.dart';

class CustomColors {
  const CustomColors({
    required this.primaryColor,
    required this.backgroundColor,
    required this.forgroundColor,
  });
  final Color primaryColor;
  final Color backgroundColor;
  final Color forgroundColor;
}

class MySignUpTheme {
  static CustomColors toggleTheme(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    if (brightness == Brightness.dark) {
      return const CustomColors(
        primaryColor: Color(0xff3362cc),
        backgroundColor: Color(0xff263238),
        forgroundColor: Color(0xffd9e5ff),
      );
    } else {
      return const CustomColors(
        primaryColor: Color(0xff407bff),
        backgroundColor: Color(0xffd9e5ff),
        forgroundColor: Color(0xff263238),
      );
    }
  }
}

class MyLogInTheme {
  static CustomColors toggleTheme(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    if (brightness == Brightness.dark) {
      return const CustomColors(
        primaryColor: Color(0xffff725e),
        backgroundColor: Color(0xff455a64),
        forgroundColor: Color(0xffffe3df),
      );
    } else {
      return const CustomColors(
        primaryColor: Color(0xffff725e),
        backgroundColor: Color(0xffffe3df),
        forgroundColor: Color(0xff263238),
      );
    }
  }
}
