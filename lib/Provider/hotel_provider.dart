import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:moonbnd/modals/all_hotel_detail_vendor_model.dart';
import 'package:moonbnd/modals/all_hotel_vendor_model.dart';
import 'package:moonbnd/modals/getlocationadd_Car_mdeol.dart';
import 'package:moonbnd/modals/hotel_property_type_model.dart';
import 'package:moonbnd/modals/notificationmodel.dart';
import 'package:moonbnd/vendor/car/car_one_screen.dart';
import 'package:moonbnd/vendor/car/car_three_screen.dart';
import 'package:moonbnd/vendor/hotel/add_hotel_screen.dart';
import 'package:moonbnd/vendor/hotel/hotel_add_three_screen.dart';
import 'package:moonbnd/vendor/hotel/hotel_location_add_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart' as gettt;
import 'package:html_editor_plus/html_editor.dart';
import 'package:http/http.dart';
import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Urls/url_holder_loan.dart';
import 'package:moonbnd/modals/my_profile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VendorHotelProvider with ChangeNotifier {
  String? _token;
  MyProfile? _userProfile;
  // Getter for user profile
  MyProfile? get myProfile => _userProfile;

  // New variables
  TextEditingController firstnamecontroller = TextEditingController();
  TextEditingController lastNameInputController = TextEditingController();
  TextEditingController businessNameInputController = TextEditingController();
  TextEditingController emailInputController = TextEditingController();
  TextEditingController mobileNumberInputController = TextEditingController();
  TextEditingController passwordInputController = TextEditingController();

  bool isShowPassword = false;

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

  TextEditingController titlecontroller = TextEditingController();
  // TextEditingController contentcontroller = TextEditingController();
  HtmlEditorController contentController = HtmlEditorController();
  TextEditingController youtubecontroller = TextEditingController();

  TextEditingController pricecontroller = TextEditingController();
  TextEditingController salepricecontroller = TextEditingController();
  TextEditingController minimumcontroller = TextEditingController();
  TextEditingController minimumdaystaycontroller = TextEditingController();

  TextEditingController addresscontroller = TextEditingController();

  TextEditingController hotelreleatedid = TextEditingController();
  TextEditingController timechecoutcontroller = TextEditingController();
  TextEditingController timechecincontroller = TextEditingController();

  String? Content;
  String? title;
  String? selectpassanger;
  String? selectreservations;
  String? selectrequirements;
  String? selectgearshift;
  String? latitude;
  String? longitude;
  String? zoom;
  List<int> selectedpropertytypeIds = [];
  HotelPropertyTypeModel? space;
  HotelPropertyTypeModel? amenity;
  HotelPropertyTypeModel? serviceshotel;

  HotelPropertyTypeModel? propertylist;
  HotelPropertyTypeModel? propertylists;

  AllHotelVendorModel? hotellist;
  AllHotelVendorModel? hotellists;

  AllHotelDetailsVendorModel? hotellistdetail;
  AllHotelDetailsVendorModel? hotellistdetails;

  HotelPropertyTypeModel? facility;
  HotelPropertyTypeModel? facilities;
  List<int> selectedfacilitytypeIds = [];

  HotelPropertyTypeModel? service;
  HotelPropertyTypeModel? services;
  List<int> selectedservicetypeIds = [];

  String? extrapricetype;
  String? locationids;
  String? locationid;
  File? bannerimage;
  File? featuredimage;
  final ImagePicker _picker = ImagePicker();
  List<ExtraPrices> extraprice = [];
  List<FAQ> faq = [];
  /*List<FAQS> faqs = [];*/

  List<EDU> edu = [];
  /*List<EDUS> edus = [];*/
  List<HEALTH> health = [];
/*  List<HEALTHS> healths = [];*/
  List<TRANSFORM> transform = [];
  /* List<TRANSFORMS> transforms = [];*/
  List<PRICE> price = [];

  AddCarLocationModel? addhotellocation;
  AddCarLocationModel? addhotellocations;

  List<File> pickedImagefile = [];
  NotificationModel? notificationmodel;

  NotificationModel? notificationmodels;
  /*Future<void> pickimage() async {
    final ImagePicker pickedimage = ImagePicker();
    final XFile? image =
    await pickedimage.pickImage(source: ImageSource.gallery);

    if (image != null) {
      pickedImagefile.add(File(image.path));
      notifyListeners();
    }
  }*/
  Future<void> pickimage() async {
    final ImagePicker picker = ImagePicker();

    // Use pickMultiImage to allow multiple selections
    final List<XFile>? images = await picker.pickMultiImage();

    if (images != null && images.isNotEmpty) {
      // Add all selected images to the pickedImagefile list
      pickedImagefile.addAll(images.map((image) => File(image.path)));
      notifyListeners(); // Notify listeners to update the UI
    }
  }

  void addfaq() {
    faq.add(FAQ(
      id: DateTime.now().add(Duration(seconds: 1)),
    ));
    notifyListeners();
  }
  /* void addfaqs() {
    faqs.add(FAQS());
    notifyListeners();
  }*/

  void addedu() {
    edu.add(EDU());
    notifyListeners();
  }

  /*void addedus() {
    edus.add(EDUS());
  }*/
  void addprice() {
    price.add(PRICE(
        name: TextEditingController(),
        price: TextEditingController(),
        perPerson: false,
        type: "one time"));
    notifyListeners();
  }

  void addhealth() {
    health.add(HEALTH());
    notifyListeners();
  }

  void addtransform() {
    transform.add(TRANSFORM());
    notifyListeners();
  }
  /*void addhealths() {
    healths.add(HEALTHS());
  }*/
  /* void addtransforms() {
    transforms.add(TRANSFORMS());
  }*/

  void removeedu(int index) {
    edu.removeAt(index);

    notifyListeners();
  }

  /*void removeedus(int index) {
    if (index > 0 && index < edus.length) {
      edus.removeAt(index);
    }
    notifyListeners();
  }*/
  /*void removehealths(int index) {
    if (index > 0 && index < healths.length) {
      healths.removeAt(index);
    }
    notifyListeners();
  }
  void removetransforms(int index) {
    if (index > 0 && index < transforms.length) {
      transforms.removeAt(index);
    }
    notifyListeners();
  }*/
  void removehealth(int index) {
    health.removeAt(index);

    notifyListeners();
  }

  void removetransform(int index) {
    transform.removeAt(index);

    notifyListeners();
  }

  void removeprice(int index) {
    price.removeAt(index);

    notifyListeners();
  }

  void removefaq(DateTime datetime) {
    log("$datetime checkId");
    faq.removeWhere((test) {
      return test.id == datetime;
    });

    notifyListeners();
  }
/*  void removefaqs(int index) {
    if (index > 0 && index < faqs.length) {
      faqs.removeAt(index);
    }
    notifyListeners();
  }*/

  void addexptraprice() {
    extraprice.add(ExtraPrices());
    notifyListeners();
  }

  void removeexptraprice(int index) {
    extraprice.removeAt(index);

    notifyListeners();
  }

  // Image picker function
  Future<void> pickImagebanner() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      bannerimage = File(pickedImage.path); // Store the image file
      notifyListeners();
    }
  }

  Future<void> pickImagefeatured() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      featuredimage = File(pickedImage.path); // Store the image file
      notifyListeners();
    }
  }

  Future fetachaddhotellocation() async {
    log("Fetching Add Hotel Location: ${ApiUrls.baseUrl}${ApiUrls.getaddcarlocation}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.getaddcarlocation}',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("hotel Response: ${result['data']}");
      addhotellocation = AddCarLocationModel.fromJson(result['data']);

      /*log("${carlist?.data?.first.address} address");*/
      addhotellocations = addhotellocation;
      notifyListeners();
    } else {
      log("Failed to fetch hotel details (7). Error: ${result['message']}");
      return null;
    }
  }

  Future<bool> addNewHotelVendor() async {
    await loadToken();

    log("$isShowPassword isShowPassword");

    // Ensure all values in the `body` map are strings
    final body = {
      'title': titlecontroller.text,
      'content': await contentController.getText(),
      'video': youtubecontroller.text,
      'star_rate': selectpassanger.toString(),
      'related_ids': hotelreleatedid.text,
      "location_id": locationids ?? "",
      'address': addresscontroller.text,
      'map_lat': latitude ?? "",
      'map_lng': longitude ?? "",
      'check_in_time': timechecincontroller.text,
      'check_out_time': timechecoutcontroller.text,
      'min_day_before_booking': selectreservations.toString(),
      'min_day_stays': selectrequirements.toString(),
      "terms":
          "${selectedpropertytypeIds.map((id) => id.toString()).join(',')},${selectedfacilitytypeIds.map((id) => id.toString()).join(',')},${selectedservicetypeIds.map((id) => id.toString()).join(',')}",
      'map_zoom': (int.tryParse(zoom ?? "10") ?? 10).toString(),
      'sale_price': salepricecontroller.text,
      'enable_extra_price': isShowPassword == true ? '1' : '0',
      'status': "publish",
      'price': pricecontroller.text,
    };

    // Create a list to hold the extra price details
    List<Map<String, dynamic>> extraPriceList = [];

    for (var i = 0; i < price.length; i++) {
      extraPriceList.add({
        "name": price[i].name?.value.text,

        'price': price[i].price?.value.text ?? "",
        // "type": valll.type,
        "type": price[i].type == "one time" ? "one_time" : "per_day",
        "per_person": price[i].perPerson == true ? "on" : "off",
      });
    }

    // Convert the list to a JSON string and assign it to the body
    body['extra_price'] = json.encode(extraPriceList);

    // Create a list to hold the FAQ details
    List<Map<String, dynamic>> faqList = [];

    for (var i = 0; i < faq.length; i++) {
      faqList.add({
        'title': faq[i].title?.toString() ?? "",
        'content': faq[i].content?.toString() ?? ""
      });
    }

    // Convert the list to a JSON string and assign it to the body
    body['policy'] = json.encode(faqList);

    // New code to combine edu, health, and transform into a single key
    Map<String, dynamic> combinedMap = {
      '1': [], // For edu
      '2': [], // For health
      '3': [], // For transform
    };

    // Populate edu
    for (var i = 0; i < edu.length; i++) {
      combinedMap['1'].add({
        'name': edu[i].title?.toString() ?? '',
        'content': edu[i].content?.toString() ?? '',
        'value': edu[i].distance?.toString() ?? '',
        'type': edu[i].type?.toString() ?? '',
      });
    }

    // Populate health
    for (var i = 0; i < health.length; i++) {
      combinedMap['2'].add({
        'name': health[i].title?.toString() ?? '',
        'content': health[i].content?.toString() ?? '',
        'value': health[i].distance?.toString() ?? '',
        'type': health[i].type?.toString() ?? '',
      });
    }

    // Populate transform
    for (var i = 0; i < transform.length; i++) {
      combinedMap['3'].add({
        'name': transform[i].title?.toString() ?? '',
        'content': transform[i].content?.toString() ?? '',
        'value': transform[i].distance?.toString() ?? '',
        'type': transform[i].type?.toString() ?? '',
      });
    }

    // Convert combinedMap to a JSON string for the policy field
    body['surrounding'] = json.encode(combinedMap);

    var uri = Uri.parse('${ApiUrls.baseUrl}${ApiUrls.vendoraddhotels}');

    // Create a multipart request
    var request = MultipartRequest(
      'POST',
      uri,
    );

    // Add headers
    request.headers.addAll({
      'Accept': 'application/json',
      'Accept-Language': gettt.Get.locale?.languageCode == "en" ? "en" : "ar",
      'Authorization': 'Bearer $_token',
    });

    // Add files to the request
    if (bannerimage != null) {
      request.files
          .add(await MultipartFile.fromPath('banner_image', bannerimage!.path));
    }
    if (pickedImagefile.isNotEmpty) {
      for (var image in pickedImagefile) {
        request.files
            .add(await MultipartFile.fromPath('gallery[]', image.path));
      }
    }
    if (featuredimage != null) {
      request.files
          .add(await MultipartFile.fromPath('image', featuredimage!.path));
    }

    // Add fields
    request.fields.addAll(body);

    // Send the request
    var streamedResponse = await request.send();
    var result = await Response.fromStream(streamedResponse);

    log('Verification Upload request: $body');

    if (result.statusCode == 200 || result.statusCode == 201) {
      var jsonResponse = json.decode(result.body);
      log('Verification Upload Response: $jsonResponse');
      log(' Response: ${result.statusCode} ');

      showErrorToast(json.decode(result.body)['message']);
      notifyListeners();

      // Dispose of all controllers after successful API call
      /*disposeControllers(); */ // Call the method to dispose controllers
      return true;
    } else {
      showErrorToast(json.decode(result.body)['message']);
      log('Failed to upload verification image. Status code: ${result.statusCode} body');
      log('Response body: ${result.body} body');
      log('Response body: ${json.decode(result.body)["message"]} body');
      return false;
    }
  }

  Future<bool> edithotelvendor({
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
    String txprice = "",
    String timeinController = "",
    String timeoutController = "",
    String minreservationController = "",
    String minstayController = "",
    String salePrice = "",
    String maxGuests = "",
    bool enableExtraPrice = false,
    List<ExtraPriceForVendor> extraPriceForVendorList = const [],
  }) async {
    await loadToken();

    List<PTDatum>? txamenity = amenity?.data?.where((test) {
      return test.value == true;
    }).toList();

    List<PTDatum>? txSpace = space?.data?.where((test) {
      return test.value == true;
    }).toList();
    List<PTDatum>? txservice = serviceshotel?.data?.where((test) {
      return test.value == true;
    }).toList();

    log("${price.length} price length");

    final body = {
      'hotel_id': spaceId,
      'title': title,
      'content': content,
      'video': youtubeVideoText,
      'star_rate': selectpassanger,
      'status': 'publish',
      'related_ids': hotelreleatedid.value.text,
      'location_id': locationId,
      'address': address,
      'map_lat': mapLat,
      'map_lng': mapLong,
      'map_zoom': int.parse("10"),
      'check_in_time': timeinController,
      'check_out_time': timeoutController,
      'min_day_before_booking': minreservationController,
      'min_day_stays': minstayController,
      /*  'default_state': defaultState,*/
      'price': txprice,
      'sale_price': salePrice,
      'max_guests': maxGuests,
      'enable_extra_price': enableExtraPrice == true ? 1 : 0,
      "terms":
          "${txamenity?.map((id) => id.id.toString()).join(',')},${txSpace?.map((id) => id.id.toString()).join(',')},${txservice?.map((id) => id.id.toString()).join(',')}",
    };

    List<Map<String, dynamic>> extraPriceList = [];

    for (var i = 0; i < extraPriceForVendorList.length; i++) {
      log("${extraPriceForVendorList[i].type} type");
      extraPriceList.add({
        "name": extraPriceForVendorList[i].nameEnglish?.value.text,

        'price': extraPriceForVendorList[i].price?.value.text ?? "",
        // "type": valll.type,
        "type": extraPriceForVendorList[i].type == "one time"
            ? "one_time"
            : "per_day",
        "per_person":
            extraPriceForVendorList[i].perPerson == true ? "on" : "off",
      });
    }

    // Convert the list to a JSON string and assign it to the body

    body.addAll({'extra_price': jsonEncode(extraPriceList)});

    var uri = Uri.parse('${ApiUrls.baseUrl}${ApiUrls.vendorupdatehotels}');
    // print('enablecheckkey${enableExtraPrice}');

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
      body.addAll({'policy': jsonEncode(faqJsonList)});
    }

// ... existing code ...
    List<List<Map<String, dynamic>>> surroundingJsonList = [
      // Check if the lists are empty and set to empty lists accordingly
      txeducationList.isNotEmpty
          ? txeducationList
              .map((item) => {
                    'name': item.name?.value.text ?? '',
                    'content': item.content?.value.text ?? '',
                    'value': item.distance?.value.text ?? '',
                    'type': item.value?.value.text ?? '',
                  })
              .toList()
          : [], // Send empty list if transportation list is empty
      txhealthList.isNotEmpty
          ? txhealthList
              .map((item) => {
                    'name': item.name?.value.text ?? '',
                    'content': item.content?.value.text ?? '',
                    'value': item.distance?.value.text ?? '',
                    'type': item.value?.value.text ?? '',
                  })
              .toList()
          : [], // Send empty list if health list is empty
      txtransportationList.isNotEmpty
          ? txtransportationList
              .map((item) => {
                    'name': item.name?.value.text ?? '',
                    'content': item.content?.value.text ?? '',
                    'value': item.distance?.value.text ?? '',
                    'type': item.value?.value.text ?? '',
                  })
              .toList()
          : [], // Send empty list if education list is empty
    ];

// Update surrounding data to ensure it sends the correct format
    body['surrounding'] = json.encode({
      "1": surroundingJsonList[0],
      "2": surroundingJsonList[1],
      "3": surroundingJsonList[2],
    });
// ... existing code ...

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

  Future<bool> clonehotelvendor({
    required String id,
  }) async {
    await loadToken();

    final body = {
      'hotel_id': id,
    };

    // Add review stats to the body

    log("$body bodycheck");
    log("${ApiUrls.baseUrl}${ApiUrls.clonehotelvendor} bodycheck");

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.clonehotelvendor}',
      'POST',
      body,
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      EasyLoading.showToast("Hotel cloned successfully !".tr,
          maskType: EasyLoadingMaskType.black);

      return true;
    } else {
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);

      return false;
    }
  }

  Future<bool> deleteimagehotelvendor({
    required String id,
    required String model,
    required String imageurl,
  }) async {
    await loadToken();

    final body = {'image_url': imageurl, 'object_model': model, 'id': id};

    // Add review stats to the body

    log("$body bodycheck");
    log("${ApiUrls.baseUrl}${ApiUrls.deletehotelimagevendor} bodycheck");

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.deletehotelimagevendor}',
      'POST',
      body,
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      log("clone submitted successfully: ${result['data']}");

      return true;
    } else {
      log("Failed to submit review. Error: ${result['message']}");
      return false;
    }
  }

  Future<bool> deletehotelvendor({
    required String id,
  }) async {
    await loadToken();

    final body = {
      'hotel_id': id,
    };

    // Add review stats to the body

    log("$body bodycheck");
    log("${ApiUrls.baseUrl}${ApiUrls.vendordeletehotel} bodycheck");

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.vendordeletehotel}',
      'POST',
      body,
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      log("delete submitted successfully: ${result['data']}");
      EasyLoading.showToast("Hotel delete successfully !".tr,
          maskType: EasyLoadingMaskType.black);
      return true;
    } else {
      log("Failed to submit review. Error: ${result['message']}");
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);
      return false;
    }
  }

  Future<bool> publishhotelvendor({
    required String id,
  }) async {
    await loadToken();

    final body = {
      'hotel_id': id,
    };

    // Add review stats to the body

    /* log("$body bodycheck");*/
    log("${ApiUrls.baseUrl}${ApiUrls.vendorpublishhotel} bodycheck");

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.vendorpublishhotel}/$id',
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

  Future<bool> hidehotelvendor({
    required String id,
  }) async {
    await loadToken();

    final body = {
      'hotel_id': id,
    };

    // Add review stats to the body

    /* log("$body bodycheck");*/
    log("${ApiUrls.baseUrl}${ApiUrls.vendorhidehotel} bodycheck");

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.vendorhidehotel}/$id',
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

  Future fetchallhotelvendor() async {
    log("Fetching All Hotel Location: ${ApiUrls.baseUrl}${ApiUrls.vendorallhotel}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.vendorallhotel}', 'GET', {}, _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("Vendorhotel Details Response: ${result['data']}");
      hotellist = AllHotelVendorModel.fromJson(result['data']);

      log(" response of hotellist = ${hotellist?.data} ");
      hotellists = hotellist;
      notifyListeners();
    } else {
      log("Failed to fetch hotel details  (8). Error: ${result['message']}");
      return null;
    }
  }

  Future fetchallhoteldetailvendor(id) async {
    log("Fetching All Hotel Detail Vendor: ${ApiUrls.baseUrl}${ApiUrls.vendorhoteldetails}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.vendorhoteldetails}/${id}',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("Car Details Response: ${result['data']}");
      hotellistdetail = AllHotelDetailsVendorModel.fromJson(result['data']);

      log(" response of hotellist = ${hotellistdetail?.data} ");
      hotellistdetails = hotellistdetail;
      notifyListeners();
      return hotellistdetail?.data;
    } else {
      log("Failed to fetch hotel details (6). Error: ${result['message']}");
      return null;
    }
  }

  Future propertytypehotelvendor() async {
    log("Fetching Hotel property Details for ID: ${ApiUrls.baseUrl}${ApiUrls.vendorhotelpropertytype}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.vendorhotelpropertytype}',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("property type  Response: ${result['data']}");
      propertylist = HotelPropertyTypeModel.fromJson(result['data']);
      space = propertylist;

      log(" response of hotellist = ${propertylist?.data} ");
      propertylists = propertylist;
      notifyListeners();
    } else {
      log("Failed to fetch property type . Error: ${result['message']}");
      return null;
    }
  }

  Future facilitiestypehotelvendor() async {
    log("Fetching Hotel facility Details for ID: ${ApiUrls.baseUrl}${ApiUrls.vendorhotelfacilitytype}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.vendorhotelfacilitytype}',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("facility type  Response: ${result['data']}");
      facility = HotelPropertyTypeModel.fromJson(result['data']);
      amenity = facility;

      log(" response of facility = ${facility?.data} ");
      facilities = facility;
      notifyListeners();
    } else {
      log("Failed to fetch facility type . Error: ${result['message']}");
      return null;
    }
  }

  Future servicestypehotelvendor() async {
    log("Fetching Hotel facility Details for ID: ${ApiUrls.baseUrl}${ApiUrls.vendorhotelservicetpe}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.vendorhotelservicetpe}',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("service type  Response: ${result['data']}");
      service = HotelPropertyTypeModel.fromJson(result['data']);
      serviceshotel = service;
      log(" response of service = ${service?.data} ");
      services = service;
      notifyListeners();
    } else {
      log("Failed to fetch service type . Error: ${result['message']}");
      return null;
    }
  }

  // Cleanup method
  @override
  void dispose() {
    firstnamecontroller.dispose();
    lastNameInputController.dispose();
    businessNameInputController.dispose();
    emailInputController.dispose();
    mobileNumberInputController.dispose();
    passwordInputController.dispose();
    titlecontroller.dispose();
    super.dispose();
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
        'object_model': "hotel",
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

  Future<bool> deleteImagecar(String imageUrl, String id) async {
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
        'object_model': "car",
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
