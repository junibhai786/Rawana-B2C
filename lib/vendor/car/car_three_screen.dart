import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Provider/singup_vendor_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/modals/car_detail_model.dart';
import 'package:moonbnd/vendor/car/car_four_screen.dart';
import 'package:moonbnd/widgets/elevatedbuttonicon.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ExtraPrices {
  String? price;
  String? type;
  String? name;
  String? egyptianame;
  String? japanesename;

  ExtraPrices(
      {this.price, this.type, this.name, this.egyptianame, this.japanesename});
}

class AddCarPricingScreen extends StatefulWidget {
  final int? defaultstate;
  final String? number;
  final String? price;
  final String? url;

  final int? saleprice;
  final String? minadvancereservation;
  final String? mindaystayrequirement;
  final List<ExtraPriceCar>? extraPrice;

  AddCarPricingScreen({
    Key? key,
    this.defaultstate,
    this.number,
    this.url,
    this.extraPrice,
    this.price,
    this.saleprice,
    this.minadvancereservation,
    this.mindaystayrequirement,
  }) : super(key: key);

  @override
  _AddCarPricingScreenState createState() => _AddCarPricingScreenState();
}

class _AddCarPricingScreenState extends State<AddCarPricingScreen> {
  final _formKey = GlobalKey<FormState>();
  final provider = VendorAuthProvider();

  bool enablePersonPrice = false;
  List<Map<String, String?>> extraPrices = [
    {'price': null, 'type': null}
  ];

  @override
  void initState() {
    super.initState();
    // Prefill the data if available
    // final provider = Provider.of<VendorAuthProvider>(context, listen: false);
    // if (widget.defaultstate != null) {
    //   provider.defaultstate = widget.defaultstate;
    //   print("Value of location id = ${widget.defaultstate}");
    // }
    // if (widget.number != null) {
    //   provider.carcontroller.text = widget.number ?? "";
    //   print("Address of title controller = ${widget.number}");
    // }
    // if (widget.price != null) {
    //   provider.pricecontroller.text = widget.price ?? "";
    //   print("Latitude = ${widget.price}");
    // }
    // if (widget.saleprice != null) {
    //   provider.salepricecontroller.text = widget.saleprice.toString();
    //   print("Longitude = ${widget.saleprice}");
    // }
    // if (widget.minadvancereservation != null) {
    //   provider.minimumcontroller.text = widget.minadvancereservation ?? "";
    //   print("Longitude = ${widget.minadvancereservation}");
    // }
    // if (widget.mindaystayrequirement != null) {
    //   provider.minimumdaystaycontroller.text =
    //       widget.mindaystayrequirement ?? "";
    //   print("Longitude = ${widget.mindaystayrequirement}");
    // }
    // if (widget.extraPrice != null && widget.extraPrice!.isNotEmpty) {
    //   _termsAccepted = true;
    //   // Ensure provider.extraprice is initialized with enough elements
    //   while (provider.extraprice.length < widget.extraPrice!.length) {
    //     provider.extraprice
    //         .add(ExtraPrices()); // Assuming ExtraPriceModel is the type
    //   }

    //   for (int index = 0; index < widget.extraPrice!.length; index++) {
    //     provider.extraprice[index].name = widget.extraPrice![index].name;
    //     provider.extraprice[index].price = widget.extraPrice![index].price;
    //     provider.extraprice[index].type = widget.extraPrice![index].type;

    //     print("Extra price added: ${widget.extraPrice![index].name}");
    //   }
    // }

    // Fetch initial data
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VendorAuthProvider>(context, listen: true);

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
                "Add New Car".tr,
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
                value: provider.defaultstateName,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please add default state".tr; // Validation message
                  }
                  return null; // Return null if validation passes
                },
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
                  provider.defaultstateName = value.toString();
                  if (value == 'Only available on specific dates') {
                    setState(() {
                      provider.defaultstate = 0;
                    });
                    // S
                  } else if (value == 'Always available') {
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
              controller: provider.carcontroller,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
            // Car Price Input
            CustomTextField(
              hintText: 'Car Price'.tr,
              controller: provider.pricecontroller,
              txKeyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please add car price"; // Validation message
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
              hintText: 'Car Sale Price'.tr,
              controller: provider.salepricecontroller,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              // validator: (value) {
              //   if (value == null || value.isEmpty) {
              //     return "Please add sale price"; // Validation message
              //   }
              //   return null; // Return null if validation passes
              // },
              txKeyboardType: TextInputType.number,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                "If the regular price is less than the discount it will show the regular price"
                    .tr
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
              controller: provider.minimumcontroller,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              // validator: (value) {
              //   if (value == null || value.isEmpty) {
              //     return "Please add minimum advance reservation"; // Validation message
              //   }
              //   return null; // Return null if validation passes
              // },
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
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please add minimum dat stay requirement"
                      .tr; // Validation message
                }
                return null; // Return null if validation passes
              },
              controller: provider.minimumdaystaycontroller,
              txKeyboardType: TextInputType.number,
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
            Row(
              children: [
                Checkbox(
                  value: provider.termsAccepted,
                  onChanged: (bool? value) {
                    setState(() {
                      provider.termsAccepted = value!;
                    });
                  },
                ),
                Text('Enable Extra Price'.tr),
              ],
            ),
            SizedBox(height: 10),
            provider.termsAccepted == true
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 10),
                        child: Text(
                          "Extra Price".tr,
                          style: TextStyle(
                              fontFamily: "inter",
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      Column(children: [
                        for (int index = 0;
                            index < provider.extraprice.length;
                            index++)
                          Column(
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, bottom: 10),
                                  child: Text(
                                    "Name".tr,
                                    style: TextStyle(
                                        fontFamily: "inter",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ),
                              CustomTextField(
                                controller: TextEditingController(
                                    text: provider.extraprice[index].name),
                                hintText: "Name".tr,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please add extra price name"
                                        .tr; // Validation message
                                  }
                                  return null; // Return null if validation passes
                                },
                                onChanged: (value) {
                                  provider.extraprice[index].name = value;
                                },
                              ),
                              CustomTextField(
                                controller: TextEditingController(
                                    text: provider
                                        .extraprice[index].japanesename),
                                onChanged: (value) {
                                  provider.extraprice[index].japanesename =
                                      value;
                                },
                                hintText: 'Japanese Name'.tr,
                              ),
                              CustomTextField(
                                controller: TextEditingController(
                                    text:
                                        provider.extraprice[index].egyptianame),
                                onChanged: (value) {
                                  provider.extraprice[index].egyptianame =
                                      value;
                                },
                                hintText: 'Egyptian Name'.tr,
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, bottom: 10),
                                  child: Text(
                                    "Price".tr,
                                    style: TextStyle(
                                        fontFamily: "inter",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ),
                              CustomTextField(
                                controller: TextEditingController(
                                    text: provider.extraprice[index].price),
                                txKeyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                hintText: "Price".tr,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please add extraprice price"; // Validation message
                                  }
                                  return null; // Return null if validation passes
                                },
                                onChanged: (value) {
                                  provider.extraprice[index].price = value;
                                },
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, bottom: 10),
                                  child: Text(
                                    "Type".tr,
                                    style: TextStyle(
                                        fontFamily: "inter",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButtonFormField<String>(
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please add extraprice type"
                                            .tr; // Validation message
                                      }
                                      return null; // Return null if validation passes
                                    },
                                    decoration: InputDecoration(
                                      border:
                                          OutlineInputBorder(), // Adds a border around the dropdown
                                      enabledBorder: OutlineInputBorder(
                                        // Border when dropdown is not focused
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        // Border when dropdown is focused
                                        borderSide: BorderSide(
                                            color: kSecondaryColor, width: 2.0),
                                      ),
                                    ),
                                    hint: Text("Select option".tr),
                                    value: provider.extraprice[index].type,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        provider.extraprice[index].type =
                                            newValue;
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
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.red, // Red background color
                                        borderRadius: BorderRadius.circular(
                                            12), // Slightly rounded corners
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color:
                                              Colors.white, // White icon color
                                        ),
                                        onPressed: () {
                                          provider.removeexptraprice(index);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: 100,
                          child: TextIconButtom(
                            size: 10,
                            icon: Icon(Icons.upload),
                            text: 'Add Item'.tr,
                            press: () {
                              provider.addexptraprice();
                            },
                          ),
                        ),
                      ]),
                    ],
                  )
                : SizedBox(),

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
                  if (provider.termsAccepted == true &&
                      provider.extraprice.isEmpty) {
                    showErrorToast("Please enter atleast one extra price");
                    return;
                  }
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              CarFourScreen(url: widget.url)));
                }
                // print("price${provider.extraprice[0].price}");
              },
              text: 'Save & Next'.tr,
            ),
          ],
        ),
      ),
    );
  }
}
