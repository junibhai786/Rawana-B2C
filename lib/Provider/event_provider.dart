import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Provider/space_provider.dart';
import 'package:moonbnd/Urls/url_holder_loan.dart';
import 'package:moonbnd/modals/event_catagories_model.dart';
import 'package:moonbnd/modals/event_detail_model.dart';
import 'package:moonbnd/modals/event_details_vendor_model.dart';
import 'package:moonbnd/modals/event_list_model.dart';
import 'package:moonbnd/screens/event/event_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart' as gettt;
import 'package:html_editor_plus/html_editor.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../modals/event_vendor_model.dart';

class EventProvider with ChangeNotifier {
  String? _token;
  EventDetailModal? eventDetail;
  EventDetailModal? _eventDetail;
  Map<int, EventList?> eventListPerCategory = {};

  // Pagination State
  final Map<int, Map<String, dynamic>> _lastSearchParams = {};
  final Map<int, bool> _isLoadingMore = {};
  final Map<int, int> _currentPage = {};

  bool isLoadingMore(int index) => _isLoadingMore[index] ?? false;

  Future<void> fetchNextPage(int index) async {
    if (isLoadingMore(index)) return;

    final currentList = eventListPerCategory[index];

    if (currentList == null ||
        currentList.currentPage == null ||
        currentList.lastPage == null ||
        currentList.currentPage! >= currentList.lastPage!) {
      return;
    }

    _isLoadingMore[index] = true;
    notifyListeners();

    try {
      final nextPage = currentList.currentPage! + 1;
      final params = _lastSearchParams[index] ?? {};

      // Call API with next page
      await eventlistapi(
        index,
        searchParams: params,
        page: nextPage,
        isLoadMore: true,
      );
    } catch (e) {
      log("Error fetching next page for index $index: $e");
    } finally {
      _isLoadingMore[index] = false;
      notifyListeners();
    }
  }

  Future<void> resetPagination(int index) async {
    _currentPage[index] = 1;
    _isLoadingMore[index] = false;
    final params = _lastSearchParams[index] ?? {};
    await eventlistapi(index, searchParams: params, page: 1, isLoadMore: false);
  }

  TextEditingController searchController = TextEditingController();

  EventModalForVendor? eventVendor;
  EventCatagoriesVendorModel? eventCatagoriesVendor;
  EventDetailsForVendor? eventDetailsVendor;
  String defaultState = "Always available";
  /////// event vendor input

  TextEditingController titleController = TextEditingController();
  HtmlEditorController contentController = HtmlEditorController();
  TextEditingController youtubeVideoController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController durationController = TextEditingController();
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
  String defaultStateInput = "";
  TextEditingController priceController = TextEditingController();
  TextEditingController salePriceController = TextEditingController();

  bool termsAccepted = false;
  List<ExtraPriceForVendor> extraPriceSpaceVendorList = [];
  List<TicketsVendorModal> ticketsVendorList = [];

  //// values for api
  String? locationid;
  TextEditingController addresscontroller = TextEditingController();
  String? latitude;
  String? longitude;
  String? zoom;
  List<EducationClass> educationList = [];
  List<EducationClass> healthList = [];
  List<EducationClass> transportationList = [];

  TextEditingController maxGuestController = TextEditingController();

  TextEditingController importUrlController = TextEditingController();

  ///////// end

  int _selectedHomeTab = 1;

  int index = -1;

  void clear() {
    titleController = TextEditingController();

    youtubeVideoController = TextEditingController();
    faqList = [];
    ticketsVendorList = [];
    bannerImage = null;
    featuredImage = null;
    galleryImages = [];
    noOfBedController = TextEditingController();
    startTimeController = TextEditingController();
    noOfBathroomController = TextEditingController();
    minimumAdvanceReservationController = TextEditingController();
    minimumDayStayController = TextEditingController();
    location = null;
    address = null;
    durationController = TextEditingController();

    defaultState = "Always available";
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

    importUrlController = TextEditingController();
    notifyListeners();
  }

  void searchIndex(int txindex) {
    index = txindex;
    notifyListeners();
  }

  int get selectedHomeTab => _selectedHomeTab;

  Future fetchEventDetails(int eventId) async {
    log("Fetching event Details for ID: $eventId");
    log("Fetching event Details for ID: ${ApiUrls.baseUrl}${ApiUrls.eventDetailsEndPoint}/$eventId',");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.eventDetailsEndPoint}/$eventId',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("Car Details Response: ${result['data']}");
      _eventDetail = EventDetailModal.fromJson(result['data']);

      log("${_eventDetail?.data?.address} address");
      eventDetail = _eventDetail;
      notifyListeners();
    } else {
      log("Failed to fetch hotel details. Error: ${result['message']}");
      return null;
    }
  }

  void update() {
    // log('${provider.eventDetailsVendor!.data[0].terms[0].child!.length} lengjj');

    if (eventDetailsVendor!.data[0].terms.isNotEmpty) {
      eventCatagoriesVendor?.data?.forEach((element) {
        for (var i = 0;
            i < eventDetailsVendor!.data[0].terms[0].child!.length;
            i++) {
          if (element.id == eventDetailsVendor!.data[0].terms[0].child?[i].id) {
            element.value = true;
          }
        }
      });
    }
    notifyListeners();
  }

  void setSelectedHomeTab(int index) {
    _selectedHomeTab = index;
    notifyListeners();
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
        'object_model': "event",
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

  Future fetchEventCatagories() async {
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.eventVendorCatagories}',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      log("Space Details Response: ${result['data']}");
      EventCatagoriesVendorModel txeventCatagoriesVendor =
          EventCatagoriesVendorModel.fromJson(result['data']);

      eventCatagoriesVendor = txeventCatagoriesVendor;
      notifyListeners();
    } else {
      log("Failed to fetch space details. Error: ${result['message']}");
      return null;
    }
  }

  Future<Map<String, dynamic>?> leaveReviewForEvent({
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
      await fetchEventDetails(int.parse(serviceId));

      return result['data'];
    } else {
      log("${result} result error");
      log("Failed to submit review. Error: ${result['message']}");
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);
      return null;
    }
  }

  void updateEventSearchParams({
    required String location,
    required DateTime? startDate,
    String? searchQuery,
  }) {
    eventlistapi(5, searchParams: {
      'location': location,
      'startDate': startDate,
    });
  }

  Future<bool> eventlistapi(int index,
      {String? sortBy,
      String? searchQuery,
      required Map<String, Object?> searchParams,
      int page = 1,
      bool isLoadMore = false}) async {
    log("Event List API Call for category index $index ===> Page $page");
    await loadToken();

    // Cache search params for pagination (only if it's a fresh search)
    if (!isLoadMore) {
      _lastSearchParams[index] = Map.from(searchParams);
    }

    // Convert searchParams to query parameters
    final queryParams = {
      'page': page.toString(),
      'per_page': '5',
      if (searchParams['location'] != null)
        'location': searchParams['location'],
      if (searchParams['startDate'] != null)
        'start': DateFormat('MM/dd/yyyy')
            .format(searchParams['startDate'] as DateTime),
      if (searchParams['price_range'] != null)
        'price_range': searchParams['price_range'],
      if (searchParams['review_score'] != null &&
          searchParams['review_score'] != '')
        'review_score': searchParams['review_score'],
      if (searchParams['event_type'] != null &&
          searchParams['event_type'] != '')
        'attrs[11]': searchParams['event_type'],
      if (sortBy != null) 'orderby': sortBy,
    };

    final queryString = Uri(queryParameters: queryParams).query;
    log('$queryString queryStringgg');
    final url = '${ApiUrls.baseUrl}${ApiUrls.eventSearch}?$queryString';
    log('$url checkurl');

    log("API URL: $url");

    // 🧪 VISUAL TEST: Show toast when loading next page
    // if (page > 1) {
    // EasyLoading.showToast("⏳ Loading Page $page...",
    //    duration: const Duration(seconds: 1),
    //   toastPosition: EasyLoadingToastPosition.bottom);
    // }

    final result =
        await makeRequest(url, 'GET', {}, _token ?? '', requiresAuth: true);

    if (result['success']) {
      log("Event List Response for index $index ===> ${result['data']}");
      EventList newEventList = EventList.fromJson(result['data']);

      if (isLoadMore && eventListPerCategory[index] != null) {
        // Append data
        final currentData = eventListPerCategory[index]!.data ?? [];
        final newData = newEventList.data ?? [];

        eventListPerCategory[index]!.data = [...currentData, ...newData];
        eventListPerCategory[index]!.currentPage = newEventList.currentPage;
        eventListPerCategory[index]!.lastPage = newEventList.lastPage;
        eventListPerCategory[index]!.total = newEventList.total;
        eventListPerCategory[index]!.text = newEventList.text;
      } else {
        // Replace data
        eventListPerCategory[index] = newEventList;
      }

      notifyListeners();

      // 🧪 VISUAL TEST: Confirm data loaded
      // if (page > 1) {
      //  EasyLoading.showToast(
      //     "✅ Loaded ${newEventList.data?.length ?? 0} new items!",
      //    duration: const Duration(seconds: 2),
      //   toastPosition: EasyLoadingToastPosition.bottom);
      // }
      return true;
    } else {
      log("Failed to fetch Car list. Error: ${result['message']}");
      return false;
    }
  }

  Future<Map<String, dynamic>?> addToCartForEvent({
    required String serviceId,
    required String serviceType,
    required DateTime startDate,
    List<ExtraPriceEvent>? extraPrices,
    List<PersonTypeForEvent>? personType,
  }) async {
    await loadToken();

    final dateFormat = DateFormat('yyyy-MM-dd');
    final body = {
      'service_id': serviceId,
      'service_type': "event",
      'start_date': dateFormat.format(startDate),
    };

    // Extra prices (existing code)
    if (extraPrices != null) {
      for (int i = 0; i < extraPrices.length; i++) {
        body['extra_price[$i][name]'] = extraPrices[i].name ?? "";
        body['extra_price[$i][price]'] = extraPrices[i].price ?? "";
        body['extra_price[$i][type]'] = extraPrices[i].type ?? "";
        body['extra_price[$i][number]'] = "0";
        body['extra_price[$i][enable]'] =
            extraPrices[i].valueType == true ? "1" : "0";
        body['extra_price[$i][price_type]'] = '';
      }
    }

    if (personType != null) {
      for (int i = 0; i < personType.length; i++) {
        body['ticket_types[$i][code]'] = personType[i].codes;
        body['ticket_types[$i][name]'] = personType[i].name;
        body['ticket_types[$i][price]'] = personType[i].price.toString();
        body['ticket_types[$i][number]'] = personType[i].countValue.toString();
        body['ticket_types[$i][min]'] = personType[i].min.toString();
        body['ticket_types[$i][max]'] = personType[i].max.toString();
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
      log("Add to Cart Response: ${result['data']}");
      EasyLoading.showToast(result['data']["message"],
          maskType: EasyLoadingMaskType.black);
      return result['data'];
    } else {
      EasyLoading.showToast(result["message"],
          maskType: EasyLoadingMaskType.black);
      // log("Failed to add to cart. Error: ${result['message']}");
      return null;
    }
  }

  Future fetchEventVendorDetails() async {
    log("Fetching Tour Details for ID: ${ApiUrls.baseUrl}${ApiUrls.eventVendorForAll}");
    await loadToken();

    final result = await makeRequest(
        '${ApiUrls.baseUrl}${ApiUrls.eventVendorForAll}',
        'GET',
        {},
        _token ?? '',
        requiresAuth: true);

    log("${result['success']} success check");
    if (result['success']) {
      // log("Car Details Response: ${result['data']}");
      EventModalForVendor txxspaceVendor =
          EventModalForVendor.fromJson(result['data']);

      eventVendor = txxspaceVendor;
      notifyListeners();
    } else {
      log("Failed to fetch hotel details. Error: ${result['message']}");
      return null;
    }
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('userToken');
    log("$_token");
  }

  Future<bool> deleteVendorEvent({
    required String id,
  }) async {
    await loadToken();

    final body = {
      'event_id': id,
    };

    // Add review stats to the body

    log("$body bodycheck");
    log("${ApiUrls.baseUrl}${ApiUrls.eventVendorDelete} bodycheck");

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.eventVendorDelete}',
      'POST',
      body,
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      log("Review submitted successfully: ${result['data']}");

      return true;
    } else {
      log("Failed to submit review. Error: ${result['message']}");
      return false;
    }
  }

  Future<bool> cloneEventVendor(String id) async {
    await loadToken();

    final body = {
      'event_id': id,
    };

    // Add review stats to the body

    log("$body bodycheck");
    log("${ApiUrls.baseUrl}${ApiUrls.eventVendorClone} bodycheck");

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.eventVendorClone}',
      'POST',
      body,
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      EasyLoading.showToast("Event cloned successfully !".tr,
          maskType: EasyLoadingMaskType.black);

      return true;
    } else {
      EasyLoading.showToast(result['message'],
          maskType: EasyLoadingMaskType.black);

      return false;
    }
  }

  Future<bool> hideEventVendor({
    required String id,
  }) async {
    await loadToken();

    await loadToken();

    final body = {
      'space_id': id,
    };

    log("${ApiUrls.baseUrl}${ApiUrls.vendorEventHide} bodycheck");

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.vendorEventHide}/$id',
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

  Future<bool> publishEventVendor({
    required String id,
  }) async {
    await loadToken();

    final body = {
      'space_id': id,
    };

    log("${ApiUrls.baseUrl}${ApiUrls.vendorEventPublish} bodycheck");

    final result = await makeMultipartRequest(
      '${ApiUrls.baseUrl}${ApiUrls.vendorEventPublish}/$id',
      'POST',
      body,
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      log("delete submitted successfully: ${result['data']}");
      EasyLoading.showToast("Event delete successfully !".tr,
          maskType: EasyLoadingMaskType.black);
      return true;
    } else {
      log("Failed to submit review. Error: ${result['message']}");
      return false;
    }
  }

  ///// Add Event vendor

  Future<bool> addEventVendor({
    //// screen 1
    String title = "",
    String content = "",
    String youtubeVideoText = "",
    String startTime = '',
    String duration = '',
    List<FaqClass> faqList = const [],
    File? bannerimage,
    File? featuredimage,
    List<File> pickedImagefile = const [],

    //// screen 2
    String locationId = "",
    String address = "",
    String mapLat = "",
    String mapLong = "",
    String mapZoom = "",
    List<EducationClass> txeducationList = const [],
    List<EducationClass> txhealthList = const [],
    List<EducationClass> txtransportationList = const [],
    //// screen 3
    String defaultState = "",
    String price = "",
    String salePrice = "",
    List<TicketsVendorModal> ticketsVendorList = const [],
    bool enableExtraPrice = false,
    List<ExtraPriceForVendor> extraPriceForVendorList = const [],
  }) async {
    await loadToken();

    List<EventCatagories>? txamenity =
        eventCatagoriesVendor?.data?.where((test) {
      return test.value == true;
    }).toList();

    log('${txamenity?.length} defaultState');

    final body = {
      'title': title,
      'content': content,
      'video': youtubeVideoText,
      'status': 'publish',
      'location_id': locationId,
      'start_time': "17:00",
      'duration': duration,
      'address': address,
      'map_lat': mapLat,
      'map_lng': mapLong,
      'map_zoom': int.parse("10"),
      'default_state': defaultState == "Always available" ? 1 : 0,
      'price': price,
      'sale_price': salePrice,
      'enable_extra_price': enableExtraPrice == true ? '1' : '0',
      "terms": txamenity?.map((id) => id.id.toString()),
    };

    var uri = Uri.parse('${ApiUrls.baseUrl}${ApiUrls.vendorEventAdd}');

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
      log("${extraPriceForVendorList[0].type} extrapricevalue add");
      List<Map<String, dynamic>> extraPriceForVendorListJsonList =
          extraPriceForVendorList
              .map((valll) => {
                    "name": valll.nameEnglish?.value.text ?? "",
                    "name_ja": valll.nameJapnese?.value.text ?? "",
                    "name_egy": valll.nameEgyptian?.value.text ?? "",
                    "price": valll.price?.value.text ?? "",
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
    if (ticketsVendorList.isNotEmpty) {
      List<Map<String, dynamic>> txxticketsVendorList = ticketsVendorList
          .map((valll) => {
                "code": valll.ticketCode?.value.text ?? "",
                "name": valll.nameEnglish?.value.text ?? "",
                "name_ja": valll.nameJapnese?.value.text ?? "",
                "name_egy": valll.nameEgyptian?.value.text ?? "",
                "price": valll.price?.value.text ?? "",
                "number": valll.numberTicket?.value.text ?? "",
              })
          .toList();
      body.addAll({'ticket_types': jsonEncode(txxticketsVendorList)});
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
    }
  }

  Future<bool> fetchEventDetailsEditById(String eventId) async {
    log("Fetching eventId Details for ID: $eventId");
    await loadToken();

    final String url =
        '${ApiUrls.baseUrl}${ApiUrls.vendorEventDetail}/$eventId';
    final result = await makeRequest(
      url,
      'GET',
      {},
      _token ?? '',
      requiresAuth: true,
    );

    if (result['success']) {
      EventDetailsForVendor txamenityList =
          EventDetailsForVendor.fromJson(result['data']);

      eventDetailsVendor = txamenityList;
      notifyListeners();
      return true;
    } else {
      log("Failed to fetch space details. Error: ${result['message']}");
      return false;
    }
  }

///// Edit Event vendor

  ///// edit space vendor

  Future<bool> editEventvendor({
    //// screen 1
    String id = "",
    String title = "",
    String content = "",
    String youtubeVideoText = "",
    String startTime = '',
    String duration = '',
    List<FaqClass> faqList = const [],
    File? bannerimage,
    File? featuredimage,
    List<File> pickedImagefile = const [],

    //// screen 2
    String locationId = "",
    String address = "",
    String mapLat = "",
    String mapLong = "",
    String mapZoom = "",
    List<EducationClass> txeducationList = const [],
    List<EducationClass> txhealthList = const [],
    List<EducationClass> txtransportationList = const [],
    //// screen 3
    String defaultState = "",
    String price = "",
    String salePrice = "",
    List<TicketsVendorModal> ticketsVendorList = const [],
    bool enableExtraPrice = false,
    List<ExtraPriceForVendor> extraPriceForVendorList = const [],
  }) async {
    await loadToken();

    List<EventCatagories>? txamenityzxz =
        eventCatagoriesVendor?.data?.where((test) {
      return test.value == true;
    }).toList();

    log('${txamenityzxz?.length} defaultState');

    final body = {
      'event_id': id,
      'title': title,
      'content': content,
      'video': youtubeVideoText,
      'status': 'publish',
      'location_id': locationId,
      'start_time': startTime,
      'duration': duration,
      'address': address,
      'map_lat': mapLat,
      'map_lng': mapLong,
      'map_zoom': int.parse("10"),
      'default_state': defaultState == "Always available" ? 1 : 0,
      'price': price,
      'sale_price': salePrice,
      'enable_extra_price': enableExtraPrice == true ? 1 : 0,
      "terms": txamenityzxz?.map((id) => id.id.toString()),
    };

    var uri =
        Uri.parse('${ApiUrls.baseUrl}${ApiUrls.vendorEventDetailForEdit}');

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
      log("${extraPriceForVendorList[0].type} extrapricevalue update");
      List<Map<String, dynamic>> extraPriceForVendorListJsonList =
          extraPriceForVendorList
              .map((valll) => {
                    "name": valll.nameEnglish?.value.text ?? "",
                    "name_ja": valll.nameJapnese?.value.text ?? "",
                    "name_egy": valll.nameEgyptian?.value.text ?? "",
                    "price": valll.price?.value.text ?? "",
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
    if (ticketsVendorList.isNotEmpty) {
      List<Map<String, dynamic>> txxticketsVendorList = ticketsVendorList
          .map((valll) => {
                "code": valll.ticketCode?.value.text ?? "",
                "name": valll.nameEnglish?.value.text ?? "",
                "name_ja": valll.nameJapnese?.value.text ?? "",
                "name_egy": valll.nameEgyptian?.value.text ?? "",
                "price": valll.price?.value.text ?? "",
                "number": valll.numberTicket?.value.text ?? "",
              })
          .toList();
      body.addAll({'ticket_types': jsonEncode(txxticketsVendorList)});
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
    }
  }
}
