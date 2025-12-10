import 'dart:developer';
import 'dart:io';

import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Provider/space_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/vendor/space/edit/edit_space_screen_four.dart';
import 'package:moonbnd/widgets/elevatedbuttonicon.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class EditSpaceThreeScreen extends StatefulWidget {
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
  EditSpaceThreeScreen({
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

class AddSpacePricingScreenState extends State<EditSpaceThreeScreen> {
  final _formKey = GlobalKey<FormState>();

  String defaultState = "Always available";

  /////// inpit fields

  String defaultStateInput = "";
  TextEditingController priceController = TextEditingController();
  TextEditingController salePriceController = TextEditingController();
  TextEditingController maxGuestController = TextEditingController();
  bool _termsAccepted = false;
  List<ExtraPriceForVendor> extraPriceSpaceVendorList = [];
  List<DiscountByNoOfDayAndNightModal> discountByNoOfDayAndNightList = [];

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

  void addDiscount() {
    discountByNoOfDayAndNightList.add(DiscountByNoOfDayAndNightModal(
        id: DateTime.now(),
        discount: TextEditingController(),
        from: TextEditingController(),
        to: TextEditingController(),
        type: "fixed"));
    setState(() {});
  }

  void deleteExtraPrice(DateTime? id) {
    extraPriceSpaceVendorList.removeWhere((test) {
      return test.id == id;
    });

    setState(() {});
  }

  void deleteDiscount(DateTime? id) {
    discountByNoOfDayAndNightList.removeWhere((test) {
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
    final spaceProvider = Provider.of<SpaceProvider>(context, listen: false);
    log("${spaceProvider.spaceDetailsVendor?.data[0].defaultState}");
    defaultState = spaceProvider.spaceDetailsVendor?.data[0].defaultState == 0
        ? "Always available"
        : "Only available on specific dates";
    priceController = TextEditingController(
        text: "${spaceProvider.spaceDetailsVendor?.data[0].price}");
    salePriceController = TextEditingController(
        text: "${spaceProvider.spaceDetailsVendor?.data[0].salePrice}");
    maxGuestController = TextEditingController(
        text: "${spaceProvider.spaceDetailsVendor?.data[0].maxGuests}");
    defaultStateInput =
        "${spaceProvider.spaceDetailsVendor?.data[0].defaultState}";
    _termsAccepted =
        spaceProvider.spaceDetailsVendor?.data[0].enableExtraPrice == 1
            ? true
            : false;
    spaceProvider.spaceDetailsVendor?.data[0].extraPrice.forEach((element) {
      return extraPriceSpaceVendorList.add(ExtraPriceForVendor(
          id: DateTime.now().add(Duration(seconds: 5)),
          nameEgyptian: TextEditingController(text: element.nameegy),
          nameEnglish: TextEditingController(text: element.name),
          nameJapnese: TextEditingController(text: element.nameja),
          perPerson: element.perPerson == "on" ? true : false,
          price: TextEditingController(text: element.price),
          type: element.type == "one_time"
              ? "one time"
              : element.type == "per_hour"
                  ? "per hour"
                  : "per day"));
    });

    spaceProvider.spaceDetailsVendor?.data[0].discountByDays
        ?.forEach((element) {
      return discountByNoOfDayAndNightList.add(DiscountByNoOfDayAndNightModal(
          id: DateTime.now().add(Duration(seconds: 5)),
          discount: TextEditingController(text: element.amount),
          from: TextEditingController(text: element.from),
          to: TextEditingController(text: element.to),
          type: element.type));
    });

    log('${spaceProvider.spaceDetailsVendor?.data[0].discountByDays?.length} lengthhh discountByDays');

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
                "Update Space".tr,
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
              hintText: 'Space Price',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Price'.tr;
                }
                return null;
              },
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
              hintText: 'Space Sale Price'.tr,
              txKeyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
              controller: maxGuestController,
              hintText: 'Ex: 3'.tr,
              txKeyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter guest'.tr;
                }
                return null;
              },
              onSaved: (value) {},
            ),
            // Padding(
            //   padding: const EdgeInsets.only(left: 10, bottom: 10),
            //   child: Text(
            //     "Leave blank if you don’t need to set minimum day stay option"
            //         .tr,
            //     style: TextStyle(
            //         fontFamily: "inter",
            //         fontSize: 12,
            //         color: Colors.grey,
            //         fontWeight: FontWeight.w400),
            //   ),
            // ),
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
              itemCount: discountByNoOfDayAndNightList.length,
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
                      controller: discountByNoOfDayAndNightList[index].from,
                      hintText: 'From'.tr,
                      onSaved: (value) {},
                    ),
                    // Minimum advance reservations
                    CustomTextField(
                      controller: discountByNoOfDayAndNightList[index].to,
                      hintText: 'To'.tr,
                      onSaved: (value) {},
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
                      controller: discountByNoOfDayAndNightList[index].discount,
                      hintText: 'Discount'.tr,
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
                        value: discountByNoOfDayAndNightList[index].type,
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
                          discountByNoOfDayAndNightList[index].type = value;
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
                          if (discountByNoOfDayAndNightList[index].id != null) {
                            deleteDiscount(
                                discountByNoOfDayAndNightList[index].id!);
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

                  if (defaultState.isEmpty) {
                    showErrorToast("Please enter state".tr);
                    return;
                  }

                  if (_termsAccepted == true &&
                      extraPriceSpaceVendorList.isEmpty) {
                    showErrorToast("Please enter atleast one extra price".tr);
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditSpaceFourScreen(
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
                            defaultState: defaultStateInput,
                            discountByNoOfDayAndNightList:
                                discountByNoOfDayAndNightList,
                            enableExtraPrice: _termsAccepted,
                            extraPriceForVendorList: extraPriceSpaceVendorList,
                            maxGuests: maxGuestController.value.text,
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
