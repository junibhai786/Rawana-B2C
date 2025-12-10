import 'dart:developer';

import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Provider/vendor_tour_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/vendor/tour/tour_six_screen.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class TourFourScreen extends StatefulWidget {
  @override
  TourFourScreenState createState() => TourFourScreenState();
}

class TourFourScreenState extends State<TourFourScreen> {
  bool loading2 = false;
  bool loading = false;
  // bool loading3 = false;

  Map<String, bool> travelTypes = {
    'Cultural'.tr: true,
    'Nature & Adventure'.tr: false,
    'Marine'.tr: false,
    'Independent'.tr: false,
    'Activities'.tr: false,
    'Festivals & Events'.tr: false,
    'Special Interest'.tr: false,
  };

  Map<String, bool> facilities = {
    'Wifi'.tr: true,
    'Gymnasium'.tr: false,
    'Mountain Bike'.tr: false,
    'Satellite Office'.tr: false,
    'Staff Lounge'.tr: false,
    'Golf Cages'.tr: false,
    'Aerobics Room'.tr: false,
  };

  @override
  void initState() {
    super.initState();
    // final provider = Provider.of<VendorTourProvider>(context, listen: false);
    // provider.clearAllData();

    setState(() {
      loading = true;
      loading2 = true;
      // loading3 = true;
    });
    Provider.of<VendorTourProvider>(context, listen: false)
        .traveltypetourvendor()
        .then((value) {
      setState(() {
        loading2 = false;
      });
    });
    Provider.of<VendorTourProvider>(context, listen: false)
        .facilitiestypetourvendor()
        .then((value) {
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VendorTourProvider>(context, listen: true);
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
                  "Add New Tour".tr,
                  style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Image.asset(
                Get.locale?.languageCode == 'ar'
                    ? 'assets/haven/level4_ar.png'
                    : 'assets/haven/level4.png',
              ),
              Divider(),

              // Car Type Section
              Text(
                'Travel Styles'.tr,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        itemCount: provider.traveltypes?.data?.length,
                        itemBuilder: (context, index) => Column(
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: provider.selectedtraveltypeIds
                                          .contains(provider
                                              .traveltypes?.data?[index].id),
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            provider.selectedtraveltypeIds.add(
                                                provider.traveltypes
                                                        ?.data?[index].id ??
                                                    0);
                                            log("${provider.selectedtraveltypeIds}");
                                          } else {
                                            provider.selectedtraveltypeIds
                                                .remove(provider.traveltypes
                                                    ?.data?[index].id);
                                            log("${provider.selectedtraveltypeIds}");
                                          }
                                        });
                                      },
                                    ),
                                    Text(
                                        "${provider.traveltypes?.data?[index].name}"),
                                  ],
                                )
                              ],
                            )),
              ),

              Divider(),

              // Car Features Section
              Text(
                'Facilities'.tr,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        itemCount: provider.facilities?.data?.length,
                        itemBuilder: (context, index) => Column(
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: provider.selectedfacilitytypeIds
                                          .contains(provider
                                              .facilities?.data?[index].id),
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            provider.selectedfacilitytypeIds
                                                .add(provider.facilities
                                                        ?.data?[index].id ??
                                                    0);
                                            log("${provider.selectedfacilitytypeIds}");
                                          } else {
                                            provider.selectedfacilitytypeIds
                                                .remove(provider.facilities
                                                    ?.data?[index].id);
                                            log("${provider.selectedfacilitytypeIds}");
                                          }
                                        });
                                      },
                                    ),
                                    Text(
                                        "${provider.facilities?.data?[index].name}"),
                                  ],
                                )
                              ],
                            )),
              ),

              // Save & Next button
              SizedBox(height: 16.0),
              Center(
                child: TertiaryButton(
                  press: () {
                    // if (provider.selectedtraveltypeIds.isEmpty) {
                    //   showErrorToast("please add atleast one travel styles".tr);
                    //   return;
                    // }
                    // if (provider.selectedfacilitytypeIds.isEmpty) {
                    //   showErrorToast("please add atleast one facilities".tr);
                    //   return;
                    // }

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TourSixScreen()));
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
