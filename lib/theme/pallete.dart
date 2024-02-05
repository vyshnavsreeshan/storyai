import 'package:flutter/material.dart';

class Pallete {
  // Colors
  static const blackColor = Color.fromRGBO(1, 1, 1, 1); // primary color
  static const greyColor = Color.fromRGBO(26, 39, 45, 1); // secondary color
  static const drawerColor = Color.fromRGBO(18, 18, 18, 1);
  static const whiteColor = Colors.white;
  static var redColor = Colors.red.shade500;
  static var blueColor = Colors.blue.shade300;
  static const cream = Color.fromRGBO(251, 244, 219, 1);
  static const vanila = Color.fromRGBO(255, 246, 217, 0.8);
  static const brown = Color.fromRGBO(45, 29, 20, 1);

  // Theme
  static var appTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: cream,
    appBarTheme: const AppBarTheme(
      backgroundColor: vanila,
      elevation: 1,
      iconTheme: IconThemeData(
        color: brown,
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: cream,
    ),
    primaryColor: redColor,
    backgroundColor: whiteColor,
  );
}
