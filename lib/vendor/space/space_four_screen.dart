import 'dart:io';

import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Provider/space_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/modals/amenities_model.dart';
import 'package:moonbnd/modals/space_type_model.dart';
import 'package:moonbnd/vendor/space/space_five_screen.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class SpaceFourScreen extends StatefulWidget {
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
  List<ExtraPriceForVendor> extraPriceForVendorList = const [];
  List<DiscountByNoOfDayAndNightModal> discountByNoOfDayAndNightList = const [];
  SpaceFourScreen({
    super.key,
    this.bannerimage,
    this.bathroom = "",
    this.bed = "",
    this.content = "",
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
    this.maxGuests = "",
    this.enableExtraPrice = false,
    this.extraPriceForVendorList = const [],
    this.discountByNoOfDayAndNightList = const [],
  });
  @override
  SpaceFourScreenState createState() => SpaceFourScreenState();
}

class SpaceFourScreenState extends State<SpaceFourScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final item = Provider.of<SpaceProvider>(context, listen: true);
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
                        "Add New Space".tr,
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
                      'Space Type'.tr,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),

                    ...(item.space?.data)!.map((element) {
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
                    }),

                    Divider(),

                    // Car Features Section
                    Text(
                      'Amenties'.tr,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ...(item.amenity?.data)!.map((element) {
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
                    }), // Save & Next button
                    SizedBox(height: 16.0),
                    Center(
                      child: TertiaryButton(
                        press: () async {
                          // List<SpaceVendor>? txdatacheck =
                          //     item.space?.data?.where((test) {
                          //   return test.value == true;
                          // }).toList();

                          // if (txdatacheck?.length == 0) {
                          //   showErrorToast(
                          //       "Please check atleast one space type");
                          //   return;
                          // }
                          // List<Amenity>? txdatacheck2 =
                          //     item.amenity?.data?.where((test) {
                          //   return test.value == true;
                          // }).toList();

                          // if (txdatacheck2?.length == 0) {
                          //   showErrorToast(
                          //       "Please check atleast one amenties type");
                          //   return;
                          // }

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SpaceFiveScreen(
                                      title: widget.title,
                                      content: widget.content,
                                      youtubeVideoText: widget.youtubeVideoText,
                                      faqList: widget.faqList ?? [],
                                      bannerimage: widget.bannerimage != null
                                          ? File(widget.bannerimage!.path)
                                          : null,
                                      featuredimage:
                                          widget.featuredimage != null
                                              ? File(widget.featuredimage!.path)
                                              : null,
                                      pickedImagefile:
                                          widget.pickedImagefile != null
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
                                      txtransportationList:
                                          widget.txtransportationList,
                                      defaultState: widget.defaultState,
                                      discountByNoOfDayAndNightList:
                                          widget.discountByNoOfDayAndNightList,
                                      enableExtraPrice: widget.enableExtraPrice,
                                      extraPriceForVendorList:
                                          widget.extraPriceForVendorList,
                                      maxGuests: widget.maxGuests,
                                      price: widget.price,
                                      salePrice: widget.salePrice)));
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
