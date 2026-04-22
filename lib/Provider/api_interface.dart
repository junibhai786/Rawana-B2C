import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moonbnd/widgets/app_snackbar.dart';

Future<Map<String, dynamic>> makeRequest(
    String url, String method, Map<String, dynamic> body, String token,
    {bool requiresAuth = false}) async {
  try {
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (requiresAuth) {
      headers['Authorization'] = 'Bearer $token';
    }
    headers['Accept-Language'] = Get.locale?.languageCode == "en" ? "en" : "ar";

    print("══════════════════════════════════════");
    print("🌐 API CALL START");
    print("URL     : $url");
    print("METHOD  : $method");
    print("HEADERS SENT: $headers");
    print("BODY    : ${json.encode(body)}");
    print("══════════════════════════════════════");

    var request = Request(method, Uri.parse(url));

    request.headers.addAll(headers);
    if (body.isNotEmpty) {
      request.body = json.encode(body);
    }

    StreamedResponse response =
        await request.send().timeout(Duration(seconds: 120));
    final responseBody = await response.stream.bytesToString();

    print("══════════════════════════════════════");
    print("📥 API RESPONSE");
    print("STATUS  : ${response.statusCode}");
    print("HEADERS : ${response.headers}");
    print("BODY    : $responseBody");
    print("══════════════════════════════════════");

    if (response.statusCode == 302) {
      print("⚠️ REDIRECT DETECTED");
      print("➡️ LOCATION: ${response.headers['location']}");
    }

    // Check for non-success status codes before attempting JSON decode
    if (response.statusCode != 200 && response.statusCode != 201) {
      log('[makeRequest] HTTP Error ${response.statusCode} for $url');
      // Try to extract error message from JSON, but handle HTML responses
      String errorMessage = 'HTTP ${response.statusCode}';

      // Special handling for 302 (redirect) - typically means auth failure
      if (response.statusCode == 302) {
        errorMessage = 'Invalid email or password. Please try again (Redirect)'.tr;
      } else {
        try {
          final errorData = json.decode(responseBody);
          if (errorData is Map && errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          }
        } catch (_) {
          // Response is not JSON (likely HTML error page)
          if (response.statusCode == 404) {
            errorMessage = 'Resource not found (404). Check API route.';
          } else if (response.statusCode == 401 || response.statusCode == 403) {
            errorMessage = 'Invalid email or password. Please try again.';
          } else {
            errorMessage = 'Server error (${response.statusCode})';
          }
        }
      }
      log('[makeRequest] Error: $errorMessage');
      return {
        'success': false,
        'message': errorMessage,
        'statusCode': response.statusCode,
        'data': responseBody
      };
    }

    // Verify response is valid JSON before decoding
    final contentType = response.headers['content-type'] ?? '';
    if (responseBody.trimLeft().startsWith('<')) {
      log('[makeRequest] Received HTML instead of JSON from $url');
      return {
        'success': false,
        'message': 'Server returned HTML instead of JSON'
      };
    }

    dynamic responseData;
    try {
      responseData = json.decode(responseBody);
    } catch (e) {
      log('[makeRequest] Failed to parse JSON response: $e');
      return {
        'success': false,
        'message': 'Invalid JSON response from server',
        'statusCode': response.statusCode,
        'data': responseBody
      };
    }

    log("${response.statusCode} statuscode");
    return {
      'success': true,
      'data': responseData,
      'statusCode': response.statusCode
    };
  } catch (e) {
    log('[makeRequest] Exception: $e');
    return {'success': false, 'message': 'Network error: ${e.toString()}'};
  }
}

Future<Map<String, dynamic>> makeMultipartRequest(
    String url, String method, Map<String, String> body, String token,
    {bool requiresAuth = false}) async {
  try {
    var headers = {'Content-Type': 'application/json'};
    headers['Accept-Language'] = Get.locale?.languageCode == "en" ? "en" : "ar";
    if (requiresAuth) {
      headers['Authorization'] = 'Bearer $token';
    }

    var request = MultipartRequest(method, Uri.parse(url));

    log(url);
    log(json.encode(body));
    request.headers.addAll(headers);
    if (body.isNotEmpty) {
      request.fields.addAll(body);
    }

    StreamedResponse response =
        await request.send().timeout(Duration(seconds: 60));
    final responseBody = await response.stream.bytesToString();
    final responseData = json.decode(responseBody);

    log("${response.statusCode} statuscode");

    if (response.statusCode == 200) {
      return {'success': true, 'data': responseData};
    } else {
      log("$responseData respine check");
      return {'success': false, 'message': responseData['message']};
    }
  } catch (e) {
    log("Error ---- ${e.toString()}");
    return {'success': false, 'message': 'An error occurred'};
  }
}

// Helper methods
Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('userToken', token);
}

Future<String> setToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("userToken");
  return token ?? "";
}

void showErrorToast(String message) {
  AppSnackbar.error(message);
}

void showSuccessToast(String message) {
  AppSnackbar.success(message);
}
