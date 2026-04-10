import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/screens/auth/signin_screen.dart';

/// Centralized session management for handling 401 Unauthorized responses.
///
/// Detects session expiration, clears credentials, and navigates to login
/// with a user-friendly dialog. Reusable across all APIs in the app.
class SessionManager {
  SessionManager._();
  static final SessionManager _instance = SessionManager._();

  /// Get the singleton instance.
  static SessionManager get instance => _instance;

  /// Track if session expired dialog is already showing to prevent duplicates.
  static bool _isDialogShowing = false;

  // ── Public API ──────────────────────────────────────────────────────────

  /// Check if a response indicates an unauthorized/session expired state.
  ///
  /// Returns `true` if:
  /// - [statusCode] is 401
  /// - [message] contains 'Unauthenticated' or 'Unauthorized' (case-insensitive)
  static bool isUnauthorized({
    int? statusCode,
    String? message,
  }) {
    // Check status code first
    if (statusCode == 401) return true;

    // Check message for common unauthorized strings
    if (message != null) {
      final msg = message.toLowerCase();
      if (msg.contains('unauthenticated') || msg.contains('unauthorized')) {
        return true;
      }
    }

    return false;
  }

  /// Clear the user session from persistent storage.
  ///
  /// Removes the stored auth token immediately. Safe to call multiple times.
  static Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userToken');
      log('[SessionManager] User session cleared — token removed from storage');
    } catch (e) {
      log('[SessionManager] Error clearing session: $e');
    }
  }

  /// Show a user-friendly "Session Expired" dialog.
  ///
  /// Guides the user back to login without showing technical error messages.
  /// On "Login Again" tap, clears session and navigates to SignInScreen
  /// with proper stack clearing to prevent navigating back into protected screens.
  ///
  /// Returns immediately if dialog is already showing (prevents duplicates).
  static Future<void> showSessionExpiredDialog(BuildContext context) async {
    // Prevent duplicate dialogs
    if (_isDialogShowing) {
      log('[SessionManager] Dialog already showing - ignoring duplicate call');
      return;
    }

    _isDialogShowing = true;

    try {
      if (!context.mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false, // Force user to tap button
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              const Icon(Icons.lock_clock, color: kPrimaryColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Session Expired',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kHeadingColor,
                  ),
                ),
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Your session has expired due to inactivity or a login from another device. Please log in again to continue.',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: kSubtitleColor,
                height: 1.5,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Not Now',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: kMutedColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                _isDialogShowing = false;

                // Clear session first
                await clearSession();

                // Navigate to login, removing all previous screens from stack
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                    (route) => false, // Remove all routes below the new one
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                'Login Again',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    } finally {
      _isDialogShowing = false;
    }
  }
}
