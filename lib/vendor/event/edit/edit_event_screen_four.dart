import 'dart:developer';
import 'dart:io';

import 'package:moonbnd/Provider/event_provider.dart';
import 'package:moonbnd/Provider/space_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/vendor/event/all_event_screen.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class EventFourEditVendorScreen extends StatefulWidget {
  String title = "";
  String id = "";
  String content = "";
  String youtubeVideoText = "";
  List<FaqClass>? faqList;
  File? bannerimage;
  File? featuredimage;
  List<File>? pickedImagefile;

  String locationId = "";
  String duration = "";
  String startTime = "";
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

  bool enableExtraPrice = false;
  List<ExtraPriceForVendor> extraPriceForVendorList = const [];
  List<TicketsVendorModal> ticketsVendorList = [];

  EventFourEditVendorScreen({
    super.key,
    this.bannerimage,
    this.id = "",
    this.startTime = "",
    this.duration = "",
    this.content = "",
    this.faqList,
    this.featuredimage,
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
    this.ticketsVendorList = const [],
    this.defaultState = "",
    this.price = "",
    this.salePrice = "",
    this.enableExtraPrice = false,
    this.extraPriceForVendorList = const [],
  });
  @override
  SpaceFourScreenState createState() => SpaceFourScreenState();
}

class SpaceFourScreenState extends State<EventFourEditVendorScreen> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      isLoading = true;
    });

    Provider.of<EventProvider>(context, listen: false)
        .fetchEventCatagories()
        .then((value) {
      Provider.of<EventProvider>(context, listen: false).update();

      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = Provider.of<EventProvider>(context, listen: true);
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
                        "Edit New Event".tr,
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
                    Text(
                      'Event Type'.tr,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),

                    ...(item.eventCatagoriesVendor?.data)!.map((element) {
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

                    SizedBox(height: 16.0),
                    Center(
                      child: TertiaryButton(
                        press: () async {
                          bool check = await item.editEventvendor(
                            id: widget.id,
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
                            startTime: widget.startTime,
                            ticketsVendorList: widget.ticketsVendorList,
                            duration: widget.duration,
                            locationId: widget.locationId,
                            address: widget.address,
                            mapLat: widget.mapLat,
                            mapLong: widget.mapLong,
                            mapZoom: widget.mapZoom,
                            txeducationList: widget.txeducationList,
                            txhealthList: widget.txhealthList,
                            txtransportationList: widget.txtransportationList,
                            defaultState: widget.defaultState,
                            price: widget.price,
                            salePrice: widget.salePrice,
                            enableExtraPrice: widget.enableExtraPrice,
                            extraPriceForVendorList:
                                widget.extraPriceForVendorList,

                            /////
                          );

                          if (check) {
                            // ignore: use_build_context_synchronously
                            Navigator.of(context).pop();
                            // ignore: use_build_context_synchronously
                            Navigator.of(context).pop();
                            // ignore: use_build_context_synchronously
                            Navigator.of(context).pop();
                            // ignore: use_build_context_synchronously

                            // ignore: use_build_context_synchronously
                            Navigator.of(context).pop("yes");
                          }
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
