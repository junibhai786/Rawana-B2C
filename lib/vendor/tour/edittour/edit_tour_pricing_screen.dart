import 'dart:developer';
import 'dart:io';

import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Provider/vendor_tour_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/vendor/tour/edittour/edit_tour_four_screen.dart';
import 'package:moonbnd/widgets/elevatedbuttonicon.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class EditTourPricingScreen extends StatefulWidget {
  String tourId = "";
  String title = "";
  String content = "";
  String youtubeVideoText = "";
  List<FaqClass>? faqList;
  File? bannerimage;
  File? featuredimage;
  List<File>? pickedImagefile;
  String minimumDayBeforeBooking = "";
  String minimumdaystaycontroller = "";
  String maximumPeople = "";
  String minimumPeople = "";
  String duration = "";
  String locationId = "";
  String address = "";
  String mapLat = "";
  String mapLong = "";
  String mapZoom = "";
  List<EducationClass> txeducationList;
  List<EducationClass> txhealthList;
  List<EducationClass> txtransportationList;
  List<ItineraryClass>? itineraryList;
  String categoryId = "";
  List<IncludeClass>? Include;
  List<ExcludeClass>? Exclude;

  EditTourPricingScreen({
    super.key,
    this.tourId = "",
    this.bannerimage,
    this.maximumPeople = "",
    this.content = "",
    this.faqList,
    this.featuredimage,
    this.minimumDayBeforeBooking = "",
    this.minimumdaystaycontroller = "",
    this.pickedImagefile,
    this.title = "",
    this.youtubeVideoText = "",
    this.locationId = "",
    this.categoryId = "",
    this.address = "",
    this.mapLat = "",
    this.mapLong = "",
    this.mapZoom = "",
    this.txeducationList = const [],
    this.txhealthList = const [],
    this.txtransportationList = const [],
    this.itineraryList,
    this.minimumPeople = "",
    this.duration = "",
    this.Include,
    this.Exclude,
  });
  @override
  EditTourPricingScreenState createState() => EditTourPricingScreenState();
}

class EditTourPricingScreenState extends State<EditTourPricingScreen> {
  final _formKey = GlobalKey<FormState>();

  String defaultState = "Always available";

  /////// inpit fields

  String defaultStateInput = "";
  TextEditingController priceController = TextEditingController();
  TextEditingController salePriceController = TextEditingController();

  bool _termsAccepted = false;
  bool _enableExtraPrice = false;
  List<PersonTypeForVendor> personTypeForVendorList = [];
  List<ExtraPriceVendor> extraPriceVendorList = [];

  void addPersonType() {
    personTypeForVendorList.add(PersonTypeForVendor(
        id: DateTime.now(),
        min: TextEditingController(),
        max: TextEditingController(),
        descriptionEgyptian: TextEditingController(),
        descriptionEnglish: TextEditingController(),
        descriptionArabic: TextEditingController(),
        nameEgyptian: TextEditingController(),
        nameEnglish: TextEditingController(),
        nameArabic: TextEditingController(),
        perPerson: false,
        price: TextEditingController(),
        type: "one_time"));
    setState(() {});
  }

  void addExtraPrice() {
    extraPriceVendorList.add(ExtraPriceVendor(
        id: DateTime.now(),
        name: TextEditingController(),
        namear: TextEditingController(),
        // nameEgy: TextEditingController(),
        price: TextEditingController(),
        type: "one_time"));
    setState(() {});
  }

  void deletePersonType(DateTime? id) {
    personTypeForVendorList.removeWhere((test) {
      return test.id == id;
    });

    setState(() {});
  }

  void deleteExtraPrice(DateTime? id) {
    extraPriceVendorList.removeWhere((test) {
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
    final tourProvider =
        Provider.of<VendorTourProvider>(context, listen: false);
    log("${tourProvider.tourlistdetails?.data?[0].defaultState}");
    defaultState = tourProvider.tourlistdetails?.data?[0].defaultState == 0
        ? "Always available"
        : "Only available on specific dates";
    priceController = TextEditingController(
        text: "${tourProvider.tourlistdetails?.data?[0].price}");
    salePriceController = TextEditingController(
        text: "${tourProvider.tourlistdetails?.data?[0].salePrice}");

    _enableExtraPrice =
        tourProvider.tourlistdetails?.data?[0].enableExtraPrice == 1
            ? true
            : false;
    tourProvider.tourlistdetails?.data?[0].extraPrice?.forEach((element) {
      return extraPriceVendorList.add(ExtraPriceVendor(
          id: DateTime.now().add(Duration(seconds: 5)),
          name: TextEditingController(text: element.name),
          // nameEgy: TextEditingController(text: element.nameEgy),
          namear: TextEditingController(text: element.namear),
          price: TextEditingController(text: element.price),
          type: element.type));
    });

    _termsAccepted =
        tourProvider.tourlistdetails?.data?[0].enablePersonTypes == 1
            ? true
            : false;
    tourProvider.tourlistdetails?.data?[0].personTypes?.forEach((element) {
      return personTypeForVendorList.add(PersonTypeForVendor(
        id: DateTime.now().add(Duration(seconds: 5)),
        min: TextEditingController(text: element.min),

        max: TextEditingController(text: element.max),
        // descriptionEgyptian: TextEditingController(),
        descriptionEnglish: TextEditingController(text: element.desc),
        descriptionArabic: TextEditingController(text: element.descar),
        // nameEgyptian: TextEditingController(text: element.nameEgy),
        nameEnglish: TextEditingController(text: element.name),
        nameArabic: TextEditingController(text: element.namear),
        descriptionEgyptian: TextEditingController(text: element.descEgy),
        price: TextEditingController(text: element.price),
      ));
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // final tourProvider = Provider.of<VendorTourProvider>(context, listen: true);
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
                "Add New Tour".tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Image.asset(
              Get.locale?.languageCode == 'ar'
                  ? 'assets/haven/level3_ar.png'
                  : 'assets/haven/level3.png',
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
              hintText: 'Tour Price',
              onSaved: (value) {},
              txKeyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Tour Price'.tr;
                }
                return null;
              },
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
              hintText: 'Sale Price'.tr,
              onSaved: (value) {},
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              // validator: (value) {
              //   if (value == null || value.isEmpty) {
              //     return 'Please enter Sale Price'.tr;
              //   }
              //   return null;
              // },
              txKeyboardType: TextInputType.number,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                "If the regular price is less than the discount , it will show the regular price"
                    .tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                "Leave blank if you don’t need to set minimum day stay option"
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
            // Extra Price Section
            Padding(
              padding: const EdgeInsets.only(
                left: 10,
              ),
              child: Text(
                "Person Types".tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ),

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
                  Text('Enable Person Types'.tr),
                ],
              ),
            ),

            if (_termsAccepted)
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: personTypeForVendorList.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 10),
                        child: Text(
                          "Person Type (English)".tr,
                          style: TextStyle(
                              fontFamily: "inter",
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      CustomTextField(
                        controller: personTypeForVendorList[index].nameEnglish,
                        hintText: 'Adult',
                      ),
                      CustomTextField(
                        controller:
                            personTypeForVendorList[index].descriptionEnglish,
                        hintText: 'Description',
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 10),
                        child: Text(
                          "Person Type (Arabic)".tr,
                          style: TextStyle(
                              fontFamily: "inter",
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      CustomTextField(
                        controller: personTypeForVendorList[index].nameArabic,
                        hintText: 'Arabic Name',
                      ),
                      CustomTextField(
                        controller:
                            personTypeForVendorList[index].descriptionArabic,
                        hintText: 'Description',
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 10, bottom: 10),
                      //   child: Text(
                      //     "Person Type (Egyptian)".tr,
                      //     style: TextStyle(
                      //         fontFamily: "inter",
                      //         fontSize: 14,
                      //         fontWeight: FontWeight.w600),
                      //   ),
                      // ),
                      // CustomTextField(
                      //   controller: personTypeForVendorList[index].nameEgyptian,
                      //   hintText: 'Egyptian Name',
                      // ),
                      // CustomTextField(
                      //   controller:
                      //       personTypeForVendorList[index].descriptionEgyptian,
                      //   hintText: 'Description',
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 10),
                        child: Text(
                          "Min".tr,
                          style: TextStyle(
                              fontFamily: "inter",
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      CustomTextField(
                        controller: personTypeForVendorList[index].min,
                        hintText: 'Min',
                        txKeyboardType: TextInputType.number,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 10),
                        child: Text(
                          "Max".tr,
                          style: TextStyle(
                              fontFamily: "inter",
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      CustomTextField(
                        controller: personTypeForVendorList[index].max,
                        hintText: 'Max',
                        txKeyboardType: TextInputType.number,
                      ),
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
                      CustomTextField(
                        controller: personTypeForVendorList[index].price,
                        hintText: 'Price',
                        txKeyboardType: TextInputType.number,
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
                            if (personTypeForVendorList[index].id != null) {
                              deletePersonType(
                                  personTypeForVendorList[index].id!);
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
                          addPersonType();
                        },
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.only(
                left: 10,
              ),
              child: Text(
                "Extra Price".tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Checkbox(
                    value: _enableExtraPrice,
                    onChanged: (bool? value) {
                      setState(() {
                        _enableExtraPrice = value!;
                      });
                    },
                  ),
                  Text('Enable Extra Price'.tr),
                ],
              ),
            ),

            if (_enableExtraPrice)
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: extraPriceVendorList.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 10),
                        child: Text(
                          "No. of People".tr,
                          style: TextStyle(
                              fontFamily: "inter",
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      CustomTextField(
                        controller: extraPriceVendorList[index].name,
                        hintText: 'English',
                      ),
                      SizedBox(height: 10),
                      CustomTextField(
                        controller: extraPriceVendorList[index].namear,
                        hintText: 'Japanese',
                      ),
                      // CustomTextField(
                      //   controller: extraPriceVendorList[index].nameEgy,
                      //   hintText: 'Egyptian Name',
                      // ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 10),
                        child: Text(
                          "Discount".tr,
                          style: TextStyle(
                              fontFamily: "inter",
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      CustomTextField(
                        controller: extraPriceVendorList[index].price,
                        hintText: 'Price',
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
                            " Price Type".tr,
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
                            value: ['one time', 'per hour', 'per day']
                                    .contains(extraPriceVendorList[index].type)
                                ? extraPriceVendorList[index].type
                                : 'one time', // Default value if type is invalid
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
                              if (value != null) {
                                extraPriceVendorList[index].type =
                                    value; // Update the value
                              }
                            },
                          ),
                        ),
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
                            if (extraPriceVendorList[index].id != null) {
                              deleteExtraPrice(extraPriceVendorList[index].id!);
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
                print("Pricing Screen - Navigation Data:");
                print("Tour ID: ${widget.tourId}");
                print("Default State: $defaultState");
                print("Price: ${priceController.text}");
                print("Sale Price: ${salePriceController.text}");
                print("Enable Extra Price: $_termsAccepted");
                print("Person Types: ${personTypeForVendorList.length} items");
                print("Extra Prices: ${extraPriceVendorList.length} items");
                print("Category ID: ${widget.categoryId}");
                print("Title: ${widget.title}");
                print("Content: ${widget.content}");
                print("YouTube Video: ${widget.youtubeVideoText}");
                print("FAQ List: ${widget.faqList}");
                print(
                    "Banner Image: ${widget.bannerimage?.path ?? "Not selected"}");
                print(
                    "Featured Image: ${widget.featuredimage?.path ?? "Not selected"}");
                print(
                    "Gallery Images Count: ${widget.pickedImagefile?.length ?? 0}");
                print(
                    "Minimum Days Before Booking: ${widget.minimumDayBeforeBooking}");
                print("Minimum People: ${widget.minimumPeople}");
                print("Maximum People: ${widget.maximumPeople}");
                print(
                    'itineryimage ids: ${widget.itineraryList?.map((itinerary) => itinerary.imageId).join(', ')}');

                print("Duration: ${widget.duration}");
                print("Location ID: ${widget.locationId}");
                print("Address: ${widget.address}");
                print("Map Lat: ${widget.mapLat}");
                print("Map Long: ${widget.mapLong}");
                print("Map Zoom: ${widget.mapZoom}");
                print("Itinerary List: ${widget.itineraryList}");
                print("Include List: ${widget.Include}");
                print("Exclude List: ${widget.Exclude}");
                if ((_termsAccepted && personTypeForVendorList.isEmpty) ||
                    priceController.text.isEmpty ||
                    salePriceController.text.isEmpty) {
                  showErrorToast("Please inpur all details");
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditTourFourScreen(
                        tourId: widget.tourId,
                        title: widget.title,
                        content: widget.content,
                        categoryId: widget.categoryId,
                        youtubeVideoText: widget.youtubeVideoText,
                        faqList: widget.faqList ?? [],
                        Include: widget.Include,
                        Exclude: widget.Exclude,
                        itineraryList: widget.itineraryList,
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
                        locationId: widget.locationId,
                        address: widget.address,
                        mapLat: widget.mapLat,
                        mapLong: widget.mapLong,
                        mapZoom: widget.mapZoom,
                        txeducationList: widget.txeducationList,
                        txhealthList: widget.txhealthList,
                        txtransportationList: widget.txtransportationList,
                        defaultState: defaultState,
                        enableExtraPrice: _enableExtraPrice,
                        enablePersonTypes: _termsAccepted,
                        personTypeForVendorList: personTypeForVendorList,
                        extraPriceVendorList: extraPriceVendorList,
                        price: priceController.value.text,
                        minimumPeople: widget.minimumPeople,
                        maximumPeople: widget.maximumPeople,
                        duration: widget.duration,
                        salePrice: salePriceController.value.text,
                      ),
                    ),
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
