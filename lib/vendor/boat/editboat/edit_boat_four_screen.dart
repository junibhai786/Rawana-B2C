import 'dart:developer';
import 'dart:io';

import 'package:moonbnd/Provider/vendor_boat_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/modals/boat_vendor_details_model.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class EditBoatFourScreen extends StatefulWidget {
  final List<BoatDetailDatum>? data;
  final String? id;
  final List<Term>? terms;
  EditBoatFourScreen({this.data, this.id, this.terms});
  @override
  EditBoatFourScreenState createState() => EditBoatFourScreenState();
}

class EditBoatFourScreenState extends State<EditBoatFourScreen> {
  bool isLoading = false;
  bool loading2 = false;
  bool loading = false;
  // Map<String, bool> boatTypes = {
  //   'Airbag': true,
  //   'Cabin Cruiser': false,
  //   'Cruise Ship': false,
  //   'Express Cruiser': false,
  //   'Electric Boat': false,
  //   'Ferry': false,
  //   'Inflatable Boat': false,
  //   'Jetboat': false,
  // };

  // Map<String, bool> carFeatures = {
  //   'Events & Meetings': true,
  //   'Scuba Gear': false,
  //   'Hot Tub/ Jacuzzi on Deck': false,
  //   'Sport Fishing': false,
  //   'Speciality Classic Yacht': false,
  //   'Gulet': false,
  // };

  @override
  void initState() {
    super.initState();

    Provider.of<VendorBoatProvider>(context, listen: false)
        .boatamenitiesvendor()
        .then((value) {
      setState(() {
        loading = false;
      });
    });
    Provider.of<VendorBoatProvider>(context, listen: false)
        .boattypetourvendor()
        .then((value) {
      setState(() {
        loading2 = false;
      });
    });

    final provider = Provider.of<VendorBoatProvider>(context, listen: false);
    provider.selectedboattypeIds.clear();
    provider.selectedboatamenityIds.clear();

    if (widget.data?.first.terms?.length != 0) {
      if (widget.data?.first.terms?[0].child != null) {
        for (var boatType in widget.data!.first.terms![0].child!) {
          provider.selectedboattypeIds.add(boatType.id ?? 0);
        }
      }
      if (widget.data?.first.terms?[1].child != null) {
        for (var amenity in widget.data!.first.terms![1].child!) {
          provider.selectedboatamenityIds.add(amenity.id ?? 0);
        }
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VendorBoatProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Stepper progress indicator
              Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 10),
                child: Text(
                  "Add New Boat".tr,
                  style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Image.asset(
                Get.locale?.languageCode == 'ar'
                    ? 'assets/haven/eventlevel4_ar.png'
                    : 'assets/haven/eventlevel4.png',
              ),

              Divider(),

              // Car Type Section
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  'Boat Type'.tr,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 300,
                // Adjust the height as needed
                child: loading2
                    ? Center(
                        child: CircularProgressIndicator(color: kSecondaryColor),
                      )
                    : ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: provider.boattypes?.data?.length,
                        itemBuilder: (context, index) => Column(
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: provider.selectedboattypeIds
                                          .contains(provider
                                              .boattypes?.data?[index].id),
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            provider.selectedboattypeIds.add(
                                                provider.boattypes?.data?[index]
                                                        .id ??
                                                    0);
                                            log("${provider.selectedboattypeIds}");
                                          } else {
                                            provider.selectedboattypeIds.remove(
                                                provider.boattypes?.data?[index]
                                                    .id);
                                            log("${provider.selectedboattypeIds}");
                                          }
                                        });
                                      },
                                    ),
                                    Text(
                                        "${provider.boattypes?.data?[index].name}"),
                                  ],
                                )
                              ],
                            )),
              ),

              Divider(),

              // Car Features Section
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  'Amenities'.tr,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 300,
                // Adjust the height as needed
                child: loading2
                    ? Center(
                        child: CircularProgressIndicator(color: kSecondaryColor),
                      )
                    : ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: provider.boatamenities?.data?.length,
                        itemBuilder: (context, index) => Column(
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: provider.selectedboatamenityIds
                                          .contains(provider
                                              .boatamenities?.data?[index].id),
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            provider.selectedboatamenityIds.add(
                                                provider.boatamenities
                                                        ?.data?[index].id ??
                                                    0);
                                            log("${provider.selectedboatamenityIds}");
                                          } else {
                                            provider.selectedboatamenityIds
                                                .remove(provider.boatamenities
                                                    ?.data?[index].id);
                                            log("${provider.selectedboatamenityIds}");
                                          }
                                        });
                                      },
                                    ),
                                    Text(
                                        "${provider.boatamenities?.data?[index].name}"),
                                  ],
                                )
                              ],
                            )),
              ),

              // Save & Next button
              SizedBox(height: 16.0),
              Center(
                child: TertiaryButton(
                  press: () async {
                    setState(() {
                      isLoading = true;
                    });

                    final provider =
                        Provider.of<VendorBoatProvider>(context, listen: false);

                    String contentSend =
                        await provider.contentController.getText();
                    log('$contentSend sennndd');
                    bool success = await provider.editBoatVendor(
                      boatId: widget.id ?? '',
                      title: provider.titleController.text,
                      content: contentSend,
                      video: provider.youtubeVideoController.text,
                      bannerImage: provider.bannerImage?.path != null
                          ? File(provider.bannerImage!.path)
                          : null,
                      featuredImage: provider.featuredImage?.path != null
                          ? File(provider.featuredImage!.path)
                          : null,
                      galleryImages: provider.galleryImages
                          .map((xFile) => File(xFile.path))
                          .toList(),
                      maxGuest: provider.guestController.text,
                      cabin: provider.cabinController.text,
                      speed: provider.speedController.text,
                      length: provider.lengthController.text,
                      cancelPolicy: provider.cancelPolicyController.text,
                      termsInformation: provider.additionalTermsController.text,
                      defaultState: provider.defaultState,
                      minDayBeforeBooking: provider.minDayBeforeBooking.text,
                      startTimeBooking: provider.startTimeController.text,
                      endTimeBooking: provider.endTimeController.text,
                      pricePerHour: provider.pricePerHourController.text,
                      pricePerDay: provider.pricePerDayController.text,
                      locationId: provider.locationid ?? '',
                      address: provider.addresscontroller.text,
                      mapLat: provider.mapLat ?? '',
                      mapLng: provider.mapLng ?? '',
                      mapZoom: provider.mapZoom ?? '',
                      faqList: provider.faqList,
                      specs: provider.specsList
                          .map((spec) => {
                                'title': spec.title?.value.text ?? '',
                                'content': spec.content?.value.text ?? '',
                              })
                          .toList(),
                      include: provider.includeList
                          .map((item) => {
                                'title': item.title?.value.text ?? '',
                              })
                          .toList(),
                      exclude: provider.excludeList
                          .map((item) => {
                                'title': item.title?.value.text ?? '',
                              })
                          .toList(),
                      enableExtraPrice: provider.enableExtraPrice,
                      extraPriceList: provider.extraPriceBoatVendorList,
                    );

                    setState(() {
                      isLoading = false;
                    });

                    if (success) {
                      Navigator.of(context).pop();
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                      log("pop here");
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop("yes");
                    }
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
