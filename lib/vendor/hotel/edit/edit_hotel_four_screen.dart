import 'dart:io';

import 'package:moonbnd/Provider/hotel_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/widgets/bottom_navigation.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class EditHotelFourScreen extends StatefulWidget {
  String spaceId = "";
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
  String timeinController = "";
  String timeoutController = "";
  String minreservationController = "";
  String minstayController = "";
  String salePrice = "";
  String maxGuests = "";
  bool enableExtraPrice = false;
  List<ExtraPriceForVendor> extraPriceForVendorList = const [];

  EditHotelFourScreen({
    super.key,
    this.bannerimage,
    this.bathroom = "",
    this.bed = "",
    this.content = "",
    this.spaceId = "",
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
    this.timeinController = "",
    this.timeoutController = "",
    this.minreservationController = "",
    this.minstayController = "",
    this.salePrice = "",
    this.maxGuests = "",
    this.enableExtraPrice = false,
    this.extraPriceForVendorList = const [],
  });
  @override
  SpaceFourScreenState createState() => SpaceFourScreenState();
}

class SpaceFourScreenState extends State<EditHotelFourScreen> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      isLoading = true;
    });

    Provider.of<VendorHotelProvider>(context, listen: false)
        .propertytypehotelvendor()
        .then((value) {
      // ignore: use_build_context_synchronously
      Provider.of<VendorHotelProvider>(context, listen: false)
          .facilitiestypehotelvendor()
          .then((value) {
        // Add the hotelservice call here
        Provider.of<VendorHotelProvider>(context, listen: false)
            .servicestypehotelvendor() // New service call
            .then((value) {
          update();
          setState(() {
            isLoading = false;
          });
        });
      });
    });
  }

  void update() {
    final provider = Provider.of<VendorHotelProvider>(context, listen: false);

    if ((provider.hotellistdetails!.data?[0].terms?.length)! >= 1) {
      provider.space?.data?.forEach((element) {
        for (var i = 0;
            i < (provider.hotellistdetails!.data![0].terms![0].child!.length);
            i++) {
          if (element.id ==
              provider.hotellistdetails!.data?[0].terms?[0].child?[i].id) {
            element.value = true;
          }
        }
      });
    }

    if ((provider.hotellistdetails!.data?[0].terms?.length)! >= 2) {
      provider.amenity?.data?.forEach((element) {
        for (var i = 0;
            i < provider.hotellistdetails!.data![0].terms![1].child!.length;
            i++) {
          if (element.id ==
              provider.hotellistdetails!.data?[0].terms?[1].child?[i].id) {
            element.value = true;
          }
        }
      });
    }
    if (provider.hotellistdetails!.data?[0].terms?.length == 3) {
      provider.serviceshotel?.data?.forEach((element) {
        for (var i = 0;
            i < provider.hotellistdetails!.data![0].terms![2].child!.length;
            i++) {
          if (element.id ==
              provider.hotellistdetails!.data?[0].terms?[2].child?[i].id) {
            element.value = true;
          }
        }
      });
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final item = Provider.of<VendorHotelProvider>(context, listen: true);
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
                        "Update Hotel".tr,
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
                            ? 'assets/haven/eventlevel4_ar.png'
                            : 'assets/haven/eventlevel4.png',
                      ),
                    ),
                    Divider(),

                    // Car Type Section
                    Text(
                      'Hotel Type'.tr,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),

                    // Check if item.space?.data is not null before mapping
                    if (item.space?.data != null)
                      ...(item.space!.data!.map((element) {
                        return Row(
                          children: [
                            Checkbox(
                                value: element.value,
                                onChanged: (value) {
                                  element.value = value;
                                  setState(() {});
                                }),
                            Text(element.name ?? ""),
                          ],
                        );
                      }))
                    else ...[
                      Text("No hotel types available"
                          .tr), // Handle the case when data is null
                    ],

                    Divider(),

                    // Car Features Section
                    Text(
                      'Facilities'.tr,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    // Check if item.space?.data is not null before mapping
                    if (item.amenity?.data != null)
                      ...(item.amenity!.data!.map((element) {
                        return Row(
                          children: [
                            Checkbox(
                                value: element.value,
                                onChanged: (value) {
                                  element.value = value;
                                  setState(() {});
                                }),
                            Text(element.name ?? ""),
                          ],
                        );
                      }))
                    else ...[
                      Text("No hotel types available"
                          .tr), // Handle the case when data is null
                    ],
                    Divider(),

                    // Car Features Section
                    Text(
                      'Hotel Services'.tr,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    // Check if item.space?.data is not null before mapping
                    if (item.services?.data != null)
                      ...(item.services!.data!.map((element) {
                        return Row(
                          children: [
                            Checkbox(
                                value: element.value,
                                onChanged: (value) {
                                  element.value = value;
                                  setState(() {});
                                }),
                            Text(element.name ?? ""),
                          ],
                        );
                      }))
                    else ...[
                      Text("No hotel types available"
                          .tr), // Handle the case when data is null
                    ], // Save & Next button
                    SizedBox(height: 16.0),
                    Center(
                      child: TertiaryButton(
                        press: () async {
                          final provider = Provider.of<VendorHotelProvider>(
                              context,
                              listen: false);
                          bool check = await item.edithotelvendor(
                            spaceId: widget.spaceId,
                            title: widget.title,
                            content: widget.content,
                            youtubeVideoText: widget.youtubeVideoText,
                            faqList: widget.faqList ?? [],
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
                            minimumdaystaycontroller:
                                widget.minimumdaystaycontroller,
                            bed: widget.bed,
                            bathroom: widget.bathroom,
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
                            extraPriceForVendorList:
                                widget.extraPriceForVendorList,
                            maxGuests: widget.maxGuests,
                            txprice: widget.price,
                            timeinController: widget.timeinController,
                            timeoutController: widget.timeoutController,
                            minreservationController:
                                widget.minreservationController,
                            minstayController: widget.minstayController,
                            salePrice: widget.salePrice,
                          );

                          if (check) {
                            setState(() {
                              // Clear all the controllers and data
                              Provider.of<VendorHotelProvider>(context,
                                      listen: false)
                                  .titlecontroller
                                  .clear();
                              Provider.of<VendorHotelProvider>(context,
                                      listen: false)
                                  .contentController
                                  .clear();
                              Provider.of<VendorHotelProvider>(context,
                                      listen: false)
                                  .youtubecontroller
                                  .clear();
                              provider.selectpassanger = "";
                              Provider.of<VendorHotelProvider>(context,
                                      listen: false)
                                  .bannerimage = null;
                              Provider.of<VendorHotelProvider>(context,
                                      listen: false)
                                  .featuredimage = null;
                              Provider.of<VendorHotelProvider>(context,
                                      listen: false)
                                  .pickedImagefile
                                  .clear();
                              provider.selectpassanger = null;
                              provider.isShowPassword = false;
                              provider.timechecincontroller.clear();
                              provider.timechecoutcontroller.clear();
                              provider.selectreservations = null;
                              provider.selectrequirements = null;

                              provider.edu = [];
                              provider.health = [];

                              provider.latitude = null;
                              provider.longitude = null;
                              provider.transform = [];
                              provider.addresscontroller.text = '';
                              provider.addresscontroller =
                                  TextEditingController();
                              provider.price = [];
                              provider.selectedpropertytypeIds = [];
                              provider.selectedfacilitytypeIds = [];
                              provider.selectedservicetypeIds = [];
                              // Clear location data
                              Provider.of<VendorHotelProvider>(context,
                                      listen: false)
                                  .locationid = null;
                              Provider.of<VendorHotelProvider>(context,
                                      listen: false)
                                  .addresscontroller
                                  .clear();

                              // Clear pricing data
                              Provider.of<VendorHotelProvider>(context,
                                      listen: false)
                                  .pricecontroller
                                  .clear();

                              // Clear lists
                              Provider.of<VendorHotelProvider>(context,
                                      listen: false)
                                  .faq
                                  .clear();

                              provider.hotelreleatedid.clear();

                              provider.faq = [];

                              Provider.of<VendorHotelProvider>(context,
                                      listen: false)
                                  .edu
                                  .clear();
                              Provider.of<VendorHotelProvider>(context,
                                      listen: false)
                                  .health
                                  .clear();
                              Provider.of<VendorHotelProvider>(context,
                                      listen: false)
                                  .transform
                                  .clear();

                              // Clear selected IDs
                              Provider.of<VendorHotelProvider>(context,
                                      listen: false)
                                  .selectedfacilitytypeIds
                                  .clear();

                              // Reset other controllers
                              Provider.of<VendorHotelProvider>(context,
                                      listen: false)
                                  .minimumcontroller
                                  .clear();
                              Provider.of<VendorHotelProvider>(context,
                                      listen: false)
                                  .minimumdaystaycontroller
                                  .clear();
                            });
                            // ignore: use_build_context_synchronously
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => BottomNav()),
                                (route) => false);
                          } else {}
                        },
                        text: 'Save'.tr,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
