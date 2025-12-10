import 'dart:developer';
import 'dart:convert';
import 'dart:io';
import 'package:moonbnd/modals/boat_vendor_details_model.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:html_editor_plus/html_editor.dart';

import 'package:http/http.dart';

import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Urls/url_holder_loan.dart';
import 'package:moonbnd/modals/add_tour_location_model.dart';
import 'package:moonbnd/modals/all_boat_vendor_model.dart';
import 'package:moonbnd/modals/boat_amenities_model.dart';
import 'package:get/get.dart' as gettt;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VendorBoatProvider with ChangeNotifier {
  AllBoatVendorModel? boatlist;
  AllBoatVendorModel? boatlists;
  String? _token;

  BoatAmenitiesVendorModel? boatamenities;
  BoatAmenitiesVendorModel? boatamenitiess;

  BoatAmenitiesVendorModel? boattypes;
  BoatAmenitiesVendorModel? boattypess;

  AddTourLocationModel? addtourlocation;
  AddTourLocationModel? addtourlocations;

  BoatVendorDetailModel? boatlistdetail;
  BoatVendorDetailModel? boatlistdetails;

  String? locationids;
  String? locationid;
  String? mapLat;
  String? mapLng;
  String? mapZoom;

  List<int> selectedboattypeIds = [];
  List<int> selectedboatamenityIds = [];

  TextEditingController locationcontroller = TextEditingController();
  TextEditingController locationidcontroller = TextEditingController();
  TextEditingController addresscontroller = TextEditingController();

  // Form Controllers
  TextEditingController titleController = TextEditingController();

  TextEditingController youtubeVideoController = TextEditingController();
  TextEditingController guestController = TextEditingController();
  TextEditingController cabinController = TextEditingController();
  TextEditingController cancelPolicyController = TextEditingController();
  TextEditingController lengthController = TextEditingController();
  TextEditingController speedController = TextEditingController();
  TextEditingController minimumDayStayController = TextEditingController();
  HtmlEditorController contentController = HtmlEditorController();
  TextEditingController additionalTermsController = TextEditingController();

  // Image Data
  XFile? bannerImage;
  XFile? featuredImage;
  List<XFile> galleryImages = [];

  // Lists for dynamic form fields
  List<FaqClass> faqList = [];
  List<SpecClass> specsList = [];
  List<TitleClass> includeList = [];
  List<TitleClass> excludeList = [];

  // Add new controllers for pricing screen
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  TextEditingController pricePerHourController = TextEditingController();
  TextEditingController pricePerDayController = TextEditingController();
  TextEditingController minDayBeforeBooking = TextEditingController();

  // Add pricing related variables
  String defaultState = "Always available";
  String defaultStateInput =
      "0"; // "0" for Always available, "1" for specific dates
  bool enableExtraPrice = false;
  List<ExtraPriceForVendor> extraPriceBoatVendorList = [];

  void clear() {
    // Form Controllers
    titleController = TextEditingController();

    youtubeVideoController = TextEditingController();
    guestController = TextEditingController();
    cabinController = TextEditingController();
    locationcontroller = TextEditingController();
    locationidcontroller = TextEditingController();
    addresscontroller = TextEditingController();
    cancelPolicyController = TextEditingController();
    lengthController = TextEditingController();
    speedController = TextEditingController();
    minimumDayStayController = TextEditingController();
    contentController = HtmlEditorController();
    additionalTermsController = TextEditingController();
    boatamenities?.data = [];
    boatamenities?.data = [];
    // Image Data
    bannerImage = null;
    featuredImage = null;
    galleryImages = [];
    locationids = null;
    locationid = null;
    mapLat = null;
    mapLng = null;
    mapZoom = null;

    // Lists for dynamic form fields
    faqList = [];
    specsList = [];
    includeList = [];
    excludeList = [];

    // Add new controllers for pricing screen
    startTimeController = TextEditingController();
    endTimeController = TextEditingController();
    pricePerHourController = TextEditingController();
    pricePerDayController = TextEditingController();
    minDayBeforeBooking = TextEditingController();

    // Add pricing related variables
    defaultState = "Always available";
    defaultStateInput = "0"; // "0" for Always available, "1" for specific dates
    enableExtraPrice = false;
    extraPriceBoatVendorList = [];

    notifyListeners();
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('userToken');
    log("$_token");
  }

  Future fetchallboatvendor() async {
    log("Fetching Boat Details for ID: ${ApiUrls.baseUrl}${ApiUrls.vendorallboat}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.vendorallboat}', 'GET', {}, _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("Boat Details Response: ${result['data']}");
      boatlist = AllBoatVendorModel.fromJson(result['data']);

      log(" response of boatlist = ${boatlist?.data} ");
      boatlists = boatlist;
      notifyListeners();
    } else {
      log("Failed to fetch boat details. Error: ${result['message']}");
      return null;
    }
  }

  Future<bool> deleteboatvendor({
    required String id,
  }) async {
    await loadToken();

    final body = {
      'boat_id': id,
    };
    log("$body bodycheck");
    log("${ApiUrls.baseUrl}${ApiUrls.vendordeleteboat} ");

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.vendordeleteboat}',
      'POST',
      body,
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      log("delete submitted successfully: ${result['data']}");
      EasyLoading.showToast("Boat delete successfully !".tr,
          maskType: EasyLoadingMaskType.black);
      return true;
    } else {
      log("Failed to submit review. Error: ${result['message']}");
      return false;
    }
  }

  Future<bool> cloneboatvendor({
    required String id,
  }) async {
    await loadToken();

    final body = {
      'boat_id': id,
    };

    log("$body bodycheck");
    log("${ApiUrls.baseUrl}${ApiUrls.clonetourvendor} bodycheck");

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.cloneboatvendor}',
      'POST',
      body,
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      EasyLoading.showToast("Boat cloned successfully !".tr,
          maskType: EasyLoadingMaskType.black);

      return true;
    } else {
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);

      return false;
    }
  }

  Future<bool> publishboatvendor({
    required String id,
  }) async {
    await loadToken();

    final body = {
      'boat_id': id,
    };
    log("${ApiUrls.baseUrl}${ApiUrls.vendorboatpublish} bodycheck");

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.vendorboatpublish}/$id',
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

  Future<bool> hideboatvendor({
    required String id,
  }) async {
    await loadToken();

    final body = {
      'boat_id': id,
    };

    log("${ApiUrls.baseUrl}${ApiUrls.vendorboathide} bodycheck");

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.vendorboathide}/$id',
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

  Future boattypetourvendor() async {
    log("Fetching Boat  type for ID: ${ApiUrls.baseUrl}${ApiUrls.vendorboattype}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.vendorboattype}', 'GET', {}, _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("boat type  Response: ${result['data']}");
      boattypes = BoatAmenitiesVendorModel.fromJson(result['data']);

      log(" response of boattype = ${boattypes?.data} ");
      boattypess = boattypes;
      notifyListeners();
    } else {
      log("Failed to fetch travel type . Error: ${result['message']}");
      return null;
    }
  }

  Future boatamenitiesvendor() async {
    log("Fetching Boat Amenities Details for ID: ${ApiUrls.baseUrl}${ApiUrls.vendorboatamenities}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.vendorboatamenities}',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("amenities type  Response: ${result['data']}");
      boatamenities = BoatAmenitiesVendorModel.fromJson(result['data']);

      log(" response of Amenities = ${boatamenities?.data} ");
      boatamenitiess = boatamenities;
      notifyListeners();
    } else {
      log("Failed to fetch Amenities type . Error: ${result['message']}");
      return null;
    }
  }

  Future fetachaddtourlocation() async {
    log("Fetching Boat Details for ID: ${ApiUrls.baseUrl}${ApiUrls.getaddcarlocation}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.getaddtourlocation}',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("Boat Details Response: ${result['data']}");
      addtourlocation = AddTourLocationModel.fromJson(result['data']);

      log("${addtourlocation?.data?.first.name} address");
      addtourlocations = addtourlocation;
      notifyListeners();
    } else {
      log("Failed to fetch hotel details. Error: ${result['message']}");
      return null;
    }
  }

  Future<bool> addBoatVendor({
    required String title,
    required String content,
    required String video,
    File? bannerImage,
    File? featuredImage,
    List<File> galleryImages = const [],
    required String maxGuest,
    required String cabin,
    required String speed,
    required String length,
    required String cancelPolicy,
    required String termsInformation,
    required String defaultState,
    required String minDayBeforeBooking,
    required String startTimeBooking,
    required String endTimeBooking,
    required String pricePerHour,
    required String pricePerDay,
    required String locationId,
    required String address,
    required String mapLat,
    required String mapLng,
    required String mapZoom,
    List<FaqClass> faqList = const [],
    List<Map<String, String>> specs = const [],
    List<Map<String, String>> include = const [],
    List<Map<String, String>> exclude = const [],
    List<ExtraPriceForVendor> extraPriceList = const [],
  }) async {
    await loadToken();

    log("$enableExtraPrice extrapriceprice");

    final body = {
      'title': title,
      'content': content,
      'status': 'publish',
      'video': video,
      'max_guest': maxGuest,
      'cabin': cabin,
      'speed': speed,
      'length': length,
      'cancel_policy': cancelPolicy,
      'terms_information': termsInformation,
      'enable_extra_price': enableExtraPrice ? '1' : '0',
      'default_state': defaultStateInput,
      'min_day_before_booking': minDayBeforeBooking,
      'start_time_booking': startTimeBooking,
      'end_time_booking': endTimeBooking,
      'price_per_hour': pricePerHour,
      'price_per_day': pricePerDay,
      'location_id': locationId,
      'address': address,
      'map_lat': mapLat,
      'map_lng': mapLng,
      'map_zoom': mapZoom,
      'terms':
          "${selectedboattypeIds.map((id) => id.toString()).join(',')},${selectedboatamenityIds.map((id) => id.toString()).join(',')}",
    };

    var uri = Uri.parse('${ApiUrls.baseUrl}${ApiUrls.vendorboatadd}');
    var request = MultipartRequest('POST', uri);

    request.headers.addAll({
      'Accept': 'application/json',
      'Accept-Language': gettt.Get.locale?.languageCode == "en" ? "en" : "ar",
      'Authorization': 'Bearer $_token',
    });

    // Add images
    if (bannerImage != null) {
      request.files
          .add(await MultipartFile.fromPath('banner_image', bannerImage.path));
    }
    if (featuredImage != null) {
      request.files
          .add(await MultipartFile.fromPath('image', featuredImage.path));
    }
    if (galleryImages.isNotEmpty) {
      for (var image in galleryImages) {
        request.files
            .add(await MultipartFile.fromPath('gallery[]', image.path));
      }
    }

    // Add FAQs
    if (faqList.isNotEmpty) {
      List<Map<String, dynamic>> faqJsonList = faqList
          .map((faq) => {
                'title': faq.title?.value.text ?? '',
                'content': faq.content?.value.text ?? '',
              })
          .toList();
      body['faqs'] = jsonEncode(faqJsonList);
    }

    // Add specs
    if (specs.isNotEmpty) {
      body['specs'] = jsonEncode(specs);
    }

    // Add include
    if (include.isNotEmpty) {
      body['include'] = jsonEncode(include);
    }

    // Add exclude
    if (exclude.isNotEmpty) {
      body['exclude'] = jsonEncode(exclude);
    }

    // Add extra prices
    if (enableExtraPrice && extraPriceList.isNotEmpty) {
      List<Map<String, dynamic>> extraPriceJsonList = extraPriceList
          .map((extra) => {
                "name": extra.name?.value.text ?? "",
                "name_ja": extra.name_ja?.value.text ?? "",
                "name_egy": extra.name_egy?.value.text ?? "",
                "price": extra.price?.value.text ?? "",
                // items: ['one_time', 'per_hour', 'per_day']
                "type": extra.type == "one time"
                    ? "one_time"
                    : extra.type == "per hour"
                        ? "per_hour"
                        : "per_day",
                // "per_person": extra.perPerson == true ? "on" : "off",
              })
          .toList();
      body['extra_price'] = jsonEncode(extraPriceJsonList);
    }

    request.fields
        .addAll(body.map((key, value) => MapEntry(key, value.toString())));

    var streamedResponse = await request.send();
    var result = await Response.fromStream(streamedResponse);
    log('Boat Add request: $body bodyyyy');
    log("${result.statusCode} bodyyyy");
    if (result.statusCode == 200 || result.statusCode == 201) {
      var jsonResponse = json.decode(result.body);
      log('Boat Add Response: $jsonResponse');
      showErrorToast(jsonResponse['message']);
      notifyListeners();
      return true;
    } else {
      log("${json.decode(result.body)} bodyyyy");

      showErrorToast(json.decode(result.body)['message']);
      // log('Failed to add boat. Status code: ${result.statusCode}');
      // log('Response body: ${result.body}');
      return false;
    }
  }

  Future fetchallboatdetailvendor(String id) async {
    log("Fetching Boat vendor Details for ID: ${ApiUrls.baseUrl}${ApiUrls.vendorallboatdetails}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.vendorallboatdetails}/$id',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("Boat vendor Details Response: ${result['data']}");
      boatlistdetail = BoatVendorDetailModel.fromJson(result['data']);

      log(" response of boatlistdetails = ${boatlistdetail?.data?.first.title} ");

      boatlistdetails = boatlistdetail;
      notifyListeners();
      return boatlistdetail?.data;
    } else {
      log("Failed to fetch boat vendor details. Error: ${result['message']}");
      return null;
    }
  }

  Future<bool> deleteImage(String imageUrl, String id) async {
    await loadToken();
    const String url = "${ApiUrls.baseUrl}${ApiUrls.vendorBoatDetailForDelete}";

    final response = await post(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        'Accept-Language': gettt.Get.locale?.languageCode == "en" ? "en" : "ar",
        'Authorization': 'Bearer $_token',
      },
      body: {
        'image_url': imageUrl,
        'object_model': "boat",
        'id': id,
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      // Handle error
      log('Failed to delete image. Status code: ${response.statusCode}');
      return false;
    }
  }

  // Methods for managing dynamic lists
  void addFaq() {
    faqList.add(FaqClass(
      id: DateTime.now(),
      content: TextEditingController(),
      title: TextEditingController(),
    ));
    notifyListeners();
  }

  void deleteFaq(DateTime? id) {
    faqList.removeWhere((test) => test.id == id);
    notifyListeners();
  }

  void addSpec() {
    specsList.add(SpecClass(
      id: DateTime.now(),
      content: TextEditingController(),
      title: TextEditingController(),
    ));
    notifyListeners();
  }

  void deleteSpec(DateTime? id) {
    specsList.removeWhere((spec) => spec.id == id);
    notifyListeners();
  }

  void addInclude() {
    includeList.add(TitleClass(
      id: DateTime.now(),
      title: TextEditingController(),
    ));
    notifyListeners();
  }

  void deleteInclude(DateTime? id) {
    includeList.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void addExclude() {
    excludeList.add(TitleClass(
      id: DateTime.now(),
      title: TextEditingController(),
    ));
    notifyListeners();
  }

  void deleteExclude(DateTime? id) {
    excludeList.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // Image picker methods
  Future<void> pickImage({bool featureCheck = false}) async {
    final picker = ImagePicker();
    final images = await picker.pickImage(source: ImageSource.gallery);

    if (images != null) {
      if (featureCheck) {
        featuredImage = images;
      } else {
        bannerImage = images;
      }
      notifyListeners();
    }
  }

  Future<void> pickGalleryImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();

    // ignore: unnecessary_null_comparison
    if (images != null) {
      galleryImages.addAll(images);
      notifyListeners();
    }
  }

  // Method to add extra price
  void addExtraPrice() {
    extraPriceBoatVendorList.add(ExtraPriceForVendor(
        id: DateTime.now(),
        name: TextEditingController(),
        name_egy: TextEditingController(),
        name_ja: TextEditingController(),
        price: TextEditingController(),
        type: "one time"));
    notifyListeners();
  }

  // Method to delete extra price
  void deleteExtraPrice(DateTime? id) {
    extraPriceBoatVendorList.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // Method to clear pricing data
  void clearPricingData() {
    startTimeController.clear();
    endTimeController.clear();
    pricePerHourController.clear();
    pricePerDayController.clear();
    minDayBeforeBooking.clear();
    defaultState = "Always available";
    defaultStateInput = "0";
    enableExtraPrice = false;
    extraPriceBoatVendorList.clear();
    notifyListeners();
  }

  // Update the existing clearFormData method to include pricing data

  Future<bool> editBoatVendor({
    required String boatId,
    required String title,
    required String content,
    required String video,
    File? bannerImage,
    File? featuredImage,
    List<File> galleryImages = const [],
    required String maxGuest,
    required String cabin,
    required String speed,
    required String length,
    required String cancelPolicy,
    required String termsInformation,
    required String defaultState,
    required String minDayBeforeBooking,
    required String startTimeBooking,
    required String endTimeBooking,
    required String pricePerHour,
    required String pricePerDay,
    required String locationId,
    required String address,
    required String mapLat,
    required String mapLng,
    required String mapZoom,
    List<FaqClass> faqList = const [],
    List<Map<String, String>> specs = const [],
    List<Map<String, String>> include = const [],
    List<Map<String, String>> exclude = const [],
    bool enableExtraPrice = false,
    List<ExtraPriceForVendor> extraPriceList = const [],
  }) async {
    await loadToken();

    final body = {
      'boat_id': boatId,
      'title': title,
      'content': content,
      'status': 'publish',
      'video': video,
      'max_guest': maxGuest,
      'cabin': cabin,
      'speed': speed,
      'length': length,
      'cancel_policy': cancelPolicy,
      'terms_information': termsInformation,
      'default_state': defaultStateInput,
      'min_day_before_booking': minDayBeforeBooking,
      'start_time_booking': startTimeBooking,
      'end_time_booking': endTimeBooking,
      'price_per_hour': pricePerHour,
      'price_per_day': pricePerDay,
      'location_id': locationId,
      'address': address,
      'map_lat': mapLat,
      'map_lng': mapLng,
      'map_zoom': mapZoom,
      'terms':
          "${selectedboattypeIds.map((id) => id.toString()).join(',')},${selectedboatamenityIds.map((id) => id.toString()).join(',')}",
      'enable_extra_price': enableExtraPrice ? '1' : '0',
    };

    var uri = Uri.parse('${ApiUrls.baseUrl}${ApiUrls.vendorboatedit}');
    var request = MultipartRequest('POST', uri);

    request.headers.addAll({
      'Accept': 'application/json',
      'Accept-Language': gettt.Get.locale?.languageCode == "en" ? "en" : "ar",
      'Authorization': 'Bearer $_token',
    });

    // Add images only if new ones are selected
    if (bannerImage != null) {
      request.files
          .add(await MultipartFile.fromPath('banner_image', bannerImage.path));
    }
    if (featuredImage != null) {
      request.files
          .add(await MultipartFile.fromPath('image', featuredImage.path));
    }
    if (galleryImages.isNotEmpty) {
      for (var image in galleryImages) {
        request.files
            .add(await MultipartFile.fromPath('gallery[]', image.path));
      }
    }

    // Add FAQs
    if (faqList.isNotEmpty) {
      List<Map<String, dynamic>> faqJsonList = faqList
          .map((faq) => {
                'title': faq.title?.value.text ?? '',
                'content': faq.content?.value.text ?? '',
              })
          .toList();
      body['faqs'] = jsonEncode(faqJsonList);
    }

    // Add specs, include, exclude
    if (specs.isNotEmpty) body['specs'] = jsonEncode(specs);
    if (include.isNotEmpty) body['include'] = jsonEncode(include);
    if (exclude.isNotEmpty) body['exclude'] = jsonEncode(exclude);

    // Add extra prices
    if (enableExtraPrice && extraPriceList.isNotEmpty) {
      List<Map<String, dynamic>> extraPriceJsonList = extraPriceList
          .map((extra) => {
                "name": extra.name?.value.text ?? "",
                "name_ja": extra.name_ja?.value.text ?? "",
                "name_egy": extra.name_egy?.value.text ?? "",
                "price": extra.price?.value.text ?? "",
                // items: ['one_time', 'per_hour', 'per_day']
                "type": extra.type == "one time"
                    ? "one_time"
                    : extra.type == "per hour"
                        ? "per_hour"
                        : "per_day",
              })
          .toList();
      body['extra_price'] = jsonEncode(extraPriceJsonList);
    }

    request.fields
        .addAll(body.map((key, value) => MapEntry(key, value.toString())));

    var streamedResponse = await request.send();
    var result = await Response.fromStream(streamedResponse);
    log('Boat Edit request: $body');

    if (result.statusCode == 200 || result.statusCode == 201) {
      var jsonResponse = json.decode(result.body);
      log('Boat Edit Response: $jsonResponse');
      showErrorToast(jsonResponse['message']);
      notifyListeners();
      return true;
    } else {
      showErrorToast(json.decode(result.body)['message']);
      log('Failed to edit boat. Status code: ${result.statusCode}');
      log('Response body: ${result.body}');
      return false;
    }
  }
}

class FaqClass {
  TextEditingController? title;
  TextEditingController? content;
  DateTime? id;
  FaqClass({this.content, this.title, this.id});
}

class SpecClass {
  TextEditingController? title;
  TextEditingController? content;
  DateTime? id;
  SpecClass({this.content, this.title, this.id});
}

class ExtraPriceForVendor {
  DateTime? id;
  TextEditingController? name;
  TextEditingController? price;
  TextEditingController? name_ja;
  TextEditingController? name_egy;
  String type;
  ExtraPriceForVendor(
      {this.name,
      this.price,
      this.type = "one time",
      this.name_ja,
      this.name_egy,
      this.id});
}

class TitleClass {
  TextEditingController? title;
  DateTime? id;
  TitleClass({this.title, this.id});
}
