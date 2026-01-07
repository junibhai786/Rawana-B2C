import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:moonbnd/data_models/motification_unread_count_model.dart';
import 'package:moonbnd/modals/all_transasction_model.dart';
import 'package:moonbnd/modals/but_Car_model.dart';
import 'package:moonbnd/modals/car_features_model.dart';
import 'package:moonbnd/modals/credit_balance_model.dart';
import 'package:moonbnd/modals/notificationmodel.dart';
import 'package:moonbnd/modals/pending_credit_model.dart';
import 'package:moonbnd/vendor/car/car_one_screen.dart';
import 'package:moonbnd/vendor/car/car_three_screen.dart';
import 'package:moonbnd/vendor/car/edit/edit_Car_one_screen.dart';
import 'package:moonbnd/vendor/hotel/add_hotel_screen.dart';
import 'package:moonbnd/vendor/hotel/hotel_location_add_screen.dart';
import 'package:get/get.dart' as gettt;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_plus/html_editor.dart';
import 'package:http/http.dart';
import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Urls/url_holder_loan.dart';
import 'package:moonbnd/modals/my_profile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VendorAuthProvider with ChangeNotifier {
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

  bool isShowPassword = true;
  bool termsAndPrivacyCheckbox = false;

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
  void updateTermsAndPrivacyCheckbox(bool value) {
    termsAndPrivacyCheckbox = value;
    notifyListeners();
  }

  TextEditingController faqtitlecontroller = TextEditingController();
  TextEditingController faqcontentcontroller = TextEditingController();

  TextEditingController titlecontroller = TextEditingController();
  // TextEditingController contentcontroller = TextEditingController();
  HtmlEditorController contentcontroller = HtmlEditorController();
  TextEditingController youtubecontroller = TextEditingController();
  TextEditingController carcontroller = TextEditingController();
  TextEditingController pricecontroller = TextEditingController();
  TextEditingController salepricecontroller = TextEditingController();
  TextEditingController minimumcontroller = TextEditingController();
  TextEditingController minimumdaystaycontroller = TextEditingController();
  TextEditingController englishnamecontroller = TextEditingController();
  TextEditingController japanaesenamecontroller = TextEditingController();
  TextEditingController egyptiannamecontroller = TextEditingController();
  TextEditingController importUrlController = TextEditingController();
  TextEditingController addresscontroller = TextEditingController();
  TextEditingController gearcontroller = TextEditingController();
  TextEditingController hotelreleatedid = TextEditingController();
  String? Content;
  String? title;
  String? selectpassanger;
  String? selectgearshift;
  String? latitude;
  String? longitude;
  String? zoom;

  int? selectbaggage;
  int? selectdoor;
  int defaultstate = 0;
  String defaultstateName = "Only available on specific dates";
  String? extrapricetype;
  String? locationids;
  String? locationid;
  File? bannerimage;
  File? featuredimage;
  ImagePicker _picker = ImagePicker();
  List<ExtraPrices> extraprice = [];
  List<FAQ> faq = [];
  List<EDU> edu = [];
  List<HEALTH> health = [];
  List<TRANSFORM> transform = [];
  CarFeaturesModel? carfeatures;
  BuyCreditModel? buycredit;
  BuyCreditModel? buycredits;
  AllTransactionModel? alltrasaction;
  AllTransactionModel? alltrasactions;
  CreditBalanceModel? creditbalance;
  CreditBalanceModel? creditbalances;
  PendingCreditModel? pendingcredit;
  PendingCreditModel? pendingcredits;
  CarFeaturesModel? carfeaturess;
  CarFeaturesModel? cartypes;

  CarFeaturesModel? cartypess;
  List<int> selectedCartypeIds = [];
  List<int> selectedCarFeatureIds = [];
  List<File> pickedImagefile = [];
  NotificationModel? notificationmodel;

  NotificationModel? notificationmodels;
  NotificationModel? notificationmodelread;

  NotificationModel? notificationmodelreads;

  NotificationModel? notificationmodelunread;

  NotificationModel? notificationmodelunreads;
  NotificationUnreadCount? notificationcountmodel;

  NotificationUnreadCount? notificationcountmodels;
  bool termsAccepted = false;

  void clear() {
    faqtitlecontroller = TextEditingController();
    faqcontentcontroller = TextEditingController();

    titlecontroller = TextEditingController();
    // TextEditingController contentcontroller = TextEditingController();

    youtubecontroller = TextEditingController();
    termsAccepted = false;
    carcontroller = TextEditingController();
    pricecontroller = TextEditingController();
    salepricecontroller = TextEditingController();
    minimumcontroller = TextEditingController();
    minimumdaystaycontroller = TextEditingController();
    englishnamecontroller = TextEditingController();
    japanaesenamecontroller = TextEditingController();
    egyptiannamecontroller = TextEditingController();
    importUrlController = TextEditingController();
    addresscontroller = TextEditingController();
    gearcontroller = TextEditingController();
    hotelreleatedid = TextEditingController();
    Content = null;
    title = null;
    selectpassanger = null;
    selectgearshift = null;
    latitude = null;
    longitude = null;
    zoom = null;

    selectbaggage = null;
    selectdoor = null;
    defaultstate = 0;
    defaultstateName = "Only available on specific dates";
    extrapricetype = null;
    locationids = null;
    locationid = null;
    bannerimage = null;
    featuredimage = null;
    _picker = ImagePicker();
    extraprice = [];
    faq = [];
    edu = [];
    health = [];
    transform = [];

    selectedCartypeIds = [];
    selectedCarFeatureIds = [];
    pickedImagefile = [];
    notifyListeners();
  }

  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();

    if (images != null && images.isNotEmpty) {
      pickedImagefile.addAll(images.map((image) => File(image.path)).toList());
      notifyListeners();
    }
  }

  void addfaq() {
    faq.add(FAQ());
  }

  Future fetchreadnotification() async {
    debugPrint(
        "Fetching Read Notification: ${ApiUrls.baseUrl}${ApiUrls.getnotificationread}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.getnotificationread}',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    debugPrint("${result['success']} success check");
    if (result['success']) {
      debugPrint("Car Details Response: ${result['data']}");
      notificationmodelread = NotificationModel.fromJson(result['data']);

      // debugPrint("${CarFeaturesModel?.data?.first.id} address");
      notificationmodelreads = notificationmodelread;
      notifyListeners();
    } else {
      debugPrint("Failed to fetch hotel details (10) . Error: ${result['message']}");
      return null;
    }
  }

  Future<bool> becomevendor() async {
    final result = await makeMultipartRequest(
        '${ApiUrls.baseUrl}${ApiUrls.becomesvendor}', 'POST', {}, _token ?? '',
        requiresAuth: true);

    if (result['success']) {
      showErrorToast(result['data']['message']);

      notifyListeners();
      return true;
    } else {
      showErrorToast(result['message']);
      return false;
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

  Future fetchunreadnotificationcount() async {
    debugPrint(
        "Fetching UnRead Notification: ${ApiUrls.baseUrl}${ApiUrls.getnotificationunreadcount}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.getnotificationunreadcount}',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    debugPrint("${result['success']} success check");
    if (result['success']) {
      debugPrint("Car Details Response: ${result['data']}");
      notificationcountmodel = NotificationUnreadCount.fromJson(result['data']);

      // debugPrint("${CarFeaturesModel?.data?.first.id} address");
      notificationcountmodels = notificationcountmodel;
      notifyListeners();
    } else {
      debugPrint("Failed to fetch hotel details (11). Error: ${result['message']}");
      return null;
    }
  }

  Future<bool> notificationread({
    String? id,
  }) async {
    final result = await makeMultipartRequest(
        '${ApiUrls.baseUrl}${ApiUrls.readednotification}$id',
        'POST',
        {},
        _token ?? '',
        requiresAuth: true);

    if (result['success']) {
      debugPrint(
          "success message${result['data']['message'] == " Read successfully!"}");
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  Future<bool> postpaymentmethod(
      {String? depositoption,
      String? paymentgateway,
      String? termconditions}) async {
    final result = await makeMultipartRequest(
        '${ApiUrls.baseUrl}${ApiUrls.postvendorcreditall}',
        'POST',
        {
          "deposit_option": depositoption ?? "",
          "payment_gateway": paymentgateway ?? "",
          "term_conditions": termconditions ?? ""
        },
        _token ?? '',
        requiresAuth: true);

    if (result['success']) {
      showErrorToast(result['data']['message']);

      notifyListeners();
      return true;
    } else {
      showErrorToast(result['message']);
      return false;
    }
  }

  Future fetchunreadnotification() async {
    debugPrint(
        "Fetching UnRead Notification: ${ApiUrls.baseUrl}${ApiUrls.getnotificationunread}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.getnotificationunread}',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    debugPrint("${result['success']} success check");
    if (result['success']) {
      debugPrint("Car Details Response: ${result['data']}");
      notificationmodelunread = NotificationModel.fromJson(result['data']);

      // debugPrint("${CarFeaturesModel?.data?.first.id} address");
      notificationmodelunreads = notificationmodelunread;
      notifyListeners();
    } else {
      debugPrint("Failed to fetch hotel details (12). Error: ${result['message']}");
      return null;
    }
  }

  void addedu() {
    edu.add(EDU());
  }

  void addhealth() {
    health.add(HEALTH());
  }

  void addtransform() {
    transform.add(TRANSFORM());
  }

  void removefaq(int index) {
    faq.removeAt(index);

    notifyListeners();
  }

  void removeedu(int index) {
    edu.removeAt(index);

    notifyListeners();
  }

  void removehealth(int index) {
    health.removeAt(index);

    notifyListeners();
  }

  void removetransform(int index) {
    transform.removeAt(index);

    notifyListeners();
  }

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

  Future fetchcartypes() async {
    log("Fetching Car Type: ${ApiUrls.baseUrl}${ApiUrls.getvednorcartypes}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.getvednorcartypes}',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("Car Details Response: ${result['data']}");
      cartypes = CarFeaturesModel.fromJson(result['data']);

      // log("${CarFeaturesModel?.data?.first.id} address");
      cartypess = cartypes;
      notifyListeners();
    } else {
      log("Failed to fetch hotel details (13). Error: ${result['message']}");
      return null;
    }
  }

  Future fetchnotification() async {
    log("Fetching Notification: ${ApiUrls.baseUrl}${ApiUrls.getnotification}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.getnotification}', 'GET', {}, _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("Car Details Response: ${result['data']}");
      notificationmodel = NotificationModel.fromJson(result['data']);

      // log("${CarFeaturesModel?.data?.first.id} address");
      notificationmodels = notificationmodel;
      notifyListeners();
    } else {
      log("Failed to fetch hotel details. (14) Error: ${result['message']}");
      return null;
    }
  }

  Future fetchcarfeatures() async {
    log("Fetching Car Featues: ${ApiUrls.baseUrl}${ApiUrls.getvednoraddcarfeatures}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.getvednoraddcarfeatures}',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("Car Details Response: ${result['data']}");
      carfeatures = CarFeaturesModel.fromJson(result['data']);

      // log("${CarFeaturesModel?.data?.first.id} address");
      carfeaturess = carfeatures;
      notifyListeners();
    } else {
      log("Failed to fetch hotel details (15). Error: ${result['message']}");
      return null;
    }
  }

  Future alltransactionvendor() async {
    log("Fetching Transaction Vendor: ${ApiUrls.baseUrl}${ApiUrls.creaditalltransaction}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.creaditalltransaction}',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("Car Details Response: ${result['data']}");
      alltrasaction = AllTransactionModel.fromJson(result['data']);

      // log("${CarFeaturesModel?.data?.first.id} address");
      alltrasactions = alltrasaction;
      notifyListeners();
    } else {
      log("Failed to fetch hotel details (16). Error: ${result['message']}");
      return null;
    }
  }

  Future Creditbalances() async {
    log("Fetching Credit Balances: ${ApiUrls.baseUrl}${ApiUrls.creditbalance}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.creditbalance}', 'GET', {}, _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("Car Details Response: ${result['data']}");
      creditbalance = CreditBalanceModel.fromJson(result['data']);

      // log("${CarFeaturesModel?.data?.first.id} address");
      creditbalances = creditbalance;
      notifyListeners();
    } else {
      log("Failed to fetch hotel details (17). Error: ${result['message']}");
      return null;
    }
  }

  Future Pendingcredit() async {
    log("Fetching Pending Credit: ${ApiUrls.baseUrl}${ApiUrls.pendingcredit}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.pendingcredit}', 'GET', {}, _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("Car Details Response: ${result['data']}");
      pendingcredit = PendingCreditModel.fromJson(result['data']);

      // log("${CarFeaturesModel?.data?.first.id} address");
      pendingcredits = pendingcredit;
      notifyListeners();
    } else {
      log("Failed to fetch hotel details (18). Error: ${result['message']}");
      return null;
    }
  }

  Future fetchbuycredit() async {
    log("Fetching Buy Credit: ${ApiUrls.baseUrl}${ApiUrls.vendordetailsbuy}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.vendordetailsbuy}',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("Car Details Response: ${result['data']}");
      buycredit = BuyCreditModel.fromJson(result['data']);

      // log("${CarFeaturesModel?.data?.first.id} address");
      buycredits = buycredit;
      notifyListeners();
    } else {
      log("Failed to fetch hotel details (19). Error: ${result['message']}");
      return null;
    }
  }

  // Authentication methods
  Future<bool> loginvendor(
      String firstname,
      String lastname,
      String bussinessname,
      String email,
      String phone,
      String password,
      String term) async {
    await loadToken();

    final result = await makeRequest(
      '${ApiUrls.baseUrl}${ApiUrls.vendorsignup}',
      'POST',
      {
        'first_name': firstname,
        'last_name': lastname,
        'business_name': bussinessname,
        'email': email.trim(),
        "phone": phone,
        'password': password.trim(),
        "term": term
      },
      _token ?? '',
    );

    if (result['success']) {
      _token = result['data']['access_token'];
      print("token${_token}");
      await saveToken(_token ?? '');
      showSuccessToast(result['data']['message']);
      print("result1${result['success']}");

      notifyListeners();
      return true;
    } else {
      print("result${result}");

      showErrorToast(result['message']);
      return false;
    }
  }

  Future updatecarvendor({
    List<FAQ2>? faqs,
    int carId = 0,
    String title = "",
    List<ExtraPrices2>? extraPrice,
    String content = "",
    String youtubeVideoText = "",
    File? bannerimages,
    File? featuredimages,
    List<File> galleryimage = const [],
    int minimumDayBeforeBooking = 0,
    int minimumdaystaycontroller = 0,
    String door = "",
    String baggage = "",
    String locationId = "2",
    String address = "",
    String mapLat = "",
    String mapLong = "",
    String mapZoom = "0",
    String defaultState = "",
    String price = "",
    String zooms = "5",
    String salePrice = "",
    String car = "",
    String passenger = "2",
    String gear = "",
    List<int> selectedCartypeIds = const [],
    List<int> selectedCarFeatureIds = const [],
    String defaultstates = "",
    bool enableExtraPrice = false,
    String ical = "",
  }) async {
    await loadToken();

    log("$locationId locationIdchecking");

    final body = {
      'car_id': carId.toString(),
      'title': title,
      'content': content,
      'video': youtubeVideoText,
      "default_state": defaultState,
      // 'star_rate': sta,
      // 'related_ids': children.toString(),
      // 'location_id': children.toString(),
      "location_id": locationId,

      // 'address': address,
      'map_lat': mapLat,
      'map_lng': mapLong,
      // ignore: equal_keys_in_map
      "terms":
          "${selectedCartypeIds.map((id) => id.toString()).join(',')},${selectedCarFeatureIds.map((id) => id.toString()).join(',')}",
      //  'extra_price[0][name]':textFields,
      // 'extra_price[0][type]':textFields2,
      'map_zoom': "10",
      // 'check_in_time': children.toString(),
      // 'check_out_time': children.toString(),
      'min_day_before_booking': minimumDayBeforeBooking.toString(),
      'enable_extra_price': termsAccepted == true ? '1' : '0',
      'sale_price': salePrice.toString(),
      'status': "publish",
      'price': price.toString(),
      'number': int.tryParse(car)?.toString() ?? '0',
      'min_day_stays': minimumdaystaycontroller.toString(),
      'passenger': passenger,
      'gear': gear,
      'baggage': baggage,
      'door': door,
      'ical_import_url': ical,

      'address': address.toString(),
    };

    if (extraPrice != null) {
      List<Map<String, dynamic>> extraPriceForVendorListJsonList = extraPrice
          .map((valll) => {
                "name": valll.name?.value.text ?? "",
                "name_ja": valll.namejapanese?.value.text ?? "",
                "name_egy": valll.nameegyptian?.value.text ?? "",
                "price": valll.price?.value.text ?? "",
                "type": valll.type,
              })
          .toList();
      body.addAll({'extra_price': jsonEncode(extraPriceForVendorListJsonList)});
    }

    if ((faqs ?? []).isNotEmpty) {
      print("faq${faq}");
      List<Map<String, dynamic>> faqJsonList = faqs!
          .map((faq) => {
                'title': faq.title?.value.text ?? "",
                'content': faq.content?.value.text ?? "",
              })
          .toList();
      body.addAll({'faqs': jsonEncode(faqJsonList)});
    }
    var uri = Uri.parse('${ApiUrls.baseUrl}${ApiUrls.vendorupdatecars}');
    log("${uri}");
    var request = await MultipartRequest(
      'POST',
      uri,
    );
    request.headers.addAll({
      'Accept': 'application/json',
      'Accept-Language': gettt.Get.locale?.languageCode == "en" ? "en" : "ar",
      'Authorization': 'Bearer $_token',
    });
    if (bannerimages != null) {
      request.files
          .add(await MultipartFile.fromPath('banner_image', bannerimages.path));
    }

    if (galleryimage.isNotEmpty) {
      for (var image in galleryimage) {
        request.files
            .add(await MultipartFile.fromPath('gallery[]', image.path));
      }
    }
    if (featuredimages != null) {
      request.files
          .add(await MultipartFile.fromPath('image', featuredimages.path));
    }

    request.fields.addAll(body);
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

  Future addnewcarvendor() async {
    await loadToken();
    log("$termsAccepted termsAccepted");
    final body = {
      'title': titlecontroller.text,
      'content': await contentcontroller.getText(),
      'video': youtubecontroller.text,
      "default_state": defaultstate.toString(),
      // 'star_rate': sta,
      // 'related_ids': children.toString(),
      // 'location_id': children.toString(),
      "location_id": locationids.toString(),

      'address': addresscontroller.text,
      'enable_extra_price': termsAccepted == true ? '1' : '0',
      'map_lat': latitude.toString(),
      'map_lng': longitude.toString(),
      // ignore: equal_keys_in_map
      "terms":
          "${selectedCartypeIds.map((id) => id.toString()).join(',')},${selectedCarFeatureIds.map((id) => id.toString()).join(',')}",
      //  'extra_price[0][name]':textFields,
      // 'extra_price[0][type]':textFields2,
      'map_zoom': (int.tryParse(zoom ?? "10") ?? 10).toString(),
      // 'check_in_time': children.toString(),
      // 'check_out_time': children.toString(),
      'min_day_before_booking': minimumcontroller.text,
      'sale_price': salepricecontroller.text,
      'status': "publish",
      'price': pricecontroller.text,
      'number': int.tryParse(carcontroller.text)?.toString() ?? '0',
      'min_day_stays': minimumdaystaycontroller.text,
      'passenger': selectpassanger.toString(),
      'gear': gearcontroller.text,
      'baggage': selectbaggage.toString(),
      'door': selectdoor.toString(),
      'ical_import_url': importUrlController.text
    };
    List<Map<String, dynamic>> extraprices = [];

    for (var i = 0; i < extraprice.length; i++) {
      extraprices.add({
        'price': extraprice[i].price,
        "name_ja": extraprice[i].japanesename ?? "",
        "name_egy": extraprice[i].egyptianame ?? "",
        'type': extraprice[i].type,
        'name': extraprice[i].name
      });
    }
    body['extra_price'] = json.encode(extraprices);

    List<Map<String, dynamic>> faqList = [];

    for (var i = 0; i < faq.length; i++) {
      faqList.add({
        'title': faq[i].title?.toString() ?? "",
        'content': faq[i].content?.toString() ?? ""
      });
    }
    body['faqs'] = json.encode(faqList);

    var uri = Uri.parse('${ApiUrls.baseUrl}${ApiUrls.vendoraddcars}');

    var request = await MultipartRequest(
      'POST',
      uri,
    );
    request.headers.addAll({
      'Accept': 'application/json',
      'Accept-Language': gettt.Get.locale?.languageCode == "en" ? "en" : "ar",
      'Authorization': 'Bearer $_token',
    });
    request.files
        .add(await MultipartFile.fromPath('banner_image', bannerimage!.path));

    for (var image in pickedImagefile) {
      request.files.add(await MultipartFile.fromPath('gallery[]', image.path));
    }
    request.files
        .add(await MultipartFile.fromPath('image', featuredimage!.path));
    request.fields.addAll(body);
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

  Future addnewhotelvendor() async {
    await loadToken();
    log(
      "${int.tryParse(zoom ?? "10")?.toString()}",
    );
    final body = {
      'title': titlecontroller.text,
      'content': await contentcontroller.getText(),
      'video': youtubecontroller.text,
      "default_state": defaultstate.toString(),
      // 'star_rate': sta,
      // 'related_ids': children.toString(),
      // 'location_id': children.toString(),
      "location_id": locationids.toString(),

      'address': addresscontroller.text,
      'map_lat': latitude.toString(),
      'map_lng': longitude.toString(),
      // ignore: equal_keys_in_map
      "terms":
          "${selectedCartypeIds.map((id) => id.toString()).join(',')},${selectedCarFeatureIds.map((id) => id.toString()).join(',')}",
      //  'extra_price[0][name]':textFields,
      // 'extra_price[0][type]':textFields2,
      'map_zoom': (int.tryParse(zoom ?? "10") ?? 10).toString(),
      // 'check_in_time': children.toString(),
      // 'check_out_time': children.toString(),
      'min_day_before_booking': minimumcontroller.text,
      'sale_price': salepricecontroller.text,
      'status': "publish",
      'price': pricecontroller.text,
      'number': int.tryParse(carcontroller.text)?.toString() ?? '0',
      'min_day_stays': minimumdaystaycontroller.text,
      'passenger': selectpassanger.toString(),
      'gear': gearcontroller.text,
      'baggage': selectbaggage.toString(),
      'door': selectdoor.toString(),
      'ical_import_url': importUrlController.text
    };
    for (var i = 0; i < extraprice.length; i++) {
      body['extra_price[$i][price]'] = extraprice[i].price ?? "";
    }
    for (var i = 0; i < extraprice.length; i++) {
      body['extra_price[$i][type]'] = extraprice[i].type ?? "";
    }

    for (var i = 0; i < extraprice.length; i++) {
      body['extra_price[$i][name]'] = extraprice[i].name ?? "";
    }
    for (var i = 0; i < faq.length; i++) {
      body['faqs[$i][title]'] = faq[i].title ?? "";
    }
    for (var i = 0; i < faq.length; i++) {
      body['faqs[$i][content]'] = faq[i].content ?? "";
    }
    var uri = Uri.parse('${ApiUrls.baseUrl}${ApiUrls.vendoraddhotels}');

    var request = await MultipartRequest(
      'POST',
      uri,
    );
    request.headers.addAll({
      'Accept': 'application/json',
      'Accept-Language': gettt.Get.locale?.languageCode == "en" ? "en" : "ar",
      'Authorization': 'Bearer $_token',
    });
    request.files
        .add(await MultipartFile.fromPath('banner_image', bannerimage!.path));

    for (var image in pickedImagefile) {
      request.files.add(await MultipartFile.fromPath('gallery[]', image.path));
    }
    request.files
        .add(await MultipartFile.fromPath('image', featuredimage!.path));
    request.fields.addAll(body);
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

  Future<bool> signup({
    String? email,
    String? password,
    String? firstName,
    String? lastName,
    String? phoneNo,
    String? businessName,
  }) async {
    Map<String, String> userData = {
      'first_name': firstName ?? '',
      'last_name': lastName ?? '',
      'email': email ?? '',
      'phone': phoneNo ?? '',
      'password': password ?? '',
      'business_name': businessName ?? '',
    };
    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.signup}', 'POST', userData, _token ?? '');

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
      showSuccessToast(result['message']);
      // Additional cleanup if needed
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

  // Cleanup method
  void dispose() {
    firstnamecontroller.dispose();
    lastNameInputController.dispose();
    businessNameInputController.dispose();
    emailInputController.dispose();
    mobileNumberInputController.dispose();
    passwordInputController.dispose();
    super.dispose();
  }

  fetchunreadnotificationcountno() {}
}
