import 'dart:developer';
import 'dart:io';

import 'package:moonbnd/Provider/vendor_tour_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/vendor/tour/edittour/edit_tour_five_screen.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class EditTourFourScreen extends StatefulWidget {
  String tourId = "";
  String title = "";
  String content = "";
  String categoryId = "";
  String youtubeVideoText = "";
  List<FaqClass>? faqList;
  File? bannerimage;
  File? featuredimage;
  List<File>? pickedImagefile;
  String minimumDayBeforeBooking = "";
  String minimumdaystaycontroller = "";

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
  String maximumPeople = "";
  bool enableExtraPrice = false;
  bool enablePersonTypes = false;
  List<ExtraPriceVendor> extraPriceVendorList = const [];
  List<PersonTypeForVendor> personTypeForVendorList = const [];
  List<ItineraryClass>? itineraryList;
  String minimumPeople = "";
  String duration = "";
  List<IncludeClass>? Include;
  List<ExcludeClass>? Exclude;

  /* List<DiscountByNoOfDayAndNightModal> discountByNoOfDayAndNightList = const [];*/
  EditTourFourScreen({
    super.key,
    this.bannerimage,
    this.content = "",
    this.tourId = "",
    this.categoryId = "",
    this.faqList,
    this.featuredimage,
    this.minimumDayBeforeBooking = "",
    this.minimumdaystaycontroller = "",
    this.pickedImagefile,
    this.title = "",
    this.youtubeVideoText = "",
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
    this.maximumPeople = "",
    this.enableExtraPrice = false,
    this.extraPriceVendorList = const [],
    this.personTypeForVendorList = const [],
    this.itineraryList,
    this.minimumPeople = "",
    this.duration = "",
    this.Include,
    this.Exclude,
    this.enablePersonTypes = false,

    /* this.discountByNoOfDayAndNightList = const [],*/
  });
  @override
  TourFourScreenState createState() => TourFourScreenState();
}

class TourFourScreenState extends State<EditTourFourScreen> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      isLoading = true;
    });

    Provider.of<VendorTourProvider>(context, listen: false)
        .traveltypetourvendor()
        .then((value) {
      // ignore: use_build_context_synchronogiusly
      Provider.of<VendorTourProvider>(context, listen: false)
          .facilitiestypetourvendor()
          .then((value) {
        update();
        setState(() {
          isLoading = false;
        });
      });
    });
  }

  void update() {
    final provider = Provider.of<VendorTourProvider>(context, listen: false);

    if ((provider.tourlistdetails!.data?[0].terms?.length ?? 0) >= 1) {
      provider.traveltype?.data?.forEach((element) {
        for (var i = 0;
            i <
                (provider.tourlistdetails!.data?[0].terms?[0].child!.length ??
                    0);
            i++) {
          if (element.id ==
              provider.tourlistdetails!.data?[0].terms?[0].child?[i].id) {
            element.value = true;
          }
        }
      });
    }

    if (provider.tourlistdetails!.data?[0].terms?.length == 2) {
      provider.facility?.data?.forEach((element) {
        for (var i = 0;
            i <
                (provider.tourlistdetails!.data?[0].terms?[1].child!.length ??
                    0);
            i++) {
          if (element.id ==
              provider.tourlistdetails!.data?[0].terms?[1].child?[i].id) {
            element.value = true;
          }
        }
      });
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final item = Provider.of<VendorTourProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: kSecondaryColor))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Stepper progress indicator
                    Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 10),
                      child: Text(
                        "Add New Tour".tr,
                        style: TextStyle(
                          fontFamily: "inter",
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Center(
                      child: Image.asset(
                        Get.locale?.languageCode == 'ar'
                            ? 'assets/haven/level4_ar.png'
                            : 'assets/haven/level4.png',
                      ),
                    ),
                    Divider(),

                    // Car Type Section
                    Text(
                      'Tour Styles'.tr,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),

                    ...(item.traveltype?.data)!.map((element) {
                      print(
                          "Rendering travel type: ${element.name}, selected: ${element.value}");
                      return Row(
                        children: [
                          Checkbox(
                              value: element.value,
                              onChanged: (value) {
                                print(
                                    "Travel type ${element.name} changed to $value");
                                setState(() {
                                  element.value = value;
                                });
                              }),
                          Text(element.name ?? ""),
                        ],
                      );
                    }),

                    Divider(),

                    // Car Features Section
                    Text(
                      'Facilities'.tr,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ...(item.facility?.data)!.map((element) {
                      return Row(
                        children: [
                          Checkbox(
                              value: element.value,
                              onChanged: (value) {
                                print(
                                    "Facility ${element.name} changed to $value");
                                setState(() {
                                  element.value = value;
                                });
                              }),
                          Text(element.name ?? ""),
                        ],
                      );
                    }), // Save & Next button
                    SizedBox(height: 16.0),
                    Center(
                      child: TertiaryButton(
                        press: () async {
                          final selectedTravelTypes = item.traveltype?.data
                              ?.where((element) => element.value == true)
                              .map((e) => e.name)
                              .toList();

                          final selectedFacilities = item.facility?.data
                              ?.where((element) => element.value == true)
                              .map((e) => e.name)
                              .toList();

                          log("Tour Features Screen - Navigation Data:");
                          log("Tour ID: ${widget.tourId}");
                          log("Selected Travel Types: $selectedTravelTypes");
                          log("Selected Facilities: $selectedFacilities");
                          log("Minimum People: ${widget.minimumPeople}");
                          log("Duration: ${widget.duration}");
                          log("Category ID: ${widget.categoryId}");
                          log("Title: ${widget.title}");
                          log("Content: ${widget.content}");
                          log("YouTube Video: ${widget.youtubeVideoText}");
                          log("FAQ List: ${widget.faqList}");
                          log("Banner Image: ${widget.bannerimage?.path ?? "Not selected"}");
                          log("Featured Image: ${widget.featuredimage?.path ?? "Not selected"}");
                          log("Gallery Images Count: ${widget.pickedImagefile?.length ?? 0}");
                          log("Minimum Days Before Booking: ${widget.minimumDayBeforeBooking}");
                          log("Maximum People: ${widget.maximumPeople}");
                          log("Duration: ${widget.duration}");

                          log("Location ID: ${widget.locationId}");
                          log("Address: ${widget.address}");
                          log("Map Lat: ${widget.mapLat}");
                          log("Map Long: ${widget.mapLong}");
                          log("Map Zoom: ${widget.mapZoom}");
                          log("Education List: ${widget.txeducationList}");
                          log("Health List: ${widget.txhealthList}");
                          log("Transportation List: ${widget.txtransportationList}");
                          log("Default State: ${widget.defaultState}");
                          log("Enable Extra Price: ${widget.enableExtraPrice}");
                          log("Extra Price List: ${widget.extraPriceVendorList}");
                          log("Price: ${widget.price}");
                          log("Sale Price: ${widget.salePrice}");
                          log("Itinerary List: ${widget.itineraryList}");
                          log("Person Type List: ${widget.personTypeForVendorList}");
                          log("Maximum People: ${widget.maximumPeople}");
                          log("Include List: ${widget.Include}");
                          log("Exclude List: ${widget.Exclude}");
                          print(
                              'itineryimage ids: ${widget.itineraryList?.map((itinerary) => itinerary.imageId).join(', ')}');

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditTourFiveScreen(
                                tourId: widget.tourId,
                                title: widget.title,
                                content: widget.content,
                                minimumPeople: widget.minimumPeople,
                                duration: widget.duration,
                                youtubeVideoText: widget.youtubeVideoText,
                                faqList: widget.faqList ?? [],
                                categoryId: widget.categoryId,
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
                                minimumDayBeforeBooking:
                                    widget.minimumDayBeforeBooking,
                                maximumPeople: widget.maximumPeople,
                                locationId: widget.locationId,
                                address: widget.address,
                                mapLat: widget.mapLat,
                                mapLong: widget.mapLong,
                                mapZoom: widget.mapZoom,
                                txeducationList: widget.txeducationList,
                                txhealthList: widget.txhealthList,
                                txtransportationList:
                                    widget.txtransportationList,
                                defaultState: widget.defaultState,
                                enableExtraPrice: widget.enableExtraPrice,
                                enablePersonTypes: widget.enablePersonTypes,
                                extraPriceVendorList:
                                    widget.extraPriceVendorList,
                                price: widget.price,
                                salePrice: widget.salePrice,
                                itineraryList: widget.itineraryList,
                                personTypeForVendorList:
                                    widget.personTypeForVendorList,
                                maxGuests: widget.maximumPeople,
                                Include: widget.Include,
                                Exclude: widget.Exclude,
                              ),
                            ),
                          );
                        },
                        text: 'Save & Next'.tr,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
