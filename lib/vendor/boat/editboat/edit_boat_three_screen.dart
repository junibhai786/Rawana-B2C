import 'package:moonbnd/Provider/vendor_boat_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/modals/boat_vendor_details_model.dart';
import 'package:moonbnd/vendor/boat/editboat/edit_boat_four_screen.dart';
import 'package:moonbnd/widgets/elevatedbuttonicon.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class EditBoatPricingScreen extends StatefulWidget {
  final List<BoatDetailDatum>? data;
  final String? id;
  const EditBoatPricingScreen({super.key, this.data, this.id});

  @override
  EditBoatPricingScreenState createState() => EditBoatPricingScreenState();
}

class EditBoatPricingScreenState extends State<EditBoatPricingScreen> {
  final _formKey = GlobalKey<FormState>();
  late VendorBoatProvider provider;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<VendorBoatProvider>(context, listen: false);

    if (widget.data != null) {
      provider.pricePerHourController.text =
          widget.data!.first.pricePerHour.toString();
      provider.pricePerDayController.text =
          widget.data!.first.pricePerDay.toString();
      provider.minDayBeforeBooking.text =
          widget.data!.first.minDayBeforeBooking.toString();
      provider.startTimeController.text =
          widget.data!.first.startTime.toString();
      provider.endTimeController.text = widget.data!.first.endTime.toString();
    }
    if (widget.data?.first.extraPrice != null) {
      provider.extraPriceBoatVendorList = widget.data!.first.extraPrice!
          .map((e) => ExtraPriceForVendor(
              id: DateTime.now().add(Duration(seconds: 5)),
              name: TextEditingController(text: e.name),
              name_ja: TextEditingController(text: e.nameJa),
              name_egy: TextEditingController(text: e.nameEgy),
              price: TextEditingController(text: e.price),
              type: e.type == "one_time"
                  ? "one time"
                  : e.type == "per_hour"
                      ? "per hour"
                      : "per day"))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VendorBoatProvider>(
      builder: (context, provider, child) {
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
                    "Add New Boat".tr,
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
                    value: provider.defaultState,
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
                    items: [
                      'Only available on specific dates',
                      'Always available'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      provider.defaultState = value!;
                      provider.defaultStateInput =
                          value == "Always available" ? "0" : "1";
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
                    "Price Per Hour".tr,
                    style: TextStyle(
                        fontFamily: "inter",
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                ),

                // Car Number Input
                CustomTextField(
                  controller: provider.pricePerHourController,
                  hintText: "Price Per Hour".tr,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please add Price Per Hour"
                          .tr; // Validation message
                    }
                    return null; // Return null if validation passes
                  },
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  txKeyboardType: TextInputType.number,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 10),
                  child: Text(
                    "Price Per Day".tr,
                    style: TextStyle(
                        fontFamily: "inter",
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                // Car Number Input
                CustomTextField(
                  controller: provider.pricePerDayController,
                  hintText: "Price Per Day".tr,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please add Price Per Day"
                          .tr; // Validation message
                    }
                    return null; // Return null if validation passes
                  },
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  txKeyboardType: TextInputType.number,
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

                CustomTextField(
                  controller: provider.minDayBeforeBooking,
                  txKeyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  hintText: 'Ex: 3'.tr,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 10),
                  child: Text(
                    "Leave blank if you dont need to use the min day option".tr,
                    style: TextStyle(
                        fontFamily: "inter",
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                // Sale Price Input
                Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 10),
                  child: Text(
                    "Start time booking".tr,
                    style: TextStyle(
                        fontFamily: "inter",
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: TextFormField(
                    controller: provider.startTimeController,
                    decoration: InputDecoration(
                      labelText: 'Select Time'.tr,
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
                          provider.startTimeController.text = formattedTime;
                        });
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 10),
                  child: Text(
                    "End time booking".tr,
                    style: TextStyle(
                        fontFamily: "inter",
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: TextFormField(
                    controller: provider.endTimeController,
                    decoration: InputDecoration(
                      labelText: 'Select Time'.tr,
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
                          provider.endTimeController.text = formattedTime;
                        });
                      }
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Checkbox(
                        value: provider.enableExtraPrice,
                        onChanged: (bool? value) {
                          setState(() {
                            provider.enableExtraPrice = value!;
                          });
                        },
                      ),
                      Text('Enable Extra Price'.tr),
                    ],
                  ),
                ),
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

                if (provider.enableExtraPrice)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: provider.extraPriceBoatVendorList.length,
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 10, bottom: 10),
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
                                provider.extraPriceBoatVendorList[index].name,
                            hintText: 'English Name'.tr,
                          ),
                          CustomTextField(
                            controller: provider
                                .extraPriceBoatVendorList[index].name_ja,
                            hintText: 'Japanese Name'.tr,
                          ),
                          CustomTextField(
                            controller: provider
                                .extraPriceBoatVendorList[index].name_egy,
                            hintText: 'Egyptian Name'.tr,
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, bottom: 10),
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
                            controller:
                                provider.extraPriceBoatVendorList[index].price,
                            hintText: 'Price'.tr,
                            txKeyboardType: TextInputType.number,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, bottom: 10),
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
                                value: provider
                                    .extraPriceBoatVendorList[index].type,
                                decoration: InputDecoration(
                                  border:
                                      OutlineInputBorder(), // Adds a border around the dropdown
                                  enabledBorder: OutlineInputBorder(
                                    // Border when dropdown is not focused
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    // Border when dropdown is focused
                                    borderSide: BorderSide(
                                        color: kSecondaryColor, width: 2.0),
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
                                  provider.extraPriceBoatVendorList[index]
                                      .type = value!;
                                  setState(() {});
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
                                if (provider
                                        .extraPriceBoatVendorList[index].id !=
                                    null) {
                                  provider.deleteExtraPrice(provider
                                      .extraPriceBoatVendorList[index].id!);
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

                // Add Item Button
                if (provider.enableExtraPrice)
                  TextIconButtom(
                    text: 'Add Item'.tr,
                    press: () => provider.addExtraPrice(),
                    size: 10,
                    icon: Icon(Icons.upload),
                  ),

                SizedBox(height: 20),
                // Save & Next Button
                TertiaryButton(
                  press: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      // Validate Minimum Days Before Booking (if not left blank)

                      // // Validate Start Time
                      // if (provider.startTimeController.text.trim().isEmpty) {
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //     SnackBar(
                      //         content: Text('Please select start time'.tr)),
                      //   );
                      //   return;
                      // }

                      // // Validate End Time
                      // if (provider.endTimeController.text.trim().isEmpty) {
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //     SnackBar(content: Text('Please select end time'.tr)),
                      //   );
                      //   return;
                      // }

                      // Validate Extra Price Items if enabled
                      if (provider.enableExtraPrice) {
                        if (provider.extraPriceBoatVendorList.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Please add at least one extra price item'
                                        .tr)),
                          );
                          return;
                        }
                      }
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditBoatFourScreen(
                                    data: widget.data,
                                    id: widget.id,
                                  )));
                    }
                  },
                  text: 'Save & Next'.tr,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
