import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1A53FF); // Blue
  static const Color secondary = Color(0xFF00D2B4); // Teal
  static const Color accent = Color(0xFF7A29FF); // Purple

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary, accent],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient verticalGradient = LinearGradient(
    colors: [primary, secondary, accent],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
