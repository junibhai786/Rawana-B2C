import 'dart:developer';

import 'package:moonbnd/Provider/vendor_tour_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/vendor/tour/tour_four_screen.dart';
import 'package:moonbnd/widgets/elevatedbuttonicon.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class TourPricingScreen extends StatefulWidget {
  const TourPricingScreen({super.key});

  @override

  // ignore: library_private_types_in_public_api
  _TourPricingScreenState createState() => _TourPricingScreenState();
}

class _TourPricingScreenState extends State<TourPricingScreen> {
  final _formKey = GlobalKey<FormState>();

  // bool _termsAccepted = false;
  // bool _enableExtraPrice = false;

  @override
  void initState() {
    super.initState();
    // final provider = Provider.of<VendorTourProvider>(context, listen: false);
    // provider.clearAllData();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VendorTourProvider>(context, listen: true);
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
                items: [
                  'Only available on specific dates'.tr,
                  'Always available'.tr
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == 'Only available on specific dates'.tr) {
                    setState(() {
                      provider.defaultstate = 0;
                    });
                    // S
                  } else if (value == 'Always available'.tr) {
                    setState(() {
                      provider.defaultstate = 1;
                    });
                    // Send 2
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
              padding: const EdgeInsets.only(left: 10, bottom: 20, top: 10),
              child: Text(
                "Tour Price".tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
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
            // Car Number Input
            CustomTextField(
              txKeyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Tour Price'.tr;
                }
                return null;
              },
              hintText: "Tour Price".tr,
              controller: provider.pricecontroller,
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
            // Car Number Input
            CustomTextField(
              hintText: "Tour Sale Price".tr,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              // validator: (value) {
              //   if (value == null || value.isEmpty) {
              //     return 'Please enter Sale Price'.tr;
              //   }
              //   return null;
              // },
              controller: provider.salePricecontroller,
              txKeyboardType: TextInputType.number,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 20),
              child: Text(
                "If the regular price is less than the discount, it will show the regular price"
                    .tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 12,
                    fontWeight: FontWeight.w400),
              ),
            ),
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
            Row(
              children: [
                Checkbox(
                  value: provider.enablePersonTypes,
                  onChanged: (bool? value) {
                    setState(() {
                      provider.enablePersonTypes = value!;
                      if (value && provider.personTypes.isEmpty) {
                        provider.personTypes
                            .add(PERSONTYPE()); // Add initial empty person type
                      }
                      log("person type ${value} ");
                    });
                  },
                ),
                Text('Enable Person Types'.tr),
              ],
            ),
            SizedBox(
              height: 10,
            ),

            if (provider.enablePersonTypes) ...[
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: provider.personTypes.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Person Type Fields
                      _buildPersonTypeFields(index),

                      // Add/Delete buttons
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 100,
                              child: TextIconButtom(
                                size: 10,
                                icon: Icon(Icons.upload),
                                text: 'Add Item'.tr,
                                press: () {
                                  setState(() {
                                    provider.personTypes.add(PERSONTYPE());
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 20),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.delete, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    provider.personTypes.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  );
                },
              ),
            ],
            SizedBox(height: 20),
            // Extra Price Section
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
            Row(
              children: [
                Checkbox(
                  value: provider.enableExtraPrice,
                  onChanged: (bool? value) {
                    setState(() {
                      provider.enableExtraPrice = value!;
                    });
                  },
                ),
                Text('Enable extra Price'.tr),
              ],
            ),
            if (provider.enableExtraPrice)
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: provider.extraPrices.length,
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
                        hintText: 'Adult'.tr,
                        txKeyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],

                        controller: TextEditingController(
                            text: provider.extraPrices[index].name),
                        onChanged: (p0) {
                          provider.extraPrices[index].name = p0;
                        },
                        // controller: TextEditingController(
                        //     text: provider.extraPrices[index].name ?? ''),
                      ),
                      SizedBox(height: 10),
                      CustomTextField(
                        hintText: 'Child'.tr,
                        txKeyboardType: TextInputType.number,
                        controller: TextEditingController(
                            text: provider.extraPrices[index].namear),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],

                        // controller: TextEditingController(
                        //     text: provider.extraPrices[index].nameJa ?? ''),
                        onChanged: (value) {
                          provider.extraPrices[index].namear = value;
                        },
                      ),
                      // SizedBox(height: 10),
                      // CustomTextField(
                      //   hintText: 'Infant',
                      //   txKeyboardType: TextInputType.text,
                      //   initialValue: provider.extraPrices[index].nameEgy ?? '',
                      //   // controller: TextEditingController(
                      //   //     text: provider.extraPrices[index].nameEgy ?? ''),
                      //   onChanged: (value) {
                      //     setState(() {
                      //       provider.extraPrices[index].nameEgy = value;
                      //     });
                      //   },
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
                        hintText: 'Price'.tr,
                        txKeyboardType: TextInputType.number,
                        controller: TextEditingController(
                            text: provider.extraPrices[index].price),

                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],

                        // controller: TextEditingController(
                        //     text: provider.extraPrices[index].price ?? ''),
                        onChanged: (value) {
                          provider.extraPrices[index].price = value;
                        },
                      ),

                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 10),
                        child: Text(
                          "Price Type".tr,
                          style: TextStyle(
                              fontFamily: "inter",
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: DropdownButtonFormField<String>(
                          value: provider.extraPrices[index].type,
                          decoration: InputDecoration(
                            labelText: 'Price Type'.tr,
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: kSecondaryColor, width: 2.0),
                            ),
                          ),
                          items: ['one time'.tr, 'per hour'.tr, 'per day'.tr]
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              provider.extraPrices[index].type = value;
                            });
                          },
                        ),
                      ),

                      // Add/Delete buttons
                      SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.delete, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              provider.extraPrices.removeAt(index);
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  );
                },
              ),

            if (provider.enableExtraPrice)
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: TextIconButtom(
                        size: 10,
                        icon: Icon(Icons.upload),
                        text: 'Add Item'.tr,
                        press: () {
                          setState(() {
                            provider.extraPrices.add(EXTRAPRICE());
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 20),
                  ],
                ),
              ),

            // Add Item Button

            SizedBox(height: 20),
            // Save & Next Button
            TertiaryButton(
              press: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  if (provider.defaultstate == null) {
                    Get.snackbar(
                        "Error".tr, "Please select a default state".tr);
                    return;
                  }
                  // if (provider.enablePersonTypes == true) {
                  //   if (provider.personTypes.isEmpty) {
                  //     Get.snackbar("Error".tr,
                  //         "Please select atleast one person type".tr);
                  //     return;
                  //   }
                  // }

                  // Proceed to the next screen if validation passes
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TourFourScreen()),
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

  Widget _buildPersonTypeFields(int index) {
    final provider = Provider.of<VendorTourProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // English fields
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 10),
          child: Text(
            "Person Type (English)".tr,
            style: TextStyle(
                fontFamily: "inter", fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        CustomTextField(
          hintText: 'Eg: Adults'.tr,
          onChanged: (p0) {
            provider.personTypes[index].name = p0;
          },
          controller: TextEditingController(
              text: provider.personTypes[index].name ?? ''),
        ),
        CustomTextField(
          hintText: 'Description'.tr,
          txKeyboardType: TextInputType.name,
          onChanged: (p0) {
            provider.personTypes[index].description = p0;
          },
          controller: TextEditingController(
              text: provider.personTypes[index].description ?? ''),
        ),

        // Japanese fields
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 10),
          child: Text(
            "Person Type (Arabic)".tr,
            style: TextStyle(
                fontFamily: "inter", fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        CustomTextField(
          hintText: 'Eg: Adults'.tr,
          txKeyboardType: TextInputType.text,
          onChanged: (p0) {
            provider.personTypes[index].namear = p0;
          },
          controller: TextEditingController(
              text: provider.personTypes[index].namear ?? ''),
        ),
        CustomTextField(
          hintText: 'Description'.tr,
          txKeyboardType: TextInputType.text,
          onChanged: (p0) {
            provider.personTypes[index].descriptionar = p0;
          },
          controller: TextEditingController(
              text: provider.personTypes[index].descriptionar ?? ''),
        ),

        // Egyptian fields
        // Padding(
        //   padding: const EdgeInsets.only(left: 10, bottom: 10),
        //   child: Text(
        //     "Person Type (Egyptian)".tr,
        //     style: TextStyle(
        //         fontFamily: "inter", fontSize: 14, fontWeight: FontWeight.w600),
        //   ),
        // ),
        // CustomTextField(
        //   hintText: 'Eg: Adults',
        //   txKeyboardType: TextInputType.name,
        //   initialValue: provider.personTypes[index].nameEgy ?? '',
        //   onChanged: (value) {
        //     setState(() {
        //       provider.personTypes[index].nameEgy = value;
        //     });
        //   },
        // ),
        // CustomTextField(
        //   hintText: 'Description',
        //   txKeyboardType: TextInputType.name,
        //   initialValue: provider.personTypes[index].descriptionEgy ?? '',
        //   onChanged: (value) {
        //     setState(() {
        //       provider.personTypes[index].descriptionEgy = value;
        //     });
        //   },
        // ),

        // Number fields
        _buildNumberField("Min".tr, index, 'min'),
        _buildNumberField("Max".tr, index, 'max'),
        _buildNumberField("Price".tr, index, 'price'),
      ],
    );
  }

  Widget _buildNumberField(String label, int index, String field) {
    final provider = Provider.of<VendorTourProvider>(context);
    String initialValue = '';

    // Get the correct initial value based on field type
    switch (field) {
      case 'min':
        initialValue = provider.personTypes[index].min ?? '';
        break;
      case 'max':
        initialValue = provider.personTypes[index].max ?? '';
        break;
      case 'price':
        initialValue = provider.personTypes[index].price ?? '';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 10),
          child: Text(
            label.tr,
            style: TextStyle(
                fontFamily: "inter", fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ),
        CustomTextField(
          hintText: label,
          controller: TextEditingController(
              text: field == "min"
                  ? provider.personTypes[index].min
                  : field == "max"
                      ? provider.personTypes[index].max
                      : provider.personTypes[index].price),
          txKeyboardType: TextInputType.number,
          onChanged: (p0) {
            field == "min"
                ? provider.personTypes[index].min = p0
                : field == "max"
                    ? provider.personTypes[index].max = p0
                    : provider.personTypes[index].price = p0;
          },
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          // controller: TextEditingController(text: initialValue),
        ),
      ],
    );
  }
}
