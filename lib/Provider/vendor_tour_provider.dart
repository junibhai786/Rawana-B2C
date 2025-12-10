import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Urls/url_holder_loan.dart';
import 'package:moonbnd/modals/add_tour_location_model.dart';
import 'package:moonbnd/modals/all_tour_vendor_model.dart';
import 'package:moonbnd/modals/tour_travel_type_model.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart' as gettt;
import 'package:moonbnd/modals/tour_vendor_detail_model.dart';
import 'package:moonbnd/vendor/tour/tour_location_screen.dart';
import 'package:moonbnd/vendor/tour/tour_one_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:html_editor_plus/html_editor.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Include {
  String? title;

  Include({this.title});

  // Add toJson method
  Map<String, dynamic> toJson() {
    return {
      'title': title ?? '',
    };
  }
}

class PERSONTYPE {
  String? name;
  String? description;
  String? namear;
  String? descriptionar;
  String? min;
  String? max;
  String? price;

  PERSONTYPE({
    this.name,
    this.description,
    this.namear,
    this.descriptionar,
    this.min,
    this.max,
    this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name ?? '',
      'desc': description ?? '',
      'name_ar': namear ?? '',
      'desc_ar': descriptionar ?? '',
      'min': min ?? '0',
      'max': max ?? '0',
      'price': price ?? '0',
    };
  }
}

class EXTRAPRICE {
  String? name;
  String? namear;
  String? price;
  String? type;

  EXTRAPRICE({this.name, this.namear, this.price, this.type});

  Map<String, dynamic> toJson() {
    return {
      'name': name ?? '',
      'name_ar': namear ?? '',
      'price': price ?? '',
      'type': type ?? 'one time'
    };
  }
}

class VendorTourProvider with ChangeNotifier {
  AllTourVendorModel? tourlist;
  AllTourVendorModel? tourlists;
  String? _token;
  TourTravelModel? traveltype;
  TourTravelModel? traveltypes;
  List<int> selectedtraveltypeIds = [];
  TourTravelModel? facility;
  TourTravelModel? facilities;
  List<int> selectedfacilitytypeIds = [];
  AddTourLocationModel? addtourlocation;
  AddTourLocationModel? addtourlocations;

  TourVendorDetailModel? tourlistdetail;
  TourVendorDetailModel? tourlistdetails;

  TourTravelModel? category;
  TourTravelModel? categories;
  String? locationids;
  String? locationid;

  TextEditingController titlecontroller = TextEditingController();
  // TextEditingController contentcontroller = TextEditingController();
  HtmlEditorController contentcontroller = HtmlEditorController();
  TextEditingController youtubecontroller = TextEditingController();
  TextEditingController pricecontroller = TextEditingController();
  TextEditingController salePricecontroller = TextEditingController();
  TextEditingController addresscontroller = TextEditingController();
  TextEditingController importUrlController = TextEditingController();
  TextEditingController minimumcontroller = TextEditingController();
  TextEditingController minimumdaystaycontroller = TextEditingController();
  TextEditingController faqtitlecontroller = TextEditingController();
  TextEditingController faqcontentcontroller = TextEditingController();
  TextEditingController durationcontroller = TextEditingController();
  TextEditingController maxpeoplecontroller = TextEditingController();

  TextEditingController itinerarytitlecontroller = TextEditingController();
  TextEditingController itinerarycontentcontroller = TextEditingController();
  TextEditingController itinerarydescriptioncontroller =
      TextEditingController();
  TextEditingController includecontroller = TextEditingController();
  TextEditingController excludecontroller = TextEditingController();

  TextEditingController surroundingtitlecontroller = TextEditingController();
  TextEditingController surroundingcontentcontroller = TextEditingController();
  TextEditingController icalimporturlcontroller = TextEditingController();

  List<String> galleryImagePaths = [];

  // Tour basic info
  String? categoryId;
  String? duration;
  String? minPeople;
  String? maxPeople;

  // Include/Exclude lists
  List<FAQ> faq = [];
  /*List<FAQS> faqs = [];*/
  List<PERSONTYPE> personTypes = [];
  List<EXTRAPRICE> extraPrices = [];
  List<Include> includes = [];
  List<Include> excludes = [];
  List<EDU> edu = [];
  List<HEALTH> health = [];
  List<TRANSFORM> transform = [];

  // Itinerary data

  List<Map<String, dynamic>> itinerary = [];

  // Surrounding data
  Map<String, List<Map<String, String>>> surrounding = {
    "1": [], // Education
    "2": [], // Health
    "3": [] // Transportation
  };

  // Location data
  String? locationId;
  String? mapLat;
  String? mapLng;
  String? mapZoom;

  // Pricing data
  final ImagePicker _picker = ImagePicker();
  File? bannerimage;
  File? featuredimage;
  String? price;
  String? salePrice;
  bool enablePersonTypes = false;
  // List<Map<String, dynamic>> personTypes = [
  //   {
  //     'name': '',
  //     'desc': '',
  //     'name_ja': '',
  //     'desc_ja': '',
  //     'name_egy': '',
  //     'desc_egy': '',
  //     'min': '',
  //     'max': '',
  //     'price': '',
  //     'type': '',
  //   }
  // ];
  bool enableExtraPrice = false;

  List<File> pickedImagefile = [];
  List<File> itineraryImagefile = [];
  int? defaultstate;
  // Availability data
  bool enableOpenHours = false;
  Map<String, Map<String, String>> openHours = {};
  String defaultState = "0";

  String? bannerImageUrl;
  String? image;
  List<String> galleryImageUrls = [];

  // Add new field to store image IDs
  Map<int, String> itineraryImageIds = {};

  void addfaq() {
    faq.add(FAQ());
  }

  void removefaq(int index) {
    faq.removeAt(index);

    notifyListeners();
  }

  void addinclude() {
    includes.add(Include());
  }

  void removeinclude(int index) {
    includes.removeAt(index);

    notifyListeners();
  }

  void addexclude() {
    excludes.add(Include());
  }

  void removeexclude(int index) {
    excludes.removeAt(index);

    notifyListeners();
  }

  void additinerary() {
    itinerary.add({'title': '', 'desc': '', 'content': '', 'image_id': ''});

    notifyListeners();
  }

  void removeitinerary(int index) {
    if (index >= 0 && index < itinerary.length) {
      itinerary.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> pickImagebanner() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      bannerimage = File(pickedImage.path); // Store the image file
      notifyListeners();
    }
  }

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

  Future<Map<String, dynamic>> pickitineraryimage(int index) async {
    try {
      final ImagePicker pickedimage = ImagePicker();
      final XFile? image =
          await pickedimage.pickImage(source: ImageSource.gallery);

      if (image != null) {
        // Upload image first
        String? imageId = await uploadImage(File(image.path));

        if (imageId != null) {
          // Ensure itinerary list has enough elements
          if (itinerary.length <= index) {
            for (int i = itinerary.length; i <= index; i++) {
              itinerary.add(
                  {'title': '', 'desc': '', 'content': '', 'image_id': ''});
            }
          }

          // Update itinerary
          itinerary[index]['image_id'] = imageId;

          // Ensure itineraryImagefile list has enough elements
          if (itineraryImagefile.length <= index) {
            for (int i = itineraryImagefile.length; i <= index; i++) {
              itineraryImagefile.add(File(''));
            }
          }

          // Update image file
          itineraryImagefile[index] = File(image.path);

          notifyListeners();
          return {'imageId': imageId, 'image': image.path};
        } else {
          print("Failed to get image ID from upload response");
        }
      }
    } catch (e) {
      print("Error picking/uploading itinerary image: $e");
    }
    return {};
  }

  void removeitineraryimage(int index) {
    if (index > 0 && index < itineraryImagefile.length) {
      itineraryImagefile.removeAt(index);
    }
    notifyListeners();
  }

  Future<void> pickImagefeatured() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      featuredimage = File(pickedImage.path); // Store the image file
      notifyListeners();
    }
  }

  void addedu() {
    edu.add(EDU());
  }

  void removeedu(int index) {
    edu.removeAt(index);

    notifyListeners();
  }

  void addhealth() {
    health.add(HEALTH());
  }

  void removehealth(int index) {
    health.removeAt(index);

    notifyListeners();
  }

  void addtransform() {
    transform.add(TRANSFORM());
  }

  void removetransform(int index) {
    transform.removeAt(index);

    notifyListeners();
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('userToken');
    log("$_token");
  }

  Future fetchalltourvendor() async {
    log("Fetching Tour Details for ID: ${ApiUrls.baseUrl}${ApiUrls.vendoralltour}");
    await loadToken();

    final result = await makeRequest(
      '${ApiUrls.baseUrl}${ApiUrls.vendoralltour}',
      'GET',
      {},
      _token ?? '',
      requiresAuth: true,
    );

    log("${result['success']} success check");
    if (result['success']) {
      log("Tour Details Response: ${result['data']}");
      tourlist = AllTourVendorModel.fromJson(result['data']);

      log(" response of tourlist = ${tourlist?.data} ");
      tourlists = tourlist;
      notifyListeners();
    } else {
      log("Failed to fetch tour details. Error: ${result['message']}");
      return null;
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

  Future<bool> deletetourvendor({
    required String id,
  }) async {
    await loadToken();

    final body = {
      'tour_id': id,
    };
    log("$body bodycheck");
    log("${ApiUrls.baseUrl}${ApiUrls.vendordeletetour} bodycheck");

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.vendordeletetour}',
      'POST',
      body,
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      log("delete submitted successfully: ${result['data']}");
      EasyLoading.showToast("Tour delete successfully !".tr,
          maskType: EasyLoadingMaskType.black);
      return true;
    } else {
      log("Failed to submit review. Error: ${result['message']}");
      return false;
    }
  }

  Future<bool> clonetourvendor({
    required String id,
  }) async {
    await loadToken();

    final body = {
      'tour_id': id,
    };

    // Add review stats to the body

    log("$body bodycheck");
    log("${ApiUrls.baseUrl}${ApiUrls.clonetourvendor} ");

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.clonetourvendor}',
      'POST',
      body,
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      EasyLoading.showToast("Tour cloned successfully !".tr,
          maskType: EasyLoadingMaskType.black);

      return true;
    } else {
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);

      return false;
    }
  }

  Future<bool> publishtourvendor({
    required String id,
  }) async {
    await loadToken();

    final body = {
      'tour_id': id,
    };

    // Add review stats to the body

    /* log("$body bodycheck");*/
    log("${ApiUrls.baseUrl}${ApiUrls.vendorpublishtour} bodycheck");

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.vendorpublishtour}/$id',
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

  Future<bool> hidetourvendor({
    required String id,
  }) async {
    await loadToken();

    final body = {
      'tour_id': id,
    };

    log("${ApiUrls.baseUrl}${ApiUrls.vendorhidetour} bodycheck");

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.vendorhidetour}/$id',
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

  Future traveltypetourvendor() async {
    log("Fetching Tour property Details for ID: ${ApiUrls.baseUrl}${ApiUrls.vendortraveltype}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.vendortraveltype}',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("property type  Response: ${result['data']}");
      traveltype = TourTravelModel.fromJson(result['data']);

      log(" response of traveltype = ${traveltype?.data} ");
      traveltypes = traveltype;
      notifyListeners();
    } else {
      log("Failed to fetch travel type . Error: ${result['message']}");
      return null;
    }
  }

  Future facilitiestypetourvendor() async {
    log("Fetching Tour facility Details for ID: ${ApiUrls.baseUrl}${ApiUrls.vendortourfacilitytype}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.vendortourfacilitytype}',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("facility type  Response: ${result['data']}");
      facility = TourTravelModel.fromJson(result['data']);

      log(" response of facility tour = ${facility?.data} ");
      facilities = facility;
      notifyListeners();
    } else {
      log("Failed to fetch facility type . Error: ${result['message']}");
      return null;
    }
  }

  Future categorytypetourvendor() async {
    log("Fetching Tour category Details for ID: ${ApiUrls.baseUrl}${ApiUrls.vendortourcategorytype}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.vendortourcategorytype}',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("category type  Response: ${result['data']}");
      category = TourTravelModel.fromJson(result['data']);

      log(" response of category = ${category?.data} ");
      categories = category;
      notifyListeners();
    } else {
      log("Failed to fetch service type . Error: ${result['message']}");
      return null;
    }
  }

  Future fetachaddtourlocation() async {
    log("Fetching Tour Details for ID: ${ApiUrls.baseUrl}${ApiUrls.getaddcarlocation}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.getaddtourlocation}',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("Tour Details Response: ${result['data']}");
      addtourlocation = AddTourLocationModel.fromJson(result['data']);

      log("${addtourlocation?.data?.first.name} address");
      addtourlocations = addtourlocation;
      notifyListeners();
    } else {
      log("Failed to fetch hotel details. Error: ${result['message']}");
      return null;
    }
  }

  Future<bool> addNewTour() async {
    await loadToken();

    // Validate required fields
    if (titlecontroller.text.isEmpty ||
        (await contentcontroller.getText()).isEmpty) {
      showErrorToast('Title and content are required');
      return false;
    }

    // Validate location
    if (locationid == null) {
      showErrorToast('Please select a location');
      return false;
    }

    // Main body with tour-specific fields
    final body = {
      'title': titlecontroller.text,
      'content': await contentcontroller.getText(),
      'video': youtubecontroller.text,
      'category_id': categoryId ?? "",
      'duration': durationcontroller.text,
      'min_day_before_booking': minimumdaystaycontroller.text,
      'min_people': minimumcontroller.text,
      'max_people': maxpeoplecontroller.text,
      'location_id': locationid,
      'address': addresscontroller.text,
      'map_lat': mapLat ?? "",
      'map_lng': mapLng ?? "",
      'map_zoom': (int.tryParse(mapZoom ?? "10") ?? 10).toString(),
      'price': pricecontroller.text,
      'sale_price': salePricecontroller.text,
      'status': "publish",
      'default_state': defaultState,
      'enable_person_types': enablePersonTypes ? '1' : '0',
      'enable_extra_price': enableExtraPrice ? '1' : '0',
      'ical_import_url': icalimporturlcontroller.text,
      // 'enable_open_hours': enableOpenHours ? '1' : '0',
      'terms':
          "${selectedtraveltypeIds.map((id) => id.toString()).join(',')},${selectedfacilitytypeIds.map((id) => id.toString()).join(',')}",

      // Update person types handling
      'person_types': enablePersonTypes
          ? json.encode(personTypes
              .map((type) => {
                    'name': type.name ?? '',
                    'desc': type.description ?? '',
                    'name_ar': type.namear ?? '',
                    'desc_ar': type.descriptionar ?? '',
                    'min': type.min ?? '0',
                    'max': type.max ?? '0',
                    'price': type.price ?? '0'
                  })
              .toList())
          : '',

      // Add extra prices data if enabled
      'extra_price': enableExtraPrice
          ? json.encode(extraPrices
              .map((price) => {
                    'name': price.name ?? '',
                    'name_ar': price.namear ?? '',
                    'price': price.price ?? '',
                    'type': price.type ?? 'one_time'
                  })
              .toList())
          : '',
    };

    // Only add non-empty includes
    List<Map<String, dynamic>> includesList = includes
        .where((item) => item.title?.isNotEmpty == true)
        .map((item) => item.toJson())
        .toList();
    if (includesList.isNotEmpty) {
      body['include'] = json.encode(includesList);
    }

    // Only add non-empty excludes
    List<Map<String, dynamic>> excludesList = excludes
        .where((item) => item.title?.isNotEmpty == true)
        .map((item) => item.toJson())
        .toList();
    if (excludesList.isNotEmpty) {
      body['exclude'] = json.encode(excludesList);
    }

    // Update itinerary handling to include image IDs
    List<Map<String, dynamic>> itineraryList = [];
    for (int i = 0; i < itinerary.length; i++) {
      if (itinerary[i]['title']?.isNotEmpty == true ||
          itinerary[i]['desc']?.isNotEmpty == true ||
          itinerary[i]['content']?.isNotEmpty == true) {
        Map<String, dynamic> item = {
          'title': itinerary[i]['title'] ?? '',
          'desc': itinerary[i]['desc'] ?? '',
          'content': itinerary[i]['content'] ?? '',
          'image_id': itinerary[i]['image_id'] ?? '', // Include the image_id
        };
        itineraryList.add(item);
      }
    }

    if (itineraryList.isNotEmpty) {
      body['itinerary'] = json.encode(itineraryList);
    }

    // Only add non-empty FAQs
    List<Map<String, dynamic>> faqList = faq
        .where((item) =>
            item.title?.isNotEmpty == true && item.content?.isNotEmpty == true)
        .map((item) => {'title': item.title, 'content': item.content})
        .toList();
    if (faqList.isNotEmpty) {
      body['faqs'] = json.encode(faqList);
    }

    // Convert surrounding data
    Map<String, List<Map<String, dynamic>>> surroundingData = {
      "1": edu
          .map((item) => {
                'name': item.title ?? '',
                'content': item.content ?? '',
                'value': item.distance ?? '',
                'type': item.type ?? ''
              })
          .toList(),
      "2": health
          .map((item) => {
                'name': item.title ?? '',
                'content': item.content ?? '',
                'value': item.distance ?? '',
                'type': item.type ?? ''
              })
          .toList(),
      "3": transform
          .map((item) => {
                'name': item.title ?? '',
                'content': item.content ?? '',
                'value': item.distance ?? '',
                'type': item.type ?? ''
              })
          .toList(),
    };
    body['surrounding'] = json.encode(surroundingData);

    // Create multipart request
    var uri = Uri.parse('${ApiUrls.baseUrl}${ApiUrls.vendoraddtour}');
    var request = await MultipartRequest('POST', uri);

    // Add headers
    request.headers.addAll({
      'Accept': 'application/json',
      'Accept-Language': gettt.Get.locale?.languageCode == "en" ? "en" : "ar",
      'Authorization': 'Bearer $_token',
    });

    // Add files
    if (featuredimage != null) {
      request.files
          .add(await MultipartFile.fromPath('image', featuredimage!.path));
    }

    if (bannerimage != null) {
      request.files
          .add(await MultipartFile.fromPath('banner_image', bannerimage!.path));
    }

    // Add gallery images
    for (var file in pickedImagefile) {
      request.files.add(await MultipartFile.fromPath('gallery[]', file.path));
    }

    // Add itinerary images
    for (var file in itineraryImagefile) {
      request.files.add(await MultipartFile.fromPath('image', file.path));
    }
    // Add fields
    Map<String, String> stringFields = {};
    body.forEach((key, value) {
      if (value != null) {
        stringFields[key] = value.toString();
      }
    });
    request.fields.addAll(stringFields);

    try {
      var streamedResponse = await request.send();
      var result = await Response.fromStream(streamedResponse);

      log('Tour Upload request: $body');

      if (result.statusCode == 200 || result.statusCode == 201) {
        var jsonResponse = json.decode(result.body);
        log('Tour Upload Response: $jsonResponse');
        showSuccessToast(jsonResponse['message']);
        notifyListeners();
        return true;
      } else {
        showErrorToast(json.decode(result.body)['message']);
        log('Failed to upload tour. Status code: ${result.statusCode}');
        log('Response body: ${result.body}');
        return false;
      }
    } catch (e) {
      log('Error uploading tour: $e');
      showErrorToast('Error uploading tour');
      return false;
    }
  }

  // Helper methods to update data
  void updateBasicInfo({
    required String categoryId,
    required String duration,
    required String minPeople,
    required String maxPeople,
    required String youtube,
    required String minDayBeforeBooking,
  }) {
    this.categoryId = categoryId;
    this.duration = duration;
    this.minPeople = minPeople;
    this.maxPeople = maxPeople;
    this.youtubecontroller.text = youtube;
    this.minimumdaystaycontroller.text = minDayBeforeBooking;
    notifyListeners();
  }

  void updateLocation({
    required String locationId,
    required String lat,
    required String lng,
    required String zoom,
  }) {
    this.locationId = locationId;
    this.mapLat = lat;
    this.mapLng = lng;
    this.mapZoom = zoom;
    notifyListeners();
  }

  void updatePricing({
    required String price,
    required String salePrice,
    required bool enablePersonTypes,
    required List<dynamic> personTypes,
  }) {
    this.price = price;
    this.salePrice = salePrice;
    this.enablePersonTypes = enablePersonTypes;
    this.personTypes = personTypes.map((type) {
      return PERSONTYPE(
        name: type['name'],
        description: type['desc'],
        namear: type['name_ar'],
        descriptionar: type['desc_ar'],
        min: type['min']?.toString(),
        max: type['max']?.toString(),
        price: type['price']?.toString(),
      );
    }).toList();
    notifyListeners();
  }

  void updateAvailability({
    required bool enableOpenHours,
    required Map<String, Map<String, String>> openHours,
    required String defaultState,
  }) {
    this.enableOpenHours = enableOpenHours;
    this.openHours = openHours;
    this.defaultState = defaultState;
    notifyListeners();
  }

  Future fetchalltourdetailvendor(String id) async {
    log("Fetching Tour vendor Details for ID: ${ApiUrls.baseUrl}${ApiUrls.vendoralltourdetails}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.vendoralltourdetails}/$id',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("Tour vendor Details Response: ${result['data']}");
      tourlistdetail = TourVendorDetailModel.fromJson(result['data']);

      log(" response of tourlist = ${tourlistdetail?.data?.first.title} ");

      tourlistdetails = tourlistdetail;
      notifyListeners();
      return tourlistdetail?.data;
    } else {
      log("Failed to fetch tour vendor details. Error: ${result['message']}");
      return null;
    }
  }

  Future<bool> updateTour(String tourId) async {
    log("Update Tour request: $tourId");

    await loadToken();

    if (titlecontroller.text.isEmpty ||
        (await contentcontroller.getText()).isEmpty) {
      showErrorToast('Title and content are required');
      return false;
    }

    if (locationid == null) {
      showErrorToast('Please select a location');
      return false;
    }

    final body = {
      'tour_id': tourId,
      'title': titlecontroller.text,
      'content': await contentcontroller.getText(),
      'default_state': '1',
      'faqs': json.encode(faq.isEmpty
          ? []
          : faq
              .where((item) =>
                  item.title?.isNotEmpty == true &&
                  item.content?.isNotEmpty == true)
              .map((item) =>
                  {'title': item.title ?? '', 'content': item.content ?? ''})
              .toList()),
      'include': json.encode(includes.isEmpty
          ? []
          : includes
              .where((item) => item.title?.isNotEmpty == true)
              .map((item) => {'title': item.title ?? ''})
              .toList()),
      'exclude': json.encode(excludes.isEmpty
          ? []
          : excludes
              .where((item) => item.title?.isNotEmpty == true)
              .map((item) => {'title': item.title ?? ''})
              .toList()),
      'itinerary': json.encode(itinerary.isEmpty
          ? []
          : itinerary
              .where((item) =>
                  item['title']?.isNotEmpty == true ||
                  item['desc']?.isNotEmpty == true ||
                  item['content']?.isNotEmpty == true)
              .map((item) => {
                    'title': item['title'] ?? '',
                    'desc': item['desc'] ?? '',
                    'content': item['content'] ?? '',
                    'image_id': item['image_id'] ?? ''
                  })
              .toList()),
      'category_id': categoryId ?? "",
      'duration': durationcontroller.text,
      'min_day_before_booking': minimumdaystaycontroller.text,
      'min_people': minimumcontroller.text,
      'max_people': maxpeoplecontroller.text,
      'location_id': locationid,
      'address': addresscontroller.text,
      'map_lat': mapLat ?? "",
      'map_lng': mapLng ?? "",
      'map_zoom': (int.tryParse(mapZoom ?? "10") ?? 10).toString(),
      'price': pricecontroller.text,
      'sale_price': salePricecontroller.text,
      'status': "publish",
      'enable_person_types': enablePersonTypes ? '1' : '0',
      'enable_extra_price': enableExtraPrice ? '1' : '0',
      'ical_import_url': icalimporturlcontroller.text,
      'terms':
          "${selectedtraveltypeIds.map((id) => id.toString()).join(',')},${selectedfacilitytypeIds.map((id) => id.toString()).join(',')}",

      // Add person types data
      'person_types': enablePersonTypes
          ? json.encode(personTypes
              .map((type) => {
                    'name': type.name ?? '',
                    'desc': type.description ?? '',
                    'name_ar': type.namear ?? '',
                    'desc_ar': type.descriptionar ?? '',
                    'min': type.min ?? '0',
                    'max': type.max ?? '0',
                    'price': type.price ?? '0'
                  })
              .toList())
          : '',

      // Add extra prices data
      'extra_price': enableExtraPrice
          ? json.encode(extraPrices
              .map((price) => {
                    'name': price.name ?? '',
                    'name_ar': price.namear ?? '',
                    'price': price.price ?? '',
                    'type': price.type ?? 'one_time'
                  })
              .toList())
          : '',
    };

    try {
      var uri = Uri.parse('${ApiUrls.baseUrl}${ApiUrls.vendoralltourupdate}');
      log('Update URL: $uri'); // Add this log to verify the URL

      var request = await MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
        'Accept-Language': gettt.Get.locale?.languageCode == "en" ? "en" : "ar",
        'Authorization': 'Bearer $_token',
      });

      // Add files
      if (featuredimage != null && !featuredimage!.path.startsWith('http')) {
        request.files
            .add(await MultipartFile.fromPath('image', featuredimage!.path));
      }

      if (bannerimage != null && !bannerimage!.path.startsWith('http')) {
        request.files.add(
            await MultipartFile.fromPath('banner_image', bannerimage!.path));
      }

      // Add gallery images
      for (var file in pickedImagefile) {
        if (!file.path.startsWith('http')) {
          request.files
              .add(await MultipartFile.fromPath('gallery[]', file.path));
        }
      }

      // Add fields
      Map<String, String> stringFields = {};
      body.forEach((key, value) {
        if (value != null) {
          stringFields[key] = value.toString();
        }
      });
      request.fields.addAll(stringFields);

      var streamedResponse = await request.send();
      var result = await Response.fromStream(streamedResponse);

      if (result.statusCode == 200 || result.statusCode == 201) {
        var jsonResponse = json.decode(result.body);
        log('Tour Update Response: $jsonResponse');
        showSuccessToast(jsonResponse['message']);
        notifyListeners();
        return true;
      } else {
        showErrorToast(json.decode(result.body)['message']);
        log('Failed to update tour. Status code: ${result.statusCode}');
        log('Response body: ${result.body}');
        return false;
      }
    } catch (e) {
      log('Error updating tour: $e');
      showErrorToast('Error updating tour');
      return false;
    }
  }

  // Add new method for image upload
  Future<String?> uploadImage(File imageFile) async {
    try {
      final uri = Uri.parse('${ApiUrls.baseUrl}${ApiUrls.uploadImage}');
      var request = await MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
        'Accept-Language': gettt.Get.locale?.languageCode == "en" ? "en" : "ar",
        'Authorization': 'Bearer $_token',
      });

      // Add the image file
      request.files.add(await MultipartFile.fromPath('file', imageFile.path));

      var streamedResponse = await request.send();
      var result = await Response.fromStream(streamedResponse);

      log("Upload Response Status: ${result.statusCode}");

      if (result.statusCode == 200) {
        var jsonResponse = json.decode(result.body);
        log("Image Upload Response: $jsonResponse");

        // Check for image_id in the response
        if (jsonResponse['image_id'] != null) {
          return jsonResponse['image_id'].toString();
        }
      }

      log("Failed to upload image. Status: ${result.statusCode}, Response: ${result.body}");
      return null;
    } catch (e) {
      log("Error uploading image: $e");
      return null;
    }
  }

  Future<bool> editTourvendor({
    String tourId = "",
    String title = "",
    String content = "",
    String youtubeVideoText = "",
    String categoryId = "",
    List<FaqClass> faqList = const [],
    File? bannerimage,
    File? featuredimage,
    List<File> pickedImagefile = const [],
    String minimumDayBeforeBooking = "",
    String minimumdaystaycontroller = "",
    String duration = "",
    String maximumPeople = "",
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
    String minmumPeople = "",
    bool enableExtraPrice = false,
    bool enablePersonTypes = false,
    List<ExtraPriceVendor> extraPriceVendorList = const [],
    String ical = "",
    List<ItineraryClass> itineraryList = const [],
    List<PersonTypeForVendor> personTypeForVendorList = const [],
    List<IncludeClass> IncludeList = const [],
    List<ExcludeClass> ExcludeList = const [],
  }) async {
    await loadToken();

    List<TourTravelDatum>? selectedtraveltypeIds =
        traveltype?.data?.where((test) {
      return test.value == true;
    }).toList();

    List<TourTravelDatum>? selectedfacilitytypeIds =
        facility?.data?.where((test) {
      return test.value == true;
    }).toList();

    final body = {
      'tour_id': tourId,
      'title': title,
      'content': content,
      'video': youtubeVideoText,
      'category_id': categoryId,
      'duration': duration,
      'status': 'publish',
      'max_people': maximumPeople,
      'min_people': minmumPeople,
      'min_day_before_booking': minimumDayBeforeBooking,
      'min_day_stays': minimumdaystaycontroller,
      'location_id': locationId,
      'address': address,
      'map_lat': mapLat,
      'map_lng': mapLong,
      'map_zoom': int.parse("10"),
      'default_state': defaultState == "Always available" ? 0 : 1,
      'price': price,
      'sale_price': salePrice,
      'enable_extra_price': enableExtraPrice == true ? '1' : '0',
      'enable_person_types': enablePersonTypes == true ? '1' : '0',
      "terms":
          "${selectedtraveltypeIds?.map((id) => id.id.toString()).join(',')},${selectedfacilitytypeIds?.map((id) => id.id.toString()).join(',')}",
      'ical_import_url': ical,
    };

    var uri = Uri.parse('${ApiUrls.baseUrl}${ApiUrls.vendoralltourupdate}');

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
    if (IncludeList.isNotEmpty) {
      List<Map<String, dynamic>> faqJsonList = IncludeList.map((includes) => {
            'title': includes.title?.value.text ?? "",
          }).toList();
      body.addAll({'include': jsonEncode(faqJsonList)});
    }

    if (ExcludeList.isNotEmpty) {
      List<Map<String, dynamic>> faqJsonList = ExcludeList.map((excludes) => {
            'title': excludes.title?.value.text ?? "",
          }).toList();
      body.addAll({'exclude': jsonEncode(faqJsonList)});
    }

    if (itineraryList.isNotEmpty) {
      List<Map<String, dynamic>> faqJsonList = itineraryList
          .map((excludes) => {
                'title': excludes.title?.value.text ?? '',
                'desc': excludes.desc?.value.text ?? '',
                'content': excludes.content?.value.text ?? '',
                'image_id': excludes.imageId,
              })
          .toList();
      body.addAll({'itinerary': jsonEncode(faqJsonList)});
    }

    if (enablePersonTypes == true && personTypeForVendorList.isNotEmpty) {
      List<Map<String, dynamic>> personTypeForVendorListJsonList =
          personTypeForVendorList
              .map((valll) => {
                    "name": valll.nameEnglish?.value.text ?? "",
                    "desc": valll.descriptionEnglish?.value.text ?? "",
                    "name_ar": valll.nameArabic?.value.text ?? "",
                    "desc_ar": valll.descriptionArabic?.value.text ?? "",
                    // "name_egy": valll.nameEgyptian?.value.text ?? "",
                    // "desc_egy": valll.descriptionEgyptian?.value.text ?? "",
                    "min": valll.min?.value.text ?? "",
                    "max": valll.max?.value.text ?? "",
                    "price": valll.price?.value.text ?? "",
                  })
              .toList();
      body.addAll(
          {'person_types': jsonEncode(personTypeForVendorListJsonList)});
    }

    if (enableExtraPrice == true && extraPriceVendorList.isNotEmpty) {
      List<Map<String, dynamic>> extraPriceForVendorListJsonList =
          extraPriceVendorList
              .map((valll) => {
                    "name": valll.name?.value.text ?? "",
                    "name_ja": valll.namear?.value.text ?? "",
                    // "name_egy": valll.nameEgy?.value.text ?? "",
                    "price": valll.price?.value.text ?? "",
                    "type": valll.type ?? "",
                  })
              .toList();
      body.addAll({'extra_price': jsonEncode(extraPriceForVendorListJsonList)});
    }

// ... existing code ...
    List<List<Map<String, dynamic>>> surroundingJsonList = [
      // Check if the lists are empty and set to empty lists accordingly
      txtransportationList.isNotEmpty
          ? txtransportationList
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
      txeducationList.isNotEmpty
          ? txeducationList
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

  void clearAllData() {
    // Clear all controllers
    titlecontroller.clear();
    contentcontroller.clear();
    youtubecontroller.clear();
    minimumdaystaycontroller.clear();
    durationcontroller.clear();
    minimumcontroller.clear();
    maxpeoplecontroller.clear();
    faqtitlecontroller.clear();
    faqcontentcontroller.clear();
    includecontroller.clear();
    excludecontroller.clear();
    itinerarytitlecontroller.clear();
    itinerarydescriptioncontroller.clear();
    itinerarycontentcontroller.clear();
    addresscontroller.clear();
    pricecontroller.clear();
    salePricecontroller.clear();
    icalimporturlcontroller.clear();

    // Clear lists
    faq.clear();
    includes.clear();
    excludes.clear();
    itinerary.clear();
    itineraryImagefile.clear();
    itineraryImageIds.clear();
    pickedImagefile.clear();
    personTypes.clear();
    extraPrices.clear();
    edu.clear();
    health.clear();
    transform.clear();
    selectedtraveltypeIds.clear();
    selectedfacilitytypeIds.clear();

    // Clear images
    bannerimage = null;
    featuredimage = null;

    // Clear location data
    locationId = null;
    mapLat = null;
    mapLng = null;
    mapZoom = null;

    // Clear pricing data
    price = null;
    salePrice = null;
    enablePersonTypes = false;
    enableExtraPrice = false;

    // Clear category selection
    categoryId = null;

    // Reset default state
    defaultState = "0";

    // Notify listeners to rebuild UI
    notifyListeners();
  }
}

class FaqClass {
  TextEditingController? title;
  TextEditingController? content;
  DateTime? id;
  FaqClass({this.content, this.title, this.id});
}

class ItineraryClass {
  DateTime? id;
  String? imageId;
  String? image;

  TextEditingController? title;
  TextEditingController? desc;
  TextEditingController? content;

  ItineraryClass(
      {this.id, this.imageId, this.title, this.desc, this.content, this.image});
}

class IncludeClass {
  TextEditingController? title;
  DateTime? id;
  IncludeClass({this.title, this.id});
}

class ExcludeClass {
  TextEditingController? title;
  DateTime? id;
  ExcludeClass({this.title, this.id});
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
      this.type = "one_time"});
}

class PersonTypeForVendor {
  DateTime? id;
  TextEditingController? nameEnglish;
  TextEditingController? descriptionEnglish;
  TextEditingController? nameArabic;
  TextEditingController? descriptionArabic;
  TextEditingController? nameEgyptian;
  TextEditingController? descriptionEgyptian;
  TextEditingController? price;
  TextEditingController? min;
  TextEditingController? max;
  String? type;
  bool? perPerson;
  PersonTypeForVendor(
      {this.nameEgyptian,
      this.nameEnglish,
      this.id,
      this.nameArabic,
      this.descriptionArabic,
      this.descriptionEnglish,
      this.descriptionEgyptian,
      this.perPerson = false,
      this.price,
      this.min,
      this.max,
      this.type = "one_time"});
}

class ExtraPriceVendor {
  DateTime? id;
  TextEditingController? name;
  TextEditingController? namear;
  TextEditingController? nameEgy;
  TextEditingController? price;
  String? type;

  ExtraPriceVendor(
      {this.nameEgy,
      this.id,
      this.namear,
      this.name,
      this.price,
      this.type = "one time"});
}
