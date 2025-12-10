import 'dart:developer';

import 'package:moonbnd/Provider/api_interface.dart';

import 'package:moonbnd/Provider/singup_vendor_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/vendor/car/car_five_screen.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class CarFourScreen extends StatefulWidget {
  final String? url;
  CarFourScreen({super.key, this.url});
  @override
  CarFourScreenState createState() => CarFourScreenState();
}

class CarFourScreenState extends State<CarFourScreen> {
  bool loading = false;
  bool loading2 = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      loading = true;
      loading2 = true;
    });
    Provider.of<VendorAuthProvider>(context, listen: false)
        .fetchcarfeatures()
        .then((value) {
      setState(() {
        loading = false;
      });
    });
    Provider.of<VendorAuthProvider>(context, listen: false)
        .fetchcartypes()
        .then((value) {
      setState(() {
        loading2 = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VendorAuthProvider>(context, listen: true);

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
                  "Add New Car".tr,
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
                'Car Type'.tr,
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
                        itemCount: provider.carfeatures?.data?.length,
                        itemBuilder: (context, index) => Column(
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: provider.selectedCartypeIds
                                          .contains(provider
                                              .cartypes?.data?[index].id),
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            provider.selectedCartypeIds.add(
                                                provider.cartypes?.data?[index]
                                                        .id ??
                                                    0);
                                            log("${provider.selectedCartypeIds}");
                                          } else {
                                            provider.selectedCartypeIds.remove(
                                                provider
                                                    .cartypes?.data?[index].id);
                                            log("${provider.selectedCartypeIds}");
                                          }
                                        });
                                      },
                                    ),
                                    Text(
                                        "${provider.cartypes?.data?[index].name}"),
                                  ],
                                )
                              ],
                            )),
              ),

              Divider(),

              // Car Features Section
              Text(
                'Car Features'.tr,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              SizedBox(
                height: 300,
                // Adjust the height as needed
                child: loading
                    ? Center(
                        child: CircularProgressIndicator(color: kSecondaryColor),
                      )
                    : ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: provider.carfeatures?.data?.length,
                        itemBuilder: (context, index) => Column(
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: provider.selectedCarFeatureIds
                                          .contains(provider
                                              .carfeatures?.data?[index].id),
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            provider.selectedCarFeatureIds.add(
                                                provider.carfeatures
                                                        ?.data?[index].id ??
                                                    0);
                                            log("${provider.selectedCarFeatureIds}");
                                          } else {
                                            provider.selectedCarFeatureIds
                                                .remove(provider.carfeatures
                                                    ?.data?[index].id);
                                            log("${provider.selectedCarFeatureIds}");
                                          }
                                        });
                                      },
                                    ),
                                    Text(
                                        "${provider.carfeatures?.data?[index].name}")
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
                    // if (provider.selectedCarFeatureIds.isEmpty) {
                    //   showErrorToast("please add atleast one car features");
                    // } else if (provider.selectedCartypeIds.isEmpty) {
                    //   showErrorToast("please add atleast one types");
                    // } else {

                    // }
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CarFiveScreen(
                                  url: widget.url,
                                )));
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
