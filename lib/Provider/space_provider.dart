import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:moonbnd/modals/all_space_vendor_modal.dart' as vendor_modal;
import 'package:moonbnd/modals/amenities_model.dart';
import 'package:moonbnd/modals/space_detail_model.dart';
import 'package:moonbnd/modals/space_details_vendor_model.dart';
import 'package:moonbnd/modals/space_list_model.dart';
import 'package:moonbnd/modals/space_type_model.dart' as space_type;
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:get/get.dart' as gettt;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Urls/url_holder_loan.dart';
import 'api_interface.dart';

import 'package:html_editor_plus/html_editor.dart';
import 'package:image_picker/image_picker.dart';

class SpaceProvider with ChangeNotifier {
  String? _token;
  Map<int, SpaceList?> spaceListPerCategory = {};
  SpaceDetailModal? spaceDetail;
  SpaceDetailModal? _spaceDetail;
  vendor_modal.SpaceVendorList? spaceVendor;
  AmenitiesModal? amenity;
  space_type.SpaceTypeModal? space;
  SpaceDetailsVendor? spaceDetailsVendor;

  ///////space vendor

/////space vendor

  TextEditingController titleController = TextEditingController();

  HtmlEditorController contentController = HtmlEditorController();
  TextEditingController youtubeVideoController = TextEditingController();
  List<FaqClass> faqList = [];
  XFile? bannerImage;
  XFile? featuredImage;
  List<XFile> galleryImages = [];
  TextEditingController noOfBedController = TextEditingController();
  TextEditingController noOfBathroomController = TextEditingController();
  TextEditingController minimumAdvanceReservationController =
      TextEditingController();
  TextEditingController minimumDayStayController = TextEditingController();
  String? location;
  String? address;

  //// values for api
  String? locationid;
  TextEditingController addresscontroller = TextEditingController();
  String? latitude;
  String? longitude;
  String? zoom;
  List<EducationClass> educationList = [];
  List<EducationClass> healthList = [];
  List<EducationClass> transportationList = [];
  String defaultState = "Always available";

  String defaultStateInput = "";
  TextEditingController priceController = TextEditingController();
  TextEditingController salePriceController = TextEditingController();
  TextEditingController maxGuestController = TextEditingController();
  bool termsAccepted = false;
  List<ExtraPriceForVendor> extraPriceSpaceVendorList = [];
  List<DiscountByNoOfDayAndNightModal> discountByNoOfDayAndNightList = [];
  TextEditingController importUrlController = TextEditingController();

////end
  ///
  ///

  void clear() {
    titleController = TextEditingController();

    youtubeVideoController = TextEditingController();
    faqList = [];
    bannerImage = null;
    featuredImage = null;
    galleryImages = [];
    noOfBedController = TextEditingController();
    noOfBathroomController = TextEditingController();
    minimumAdvanceReservationController = TextEditingController();
    minimumDayStayController = TextEditingController();
    location = null;
    address = null;

    locationid = null;
    addresscontroller = TextEditingController();
    latitude = null;
    longitude = null;
    zoom = null;
    educationList = [];
    healthList = [];
    transportationList = [];
    defaultState = "Always available";

    defaultStateInput = "";
    priceController = TextEditingController();
    salePriceController = TextEditingController();
    maxGuestController = TextEditingController();
    termsAccepted = false;
    extraPriceSpaceVendorList = [];
    discountByNoOfDayAndNightList = [];
    importUrlController = TextEditingController();
    notifyListeners();
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('userToken');
    log("Token loaded: $_token");
  }

  void updateSpaceSearchParams({
    required String location,
    required DateTime? startDate,
    required DateTime? endDate,
    String? searchQuery,
  }) {
    spacelistapi(2, searchParams: {
      'location': location,
      'startDate': startDate,
      'endDate': endDate,
    });
  }

  Future<bool?> spacelistapi(int index,
      {String? sortBy,
      String? searchQuery,
      required Map<String, dynamic> searchParams}) async {
    log("Space List API Call for category index $index ===>");
    await loadToken();

    // Convert searchParams to query parameters
    final queryParams = {
      if (searchParams['location'] != null)
        'location': searchParams['location'],
      if (searchParams['startDate'] != null)
        'start': DateFormat('MM/dd/yyyy')
            .format(searchParams['startDate'] as DateTime),
      if (searchParams['endDate'] != null)
        'end': DateFormat('MM/dd/yyyy')
            .format(searchParams['endDate'] as DateTime),
      if (searchParams['price_range'] != null)
        'price_range': searchParams['price_range'],
      if (searchParams['review_score'] != null &&
          searchParams['review_score'] != '')
        'review_score': searchParams['review_score'],
      if (sortBy != null) 'orderby': sortBy,
      if (searchParams['space_types'] != null &&
          searchParams['space_types'] != '')
        'attrs[3]': searchParams['space_types'],
      if (searchParams['amenities'] != null && searchParams['amenities'] != '')
        'attrs[4]': searchParams['amenities'],
    };

    final queryString = Uri(queryParameters: queryParams).query;
    log('$queryString queryStringgg');
    String url = '${ApiUrls.baseUrl}${ApiUrls.spaceSearch}?$queryString';
    log('$url checkurl');
    final result = await makeRequest(
      url,
      'GET',
      {},
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      log("Space List Response for index $index ===> ${result['data']}");
      SpaceList spaceList = SpaceList.fromJson(result['data']);
      spaceListPerCategory[index] = spaceList;
      notifyListeners();
      return true;
    } else {
      log("Failed to fetch sapce list. Error: ${result['message']}");
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);
      return false;
    }
  }

  Future fetchSpaceDetails(int spaceId) async {
    log("Fetching Space Details for ID: $spaceId");
    log("Fetching Space Details for ID: ${ApiUrls.baseUrl}${ApiUrls.spaceDetailsEndPoint}/$spaceId',");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.spaceDetailsEndPoint}/$spaceId',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("Space Details Response: ${result['data']}");
      _spaceDetail = SpaceDetailModal.fromJson(result['data']);

      log("${_spaceDetail?.data?.address} address");
      spaceDetail = _spaceDetail;
      notifyListeners();
    } else {
      log("Failed to fetch space details. Error: ${result['message']}");
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);
      return null;
    }
  }

  Future<Map<String, dynamic>?> leaveReviewForSpace({
    required String reviewTitle,
    required String reviewContent,
    required Map<String, int> reviewStats,
    required String serviceId,
    required String serviceType,
  }) async {
    await loadToken();

    final Map<String, String> body = {
      'review_title': reviewTitle.toString(),
      'review_content': reviewContent.toString(),
      'review_service_id': serviceId.toString(),
      'review_service_type': serviceType.toString(),
      'submit': 'Leave a Review',
    };

    // Add review stats to the body
    reviewStats.forEach((key, value) {
      body['review_stats[$key]'] = value.toString();
    });

    log("${body} bodycheck");
    log("${ApiUrls.baseUrl}${ApiUrls.leaveReview} bodycheck");

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.leaveReview}',
      'POST',
      body,
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      log("Review submitted successfully: ${result['data']}");
      await fetchSpaceDetails(int.parse(serviceId));

      return result['data'];
    } else {
      log("Failed to submit review. Error: ${result['message']}");
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);
      return null;
    }
  }

  Future<Map<String, dynamic>?> addToCartForSpace({
    required String serviceId,
    required String serviceType,
    required DateTime startDate,
    required DateTime endDate,
    required int number,
    Map<String, dynamic>? guestData,
    List<SpaceDetailExtraPrice>? extraPrices,
  }) async {
    await loadToken();

    final dateFormat = DateFormat('yyyy-MM-dd');
    final body = {
      'service_id': serviceId,
      'service_type': "space",
      'start_date': dateFormat.format(startDate),
      'end_date': dateFormat.format(endDate),
      'adults': guestData?['adults']?.toString() ?? '0',
      'children': guestData?['children']?.toString() ?? '0',
    };

    // Add extra prices to the request
    if (extraPrices != null) {
      for (int i = 0; i < extraPrices.length; i++) {
        body['extra_price[$i][name]'] = extraPrices[i].name ?? '';
        body['extra_price[$i][name_ja]'] = '';
        body['extra_price[$i][name_egy]'] = '';
        body['extra_price[$i][price]'] = extraPrices[i].price ?? '';
        body['extra_price[$i][type]'] = extraPrices[i].type ?? 'one_time';
        body['extra_price[$i][number]'] = '0';
        body['extra_price[$i][enable]'] =
            extraPrices[i].valueType == true ? '1' : '0';
        body['extra_price[$i][price_html]'] = '\$${extraPrices[i].price}';
        body['extra_price[$i][price_type]'] = '';
      }
    }

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.addToCart}',
      'POST',
      body,
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      EasyLoading.showToast("${result['data']["message"]}",
          maskType: EasyLoadingMaskType.black);
      return result['data'];
    } else {
      log("Failed to add to cart. Error: ${result['message']}");
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);
      return null;
    }
  }

  Future fetchSpaceVendorDetails() async {
    log("Fetching Space Vendor Details: ${ApiUrls.baseUrl}${ApiUrls.spaceVendorForAll}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.spaceVendorForAll}',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("Car Details Response: ${result['data']}");
      vendor_modal.SpaceVendorList txxspaceVendor =
          vendor_modal.SpaceVendorList.fromJson(result['data']);

      spaceVendor = txxspaceVendor;
      notifyListeners();
    } else {
      log("Failed to fetch hotel details (9). Error: ${result['message']}");
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);
      return null;
    }
  }

  Future<bool> deleteVendorSpace({
    required String id,
  }) async {
    await loadToken();

    final body = {
      'id': id,
    };

    // Add review stats to the body

    log("$body bodycheck");
    log("${ApiUrls.baseUrl}${ApiUrls.spaceVendorDelete} bodycheck");

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.spaceVendorDelete}',
      'POST',
      body,
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      log("delete submitted successfully: ${result['data']}");
      EasyLoading.showToast("Space delete successfully !".tr,
          maskType: EasyLoadingMaskType.black);
      return true;
    } else {
      log("Failed to submit review. Error: ${result['message']}");
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);
      return false;
    }
  }

  Future<bool> cloneSpaceVendor(String id) async {
    await loadToken();

    final body = {
      'space_id': id,
    };

    // Add review stats to the body

    log("$body bodycheck");
    log("${ApiUrls.baseUrl}${ApiUrls.spaceVendorClone} bodycheck");

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.spaceVendorClone}',
      'POST',
      body,
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      EasyLoading.showToast("Space cloned successfully !".tr,
          maskType: EasyLoadingMaskType.black);

      return true;
    } else {
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);

      return false;
    }
  }

  Future<bool> hideSpaceVendor({
    required String id,
  }) async {
    await loadToken();

    await loadToken();

    final body = {
      'space_id': id,
    };

    log("${ApiUrls.baseUrl}${ApiUrls.vendorSpaceHide} bodycheck");

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.vendorSpaceHide}/$id',
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
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);
      return false;
    }
  }

  Future<bool> publishSpaceVendor({
    required String id,
  }) async {
    await loadToken();

    final body = {
      'space_id': id,
    };

    log("${ApiUrls.baseUrl}${ApiUrls.vendorSpacePublish} bodycheck");

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.vendorSpacePublish}/$id',
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
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);
      return false;
    }
  }

  ///// add space vendor

  Future<bool> addSpacevendor({
    String title = "",
    String content = "",
    String youtubeVideoText = "",
    List<FaqClass> faqList = const [],
    File? bannerimage,
    File? featuredimage,
    List<File> pickedImagefile = const [],
    String minimumDayBeforeBooking = "",
    String minimumdaystaycontroller = "",
    String bed = "",
    String bathroom = "",
    String locationId = "",
    String address = "",
    String mapLat = "",
    String mapLong = "",
    String mapZoom = "",
    List<EducationClass> txeducationList = const [],
    List<EducationClass> txhealthList = const [],
    List<EducationClass> txtransportationList = const [],
    String defaultState = "",
    String price = "",
    String salePrice = "",
    String maxGuests = "",
    bool enableExtraPrice = false,
    List<ExtraPriceForVendor> extraPriceForVendorList = const [],
    List<DiscountByNoOfDayAndNightModal> discountByNoOfDayAndNightList =
        const [],
    String ical = "",
  }) async {
    await loadToken();

    List<Amenity>? txamenity = amenity?.data?.where((test) {
      return test.value == true;
    }).toList();

    List<space_type.SpaceVendor>? txSpace = space?.data?.where((test) {
      return test.value == true;
    }).toList();

    log("${discountByNoOfDayAndNightList.length} discountByNoOfDayAndNightList added");

// List<SpaceVendor>? txSpaceType = space?.data?.where((test) {
//       return test.value == true;
//     }).toList();

    final body = {
      'title': title,
      'content': content,
      'video': youtubeVideoText,
      'bed': bed,
      'status': 'publish',
      'bathroom': bathroom,
      'min_day_before_booking': minimumDayBeforeBooking,
      'min_day_stays': minimumdaystaycontroller,
      'location_id': locationId,
      'address': address,
      'map_lat': mapLat,
      'map_lng': mapLong,
      'map_zoom': int.parse("10"),
      'default_state': defaultState,
      'price': price,
      'sale_price': salePrice,
      'max_guests': maxGuests,
      'enable_extra_price': enableExtraPrice == true ? '1' : '0',
      "terms":
          "${txamenity?.map((id) => id.id.toString()).join(',')},${txSpace?.map((id) => id.id.toString()).join(',')}",
      'ical_import_url': ical,
    };

    var uri = Uri.parse('${ApiUrls.baseUrl}${ApiUrls.vendorSpaceAdd}');

    var request = MultipartRequest(
      'POST',
      uri,
    );
    request.headers.addAll({
      'Accept': 'application/json',
      'Accept-Language': gettt.Get.locale?.languageCode == "en" ? "en" : "ar",
      'Authorization': 'Bearer $_token',
    });
    if (bannerimage != null) {
      request.files
          .add(await MultipartFile.fromPath('banner_image', bannerimage.path));
    }

    if (pickedImagefile.isNotEmpty) {
      for (var image in pickedImagefile) {
        request.files
            .add(await MultipartFile.fromPath('gallery[]', image.path));
      }
    }
    if (featuredimage != null) {
      request.files
          .add(await MultipartFile.fromPath('image', featuredimage.path));
    }

    if (faqList.isNotEmpty) {
      List<Map<String, dynamic>> faqJsonList = faqList
          .map((faq) => {
                'title': faq.title?.value.text ?? "",
                'content': faq.content?.value.text ?? "",
              })
          .toList();
      body.addAll({'faqs': jsonEncode(faqJsonList)});
    }

    if (enableExtraPrice == true && extraPriceForVendorList.isNotEmpty) {
      List<Map<String, dynamic>> extraPriceForVendorListJsonList =
          extraPriceForVendorList
              .map((valll) => {
                    "name": valll.nameEnglish?.value.text ?? "",
                    "name_ja": valll.nameJapnese?.value.text ?? "",
                    "name_egy": valll.nameEgyptian?.value.text ?? "",
                    "price": valll.price?.value.text ?? "",
                    // "type": valll.type,
                    "type": valll.type == "one time"
                        ? "one_time"
                        : valll.type == "per hour"
                            ? "per_hour"
                            : "per_day",
                    "per_person": valll.perPerson == true ? "on" : "off",
                  })
              .toList();
      body.addAll({'extra_price': jsonEncode(extraPriceForVendorListJsonList)});
    }

    if (discountByNoOfDayAndNightList.isNotEmpty) {
      List<Map<String, dynamic>> discountByNoOfDayAndNightJsonList =
          discountByNoOfDayAndNightList
              .map((valll) => {
                    "from": valll.from?.value.text ?? "",
                    "to": valll.to?.value.text ?? "",
                    "amount": valll.discount?.value.text ?? "",
                    "type": valll.type,
                  })
              .toList();
      body.addAll(
          {'discount_by_days': jsonEncode(discountByNoOfDayAndNightJsonList)});
    }

    List<List<Map<String, dynamic>>> surroundingJsonList = [
      txtransportationList
          .map((item) => {
                'name': item.name?.value.text ?? '',
                'content': item.content?.value.text ?? '',
                'value': item.distance?.value.text ?? '',
                'type': item.value?.value.text ?? '',
              })
          .toList(),
      txhealthList
          .map((item) => {
                'name': item.name?.value.text ?? '',
                'content': item.content?.value.text ?? '',
                'value': item.distance?.value.text ?? '',
                'type': item.value?.value.text ?? '',
              })
          .toList(),
      txeducationList
          .map((item) => {
                'name': item.name?.value.text ?? '',
                'content': item.content?.value.text ?? '',
                'value': item.distance?.value.text ?? '',
                'type': item.value?.value.text ?? '',
              })
          .toList(),
    ];

    body.addAll({'surrounding': jsonEncode(surroundingJsonList)});

    request.fields
        .addAll(body.map((key, value) => MapEntry(key, value.toString())));
    var streamedResponse = await request.send();
    var result = await Response.fromStream(streamedResponse);
    log('Verification Upload request: $body');

    if (result.statusCode == 200 || result.statusCode == 201) {
      var jsonResponse = json.decode(result.body);
      log('Verification Upload Response: $jsonResponse');
      showErrorToast(json.decode(result.body)['message']);
      notifyListeners();
      return true;
    } else {
      showErrorToast(json.decode(result.body)['message']);

      log('Failed to upload verification image. Status code: ${result.statusCode}');
      log('Response body: ${result.body}');
      return false;
      // Handle error
    }
  }

  ///// edit space vendor

  Future<bool> editSpacevendor({
    String spaceId = "",
    String title = "",
    String content = "",
    String youtubeVideoText = "",
    List<FaqClass> faqList = const [],
    File? bannerimage,
    File? featuredimage,
    List<File> pickedImagefile = const [],
    String minimumDayBeforeBooking = "",
    String minimumdaystaycontroller = "",
    String bed = "",
    String bathroom = "",
    String locationId = "",
    String address = "",
    String mapLat = "",
    String mapLong = "",
    String mapZoom = "",
    List<EducationClass> txeducationList = const [],
    List<EducationClass> txhealthList = const [],
    List<EducationClass> txtransportationList = const [],
    String defaultState = "",
    String price = "",
    String salePrice = "",
    String maxGuests = "",
    bool enableExtraPrice = false,
    List<ExtraPriceForVendor> extraPriceForVendorList = const [],
    List<DiscountByNoOfDayAndNightModal> discountByNoOfDayAndNightList =
        const [],
    String ical = "",
  }) async {
    await loadToken();

    List<Amenity>? txamenity = amenity?.data?.where((test) {
      return test.value == true;
    }).toList();

    List<space_type.SpaceVendor>? txSpace = space?.data?.where((test) {
      return test.value == true;
    }).toList();

// List<SpaceVendor>? txSpaceType = space?.data?.where((test) {
//       return test.value == true;
//     }).toList();

    // log('$bed checkData');
    // log('$bathroom checkData');

    log("${discountByNoOfDayAndNightList.length} discountByNoOfDayAndNightList added");

    final body = {
      'space_id': spaceId,
      'title': title,
      'content': content,
      'video': youtubeVideoText,
      'bed': bed,
      'status': 'publish',
      'bathroom': bathroom,
      'min_day_before_booking': minimumDayBeforeBooking,
      'min_day_stays': minimumdaystaycontroller,
      'location_id': locationId,
      'address': address,
      'map_lat': mapLat,
      'map_lng': mapLong,
      'map_zoom': int.parse("10"),
      'default_state': defaultState,
      'price': price,
      'sale_price': salePrice,
      'max_guests': maxGuests,
      'enable_extra_price': enableExtraPrice == true ? '1' : '0',
      "terms":
          "${txamenity?.map((id) => id.id.toString()).join(',')},${txSpace?.map((id) => id.id.toString()).join(',')}",
      'ical_import_url': ical,
    };

    var uri = Uri.parse('${ApiUrls.baseUrl}${ApiUrls.vendorSpaceEdit}');

    var request = MultipartRequest(
      'POST',
      uri,
    );
    request.headers.addAll({
      'Accept': 'application/json',
      'Accept-Language': gettt.Get.locale?.languageCode == "en" ? "en" : "ar",
      'Authorization': 'Bearer $_token',
    });
    if (bannerimage != null) {
      request.files
          .add(await MultipartFile.fromPath('banner_image', bannerimage.path));
    }

    if (pickedImagefile.isNotEmpty) {
      for (var image in pickedImagefile) {
        request.files
            .add(await MultipartFile.fromPath('gallery[]', image.path));
      }
    }
    if (featuredimage != null) {
      request.files
          .add(await MultipartFile.fromPath('image', featuredimage.path));
    }

    if (faqList.isNotEmpty) {
      List<Map<String, dynamic>> faqJsonList = faqList
          .map((faq) => {
                'title': faq.title?.value.text ?? "",
                'content': faq.content?.value.text ?? "",
              })
          .toList();
      body.addAll({'faqs': jsonEncode(faqJsonList)});
    }

    if (enableExtraPrice == true && extraPriceForVendorList.isNotEmpty) {
      List<Map<String, dynamic>> extraPriceForVendorListJsonList =
          extraPriceForVendorList
              .map((valll) => {
                    "name": valll.nameEnglish?.value.text ?? "",
                    "name_ja": valll.nameJapnese?.value.text ?? "",
                    "name_egy": valll.nameEgyptian?.value.text ?? "",
                    "price": valll.price?.value.text ?? "",
                    // items: ['one_time', 'per_hour', 'per_day']
                    "type": valll.type == "one time"
                        ? "one_time"
                        : valll.type == "per hour"
                            ? "per_hour"
                            : "per_day",
                    "per_person": valll.perPerson == true ? "on" : "off",
                  })
              .toList();
      body.addAll({'extra_price': jsonEncode(extraPriceForVendorListJsonList)});
    }

    if (discountByNoOfDayAndNightList.isNotEmpty) {
      List<Map<String, dynamic>> discountByNoOfDayAndNightJsonList =
          discountByNoOfDayAndNightList
              .map((valll) => {
                    "from": valll.from?.value.text ?? "",
                    "to": valll.to?.value.text ?? "",
                    "amount": valll.discount?.value.text ?? "",
                    "type": valll.type,
                  })
              .toList();
      body.addAll(
          {'discount_by_days': jsonEncode(discountByNoOfDayAndNightJsonList)});
    }

    List<List<Map<String, dynamic>>> surroundingJsonList = [
      txtransportationList
          .map((item) => {
                'name': item.name?.value.text ?? '',
                'content': item.content?.value.text ?? '',
                'value': item.distance?.value.text ?? '',
                'type': item.value?.value.text ?? '',
              })
          .toList(),
      txhealthList
          .map((item) => {
                'name': item.name?.value.text ?? '',
                'content': item.content?.value.text ?? '',
                'value': item.distance?.value.text ?? '',
                'type': item.value?.value.text ?? '',
              })
          .toList(),
      txeducationList
          .map((item) => {
                'name': item.name?.value.text ?? '',
                'content': item.content?.value.text ?? '',
                'value': item.distance?.value.text ?? '',
                'type': item.value?.value.text ?? '',
              })
          .toList(),
    ];

    body.addAll({'surrounding': jsonEncode(surroundingJsonList)});

    request.fields
        .addAll(body.map((key, value) => MapEntry(key, value.toString())));
    var streamedResponse = await request.send();
    var result = await Response.fromStream(streamedResponse);
    log('Verification Upload request: $body');

    if (result.statusCode == 200 || result.statusCode == 201) {
      var jsonResponse = json.decode(result.body);
      log('Verification Upload Response: $jsonResponse');
      showErrorToast(json.decode(result.body)['message']);
      notifyListeners();
      return true;
    } else {
      showErrorToast(json.decode(result.body)['message']);

      log('Failed to upload verification image. Status code: ${result.statusCode}');
      log('Response body: ${result.body}');
      return false;
      // Handle error
    }
  }

  Future<bool> deleteImage(String imageUrl, String id) async {
    await loadToken();
    const String url =
        "${ApiUrls.baseUrl}${ApiUrls.vendorSpaceDetailForDelete}";

    final response = await post(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        'Accept-Language': gettt.Get.locale?.languageCode == "en" ? "en" : "ar",
        'Authorization': 'Bearer $_token',
      },
      body: {
        'image_url': imageUrl,
        'object_model': "space",
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

  Future fetchFacilites() async {
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.vendorSpaceAmenities}',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("Space Details Response: ${result['data']}");
      AmenitiesModal txamenityList = AmenitiesModal.fromJson(result['data']);

      amenity = txamenityList;
      notifyListeners();
    } else {
      log("Failed to fetch space details. Error: ${result['message']}");
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);
      return null;
    }
  }

  Future fetchSpaceType() async {
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.vendorSpaceType}', 'GET', {}, _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("Space Details Response: ${result['data']}");
      space_type.SpaceTypeModal txamenityList =
          space_type.SpaceTypeModal.fromJson(result['data']);

      space = txamenityList;
      notifyListeners();
    } else {
      log("Failed to fetch space details. Error: ${result['message']}");
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);
      return null;
    }
  }

  Future<bool> fetchSpaceDetailsEditById(String spaceId) async {
    log("Fetching Space Details for ID: $spaceId");
    await loadToken();

    final String url =
        '${ApiUrls.baseUrl}${ApiUrls.vendorSpaceDetailForEdit}/$spaceId';
    final result = await makeRequest(
      url,
      'GET',
      {},
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      SpaceDetailsVendor txamenityList =
          SpaceDetailsVendor.fromJson(result['data']);

      spaceDetailsVendor = txamenityList;
      notifyListeners();
      return true;
    } else {
      log("Failed to fetch space details. Error: ${result['message']}");
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);
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

class EducationClass {
  TextEditingController? name;
  TextEditingController? content;
  TextEditingController? distance;
  TextEditingController? value;
  DateTime? id;
  EducationClass({this.content, this.name, this.distance, this.id, this.value});
}

class ExtraPriceForVendor {
  DateTime? id;
  TextEditingController? nameEnglish;
  TextEditingController? nameJapnese;
  TextEditingController? nameEgyptian;
  TextEditingController? price;
  String? type;
  bool? perPerson;
  ExtraPriceForVendor(
      {this.nameEgyptian,
      this.nameEnglish,
      this.id,
      this.nameJapnese,
      this.perPerson = false,
      this.price,
      this.type = "one time"});
}

class DiscountByNoOfDayAndNightModal {
  DateTime? id;
  TextEditingController? from;
  TextEditingController? to;
  TextEditingController? discount;

  String? type;

  DiscountByNoOfDayAndNightModal(
      {this.to, this.from, this.id, this.discount, this.type = "fixed"});
}

class TicketsVendorModal {
  DateTime? id;
  TextEditingController? ticketCode;
  TextEditingController? nameEnglish;
  TextEditingController? vipCode;
  TextEditingController? nameJapnese;
  TextEditingController? nameEgyptian;
  TextEditingController? price;
  TextEditingController? numberTicket;

  TicketsVendorModal(
      {this.nameEgyptian,
      this.nameEnglish,
      this.id,
      this.vipCode,
      this.nameJapnese,
      this.numberTicket,
      this.price,
      this.ticketCode});
}
