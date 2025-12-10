import 'dart:io';

import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Provider/space_provider.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class EditSpaceFiveScreen extends StatefulWidget {
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
  String salePrice = "";
  String maxGuests = "";
  bool enableExtraPrice = false;
  List<ExtraPriceForVendor> extraPriceForVendorList = const [];
  List<DiscountByNoOfDayAndNightModal> discountByNoOfDayAndNightList = const [];

  EditSpaceFiveScreen({
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
    this.spaceId = "",
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
  SpaceFiveScreenState createState() => SpaceFiveScreenState();
}

class SpaceFiveScreenState extends State<EditSpaceFiveScreen> {
  TextEditingController _importUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _importUrlController = TextEditingController(
        text: Provider.of<SpaceProvider>(context, listen: false)
            .spaceDetailsVendor
            ?.data[0]
            .ical_import_url);
  }

  @override
  Widget build(BuildContext context) {
    final item = Provider.of<SpaceProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Stepper progress indicator

            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text("Update Space".tr,
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
              controller: _importUrlController,
              hintText: "Import url".tr,
            ),

            SizedBox(height: 32.0),

            // Save & Next button
            Center(
              child: TertiaryButton(
                press: () async {
                  bool check = await item.editSpacevendor(
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
                      minimumDayBeforeBooking: widget.minimumDayBeforeBooking,
                      minimumdaystaycontroller: widget.minimumdaystaycontroller,
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
                      discountByNoOfDayAndNightList:
                          widget.discountByNoOfDayAndNightList,
                      enableExtraPrice: widget.enableExtraPrice,
                      extraPriceForVendorList: widget.extraPriceForVendorList,
                      maxGuests: widget.maxGuests,
                      price: widget.price,
                      salePrice: widget.salePrice,
                      ical: _importUrlController.value.text);

                  if (check) {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();

                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop("yes");
                  } else {}
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
