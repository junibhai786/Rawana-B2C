import 'dart:io';

import 'package:moonbnd/Provider/vendor_tour_provider.dart';
import 'package:moonbnd/widgets/bottom_navigation.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class EditTourFiveScreen extends StatefulWidget {
  String tourId = "";
  String title = "";
  String content = "";
  String youtubeVideoText = "";
  List<FaqClass>? faqList;
  File? bannerimage;
  File? featuredimage;
  List<File>? pickedImagefile;
  String minimumDayBeforeBooking = "";
  String minimumdaystaycontroller = "";
  String bed = "";
  String bathroom = "";
  String locationId = "";
  String address = "";
  String mapLat = "";
  String mapLong = "";
  String mapZoom = "";
  List<EducationClass> txeducationList;
  List<EducationClass> txhealthList;
  List<EducationClass> txtransportationList;
  String defaultState = "";
  String price = "";
  String salePrice = "";
  String maxGuests = "";
  bool enableExtraPrice = false;
  List<ExtraPriceVendor> extraPriceVendorList = const [];
  List<IncludeClass>? Include;
  List<ExcludeClass>? Exclude;
/*  List<DiscountByNoOfDayAndNightModal> discountByNoOfDayAndNightList = const [];*/
  String categoryId = "";
  List<ItineraryClass>? itineraryList;
  List<PersonTypeForVendor> personTypeForVendorList;
  String minimumPeople = "";
  String duration = "";
  bool enablePersonTypes = false;

  EditTourFiveScreen({
    super.key,
    this.bannerimage,
    this.featuredimage,
    this.minimumDayBeforeBooking = "",
    this.minimumdaystaycontroller = "",
    this.pickedImagefile,
    this.title = "",
    this.youtubeVideoText = "",
    this.tourId = "",
    this.locationId = "",
    this.address = "",
    this.mapLat = "",
    this.mapLong = "",
    this.mapZoom = "",
    this.txeducationList = const [],
    this.txhealthList = const [],
    this.txtransportationList = const [],
    this.defaultState = "",
    this.price = "",
    this.salePrice = "",
    this.maxGuests = "",
    this.enableExtraPrice = false,
    this.extraPriceVendorList = const [],
    this.content = "",
    required String maximumPeople,
    this.categoryId = "",
    this.faqList,
    /* this.discountByNoOfDayAndNightList = const [],*/
    this.itineraryList,
    this.personTypeForVendorList = const [],
    this.minimumPeople = "",
    this.duration = "",
    this.Include,
    this.Exclude,
    this.enablePersonTypes = false,
  });
  @override
  SpaceFiveScreenState createState() => SpaceFiveScreenState();
}

class SpaceFiveScreenState extends State<EditTourFiveScreen> {
  TextEditingController _importUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print({
      "title": widget.title,
      "content": widget.content,
      "locationId": widget.locationId,
      "price": widget.price,
      "maxGuests": widget.maxGuests,
      "minimumPeople": widget.minimumPeople,
      "duration": widget.duration,
      "enablePersonTypes": widget.enablePersonTypes,
      "extraPriceVendorList": widget.extraPriceVendorList,

      // ... add other key parameters
    });
    print("hello");

    _importUrlController = TextEditingController(
        text: Provider.of<VendorTourProvider>(context, listen: false)
            .tourlistdetails
            ?.data?[0]
            .icalImportUrl);
  }

  @override
  Widget build(BuildContext context) {
    final item = Provider.of<VendorTourProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Stepper progress indicator

            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text("Update Tour".tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Inter",
                  )),
            ),
            Image.asset(
              Get.locale?.languageCode == 'ar'
                  ? 'assets/haven/level5_ar.png'
                  : 'assets/haven/level5.png',
            ),
            SizedBox(
              height: 20,
            ),
            // ICAL Section
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text('ICAL'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Inter",
                  )),
            ),

            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text('Import url'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Inter",
                  )),
            ),

            // Import URL Field
            CustomTextField(
              controller: _importUrlController,
              hintText: "Import url".tr,
            ),

            SizedBox(height: 32.0),

            // Save & Next button
            Center(
              child: TertiaryButton(
                press: () async {
                  print(
                      'itineryimage ids: ${widget.itineraryList?.map((itinerary) => itinerary.imageId).join(', ')}');
                  print("Tour Features Screen - Navigation Data:");
                  print("Tour ID: ${widget.tourId}");
                  // print("Selected Travel Types: ${widget.}");
                  // print("Selected Facilities: $selectedFacilities");
                  print("Minimum People: ${widget.minimumPeople}");
                  print("Duration: ${widget.duration}");
                  print("Category ID: ${widget.categoryId}");
                  print("Title: ${widget.title}");
                  print("Content: ${widget.content}");
                  print("YouTube Video: ${widget.youtubeVideoText}");
                  print("FAQ List: ${widget.faqList}");
                  print(
                      "Banner Image: ${widget.bannerimage?.path ?? "Not selected"}");
                  print(
                      "Featured Image: ${widget.featuredimage?.path ?? "Not selected"}");
                  print(
                      "Gallery Images Count: ${widget.pickedImagefile?.length ?? 0}");
                  print(
                      "Minimum Days Before Booking: ${widget.minimumDayBeforeBooking}");
                  print("Maximum People: ${widget.maxGuests}");
                  print("Duration: ${widget.duration}");

                  print("Location ID: ${widget.locationId}");
                  print("Address: ${widget.address}");
                  print("Map Lat: ${widget.mapLat}");
                  print("Map Long: ${widget.mapLong}");
                  print("Map Zoom: ${widget.mapZoom}");
                  print("Education List: ${widget.txeducationList}");
                  print("Health List: ${widget.txhealthList}");
                  print("Transportation List: ${widget.txtransportationList}");
                  print("Default State: ${widget.defaultState}");
                  print("Enable Extra Price: ${widget.enableExtraPrice}");
                  print("Extra Price List: ${widget.extraPriceVendorList}");
                  print("Price: ${widget.price}");
                  print("Sale Price: ${widget.salePrice}");
                  print("Itinerary List: ${widget.itineraryList}");
                  print("Person Type List: ${widget.personTypeForVendorList}");
                  print("Minimum People: ${widget.minimumPeople}");
                  print("Include List: ${widget.Include}");
                  print("Exclude List: ${widget.Exclude}");
                  bool check = await item.editTourvendor(
                    tourId: widget.tourId,
                    title: widget.title,
                    content: widget.content,
                    IncludeList: widget.Include ?? [],
                    ExcludeList: widget.Exclude ?? [],
                    youtubeVideoText: widget.youtubeVideoText,
                    faqList: widget.faqList ?? [],
                    categoryId: widget.categoryId,
                    duration: widget.duration,
                    bannerimage: widget.bannerimage != null
                        ? File(widget.bannerimage!.path)
                        : null,
                    featuredimage: widget.featuredimage != null
                        ? File(widget.featuredimage!.path)
                        : null,
                    pickedImagefile: widget.pickedImagefile != null
                        ? widget.pickedImagefile!
                            .map((e) => File(e.path))
                            .toList()
                        : [],
                    minimumDayBeforeBooking: widget.minimumDayBeforeBooking,
                    minimumdaystaycontroller: widget.minimumdaystaycontroller,
                    locationId: widget.locationId,
                    address: widget.address,
                    mapLat: widget.mapLat,
                    mapLong: widget.mapLong,
                    mapZoom: widget.mapZoom,
                    txeducationList: widget.txeducationList,
                    txhealthList: widget.txhealthList,
                    txtransportationList: widget.txtransportationList,
                    defaultState: widget.defaultState,
                    enableExtraPrice: widget.enableExtraPrice,
                    enablePersonTypes: widget.enablePersonTypes,
                    extraPriceVendorList: widget.extraPriceVendorList,
                    price: widget.price,
                    salePrice: widget.salePrice,
                    ical: _importUrlController.value.text,
                    itineraryList: widget.itineraryList ?? [],
                    personTypeForVendorList: widget.personTypeForVendorList,
                    maximumPeople: widget.maxGuests,
                    minmumPeople: widget.minimumPeople,
                  );

                  if (check) {
                    print("Tour update successful!");
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();

                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop("yes");
                    // from pop here
                    // ignore: use_build_context_synchronously
                    // Navigator.of(context).pushAndRemoveUntil(
                    //     MaterialPageRoute(builder: (context) => BottomNav()),
                    //     (route) => false);
                  } else {
                    print("Tour update failed!");
                  }
                },
                text: 'Save'.tr,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
