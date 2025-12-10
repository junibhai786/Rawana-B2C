import 'dart:developer';
import 'dart:io';

import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Provider/singup_vendor_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/modals/car_detail_model.dart';
import 'package:moonbnd/vendor/car/edit/edit_Car_one_screen.dart';
import 'package:moonbnd/vendor/car/edit/edit_car_four_screen.dart';
import 'package:moonbnd/widgets/elevatedbuttonicon.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class EditCarPricingScreen extends StatefulWidget {
  final int? defaultstate;
  final int? price;
  final String? url;

  final int? saleprice;
  final String? minadvancereservation;
  final String? mindaystayrequirement;
  final List<ExtraPriceCar>? extraPrice;
  int carid = 0;
  String title = "";
  String content = "";
  String youtubeVideoText = "";
  File? bannerimage;
  File? featuredimage;
  List<File>? pickedImagefile;
  int minimumDayBeforeBooking = 0;
  int minimumdaystaycontroller = 0;
  String bed = "";
  String bathroom = "";
  String locationId = "";
  String address = "";
  String mapLat = "";
  String mapLong = "";
  String mapZoom = "";
  String passenger = "";
  int baggage = 0;
  List<String> selectedCarFeatureIdss = [];
  List<String> selectedCartypeIdss = [];
  List<FAQ2>? faq;
  List<Term>? terms;

  String gear = "";

  int car = 0;
  int door = 0;

  String maxGuests = "";
  bool enableExtraPrice = false;

  EditCarPricingScreen({
    Key? key,
    this.defaultstate,
    this.url,
    this.terms,
    this.extraPrice,
    this.price,
    this.saleprice,
    this.minadvancereservation,
    this.mindaystayrequirement,
    this.bannerimage,
    this.passenger = "",
    this.gear = "",
    this.door = 0,
    this.bathroom = "",
    this.baggage = 0,
    this.faq,
    this.bed = "",
    this.content = "",
    this.featuredimage,
    this.minimumDayBeforeBooking = 0,
    this.minimumdaystaycontroller = 0,
    this.pickedImagefile,
    this.title = "",
    this.youtubeVideoText = "",
    this.carid = 0,
    this.locationId = "",
    this.address = "",
    this.mapLat = "",
    this.mapLong = "",
    this.mapZoom = "",
    this.car = 0,
    this.maxGuests = "",
    this.enableExtraPrice = false,
  }) : super(key: key);

  @override
  EditCarPricingScreenState createState() => EditCarPricingScreenState();
}

class EditCarPricingScreenState extends State<EditCarPricingScreen> {
  final _formKey = GlobalKey<FormState>();
  final provider = VendorAuthProvider();

  bool enablePersonPrice = false;
  List<Map<String, String?>> extraPrices = [
    {'price': null, 'type': null}
  ];
  bool _termsAccepted = false;
  void deleteExtraPrice(DateTime? id) {
    extraprice.removeWhere((test) {
      return test.id == id;
    });

    setState(() {});
  }

  String? locationid;
  int defaultstate = 0;
  TextEditingController carcontroller = TextEditingController();
  TextEditingController pricecontroller = TextEditingController();
  TextEditingController salepricecontroller = TextEditingController();
  TextEditingController minimumcontroller = TextEditingController();
  TextEditingController minimumdaystaycontroller = TextEditingController();
  List<ExtraPrices2> extraprice = [];

  void removeexptraprice(DateTime? id) {
    extraprice.removeWhere((test) {
      return test.id == id;
    });

    setState(() {});
  }

  void addExtraPrice() {
    extraprice.add(ExtraPrices2(
        id: DateTime.now(),
        name: TextEditingController(),
        namejapanese: TextEditingController(),
        nameegyptian: TextEditingController(),
        price: TextEditingController(),
        type: "one time"));
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    log("pickedImagefile=${widget.pickedImagefile}");

    log("mapLat${widget.mapLat}");
    log("mapZoom${widget.mapZoom}");
    log("mapLong${widget.mapLong}");
    log("${widget.extraPrice?.length} extra price length");

    // Prefill the data if available

    if (widget.defaultstate != null) {
      defaultstate = widget.defaultstate ?? 0;
    }
    carcontroller.text = widget.car.toString();
    if (widget.price != null) {
      pricecontroller.text = widget.price.toString();
    }
    if (widget.saleprice != null) {
      salepricecontroller.text = widget.saleprice.toString();
    }
    if (widget.minimumDayBeforeBooking != 0) {
      minimumcontroller.text = widget.minimumDayBeforeBooking.toString();
    }
    if (widget.minadvancereservation != null) {
      minimumdaystaycontroller.text = widget.minadvancereservation ?? "";
    }

    if (widget.extraPrice != null && widget.extraPrice!.isNotEmpty) {
      _termsAccepted = true;
      // Ensure provider.extraprice is initialized with enough elements

      widget.extraPrice?.forEach((element) {
        return extraprice.add(ExtraPrices2(
          id: DateTime.now().add(Duration(seconds: 5)),
          name: TextEditingController(text: element.name),
          nameegyptian: TextEditingController(text: element.egyptianame),
          namejapanese: TextEditingController(text: element.japanesename),
          type: element.type,
          price: TextEditingController(text: element.price),
        ));
      });
    }

    // Fetch initial data
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
                "Update Car".tr,
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
                value: defaultstate == 0
                    ? 'Only available on specific dates'.tr
                    : 'Always available'.tr,
                decoration: InputDecoration(
                  labelText: 'Only available on specific dates'.tr,
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
                  if (value == 'Only available on specific dates') {
                    setState(() {
                      defaultstate = 0;
                    });
                    // S
                    print(1); // Replace with your logic to handle the value
                  } else if (value == 'Always available') {
                    setState(() {
                      defaultstate = 1;
                    });
                    // Send 2
                    print(2); // Replace with your logic to handle the value
                  }
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
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                "Number of cars available".tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
            ),

            // Car Number Input
            CustomTextField(
              hintText: "Number of cars available".tr,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: carcontroller,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please add number of cars".tr; // Validation message
                }
                return null; // Return null if validation passes
              },
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
            // Event Price Input
            CustomTextField(
              hintText: 'Car Price'.tr,
              controller: pricecontroller,
              txKeyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please add car price".tr; // Validation message
                }
                return null; // Return null if validation passes
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
              hintText: 'Sale Car Price',
              controller: salepricecontroller,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                "Minimum advance reservations".tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
            ),
            // Minimum advance reservations
            CustomTextField(
              hintText: 'Ex: 3'.tr,
              controller: minimumcontroller,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              txKeyboardType: TextInputType.number,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                "Leave blank if you dont need to use the min day option".tr,
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
                "Minimum day stay requirements".tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
            ),
            // Minimum day stay requirements
            CustomTextField(
              hintText: 'Ex: 3'.tr,
              controller: minimumdaystaycontroller,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please add minimum day stay requirement"; // Validation message
                }
                return null; // Return null if validation passes
              },
              txKeyboardType: TextInputType.number,
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
            Row(
              children: [
                Checkbox(
                  value: _termsAccepted,
                  onChanged: (bool? value) {
                    setState(() {
                      _termsAccepted = value!;
                      extraprice.clear();
                    });
                  },
                ),
                Text('Enable Extra Price'.tr),
              ],
            ),
            SizedBox(height: 10),

            if (_termsAccepted)
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: extraprice.length,
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
                        controller: extraprice[index].name,
                        hintText: 'English Name'.tr,
                      ),
                      CustomTextField(
                        controller: extraprice[index].namejapanese,
                        hintText: 'Japanese Name'.tr,
                      ),
                      CustomTextField(
                        controller: extraprice[index].nameegyptian,
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
                        controller: extraprice[index].price,
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
                            hint: Text("Select option".tr),
                            value: extraprice[index].type,
                            onChanged: (String? newValue) {
                              setState(() {
                                extraprice[index].type = newValue;
                              });
                            },
                            items: const [
                              DropdownMenuItem(
                                child: Text("One-time"),
                                value: "one_time",
                              ),
                              DropdownMenuItem(
                                child: Text("Per day"),
                                value: "per_day",
                              ),
                            ],
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
                            if (extraprice[index].id != null) {
                              deleteExtraPrice(extraprice[index].id!);
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

            // ListView.builder(
            //   shrinkWrap: true,
            //   physics: NeverScrollableScrollPhysics(),
            //   itemCount: extraPrices.length,
            //   itemBuilder: (context, index) {
            //     return Column(
            //       children: [
            //         // CustomTextField(
            //         //   hintText: 'English Name',
            //         //   onSaved: (value) {
            //         //     extraPrices[index]['englishName'] = value;
            //         //   },
            //         //   controller: provider.minimumdaystaycontroller,
            //         // ),
            //         // CustomTextField(
            //         //   hintText: 'Japanese Name',
            //         //   onSaved: (value) {
            //         //     extraPrices[index]['japaneseName'] = value;
            //         //   },
            //         //   controller: provider.japanaesenamecontroller,
            //         // ),
            //         // CustomTextField(
            //         //   hintText: 'Egyptian Name',
            //         //   onSaved: (value) {
            //         //     extraPrices[index]['egyptianName'] = value;
            //         //   },
            //         //   controller: provider.egyptiannamecontroller,
            //         // ),

            //         SizedBox(height: 20),
            //       ],
            //     );
            //   },
            // ),

            // Add Item Button

            SizedBox(height: 20),
            // Save & Next Button
            TertiaryButton(
              press: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  if (_termsAccepted == true && extraprice.isEmpty) {
                    showErrorToast("Please enter atleast one extra price");
                    return;
                  }

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditCarFourScreen(
                                terms: widget.terms,
                                baggage: widget.baggage.toString(),
                                passenger: widget.passenger,
                                gear: widget.gear,
                                faq: widget.faq,
                                url: widget.url,
                                carid: widget.carid,
                                title: widget.title,
                                content: widget.content,
                                youtubeVideoText: widget.youtubeVideoText,
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
                                door: widget.door.toString(),
                                //check again
                                minimumDayBeforeBooking: minimumcontroller.text,
                                minimumdaystaycontroller:
                                    minimumdaystaycontroller.text,

                                //chcekc again
                                locationId: widget.locationId,
                                address: widget.address,
                                mapLat: widget.mapLat,
                                mapLong: widget.mapLong,
                                mapZoom: widget.mapZoom,
                                extraPrice: extraprice,
                                enableExtraPrice: _termsAccepted,
                                defaultState: defaultstate,
                                car: carcontroller.text,
                                price: pricecontroller.text,
                                salePrice: salepricecontroller.text,
                              )));
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
