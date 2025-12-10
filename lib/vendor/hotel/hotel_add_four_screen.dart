import 'package:moonbnd/Provider/hotel_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/widgets/bottom_navigation.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class HotelFourScreen extends StatefulWidget {
  HotelFourScreen({Key? key});

  @override
  HotelFourScreenState createState() => HotelFourScreenState();
}

class HotelFourScreenState extends State<HotelFourScreen> {
  bool loading2 = false;
  bool loading = false;
  bool loading3 = false;

  Map<String, bool> hotelservice = {
    'Havana Lobby Bar'.tr: true,
    'Fiesta Restaurant'.tr: false,
    'Hotel Transport Services'.tr: false,
    'Free Luggage Deposit'.tr: false,
    'Laundry Services'.tr: false,
    'Pets Welcome'.tr: false,
    'Tickets'.tr: false,
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

    Provider.of<VendorHotelProvider>(context, listen: false)
        .propertytypehotelvendor()
        .then((value) {
      setState(() {
        loading2 = false;
      });
    });
    Provider.of<VendorHotelProvider>(context, listen: false)
        .facilitiestypehotelvendor()
        .then((value) {
      setState(() {
        loading = false;
      });
    });
    Provider.of<VendorHotelProvider>(context, listen: false)
        .servicestypehotelvendor()
        .then((value) {
      setState(() {
        loading3 = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VendorHotelProvider>(context, listen: true);
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
                  "Add New Hotel".tr,
                  style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Image.asset(Get.locale?.languageCode == 'ar'
                  ? 'assets/haven/eventlevel4_ar.png'
                  : 'assets/haven/eventlevel4.png'),

              Divider(),

              // Car Type Section
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  'Property Type'.tr,
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
                        itemCount: provider.propertylists?.data?.length,
                        itemBuilder: (context, index) => Column(
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: provider.selectedpropertytypeIds
                                          .contains(provider
                                              .propertylists?.data?[index].id),
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            provider.selectedpropertytypeIds
                                                .add(provider.propertylists
                                                        ?.data?[index].id ??
                                                    0);
                                          } else {
                                            provider.selectedpropertytypeIds
                                                .remove(provider.propertylists
                                                    ?.data?[index].id);
                                          }
                                        });
                                      },
                                    ),
                                    Text(
                                        "${provider.propertylists?.data?[index].name}"),
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
                  'Facilities'.tr,
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
                                          } else {
                                            provider.selectedfacilitytypeIds
                                                .remove(provider.facilities
                                                    ?.data?[index].id);
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

              Divider(),

              // Car Features Section
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  'Hotel Service'.tr,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 300,
                // Adjust the height as needed
                child: loading3
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
              SizedBox(height: 16.0),
              Center(
                child: TertiaryButton(
                  press: () {
                    setState(() {
                      loading = true;
                    });
                    provider.addNewHotelVendor().then((value) {
                      setState(() {
                        loading = false;
                      });
                      if (value == true) {
                        setState(() {
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
                          provider.addresscontroller = TextEditingController();
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

                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => BottomNav()),
                            (route) => false);
                      }
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
