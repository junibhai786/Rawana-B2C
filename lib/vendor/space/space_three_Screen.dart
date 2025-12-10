import 'dart:io';

import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Provider/space_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/vendor/space/space_four_screen.dart';
import 'package:moonbnd/widgets/elevatedbuttonicon.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class AddSpacePricingScreenThree extends StatefulWidget {
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
  AddSpacePricingScreenThree({
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

class AddSpacePricingScreenState extends State<AddSpacePricingScreenThree> {
  final _formKey = GlobalKey<FormState>();

  void addExtraPrice() {
    Provider.of<SpaceProvider>(context, listen: false)
        .extraPriceSpaceVendorList
        .add(ExtraPriceForVendor(
            id: DateTime.now(),
            nameEgyptian: TextEditingController(),
            nameEnglish: TextEditingController(),
            nameJapnese: TextEditingController(),
            perPerson: false,
            price: TextEditingController(),
            type: "one time"));
    setState(() {});
  }

  void addDiscount() {
    Provider.of<SpaceProvider>(context, listen: false)
        .discountByNoOfDayAndNightList
        .add(DiscountByNoOfDayAndNightModal(
            id: DateTime.now(),
            discount: TextEditingController(),
            from: TextEditingController(),
            to: TextEditingController(),
            type: "fixed"));
    setState(() {});
  }

  void deleteExtraPrice(DateTime? id) {
    Provider.of<SpaceProvider>(context, listen: false)
        .extraPriceSpaceVendorList
        .removeWhere((test) {
      return test.id == id;
    });

    setState(() {});
  }

  void deleteDiscount(DateTime? id) {
    Provider.of<SpaceProvider>(context, listen: false)
        .discountByNoOfDayAndNightList
        .removeWhere((test) {
      return test.id == id;
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final spaceProvider = Provider.of<SpaceProvider>(context, listen: true);
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
                "Add New Space".tr,
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
                value: spaceProvider.defaultState,
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
                  spaceProvider.defaultState = value.toString();
                  if (value == "Always available") {
                    spaceProvider.defaultStateInput = "0";
                  } else if (value == "Only available on specific dates") {
                    spaceProvider.defaultStateInput = "1";
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
              controller: spaceProvider.priceController,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Price'.tr;
                }
                return null;
              },
              hintText: 'Space Price'.tr,
              txKeyboardType: TextInputType.number,
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
              controller: spaceProvider.salePriceController,
              txKeyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              // validator: (value) {
              //   if (value == null || value.isEmpty) {
              //     return 'Please enter Sale Price'.tr;
              //   }
              //   return null;
              // },
              hintText: 'Space Sale Price'.tr,
              onSaved: (value) {},
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
                "Max Guests".tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
            ),
            // Minimum day stay requirements
            CustomTextField(
              controller: spaceProvider.maxGuestController,
              txKeyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter guest'.tr;
                }
                return null;
              },
              hintText: 'Ex: 3',
              onSaved: (value) {},
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
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Checkbox(
                    value: spaceProvider.termsAccepted,
                    onChanged: (bool? value) {
                      setState(() {
                        spaceProvider.termsAccepted = value!;
                      });
                    },
                  ),
                  Text('Enable Extra Price'.tr),
                ],
              ),
            ),

            if (spaceProvider.termsAccepted)
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: spaceProvider.extraPriceSpaceVendorList.length,
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
                        controller: spaceProvider
                            .extraPriceSpaceVendorList[index].nameEnglish,
                        hintText: 'English Name'.tr,
                      ),
                      CustomTextField(
                        controller: spaceProvider
                            .extraPriceSpaceVendorList[index].nameJapnese,
                        hintText: 'Japanese Name'.tr,
                      ),
                      CustomTextField(
                        controller: spaceProvider
                            .extraPriceSpaceVendorList[index].nameEgyptian,
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
                        controller: spaceProvider
                            .extraPriceSpaceVendorList[index].price,
                        txKeyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Price'.tr;
                          }
                          return null;
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        hintText: 'Price'.tr,
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
                            value: spaceProvider
                                .extraPriceSpaceVendorList[index].type,
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
                            onChanged: (value) {},
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: spaceProvider
                                .extraPriceSpaceVendorList[index].perPerson,
                            onChanged: (bool? value) {
                              setState(() {
                                spaceProvider.extraPriceSpaceVendorList[index]
                                    .perPerson = value!;
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
                            if (spaceProvider
                                    .extraPriceSpaceVendorList[index].id !=
                                null) {
                              deleteExtraPrice(spaceProvider
                                  .extraPriceSpaceVendorList[index].id!);
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

            if (spaceProvider.termsAccepted)
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
            // Add Item Button
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                "Discount by number of day or night".tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            ),

            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: spaceProvider.discountByNoOfDayAndNightList.length,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 10),
                      child: Text(
                        "From - To".tr,
                        style: TextStyle(
                            fontFamily: "inter",
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    CustomTextField(
                      controller: spaceProvider
                          .discountByNoOfDayAndNightList[index].from,
                      txKeyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      hintText: 'From'.tr,
                      onSaved: (value) {},
                    ),
                    // Minimum advance reservations
                    CustomTextField(
                      controller:
                          spaceProvider.discountByNoOfDayAndNightList[index].to,
                      hintText: 'To'.tr,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSaved: (value) {},
                      txKeyboardType: TextInputType.number,
                    ),
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
                      controller: spaceProvider
                          .discountByNoOfDayAndNightList[index].discount,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      hintText: 'Discount'.tr,
                      txKeyboardType: TextInputType.number,
                      onSaved: (value) {},
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 10),
                      child: Text(
                        "Type".tr,
                        style: TextStyle(
                            fontFamily: "inter",
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: DropdownButtonFormField<String>(
                        value: spaceProvider
                            .discountByNoOfDayAndNightList[index].type,
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
                        items: ['fixed', 'percent'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          spaceProvider.discountByNoOfDayAndNightList[index]
                              .type = value;
                          setState(() {});
                        },
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
                          if (spaceProvider
                                  .discountByNoOfDayAndNightList[index].id !=
                              null) {
                            deleteDiscount(spaceProvider
                                .discountByNoOfDayAndNightList[index].id!);
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
                        addDiscount();
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

                  if (spaceProvider.defaultState.isEmpty) {
                    showErrorToast("Please enter state".tr);
                    return;
                  }

                  if (spaceProvider.termsAccepted == true &&
                      spaceProvider.extraPriceSpaceVendorList.isEmpty) {
                    showErrorToast("Please enter atleast one extra price".tr);
                    return;
                  }
                  // if (spaceProvider.discountByNoOfDayAndNightList.isEmpty) {
                  //   showErrorToast(
                  //       "Please enter atleast one discount by day and night");
                  //   return;
                  // }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SpaceFourScreen(
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
                            defaultState: spaceProvider.defaultState,
                            discountByNoOfDayAndNightList:
                                spaceProvider.discountByNoOfDayAndNightList,
                            enableExtraPrice: spaceProvider.termsAccepted,
                            extraPriceForVendorList:
                                spaceProvider.extraPriceSpaceVendorList,
                            maxGuests:
                                spaceProvider.maxGuestController.value.text,
                            price: spaceProvider.priceController.value.text,
                            salePrice:
                                spaceProvider.salePriceController.value.text)),
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
