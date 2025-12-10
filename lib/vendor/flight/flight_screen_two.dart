import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Provider/flight_vendor_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/modals/hotel_property_type_model.dart';
import 'package:moonbnd/widgets/bottom_navigation.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class FlightScreenTwo extends StatefulWidget {
  const FlightScreenTwo({super.key});

  @override
  FlightScreenTwoState createState() => FlightScreenTwoState();
}

class FlightScreenTwoState extends State<FlightScreenTwo> {
  bool loading2 = false;
  bool loading = false;
  bool loading3 = false;
  Map<String, bool> carTypes = {
    'Business': true,
    'First Class': false,
    'Economy': false,
    'Premium Economy': false,
  };
  Map<String, bool> inflight = {
    'Inflight dining': true,
    'Music': false,
    'Sky shopping': false,
    'Seats & Cabin': false,
  };

  @override
  void initState() {
    super.initState();
    // Fetch initial data
    setState(() {
      loading = true;
      loading2 = true;
      loading3 = true;
    });

    Provider.of<VendorFlightProvider>(context, listen: false)
        .flighttypevendor()
        .then((value) {
      setState(() {
        loading2 = false;
      });
    });

    Provider.of<VendorFlightProvider>(context, listen: false)
        .servicestypeflightvendor()
        .then((value) {
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VendorFlightProvider>(context, listen: true);
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
                  "Add New Flight".tr,
                  style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Image.asset(
                Get.locale?.languageCode == 'ar'
                    ? 'assets/haven/flightlevel2_ar.png'
                    : 'assets/haven/flightlevel2.png',
              ),
              Divider(),

              // Car Type Section
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  'Flight Type'.tr,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 200,
                child: loading2
                    ? Center(
                        child: CircularProgressIndicator(color: kSecondaryColor),
                      )
                    : ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: provider.flighttypelists?.data?.length,
                        itemBuilder: (context, index) => Column(
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: provider.selectedFlighttypeIds
                                          .contains(provider.flighttypelists
                                              ?.data?[index].id),
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            provider.selectedFlighttypeIds.add(
                                                provider.flighttypelists
                                                        ?.data?[index].id ??
                                                    0);
                                          } else {
                                            provider.selectedFlighttypeIds
                                                .remove(provider.flighttypelists
                                                    ?.data?[index].id);
                                          }
                                        });
                                      },
                                    ),
                                    Text(
                                        "${provider.flighttypelists?.data?[index].name}"),
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
                  'Flight Service'.tr,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 200,
                // Adjust the height as needed
                child: loading
                    ? Center(
                        child: CircularProgressIndicator(color: kSecondaryColor),
                      )
                    : ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: provider.services?.data?.length,
                        itemBuilder: (context, index) => Column(
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: provider.selectedservicetypeIds
                                          .contains(provider
                                              .services?.data?[index].id),
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            provider.selectedservicetypeIds.add(
                                                provider.services?.data?[index]
                                                        .id ??
                                                    0);
                                          } else {
                                            provider.selectedservicetypeIds
                                                .remove(provider
                                                    .services?.data?[index].id);
                                          }
                                        });
                                      },
                                    ),
                                    Text(
                                        "${provider.services?.data?[index].name}"),
                                  ],
                                )
                              ],
                            )),
              ),
              // Save & Next button
              // Save & Next button
              SizedBox(height: 16.0),
              Center(
                child: TertiaryButton(
                  press: () {
                    if (provider.selectedFlighttypeIds.isEmpty) {
                      showErrorToast("Please check atleast one flight type".tr);
                      return;
                    }
                    if (provider.selectedservicetypeIds.isEmpty) {
                      showErrorToast(
                          "Please check atleast one flight service".tr);
                      return;
                    }

                    provider.addNewFlightVendor().then((value) {
                      if (value == true) {
                        provider.resetAllFields();
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => BottomNav()),
                            (route) => false);
                      }
                    }).then((value) {
                      setState(() {
                        loading = false;
                      });
                    });
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
