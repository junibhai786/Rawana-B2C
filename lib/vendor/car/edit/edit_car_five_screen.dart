import 'dart:developer';
import 'dart:io';

import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Provider/singup_vendor_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/vendor/car/edit/edit_Car_one_screen.dart';
import 'package:moonbnd/widgets/bottom_navigation.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class EditCarFiveScreen extends StatefulWidget {
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
  List<int> selectedCartypeIds = [];
  List<int> selectedCarFeatureIds = [];

  String defaultstates = "";
  String gear = "";

  String car = "";
  String door = "";

  String defaultState = "";
  String price = "";
  String salePrice = "";
  List<FAQ2>? faq;
  List<ExtraPrices2>? extraPrice = [];

  String maxGuests = "";
  bool enableExtraPrice = false;

  EditCarFiveScreen({
    this.url,
    this.bannerimage,
    this.selectedCartypeIds = const [],
    this.selectedCarFeatureIds = const [],
    this.passenger = "",
    this.extraPrice,
    this.baggage = "",
    this.faq,
    this.bathroom = "",
    this.bed = "",
    this.gear = "",
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
    this.defaultState = "",
    this.price = "",
    this.salePrice = "",
    this.door = "",
    this.maxGuests = "",
    this.enableExtraPrice = false,
  });
  @override
  EditCarFiveScreenState createState() => EditCarFiveScreenState();
}

class EditCarFiveScreenState extends State<EditCarFiveScreen> {
  TextEditingController importUrlController = TextEditingController();

  bool loading = false;
  @override
  void initState() {
    super.initState();
    log("faq${widget.faq}");
    log("extraprice${widget.extraPrice}");

    log("featuredimage${widget.pickedImagefile}");

    log("url${widget.url}");
    if (widget.url != null) {
      importUrlController.text = widget.url ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VendorAuthProvider>(context, listen: true);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: loading
          ? Center(
              child: CircularProgressIndicator(color: kSecondaryColor),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Stepper progress indicator

                  Padding(
                    padding: const EdgeInsets.only(left: 10, bottom: 10),
                    child: Text('Update Car'.tr,
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
                    controller: importUrlController,
                    hintText: "Import url".tr,
                  ),

                  SizedBox(height: 32.0),

                  // Save & Next button
                  Center(
                    child: TertiaryButton(
                      press: () {
                        // setState(() {
                        //   loading = true;
                        // });

                        provider
                            .updatecarvendor(
                          extraPrice: widget.extraPrice,
                          faqs: widget.faq,
                          passenger: widget.passenger,
                          carId: widget.carid,
                          title: widget.title,
                          content: widget.content,
                          youtubeVideoText: widget.youtubeVideoText,
                          bannerimages: widget.bannerimage != null
                              ? File(widget.bannerimage!.path)
                              : null,
                          featuredimages: widget.featuredimage != null
                              ? File(widget.featuredimage!.path)
                              : null,
                          galleryimage:
                              (widget.pickedImagefile ?? []).isNotEmpty
                                  ? widget.pickedImagefile!
                                      .map((e) => File(e.path))
                                      .toList()
                                  : [],
                          minimumDayBeforeBooking:
                              int.tryParse(widget.minimumDayBeforeBooking) ?? 0,
                          minimumdaystaycontroller:
                              int.tryParse(widget.minimumdaystaycontroller) ??
                                  0,
                          car: widget.car,
                          door: widget.door,
                          locationId: widget.locationId,
                          address: widget.address,
                          mapLat: widget.mapLat,
                          mapLong: widget.mapLong,
                          mapZoom: widget.mapZoom,
                          defaultState: widget.defaultState,
                          enableExtraPrice: widget.enableExtraPrice,
                          price: widget.price,
                          salePrice: widget.salePrice,
                          ical: importUrlController.text,
                          baggage: widget.baggage,
                          defaultstates: widget.defaultState,
                          gear: widget.gear,
                          selectedCarFeatureIds: widget.selectedCarFeatureIds,
                          selectedCartypeIds: widget.selectedCartypeIds,
                          zooms: widget.mapZoom,
                        )
                            .then((value) {
                          if (value == true) {
                            setState(() {});
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
    );
  }
}
