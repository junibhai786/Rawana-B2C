import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Urls/url_holder_loan.dart';
import 'package:moonbnd/modals/my_profile.dart';
import 'package:moonbnd/widgets/app_snackbar.dart';
import 'package:get/get.dart' as gettt;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  MyProfile? _userProfile;
  // Getter for user profile
  MyProfile? get myProfile => _userProfile;

  /// Build a MyProfile from login/signup response user data
  void _buildProfileFromResponse(Map<String, dynamic> responseData) {
    final user = responseData['user'];
    if (user != null && user is Map<String, dynamic>) {
      _userProfile = MyProfile(
        success: true,
        data: Data(
          id: user['id'],
          name: user['name'],
          email: user['email'],
          createdAt: user['created_at'],
        ),
        status: 1,
      );
    }
  }

  // Authentication methods
  Future<bool> login(String email, String password, bool checked) async {
    final prefs = await SharedPreferences.getInstance();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.login}',
        'POST',
        {
          'email': email.trim(),
          'password': password.trim(),
        },
        _token ?? '');

    if (result['success']) {
      // ── [LOGIN API RESPONSE] ─────────────────────────────────────────────
      log('');
      log('[LOGIN API RESPONSE]');
      log('RAW RESPONSE: ${result['data']}');

      // ── [LOGIN TOKEN PARSE] ──────────────────────────────────────────────
      _token = result['data']['token']?.toString();
      log('');
      log('[LOGIN TOKEN PARSE]');
      log('PARSED TOKEN : $_token');
      log('TOKEN IS NULL: ${_token == null}');
      log('TOKEN LENGTH : ${_token?.length ?? 0}');

      // Always save token to SharedPreferences so downstream API calls
      // (e.g. hotel checkout) can read it via setToken().
      // Remember Me only controls whether to persist email for next login.
      bool tokenSaveSuccess = false;
      try {
        await saveToken(_token ?? '');
        tokenSaveSuccess = true;
      } catch (e) {
        log('[TOKEN SAVE DEBUG] SAVE EXCEPTION: $e');
      }

      if (checked) {
        await prefs.setBool('remember_me', true);
        await prefs.setString('email', email);
      } else {
        await prefs.setBool('remember_me', false);
        await prefs.remove('email');
        await prefs.remove('password');
      }

      // ── [LOGIN TOKEN SAVE DEBUG] ─────────────────────────────────────────
      log('');
      log('[LOGIN TOKEN SAVE DEBUG]');
      log('TOKEN KEY    : userToken');
      log('TOKEN VALUE  : $_token');
      log('TOKEN IS NULL: ${_token == null || _token!.isEmpty}');
      log('TOKEN LENGTH : ${_token?.length ?? 0}');
      log('SAVE SUCCESS : $tokenSaveSuccess');

      // Build profile from login response user data
      _buildProfileFromResponse(result['data']);

      final user = result['data']['user'];
      debugPrint('════════════════════════════════════════');
      debugPrint('✅ LOGIN SUCCESS');
      debugPrint('Token    : $_token');
      debugPrint('Message  : ${result['data']['message']}');
      debugPrint('User ID  : ${user?['id']}');
      debugPrint('Name     : ${user?['name']}');
      debugPrint('Email    : ${user?['email']}');
      debugPrint('Type     : ${user?['user_type']}');
      debugPrint('Created  : ${user?['created_at']}');
      debugPrint('════════════════════════════════════════');

      notifyListeners();
      return true;
    } else {
      log('❌ LOGIN FAILED: ${result['message']}');
      showErrorToast(result['message']);
      return false;
    }
  }

  Future<bool> signup(
      {String? email,
      String? password,
      String? passwordConfirmation,
      String? firstName,
      String? lastName,
      String? phoneNo}) async {
    // Combine first + last name into single 'name' field for new API
    final name = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    Map<String, dynamic> userData = {
      'name': name,
      'email': email ?? '',
      'password': password ?? '',
      'password_confirmation': passwordConfirmation ?? password ?? '',
    };

    print("══════════════════════════════════════");
    print("📤 SIGNUP API REQUEST");
    print("URL      : /api/auth/register");
    print("BODY     : {");
    print("  name: $firstName");
    print("  email: $email");
    print("  password: $password");
    print("  password_confirmation: $passwordConfirmation");
    print("}");
    print("══════════════════════════════════════");

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.signup}', 'POST', userData, _token ?? '');

    log("message===result['success']===${result['success']}");
    if (result['success']) {
      _token = result['data']['token'];
      await saveToken(_token ?? '');
      AppSnackbar.success('Account created successfully');
      // Build profile from signup response user data
      _buildProfileFromResponse(result['data']);

      final user = result['data']['user'];
      debugPrint('════════════════════════════════════════');
      debugPrint('✅ SIGNUP SUCCESS');
      debugPrint('Token    : $_token');
      debugPrint('Message  : ${result['data']['message']}');
      debugPrint('User ID  : ${user?['id']}');
      debugPrint('Name     : ${user?['name']}');
      debugPrint('Email    : ${user?['email']}');
      debugPrint('Type     : ${user?['user_type']}');
      debugPrint('Created  : ${user?['created_at']}');
      debugPrint('════════════════════════════════════════');

      notifyListeners();
      return true;
    } else {
      print("══════════════════════════════════════");
      print("❌ SIGNUP API FAILED");
      print("STATUS   : ${result['statusCode']}");
      print("MESSAGE  : ${result['message']}");
      print("RESPONSE : ${result['data']}");
      print("══════════════════════════════════════");

      debugPrint('════════════════════════════════════════');
      debugPrint('❌ SIGNUP FAILED (Debug logs above)');
      debugPrint('════════════════════════════════════════');
      AppSnackbar.error(
          result['message'] ?? 'Registration failed. Please try again.');
      return false;
    }
  }

  // OTP verification — currently not used in signup flow, kept for forgot-password flow
  Future<bool> verifyOtp(String email, String otp) async {
    _token = await setToken();
    final result = await makeRequest('${ApiUrls.baseUrl}${ApiUrls.verifyOtp}',
        'POST', {'email': email, 'otp': otp}, _token ?? '',
        requiresAuth: true);

    if (result['success']) {
      _token = result['data']['token'];
      await saveToken(_token ?? '');
      await getMe();
      notifyListeners();
      return true;
    } else {
      showErrorToast(result['message']);
      return false;
    }
  }

  Future<void> getMe() async {
    // log("get me");
    _token = await setToken();

    // var headers = {
    //   'Accept': 'application/json',
    //   'Authorization': "Bearer $_token"
    // };
    // var request =
    //     MultipartRequest('GET', Uri.parse('https://moonbnd.app/api/auth/me'));

    // request.headers.addAll(headers);

    // StreamedResponse response = await request.send();

    // if (response.statusCode == 200) {
    //   log(await response.stream.bytesToString());
    // } else {
    //   log(response.reasonPhrase.toString());
    // }

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.getMe}', 'GET', {}, _token ?? '',
        requiresAuth: true);

    if (result['success'] && result['data'] != null) {
      try {
        _userProfile = MyProfile.fromJson(result['data']);
      } catch (e) {
        log('[getMe] Failed to parse profile: $e');
      }
    } else {
      log('[getMe] API failed or returned null data');
    }

    notifyListeners();
  }

  Future<bool> updateProfile(
      {String firstName = "",
      String lastName = "",
      String phone = "",
      String birthday = "",
      String city = "",
      String aboutYourself = "",
      String state = "",
      String country = "",
      String zipCode = "",
      String bio = "",
      String address = "",
      String address2 = ""}) async {
    _token = await setToken();
    Map<String, String> profileData = {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'about_yourself': bio,
      'birthday': birthday,
      'city': city,
      'state': state,
      'country': country,
      'zip_code': zipCode,
      'address_line_1': address,
      'address_line_2': address2
    };
    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.updateProfile}',
        'POST',
        profileData,
        _token ?? '',
        requiresAuth: true);

    if (result['success']) {
      showSuccessToast("Profile updated successfully!");
      await getMe();
      notifyListeners();
      return true;
    } else {
      showErrorToast(result['message']);
      notifyListeners();
      return false;
    }
  }

  // OTP resend — currently not used in signup flow, kept for forgot-password flow
  Future<bool> resendOtp(String email) async {
    _token = await setToken();
    final result = await makeRequest('${ApiUrls.baseUrl}${ApiUrls.resendOtp}',
        'POST', {'email': email}, _token ?? '',
        requiresAuth: true);

    if (result['success']) {
      showSuccessToast(result['data']['message']);
      notifyListeners();
      return true;
    } else {
      showErrorToast(result['message']);
      return false;
    }
  }

  Future<bool> changeProfilePic(String imagePicture) async {
    _token = await setToken();
    var headers = {
      'Accept': 'application/json',
      'Accept-Language': gettt.Get.locale?.languageCode == "en" ? "en" : "ar",
      'Authorization': 'Bearer $_token'
    };
    var request = MultipartRequest(
        'POST', Uri.parse('${ApiUrls.baseUrl}${ApiUrls.updateProfilePicture}'));
    request.fields.addAll({'type': 'image'});
    request.files.add(await MultipartFile.fromPath('file', imagePicture));
    request.headers.addAll(headers);

    StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      await getMe();
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  Future<bool> deleteMyAccount() async {
    _token = await setToken();
    log("Token being sent: ${_token ?? 'NO TOKEN'}"); // Debug log

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.deleteAccount}', 'POST', {}, _token ?? '',
        requiresAuth: true);

    log("Delete account response: $result"); // Debug log

    if (result['success']) {
      showSuccessToast(result['data']['message']);

      // Additional cleanup if needed
      // Clear local state and token equivalent to logout
      await logoutState();
      return true;
    } else {
      log("result${result}");

      showErrorToast(result['message']);
      return false;
    }
  }

  Future<void> logoutState() async {
    _token = null;
    _userProfile = null;
    final prefs = await SharedPreferences.getInstance();
    // Remove only token-related and remember me data
    await prefs.remove('userToken');
    await prefs.remove('remember_me');
    await prefs.remove('email');
    // Password is never stored, so no need to remove it
    // DO NOT clear 'has_launched_before' - user should not see splash again after logout
    notifyListeners();
  }

  Future<bool> resetpassowrd(
      String newPassword, String confirmpassword, String email) async {
    _token = await setToken();
    log(confirmpassword);
    log(_token ?? "no token");
    log(newPassword);
    final result = await makeRequest(
      '${ApiUrls.baseUrl}${ApiUrls.resetPassword}',
      'POST',
      {
        'email': email,
        'new_password': confirmpassword,
        'new_password_confirmation': newPassword,
      },
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      log("$result");
      showSuccessToast(result["data"]['message']);
      notifyListeners();
      return true;
    } else {
      showErrorToast(result['message']);
      return false;
    }
  }

  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    _token = await setToken();
    log(currentPassword);
    log(_token ?? "no token");
    log(newPassword);
    final result = await makeRequest(
      '${ApiUrls.baseUrl}${ApiUrls.changePassword}',
      'POST',
      {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      log("$result");
      showSuccessToast(result["data"]['message']);
      notifyListeners();
      return true;
    } else {
      showErrorToast(result['message']);
      return false;
    }
  }
}
