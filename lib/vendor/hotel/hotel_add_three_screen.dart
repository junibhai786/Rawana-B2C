import 'dart:developer';

import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Provider/hotel_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/vendor/hotel/hotel_add_four_screen.dart';
import 'package:moonbnd/widgets/elevatedbuttonicon.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class PRICE {
  DateTime? id;
  TextEditingController? name;
  TextEditingController? price;
  String? type;
  bool? perPerson;
  PRICE(
      {this.name,
      this.id,
      this.perPerson = false,
      this.price,
      this.type = "one time"});
}

class HotelPricingScreen extends StatefulWidget {
  HotelPricingScreen({
    Key? key,
  });
  @override
  HotelPricingScreenState createState() => HotelPricingScreenState();
}

class HotelPricingScreenState extends State<HotelPricingScreen> {
  final _formKey = GlobalKey<FormState>();

  bool enablePersonPrice = false;
  List<Map<String, String?>> extraPrices = [
    {
      'englishName': null,
      'japaneseName': null,
      'egyptianName': null,
      'price': null,
      'type': null
    }
  ];

  List<String> passangeroption = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10'
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VendorHotelProvider>(context, listen: true);
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
                "Add New Hotel".tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Image.asset(Get.locale?.languageCode == 'ar'
                ? 'assets/haven/eventlevel3_ar.png'
                : 'assets/haven/eventlevel3.png'),
            SizedBox(
              height: 10,
            ),
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
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 20, top: 10),
              child: Text(
                "Time for check in".tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
            ),

            // // Car Number Input
            // CustomTextField(
            //   hintText: "Ex- 12:00 AM".tr,
            //   controller: provider.timechecincontroller,
            //   onChanged: (value) {
            //     provider.timechecincontroller.text = value;
            //   },
            // ),
            Container(
              padding: const EdgeInsets.only(left: 0, right: 0, bottom: 10),
              margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: TextFormField(
                controller: provider.timechecincontroller,
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
                    initialTime: TimeOfDay(hour: 12, minute: 00),
                    context: context,
                  );

                  if (pickedTime != null) {
                    // log("${} checkId");
                    String formattedTime = pickedTime.format(context);
                    // '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                    setState(() {
                      provider.timechecincontroller.text = formattedTime;
                    });
                  }
                },
              ),
            ),
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
            //   hintText: "Ex- 12:00 AM".tr,
            //   controller: provider.timechecoutcontroller,
            // ),

            Container(
              padding: const EdgeInsets.only(left: 0, right: 0, bottom: 10),
              margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: TextFormField(
                controller: provider.timechecoutcontroller,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter CheckOut Time'.tr;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Checkout Time'.tr,

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
                    initialTime: TimeOfDay(hour: 12, minute: 00),
                    context: context,
                  );

                  if (pickedTime != null) {
                    String formattedTime = pickedTime.format(context);
                    // '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                    setState(() {
                      provider.timechecoutcontroller.text = formattedTime;
                    });
                  }
                },
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

            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButtonFormField<String>(
                      hint: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text("Ex : 3".tr),
                      ),
                      value: provider.selectreservations,
                      items: passangeroption.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            provider.selectreservations = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
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

            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButtonFormField<String>(
                      hint: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text("Ex : 3"),
                      ),
                      value: provider.selectrequirements,
                      items: passangeroption.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            provider.selectrequirements = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
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
              controller: provider.pricecontroller,
              txKeyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Price'.tr;
                }
                return null;
              },
            ),

            Row(
              children: [
                Checkbox(
                  value: provider.isShowPassword,
                  onChanged: (bool? value) {
                    setState(() {
                      provider.isShowPassword = value!;
                    });
                  },
                ),
                Text('Enable extra Price'.tr),
              ],
            ),

            if (provider.isShowPassword)
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: provider.price.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        controller: provider.price[index].name,
                        hintText: 'Name'.tr,
                      ),
                      CustomTextField(
                        controller: provider.price[index].price,
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
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<String>(
                            value: provider.price[index].type,
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
                            items: ['one time', 'per day'].map((String value) {
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
                            value: provider.price[index].perPerson,
                            onChanged: (bool? value) {
                              setState(() {
                                provider.price[index].perPerson = value!;
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
                            provider.removeprice(index);
                            setState(() {});
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  );
                },
              ),

            // // Extra Price Section
            // Padding(
            //   padding: const EdgeInsets.only(
            //     left: 10,
            //   ),
            //   child: Text(
            //     "Extra Price".tr,
            //     style: TextStyle(
            //         fontFamily: "inter",
            //         fontSize: 14,
            //         fontWeight: FontWeight.w400),
            //   ),
            // ),
            // SizedBox(height: 10),
            // if (provider.isShowPassword)
            //   for (int index = 0; index < provider.price.length; index++)
            //     Column(
            //       children: [
            //         CustomTextField(
            //           hintText: "Name",
            //           onChanged: (value) {
            //             provider.price[index].name = value;
            //           },
            //         ),
            //         CustomTextField(
            //           hintText: "Price",
            //           onChanged: (value) {
            //             provider.price[index].price = value;
            //             print("price${provider.price[index].price}");
            //           },
            //         ),
            //         CustomTextField(
            //           hintText: "time",
            //           onChanged: (value) {
            //             provider.price[index].time = value;
            //             print("price${provider.price[index].time}");
            //           },
            //         ),
            //         Padding(
            //           padding: const EdgeInsets.only(left: 10),
            //           child: Row(
            //             children: [
            //               SizedBox(
            //                 width: 20,
            //               ),
            //               if (index > 0)
            //                 Container(
            //                   decoration: BoxDecoration(
            //                     color: Colors.red, // Red background color
            //                     borderRadius: BorderRadius.circular(
            //                         12), // Slightly rounded corners
            //                   ),
            //                   child: IconButton(
            //                     icon: Icon(
            //                       Icons.delete,
            //                       color: Colors.white, // White icon color
            //                     ),
            //                     onPressed: () {
            //                       provider.removeprice(index);
            //                     },
            //                   ),
            //                 ),
            //             ],
            //           ),
            //         ),
            //       ],
            //     ),

            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: SizedBox(
                width: 100,
                child: TextIconButtom(
                  size: 10,
                  icon: Icon(Icons.upload),
                  text: 'Add Item'.tr,
                  press: () {
                    setState(() {
                      provider.addprice();
                    });
                  },
                ),
              ),
            ),
            // Add Item Button

            SizedBox(height: 20),
            // Save & Next Button
            TertiaryButton(
              press: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  // if (provider.selectreservations == null) {
                  //   showErrorToast(
                  //       "Please select Minimum advance reservations");
                  //   return;
                  // }
                  // if (provider.selectrequirements == null) {
                  //   showErrorToast(
                  //       "Please select Minimum day stay requirements");
                  //   return;
                  // }
                  if (provider.isShowPassword == true &&
                      provider.price.isEmpty) {
                    showErrorToast("Please select atleast one extra price".tr);
                    return;
                  }

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HotelFourScreen()));
                }

                // Check for hotel related IDs
              },
              text: 'Save & Next'.tr,
            ),
          ],
        ),
      ),
    );
  }
}
