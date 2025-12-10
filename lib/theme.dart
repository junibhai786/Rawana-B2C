import 'package:flutter/material.dart';
import 'constants.dart';

ThemeData havenTheme() {
  return ThemeData(
    scaffoldBackgroundColor: kBackgroundColor,
    fontFamily: "Poppins",
    appBarTheme: appBarTheme(),
    textTheme: textTheme(),
    iconTheme: iconTheme(),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    useMaterial3: false,
  );
}

AppBarTheme appBarTheme() {
  return const AppBarTheme(
    color: kBackgroundColor,
    elevation: 0.0,
    iconTheme: IconThemeData(
      color: kPrimaryColor,
      size: 24,
    ),
    titleTextStyle: TextStyle(
      color: kPrimaryColor,
      fontSize: 18,
      fontWeight: FontWeight.w500,
      fontFamily: 'Inter'
    ),
    centerTitle: false,
    // systemOverlayStyle: SystemUiOverlayStyle(
    //   statusBarColor: Colors.transparent,
    // ),
  );
}

TextTheme textTheme() {
  return const TextTheme(
    bodyLarge: TextStyle(
      color: kPrimaryColor,
      fontWeight: FontWeight.w100,
      fontSize: 14,
      fontFamily: 'Inter'
    ),
    bodyMedium: TextStyle(
      color: kPrimaryColor,
      fontSize: 14,
      fontFamily: 'Inter'
    ),
  );
}

IconThemeData iconTheme() {
  return const IconThemeData(
    color: kPrimaryColor,
    size: 24,
  );
}
