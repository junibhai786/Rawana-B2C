import 'dart:developer';
import 'dart:io';

import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Provider/event_provider.dart';
import 'package:moonbnd/Provider/space_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/vendor/event/edit/edit_event_screen_four.dart';
import 'package:moonbnd/widgets/elevatedbuttonicon.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class EditEventPricingScreenThree extends StatefulWidget {
  String title = "";
  String content = "";
  String youtubeVideoText = "";
  List<FaqClass>? faqList;
  File? bannerimage;
  File? featuredimage;
  List<File>? pickedImagefile;
  String duration = "";
  String startTime = "";
  String id = "";
  String locationId = "";
  String address = "";
  String mapLat = "";
  String mapLong = "";
  String mapZoom = "";
  List<EducationClass> txeducationList;
  List<EducationClass> txhealthList;
  List<EducationClass> txtransportationList;
  EditEventPricingScreenThree({
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
  });
  @override
  AddSpacePricingScreenState createState() => AddSpacePricingScreenState();
}

class AddSpacePricingScreenState extends State<EditEventPricingScreenThree> {
  final _formKey = GlobalKey<FormState>();

  String defaultState = "Always available";

  /////// inpit fields

  String defaultStateInput = "";
  TextEditingController priceController = TextEditingController();
  TextEditingController salePriceController = TextEditingController();

  bool _termsAccepted = false;
  List<ExtraPriceForVendor> extraPriceSpaceVendorList = [];
  List<TicketsVendorModal> ticketsVendorList = [];

  void addExtraPrice() {
    extraPriceSpaceVendorList.add(ExtraPriceForVendor(
        id: DateTime.now(),
        nameEgyptian: TextEditingController(),
        nameEnglish: TextEditingController(),
        nameJapnese: TextEditingController(),
        perPerson: false,
        price: TextEditingController(),
        type: "one time"));
    setState(() {});
  }

  void addEvent() {
    ticketsVendorList.add(TicketsVendorModal(
      id: DateTime.now(),
      nameEgyptian: TextEditingController(),
      nameEnglish: TextEditingController(),
      nameJapnese: TextEditingController(),
      numberTicket: TextEditingController(),
      price: TextEditingController(),
    ));
    setState(() {});
  }

  void deleteExtraPrice(DateTime? id) {
    extraPriceSpaceVendorList.removeWhere((test) {
      return test.id == id;
    });

    setState(() {});
  }

  void deleteTickets(DateTime? id) {
    ticketsVendorList.removeWhere((test) {
      return test.id == id;
    });

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    update();
  }

  void update() {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    log("${eventProvider.eventDetailsVendor?.data[0].defaultState}");
    defaultState = eventProvider.eventDetailsVendor?.data[0].defaultState == 0
        ? "Always available"
        : "Only available on specific dates";
    priceController = TextEditingController(
        text: "${eventProvider.eventDetailsVendor?.data[0].price}");
    salePriceController = TextEditingController(
        text: "${eventProvider.eventDetailsVendor?.data[0].salePrice}");

    _termsAccepted =
        eventProvider.eventDetailsVendor?.data[0].enableExtraPrice == 1
            ? true
            : false;
    eventProvider.eventDetailsVendor?.data[0].extraPrice.forEach((element) {
      return extraPriceSpaceVendorList.add(ExtraPriceForVendor(
          id: DateTime.now().add(Duration(seconds: 5)),
          nameEgyptian: TextEditingController(text: element.nameEgy),
          nameEnglish: TextEditingController(text: element.name),
          nameJapnese: TextEditingController(text: element.nameJa),
          perPerson: element.perPerson == "on" ? true : false,
          price: TextEditingController(text: element.price),
          type: element.type == "one_time"
              ? "one time"
              : element.type == "per_hour"
                  ? "per hour"
                  : "per day"));
    });
    eventProvider.eventDetailsVendor?.data[0].ticketTypes.forEach((element) {
      return ticketsVendorList.add(TicketsVendorModal(
        id: DateTime.now().add(Duration(seconds: 5)),
        ticketCode: TextEditingController(text: element.code),
        nameEgyptian: TextEditingController(text: element.nameEgy),
        nameEnglish: TextEditingController(text: element.name),
        nameJapnese: TextEditingController(text: element.nameJa),
        numberTicket: TextEditingController(text: element.number),
        price: TextEditingController(text: element.price),
      ));
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // final spaceProvider = Provider.of<SpaceProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            // Stepper for process navigation

            // Default State Dropdown
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                "Edit New Event".tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Image.asset(
              Get.locale?.languageCode == 'ar'
                  ? 'assets/haven/eventlevel3_ar.png'
                  : 'assets/haven/eventlevel3.png',
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                "Default State".tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: DropdownButtonFormField<String>(
                value: defaultState,
                decoration: InputDecoration(
                  border:
                      OutlineInputBorder(), // Adds a border around the dropdown
                  enabledBorder: OutlineInputBorder(
                    // Border when dropdown is not focused
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    // Border when dropdown is focused
                    borderSide: BorderSide(color: kSecondaryColor, width: 2.0),
                  ),
                ),
                items: ['Only available on specific dates', 'Always available']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == "Always available") {
                    defaultStateInput = "0";
                  } else if (value == "Only available on specific dates") {
                    defaultStateInput = "1";
                  }
                  setState(() {});
                },
              ),
            ),

            SizedBox(height: 15),
            Divider(
              thickness: 2,
            ),
            SizedBox(height: 15),

            // Pricing Section
            Padding(
              padding: const EdgeInsets.only(left: 9, bottom: 10),
              child: Text(
                "Pricing".tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
            ),

            // Car Number Input

            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                "Price".tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
            ),
            // Event Price Input
            CustomTextField(
              controller: priceController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Price'.tr;
                }
                return null;
              },
              txKeyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              hintText: 'Event Price'.tr,
              onSaved: (value) {},
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                "Sale Price".tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
            ),

            // Sale Price Input
            CustomTextField(
              controller: salePriceController,
              hintText: 'Event Sale Price'.tr,
              txKeyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onSaved: (value) {},
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                "If the regular price is less than the discount it will show the regular price"
                    .tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400),
              ),
            ),

            // Enable Person Price Switch

            SizedBox(height: 10),
            Text('Tickets'.tr),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: ticketsVendorList.length,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 10),
                      child: Text(
                        "Code".tr,
                        style: TextStyle(
                            fontFamily: "inter",
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    CustomTextField(
                      controller: ticketsVendorList[index].ticketCode,
                      hintText: 'Ticket Vip'.tr,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 10),
                      child: Text(
                        "Name".tr,
                        style: TextStyle(
                            fontFamily: "inter",
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    CustomTextField(
                      controller: ticketsVendorList[index].nameEnglish,
                      hintText: 'English Name'.tr,
                    ),
                    CustomTextField(
                      controller: ticketsVendorList[index].nameJapnese,
                      hintText: 'Japanese Name'.tr,
                    ),
                    CustomTextField(
                      controller: ticketsVendorList[index].nameEgyptian,
                      hintText: 'Egyptian Name'.tr,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 10),
                        child: Text(
                          "Price".tr,
                          style: TextStyle(
                              fontFamily: "inter",
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    CustomTextField(
                      controller: ticketsVendorList[index].price,
                      hintText: 'Price Ticket'.tr,
                      txKeyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      controller: ticketsVendorList[index].numberTicket,
                      hintText: 'Number Ticket'.tr,
                      txKeyboardType: TextInputType.number,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red, // Red background color
                        borderRadius: BorderRadius.circular(
                            12), // Slightly rounded corners
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.white, // White icon color
                        ),
                        onPressed: () {
                          if (ticketsVendorList[index].id != null) {
                            deleteTickets(ticketsVendorList[index].id!);
                          }
                          setState(() {});
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                );
              },
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 130,
                    child: TextIconButtom(
                      size: 10,
                      icon: Icon(Icons.upload),
                      text: 'Add Item'.tr,
                      press: () {
                        addEvent();
                      },
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),

            // Extra Price Section
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Checkbox(
                    value: _termsAccepted,
                    onChanged: (bool? value) {
                      setState(() {
                        _termsAccepted = value!;
                      });
                    },
                  ),
                  Text('Enable Extra Price'.tr),
                ],
              ),
            ),

            if (_termsAccepted)
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: extraPriceSpaceVendorList.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 10),
                        child: Text(
                          "Name".tr,
                          style: TextStyle(
                              fontFamily: "inter",
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      CustomTextField(
                        controller:
                            extraPriceSpaceVendorList[index].nameEnglish,
                        hintText: 'English Name'.tr,
                      ),
                      CustomTextField(
                        controller:
                            extraPriceSpaceVendorList[index].nameJapnese,
                        hintText: 'Japanese Name'.tr,
                      ),
                      CustomTextField(
                        controller:
                            extraPriceSpaceVendorList[index].nameEgyptian,
                        hintText: 'Egyptian Name'.tr,
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, bottom: 10),
                          child: Text(
                            "Price".tr,
                            style: TextStyle(
                                fontFamily: "inter",
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      CustomTextField(
                        controller: extraPriceSpaceVendorList[index].price,
                        hintText: 'Price'.tr,
                        txKeyboardType: TextInputType.number,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, bottom: 10),
                          child: Text(
                            "Type".tr,
                            style: TextStyle(
                                fontFamily: "inter",
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<String>(
                            value: extraPriceSpaceVendorList[index].type,
                            decoration: InputDecoration(
                              border:
                                  OutlineInputBorder(), // Adds a border around the dropdown
                              enabledBorder: OutlineInputBorder(
                                // Border when dropdown is not focused
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                // Border when dropdown is focused
                                borderSide:
                                    BorderSide(color: kSecondaryColor, width: 2.0),
                              ),
                            ),
                            items: ['one time', 'per hour', 'per day']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              extraPriceSpaceVendorList[index].type = value;
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                      // Row(
                      //   children: [
                      //     Checkbox(
                      //       value: extraPriceSpaceVendorList[index].perPerson,
                      //       onChanged: (bool? value) {
                      //         setState(() {
                      //           extraPriceSpaceVendorList[index].perPerson =
                      //               value!;
                      //         });
                      //       },
                      //     ),
                      //     Text('Price Per Person'.tr),
                      //   ],
                      // ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red, // Red background color
                          borderRadius: BorderRadius.circular(
                              12), // Slightly rounded corners
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.white, // White icon color
                          ),
                          onPressed: () {
                            if (extraPriceSpaceVendorList[index].id != null) {
                              deleteExtraPrice(
                                  extraPriceSpaceVendorList[index].id!);
                            }
                            setState(() {});
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  );
                },
              ),

            if (_termsAccepted)
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 130,
                      child: TextIconButtom(
                        size: 10,
                        icon: Icon(Icons.upload),
                        text: 'Add Item'.tr,
                        press: () {
                          addExtraPrice();
                        },
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              ),

            SizedBox(height: 20),
            // Save & Next Button
            TertiaryButton(
              press: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  if (defaultState.isEmpty) {
                    showErrorToast("Please enter state");
                    return;
                  }

                  if (_termsAccepted == true &&
                      extraPriceSpaceVendorList.isEmpty) {
                    showErrorToast("Please enter atleast one extra price");
                    return;
                  }

                  if (ticketsVendorList.isEmpty) {
                    showErrorToast("Please enter atleast one Ticket");
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EventFourEditVendorScreen(
                            id: widget.id,
                            title: widget.title,
                            content: widget.content,
                            duration: widget.duration,
                            startTime: widget.startTime,
                            youtubeVideoText: widget.youtubeVideoText,
                            ticketsVendorList: ticketsVendorList,
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
                            locationId: widget.locationId,
                            address: widget.address,
                            mapLat: widget.mapLat,
                            mapLong: widget.mapLong,
                            mapZoom: widget.mapZoom,
                            txeducationList: widget.txeducationList,
                            txhealthList: widget.txhealthList,
                            txtransportationList: widget.txtransportationList,
                            defaultState: defaultState,
                            enableExtraPrice: _termsAccepted,
                            extraPriceForVendorList: extraPriceSpaceVendorList,
                            price: priceController.value.text,
                            salePrice: salePriceController.value.text)),
                  );
                }
              },
              text: 'Save & Next'.tr,
            ),
          ],
        ),
      ),
    );
  }
}
