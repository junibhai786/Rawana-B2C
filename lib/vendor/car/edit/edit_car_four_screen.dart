import 'dart:developer';
import 'dart:io';

import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Provider/home_provider.dart';

import 'package:moonbnd/Provider/singup_vendor_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/modals/car_detail_model.dart';
import 'package:moonbnd/vendor/car/edit/edit_Car_one_screen.dart';
import 'package:moonbnd/vendor/car/edit/edit_car_five_screen.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class EditCarFourScreen extends StatefulWidget {
  final String? url;
  int carid = 0;
  String title = "";
  String content = "";
  String youtubeVideoText = "";
  File? bannerimage;
  File? featuredimage;
  List<File>? pickedImagefile;
  String minimumDayBeforeBooking = "0";
  String minimumdaystaycontroller = "0";
  String bed = "";
  String bathroom = "";
  String locationId = "";
  String address = "";
  String mapLat = "";
  String mapLong = "";
  String mapZoom = "";
  String passenger = "";
  String baggage = "";
  List<String> selectedCarFeatureIdss = [];
  List<String> selectedCartypeIdss = [];

  String defaultstates = "";
  String gear = "";

  String car = "";
  List<ExtraPrices2> extraPrice;

  int defaultState = 0;
  String price = "";
  String salePrice = "";
  String maxGuests = "";

  String door = "";
  List<FAQ2>? faq;
  List<Term>? terms;
  List<ExtraPrices2> extraprice = [];

  bool enableExtraPrice = false;

  EditCarFourScreen({
    super.key,
    this.url,
    this.terms,
    this.extraPrice = const [],
    this.passenger = '',
    this.door = '',
    this.bannerimage,
    this.gear = '',
    this.bathroom = "",
    this.baggage = "",
    this.faq,
    this.bed = "",
    this.content = "",
    this.featuredimage,
    this.minimumDayBeforeBooking = "0",
    this.minimumdaystaycontroller = "0",
    this.pickedImagefile,
    this.title = "",
    this.youtubeVideoText = "",
    this.carid = 0,
    this.locationId = "",
    this.address = "",
    this.mapLat = "",
    this.mapLong = "",
    this.mapZoom = "",
    this.car = "",
    this.defaultState = 0,
    this.price = "",
    this.salePrice = "",
    this.maxGuests = "",
    this.enableExtraPrice = false,
  });
  @override
  EditCarFourScreenState createState() => EditCarFourScreenState();
}

class EditCarFourScreenState extends State<EditCarFourScreen> {
  bool loading = false;
  bool loading2 = false;
  List<int> selectedCartypeIds = [];
  List<int> selectedCarFeatureIds = [];
  HomeProvider? provider2;
  @override
  void initState() {
    super.initState();
    log("minimumDayBeforeBooking${widget.url}");
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
    update();
  }

  void update() {
    final provider = Provider.of<VendorAuthProvider>(context, listen: false);
    provider.selectedCartypeIds.clear();
    provider.selectedCarFeatureIds.clear();
    if (widget.terms != null && widget.terms!.isNotEmpty) {
      if (widget.terms![0].child != null) {
        for (var child in widget.terms![0].child!) {
          selectedCartypeIds.add(child.id ?? 0);
        }
      }
    }
    if (widget.terms != null && widget.terms!.length >= 2) {
      if (widget.terms![1].child != null) {
        for (var child in widget.terms![1].child!) {
          selectedCarFeatureIds.add(child.id ?? 0);
        }
      }
    }
    setState(() {});
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
                  "Update Car".tr,
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
                        itemCount: provider.cartypes?.data?.length,
                        itemBuilder: (context, index) => Column(
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: selectedCartypeIds.contains(
                                          provider.cartypes?.data?[index].id),
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            selectedCartypeIds.add(provider
                                                    .cartypes
                                                    ?.data?[index]
                                                    .id ??
                                                0);
                                          } else {
                                            selectedCartypeIds.remove(provider
                                                .cartypes?.data?[index].id);
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
                                      value: selectedCarFeatureIds.contains(
                                          provider
                                              .carfeatures?.data?[index].id),
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            selectedCarFeatureIds.add(provider
                                                    .carfeatures
                                                    ?.data?[index]
                                                    .id ??
                                                0);
                                          } else {
                                            selectedCarFeatureIds.remove(
                                                provider.carfeatures
                                                    ?.data?[index].id);
                                          }
                                        });
                                      },
                                    ),
                                    Text(
                                        "${provider.carfeatures?.data?[index].name}"),
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditCarFiveScreen(
                                  selectedCarFeatureIds: selectedCarFeatureIds,
                                  selectedCartypeIds: selectedCartypeIds,
                                  extraPrice: widget.extraPrice,
                                  featuredimage: widget.featuredimage,
                                  pickedImagefile: widget.pickedImagefile,
                                  bannerimage: widget.bannerimage,
                                  faq: widget.faq,
                                  passenger: widget.passenger,
                                  gear: widget.gear,
                                  door: widget.door,
                                  url: widget.url,
                                  carid: widget.carid,
                                  title: widget.title,
                                  content: widget.content,
                                  youtubeVideoText: widget.youtubeVideoText,
                                  baggage: widget.baggage,
                                  locationId: widget.locationId,
                                  address: widget.address,
                                  mapLat: widget.mapLat,
                                  mapLong: widget.mapLong,
                                  defaultState: widget.defaultState.toString(),
                                  car: widget.car,
                                  price: widget.price,
                                  salePrice: widget.salePrice,
                                  minimumDayBeforeBooking:
                                      widget.minimumDayBeforeBooking,
                                  minimumdaystaycontroller:
                                      widget.minimumdaystaycontroller,
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
