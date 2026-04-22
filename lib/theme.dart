import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'constants.dart';

ThemeData havenTheme() {
  return ThemeData(
    scaffoldBackgroundColor: kBackgroundColor,
    fontFamily: "Poppins",
    primaryColor: AppColors.primary,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.accent,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
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
      color: AppColors.primary,
      size: 24,
    ),
    titleTextStyle: TextStyle(
      color: AppColors.primary,
      fontSize: 18,
      fontWeight: FontWeight.w500,
      fontFamily: 'Inter',
    ),
    centerTitle: false,
  );
}

TextTheme textTheme() {
  return const TextTheme(
    bodyLarge: TextStyle(
      color: AppColors.primary,
      fontWeight: FontWeight.w100,
      fontSize: 14,
      fontFamily: 'Inter',
    ),
    bodyMedium: TextStyle(
      color: AppColors.primary,
      fontSize: 14,
      fontFamily: 'Inter',
    ),
  );
}

IconThemeData iconTheme() {
  return const IconThemeData(
    color: AppColors.primary,
    size: 24,
  );
}
