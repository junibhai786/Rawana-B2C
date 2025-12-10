import 'dart:developer';
import 'dart:io';

import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Provider/hotel_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/vendor/hotel/edit/edit_hotel_four_screen.dart';
import 'package:moonbnd/widgets/elevatedbuttonicon.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class EditHotelPricingScreen extends StatefulWidget {
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
  EditHotelPricingScreen({
    super.key,
    this.bannerimage,
    this.bathroom = "",
    this.spaceId = "",
    this.bed = "",
    this.content = "",
    this.faqList,
    this.featuredimage,
    this.minimumDayBeforeBooking = "",
    this.minimumdaystaycontroller = "",
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

class AddSpacePricingScreenState extends State<EditHotelPricingScreen> {
  final _formKey = GlobalKey<FormState>();

  String defaultState = "Always available".tr;

  /////// inpit fields

  String defaultStateInput = "";
  TextEditingController priceController = TextEditingController();
  TextEditingController salePriceController = TextEditingController();
  TextEditingController maxGuestController = TextEditingController();
  TextEditingController timeinController = TextEditingController();
  TextEditingController timeoutController = TextEditingController();
  TextEditingController minreservationController = TextEditingController();
  TextEditingController minstayController = TextEditingController();
  bool _termsAccepted = false;
  List<ExtraPriceForVendor> extraPriceSpaceVendorList = [];

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

  void deleteExtraPrice(DateTime? id) {
    extraPriceSpaceVendorList.removeWhere((test) {
      return test.id == id;
    });

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    update();
  }

  void update() {
    final spaceProvider =
        Provider.of<VendorHotelProvider>(context, listen: false);

    priceController = TextEditingController(
        text: "${spaceProvider.hotellistdetails?.data?[0].price}");
    salePriceController = TextEditingController(
        text: "${spaceProvider.hotellistdetails?.data?[0].salePrice}");
    timeinController = TextEditingController(
        text: "${spaceProvider.hotellistdetails?.data?[0].checkInTime}");
    timeoutController = TextEditingController(
        text: "${spaceProvider.hotellistdetails?.data?[0].checkOutTime}");
    minreservationController = TextEditingController(
        text:
            "${spaceProvider.hotellistdetails?.data?[0].minDayBeforeBooking}");
    minstayController = TextEditingController(
        text: "${spaceProvider.hotellistdetails?.data?[0].minDayStays}");

    _termsAccepted =
        spaceProvider.hotellistdetails?.data?[0].enableExtraPrice == "0"
            ? false
            : true;
    spaceProvider.hotellistdetails?.data?[0].extraPrice?.forEach((element) {
      log("${element.type} typoe");
      return extraPriceSpaceVendorList.add(ExtraPriceForVendor(
          id: DateTime.now().add(Duration(seconds: 2)),
          nameEgyptian: TextEditingController(text: ""),
          nameEnglish: TextEditingController(text: element.name),
          nameJapnese: TextEditingController(text: ""),
          perPerson: element.perPerson == "on" ? true : false,
          price: TextEditingController(text: element.price),
          type: element.type == "one_time" ? "one time".tr : "per day".tr));
    });

    // log('${spaceProvider.hotellistdetails?.data?[0].discountByDays?.length} lengthhh discountByDays');

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
                "Update Hotel".tr,
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
            SizedBox(height: 15),
            Divider(
              thickness: 2,
            ),
            SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                "Check in/out time".tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(
                left: 10,
                bottom: 20,
              ),
              child: Text(
                "Time for check in".tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
            ),
            // Car Number Input
            // CustomTextField(
            //   margin: false,
            //   controller: timeinController,
            //   hintText: 'Ex: 2',
            // ),
            Padding(
              padding: const EdgeInsets.only(left: 0, right: 0, bottom: 10),
              child: TextFormField(
                controller: timeinController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter CheckIn Time'.tr;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Checkin Time'.tr,
                  hintText: '07:30',
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: kSecondaryColor, width: 2.0),
                  ),
                  // suffixIcon: Icon(Icons.access_time),
                ),
                readOnly: true,
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    initialTime: TimeOfDay.now(),
                    context: context,
                  );

                  if (pickedTime != null) {
                    String formattedTime =
                        '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                    setState(() {
                      timeinController.text = formattedTime;
                    });
                  }
                },
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                "Time for check out".tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
            ),
            // Car Number Input
            // CustomTextField(
            //   margin: false,
            //   controller: timeoutController,
            //   hintText: 'Ex: 2',
            // ),
            SizedBox(height: 5),

            Padding(
              padding: const EdgeInsets.only(left: 0, right: 0, bottom: 10),
              child: TextFormField(
                controller: timeoutController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter CheckOut Time'.tr;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Checkout Time'.tr,
                  hintText: '17:30',
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: kSecondaryColor, width: 2.0),
                  ),
                  // suffixIcon: Icon(Icons.access_time),
                ),
                readOnly: true,
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    initialTime: TimeOfDay.now(),
                    context: context,
                  );

                  if (pickedTime != null) {
                    String formattedTime =
                        '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                    setState(() {
                      timeoutController.text = formattedTime;
                    });
                  }
                },
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                "Minimum advance reservations".tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
            ),

            CustomTextField(
              margin: false,
              controller: minreservationController,
              hintText: 'Ex: 2',
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                "Leave blank if you dont need to use the min day option".tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 11,
                    fontWeight: FontWeight.w400),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                "Minimum day stay requirements".tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
            ),

            CustomTextField(
              margin: false,
              controller: minstayController,
              hintText: 'Ex: 2'.tr,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                "Leave blank if you dont need to use the min day option".tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 11,
                    fontWeight: FontWeight.w400),
              ),
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
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 20, top: 10),
              child: Text(
                "Price ".tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
            ),

            // Car Number Input
            CustomTextField(
                hintText: "1".tr,
                controller: priceController,
                txKeyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Price'.tr;
                  }
                  return null;
                }),
            // Enable Person Price Switch

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
                            items: ['one time'.tr, 'per day'.tr]
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              log('$value');
                              extraPriceSpaceVendorList[index].type = value;
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: extraPriceSpaceVendorList[index].perPerson,
                            onChanged: (bool? value) {
                              setState(() {
                                extraPriceSpaceVendorList[index].perPerson =
                                    value!;
                              });
                            },
                          ),
                          Text('Price Per Person'.tr),
                        ],
                      ),
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

            // Add Item Button

            SizedBox(height: 20),
            // Save & Next Button
            TertiaryButton(
              press: () async {
                // if (widget.pickedImagefile!.isEmpty) {
                //   showErrorToast("Please input all details");
                // } else {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  if (_termsAccepted == true &&
                      extraPriceSpaceVendorList.isEmpty) {
                    showErrorToast("Please select atleast one extra price");
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditHotelFourScreen(
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
                            minimumDayBeforeBooking:
                                widget.minimumDayBeforeBooking,
                            minimumdaystaycontroller:
                                widget.minimumdaystaycontroller,
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
                            defaultState: defaultState,
                            enableExtraPrice: _termsAccepted,
                            extraPriceForVendorList: extraPriceSpaceVendorList,
                            maxGuests: maxGuestController.value.text,
                            price: priceController.value.text,
                            timeinController: timeinController.value.text,
                            timeoutController: timeoutController.value.text,
                            minreservationController:
                                minreservationController.value.text,
                            minstayController: minstayController.value.text,
                            salePrice: salePriceController.value.text)),
                  );
                }
              },
              // },
              text: 'Save & Next'.tr,
            ),
          ],
        ),
      ),
    );
  }
}
