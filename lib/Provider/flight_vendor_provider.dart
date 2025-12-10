import 'dart:convert';
import 'dart:developer';

import 'package:moonbnd/modals/all_flight_vendor_model.dart';
import 'package:moonbnd/modals/flight_airline_model.dart';
import 'package:moonbnd/modals/flight_airport_vendor_model.dart';
import 'package:moonbnd/modals/flight_detail_vendor_model.dart';
import 'package:moonbnd/modals/hotel_property_type_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonbnd/Provider/api_interface.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart' as gettt;
import 'package:moonbnd/Urls/url_holder_loan.dart';
import 'package:moonbnd/modals/my_profile.dart';
import 'package:http/http.dart';

import 'package:shared_preferences/shared_preferences.dart';

class VendorFlightProvider with ChangeNotifier {
  String? _token;
  MyProfile? _userProfile;
  // Getter for user profile
  MyProfile? get myProfile => _userProfile;

  bool isShowPassword = true;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('userToken');
    log("$_token");
  }

  // New function to toggle password visibility
  void togglePasswordVisibility() {
    isShowPassword = !isShowPassword;
    notifyListeners();
  }

  // New function to update terms and privacy checkbox
  /*void updateTermsAndPrivacyCheckbox(bool value) {
    termsAndPrivacyCheckbox = value;
    notifyListeners();
  }*/
  DateTime? selectedDepartureDateTime;
  DateTime? selectedArrivalDateTime;

  void setSelectedDepartureDateTime(DateTime dateTime) {
    selectedDepartureDateTime = dateTime;
    notifyListeners();
  }

  void setSelectedArrivalDateTime(DateTime dateTime) {
    selectedArrivalDateTime = dateTime;
    notifyListeners();
  }

  // Clear method to reset dates during initialization
  void clearDateTimes() {
    selectedDepartureDateTime = null;
    selectedArrivalDateTime = null;
  }

  TextEditingController titlecontroller = TextEditingController();
  TextEditingController contentcontroller = TextEditingController();

  TextEditingController departureTime = TextEditingController();

  TextEditingController arrivalcontroller = TextEditingController();
  void resetAllFields() {
    titlecontroller.clear();
    contentcontroller.clear();
    selectpassanger = null;
    flightairportfromids = null;
    flightairporttoids = null;
    flightairlineids = null;
    selectedDepartureDateTime = null;
    selectedArrivalDateTime = null;
    selectedFlighttypeIds.clear();
    selectedservicetypeIds.clear();
    notifyListeners();
  }

  String? Content;
  String? title;
  String? selectpassanger;

  List<int> selectedFlighttypeIds = [];

  HotelPropertyTypeModel? propertylist;
  HotelPropertyTypeModel? propertylists;

  HotelPropertyTypeModel? flighttypelist;
  HotelPropertyTypeModel? flighttypelists;

  FlightAirLineVendorModel? flightairlinelist;
  FlightAirLineVendorModel? flightairlinelists;

  FlightAirportVendorModel? flightairportlist;
  FlightAirportVendorModel? flightairportlists;

  AllFlightVendorModel? flight;
  AllFlightVendorModel? flights;

  FlightDetailVendorModel? flightlistdetail;
  FlightDetailVendorModel? flightlistdetails;

  HotelPropertyTypeModel? facility;
  HotelPropertyTypeModel? facilities;

  HotelPropertyTypeModel? service;
  HotelPropertyTypeModel? services;
  List<int> selectedservicetypeIds = [];

  String? flightairlineid;
  String? flightairlineids;
  String? flightairporttoid;
  String? flightairporttoids;
  String? flightairportfromid;
  String? flightairportfromids;

  Future<bool> addNewFlightVendor() async {
    await loadToken();

    // Ensure all values in the `body` map are strings
    final body = {
      'title': titlecontroller.text,
      'code': contentcontroller.text,
      'airport_from': flightairportfromids ?? '',
      'airport_to': flightairporttoids ?? "",
      'airline_id': flightairlineids ?? "",
      'status': 'publish',
      'arrival_time': selectedArrivalDateTime.toString(),
      'departure_time': selectedDepartureDateTime.toString(),
      "terms":
          "${selectedFlighttypeIds.map((id) => id.toString()).join(',')},${selectedservicetypeIds.map((id) => id.toString()).join(',')},${selectedservicetypeIds.map((id) => id.toString()).join(',')}",
    };

    var uri = Uri.parse('${ApiUrls.baseUrl}${ApiUrls.vendoraddflight}');

    // Create a multipart request
    var request = await MultipartRequest(
      'POST',
      uri,
    );

    // Add headers
    request.headers.addAll({
      'Accept': 'application/json',
      'Accept-Language': gettt.Get.locale?.languageCode == "en" ? "en" : "ar",
      'Authorization': 'Bearer $_token',
    });

    // Add fields
    request.fields.addAll(body);

    // Send the request
    var streamedResponse = await request.send();
    var result = await Response.fromStream(streamedResponse);

    log('Verification Upload request: $body');

    if (result.statusCode == 200 || result.statusCode == 201) {
      var jsonResponse = json.decode(result.body);
      log('Verification Upload Response: $jsonResponse');
      showErrorToast(json.decode(result.body)['message']);
      notifyListeners();

      // Dispose of all controllers after successful API call
      /* disposeControllers(); */ // Call the method to dispose controllers
      return true;
    } else {
      showErrorToast(json.decode(result.body)['message']);
      log('Failed to upload verification image. Status code: ${result.statusCode}');
      log('Response body: ${result.body}');
      return false;
    }
  }

  Future<bool> UpdateFlightVendor(ids) async {
    await loadToken();

    // Ensure all values in the `body` map are strings
    final body = {
      'flight_id': ids.toString(),
      'title': titlecontroller.text,
      'code': contentcontroller.text,
      'airport_from': flightairportfromids ?? '',
      'airport_to': flightairporttoids ?? "",
      'airline_id': flightairlineids ?? "",
      'status': 'publish',
      'arrival_time': selectedArrivalDateTime.toString(),
      'departure_time': selectedDepartureDateTime.toString(),
      "terms":
          "${selectedFlighttypeIds.map((id) => id.toString()).join(',')},${selectedservicetypeIds.map((id) => id.toString()).join(',')},}",
    };

    var uri = Uri.parse('${ApiUrls.baseUrl}${ApiUrls.vendorupdateflight}');

    // Create a multipart request
    var request = await MultipartRequest(
      'POST',
      uri,
    );

    // Add headers
    request.headers.addAll({
      'Accept': 'application/json',
      'Accept-Language': gettt.Get.locale?.languageCode == "en" ? "en" : "ar",
      'Authorization': 'Bearer $_token',
    });

    // Add fields
    request.fields.addAll(body);

    // Send the request
    var streamedResponse = await request.send();
    var result = await Response.fromStream(streamedResponse);

    log('Verification Upload request: $body');

    if (result.statusCode == 200 || result.statusCode == 201) {
      var jsonResponse = json.decode(result.body);
      log('Verification Upload Response: $jsonResponse');
      showErrorToast(json.decode(result.body)['message']);
      notifyListeners();

      // Dispose of all controllers after successful API call
      /* disposeControllers(); */ // Call the method to dispose controllers
      return true;
    } else {
      showErrorToast(json.decode(result.body)['message']);
      log('Failed to upload verification image. Status code: ${result.statusCode}');
      log('Response body: ${result.body}');
      showErrorToast(json.decode(result.body)['message']);
      return false;
    }
  }

// Method to dispose of all controllers
  void disposeControllers() {
    titlecontroller.dispose();
    contentcontroller.dispose();
    departureTime.dispose();
    arrivalcontroller.dispose();

    // Dispose of any other controllers as needed
  }

  Future<bool> cloneflightvendor({
    required String id,
  }) async {
    await loadToken();

    final body = {
      'flight_id': id,
    };

    // Add review stats to the body

    log("$body bodycheck");
    log("${ApiUrls.baseUrl}${ApiUrls.cloneflightvendor} bodycheck");

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.cloneflightvendor}',
      'POST',
      body,
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      EasyLoading.showToast("Flight cloned successfully !".tr,
          maskType: EasyLoadingMaskType.black);

      return true;
    } else {
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);

      return false;
    }
  }

  Future<bool> deleteflightvendor({
    required String id,
  }) async {
    await loadToken();

    final body = {
      'flight_id': id,
    };

    // Add review stats to the body

    log("$body bodycheck");
    log("${ApiUrls.baseUrl}${ApiUrls.vendordeleteflight} bodycheck");

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.vendordeleteflight}',
      'POST',
      body,
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      log("delete submitted successfully: ${result['data']}");
      EasyLoading.showToast("Flight delete successfully !".tr,
          maskType: EasyLoadingMaskType.black);
      return true;
    } else {
      log("Failed to submit review. Error: ${result['message']}");
      return false;
    }
  }

  Future<bool> publishflightvendor({
    required String id,
  }) async {
    await loadToken();

    final body = {
      'hotel_id': id,
    };

    // Add review stats to the body

    /* log("$body bodycheck");*/
    log("${ApiUrls.baseUrl}${ApiUrls.vendorpublishflight} bodycheck");

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.vendorpublishflight}/$id',
      'POST',
      body,
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      log("delete submitted successfully: ${result['data']}");

      return true;
    } else {
      log("Failed to submit review. Error: ${result['message']}");
      return false;
    }
  }

  Future<bool> hideflightvendor({
    required String id,
  }) async {
    await loadToken();

    final body = {
      'hotel_id': id,
    };

    // Add review stats to the body

    /* log("$body bodycheck");*/
    log("${ApiUrls.baseUrl}${ApiUrls.vendorhideflight} bodycheck");

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.vendorhideflight}/$id',
      'POST',
      body,
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      log("delete submitted successfully: ${result['data']}");

      return true;
    } else {
      log("Failed to submit review. Error: ${result['message']}");
      return false;
    }
  }

  Future fetchallflightvendor() async {
    log("Fetching All Flight Vendor: ${ApiUrls.baseUrl}${ApiUrls.vendorallflight}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.vendorallflight}', 'GET', {}, _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("Car Details Response: ${result['data']}");
      flight = AllFlightVendorModel.fromJson(result['data']);

      log(" response of hotellist = ${flight?.data} ");
      flights = flight;
      notifyListeners();
    } else {
      log("Failed to fetch hotel details. Error: ${result['message']}");
      return null;
    }
  }

  Future fetchallflightdetailvendor(id) async {
    log("Fetching All Flight Detail Vendor: ${ApiUrls.baseUrl}${ApiUrls.vendorflightdetails}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.vendorflightdetails}/${id}',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("Car Details Response: ${result['data']}");
      flightlistdetail = FlightDetailVendorModel.fromJson(result['data']);

      log(" response of hotellist = ${flightlistdetail?.data} ");
      flightlistdetails = flightlistdetail;
      notifyListeners();
      return flightlistdetail?.data;
    } else {
      log("Failed to fetch hotel details. Error: ${result['message']}");
      return null;
    }
  }

  Future flighttypevendor() async {
    log("Fetching Hotel property Details for ID: ${ApiUrls.baseUrl}${ApiUrls.vendorflighttype}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.vendorflighttype}',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("property type  Response: ${result['data']}");
      flighttypelist = HotelPropertyTypeModel.fromJson(result['data']);

      log(" response of hotellist = ${flighttypelist?.data} ");
      flighttypelists = flighttypelist;
      notifyListeners();
    } else {
      log("Failed to fetch property type . Error: ${result['message']}");
      return null;
    }
  }

  Future flightairlinevendor() async {
    log("Fetching Hotel property Details for ID: ${ApiUrls.baseUrl}${ApiUrls.vendorflightairline}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.vendorflightairline}',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("property type  Response: ${result['data']}");
      flightairlinelist = FlightAirLineVendorModel.fromJson(result['data']);

      log(" response of hotellist = ${flightairlinelist?.data} ");
      flightairlinelists = flightairlinelist;
      notifyListeners();
    } else {
      log("Failed to fetch property type . Error: ${result['message']}");
      return null;
    }
  }

  Future flightairportvendor() async {
    log("Fetching Hotel property Details for ID: ${ApiUrls.baseUrl}${ApiUrls.vendorflightairport}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.vendorflightairport}',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("flight type  Response: ${result['data']}");
      flightairportlist = FlightAirportVendorModel.fromJson(result['data']);

      log(" response of hotellist = ${flightairportlist?.data} ");
      flightairportlists = flightairportlist;
      notifyListeners();
    } else {
      log("Failed to fetch flight type . Error: ${result['message']}");
      return null;
    }
  }

  Future servicestypeflightvendor() async {
    log("Fetching Hotel facility Details for ID: ${ApiUrls.baseUrl}${ApiUrls.vendorflightservice}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.vendorflightservice}',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("service type  Response: ${result['data']}");
      service = HotelPropertyTypeModel.fromJson(result['data']);

      log(" response of service = ${service?.data} ");
      services = service;
      notifyListeners();
    } else {
      log("Failed to fetch service type . Error: ${result['message']}");
      return null;
    }
  }

  // Cleanup method
  /* void dispose() {
    firstnamecontroller.dispose();
    lastNameInputController.dispose();
    businessNameInputController.dispose();
    emailInputController.dispose();
    mobileNumberInputController.dispose();
    passwordInputController.dispose();
    titlecontroller.dispose();
    super.dispose();
  }*/
}
