import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>> makeRequest(
    String url, String method, Map<String, dynamic> body, String token,
    {bool requiresAuth = false}) async {
  try {
    var headers = {'Content-Type': 'application/json'};
    if (requiresAuth) {
      headers['Authorization'] = 'Bearer $token';
    }
    headers['Accept-Language'] = Get.locale?.languageCode == "en" ? "en" : "ar";

    var request = Request(method, Uri.parse(url));

    log(url);
    log(json.encode(body));
    request.headers.addAll(headers);
    if (body.isNotEmpty) {
      request.body = json.encode(body);
    }

    StreamedResponse response =
        await request.send().timeout(Duration(seconds: 120));
    final responseBody = await response.stream.bytesToString();
    log('responseBody123: $responseBody'.toString());
    final responseData = json.decode(responseBody);

    if (response.statusCode == 200 || response.statusCode == 201) {
      log("${response.statusCode} statuscode");
      return {
        'success': true,
        'data': responseData,
      };
    } else {
      log("$responseData respine check");
      return {'success': false, 'message': responseData['message']};
    }
  } catch (e) {
    return {'success': false, 'message': 'An error occurred'};
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
  EasyLoading.showToast(message, maskType: EasyLoadingMaskType.black);
}

void showSuccessToast(String message) {
  EasyLoading.showToast(message, maskType: EasyLoadingMaskType.black);
}
