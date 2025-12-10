import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Urls/url_holder_loan.dart';
import 'package:moonbnd/modals/my_profile.dart';
import 'package:get/get.dart' as gettt;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  MyProfile? _userProfile;
  // Getter for user profile
  MyProfile? get myProfile => _userProfile;

  // Authentication methods
  Future<bool> login(String email, String password, bool checked) async {
    final prefs = await SharedPreferences.getInstance();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.login}',
        'POST',
        {
          'email': email.trim(),
          'password': password.trim(),
          'device_name': 'mobile',
        },
        _token ?? '');
    if (checked) {
      prefs.setBool('remember_me', checked);
      prefs.setString('email', email);
      prefs.setString('password', password);
    }

    if (result['success']) {
      _token = result['data']['access_token'];
      await saveToken(_token ?? '');
      notifyListeners();
      return true;
    } else {
      showErrorToast(result['message']);
      return false;
    }
  }

  Future<bool> signup(
      {String? email,
      String? password,
      String? firstName,
      String? lastName,
      String? phoneNo}) async {
    Map<String, dynamic> userData = {
      'first_name': firstName ?? '',
      'last_name': lastName ?? '',
      'email': email ?? '',
      'phone': phoneNo ?? '',
      'password': password ?? '',
      // 'term': 1,
    };
    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.signup}', 'POST', userData, _token ?? '');

    log("message===result['success']===${result['success']}");
    if (result['success']) {
      _token = result['data']['access_token'];
      await saveToken(_token ?? '');
      showSuccessToast(result['data']['message']);
      notifyListeners();
      return true;
    } else {
      showErrorToast(result['message']);
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    _token = await setToken();
    final result = await makeRequest('${ApiUrls.baseUrl}${ApiUrls.verifyOtp}',
        'POST', {'email': email, 'otp': otp}, _token ?? '',
        requiresAuth: true);

    if (result['success']) {
      _token = result['data']['access_token'];
      await saveToken(_token ?? '');
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

    _userProfile = MyProfile.fromJson(result['data']);

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
    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.deleteAccount}', 'POST', {}, _token ?? '',
        requiresAuth: true);

    if (result['success']) {
      showSuccessToast(result['data']['message']);

      // Additional cleanup if needed
      return true;
    } else {
      log("result${result}");

      showErrorToast(result['message']);
      return false;
    }
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
