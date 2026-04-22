import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:moonbnd/constants.dart';

/// App-wide snackbar helper using theme colors from constants.dart
class AppSnackbar {
  /// Show success snackbar with primary color
  static void success(String message) {
    // Dismiss any loading indicators first
    EasyLoading.dismiss();

    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: kPrimaryColor, // Primary teal color from constants
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  /// Show error snackbar with red/error color
  static void error(String message) {
    // Dismiss any loading indicators first
    EasyLoading.dismiss();

    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFE74C3C), // Error red
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      //icon: const Icon(Icons.error_outline, color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
