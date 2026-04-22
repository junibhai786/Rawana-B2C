import 'dart:developer';
import 'dart:io';

import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/modals/manage_service_model.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:flutter/material.dart';
import 'package:moonbnd/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ManageAddCouponScreen extends StatefulWidget {
  @override
  State<ManageAddCouponScreen> createState() => _ManageAddCouponScreenState();
}

class _ManageAddCouponScreenState extends State<ManageAddCouponScreen> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  TextEditingController unquieCodeController = TextEditingController();
  TextEditingController unquieNameController = TextEditingController();
  TextEditingController unquieAmountController = TextEditingController();
  String discountType = "";
  DateTime? selectEndDate;
  TextEditingController endDateController = TextEditingController();
  TextEditingController minimumSpendController = TextEditingController();
  TextEditingController maximumSpendController = TextEditingController();
  String manageServices = "";
  TextEditingController unlimitedUsageCouponController =
      TextEditingController();
  TextEditingController unlimitedUsageUserController = TextEditingController();
  String contentStatus = "draft";
  XFile? featuredImage;

  @override
  void initState() {
    super.initState();

    setState(() {
      loading = true;
    });
    Provider.of<HomeProvider>(context, listen: false)
        .fetchVendorServices()
        .then((value) {
      setState(() {
        loading = false;
      });
    });
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    // log(featureCheck);

    final images = await picker.pickImage(source: ImageSource.gallery);

    if (images != null) {
      setState(() {
        featuredImage = images;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      setState(() {
        selectEndDate = pickedDate;
        endDateController = TextEditingController(
            text: DateFormat('d/MM/yyyy').format(pickedDate));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<HomeProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Coupon'.tr,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: kSecondaryColor))
          : Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16),
                      Text(
                        'General'.tr,
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 25),
                      /////////////
                      ///            Column 1
                      ////////////
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          'Coupon Code'.tr,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w400),
                        ),
                      ),
                      SizedBox(height: 8),
                      CustomTextField(
                        margin: false,
                        controller: unquieCodeController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Coupon Code'.tr;
                          }
                          return null;
                        },
                        hintText: 'Unique Code'.tr,
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          'Coupon Name'.tr,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w400),
                        ),
                      ),
                      SizedBox(height: 8),
                      CustomTextField(
                        margin: false,
                        controller: unquieNameController,
                        hintText: 'Unique Name'.tr,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Coupon Name'.tr;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          'Coupon Amount'.tr,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w400),
                        ),
                      ),
                      SizedBox(height: 16),
                      CustomTextField(
                        margin: false,
                        controller: unquieAmountController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Coupon Amount'.tr;
                          }
                          return null;
                        },
                        txKeyboardType: TextInputType.number,
                        hintText: 'Unique Amount'.tr,
                      ),
                      SizedBox(height: 16),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          'Discount Type'.tr,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w400),
                        ),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select Discount Type'.tr;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Amount".tr,

                          border:
                              OutlineInputBorder(), // Adds a border around the dropdown
                          enabledBorder: OutlineInputBorder(
                            // Border when dropdown is not focused
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            // Border when dropdown is focused
                            borderSide:
                                BorderSide(color: AppColors.primary, width: 2.0),
                          ),
                        ),
                        items: ['fixed', 'percent'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          discountType = value.toString();
                          setState(() {});
                        },
                      ),
                      SizedBox(height: 16),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          'End Date'.tr,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w400),
                        ),
                      ),
                      SizedBox(height: 16),
                      CustomTextField(
                        controller: endDateController,
                        margin: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter end date'.tr;
                          }
                          return null;
                        },
                        isReadOnly: true,
                        onTap: () {
                          _selectDate(context);
                        },
                        hintText: 'End Date'.tr,
                      ),
                      SizedBox(height: 16),
                      /////////////
                      ///            Column 2
                      ////////////
                      Divider(thickness: 1.0),
                      SizedBox(height: 16),
                      Text(
                        'Usage Restriction'.tr,
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 25),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          'Minimum Spend'.tr,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w400),
                        ),
                      ),
                      SizedBox(height: 16),
                      CustomTextField(
                        margin: false,
                        controller: minimumSpendController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter minimum spend'.tr;
                          }
                          return null;
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        txKeyboardType: TextInputType.number,
                        hintText: 'No Minimum'.tr,
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          'The Minimum Spend does not include any Booking fee'
                              .tr,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey),
                        ),
                      ),
                      SizedBox(height: 16),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          'Maximum Spend'.tr,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w400),
                        ),
                      ),
                      SizedBox(height: 16),
                      CustomTextField(
                        margin: false,
                        controller: maximumSpendController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter maximum spend'.tr;
                          }
                          return null;
                        },
                        txKeyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        hintText: 'No Maximum'.tr,
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          'The Maximum Spend does not include any Booking fee'
                              .tr,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey),
                        ),
                      ),
                      SizedBox(height: 16),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          'Only for Services'.tr,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w400),
                        ),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select service'.tr;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Select Service".tr,
                          border:
                              OutlineInputBorder(), // Adds a border around the dropdown
                          enabledBorder: OutlineInputBorder(
                            // Border when dropdown is not focused
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            // Border when dropdown is focused
                            borderSide:
                                BorderSide(color: AppColors.primary, width: 2.0),
                          ),
                        ),
                        items: itemProvider.manageServiceResponse?.data
                            ?.map((ServiceModal value) {
                          return DropdownMenuItem<String>(
                            value: value.objectId.toString(),
                            child: Text(
                                "${value.objectModel} (#${value.objectId}): ${value.title}"),
                          );
                        }).toList(),
                        onChanged: (value) {
                          manageServices = value.toString();
                          setState(() {});
                        },
                      ),
                      SizedBox(height: 16),
                      Divider(thickness: 1.0),
                      /////////////
                      ///            Column 3
                      ////////////
                      SizedBox(height: 16),
                      Text(
                        'Usage Limits'.tr,
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 25),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          'Usage Limit Per Coupon'.tr,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w400),
                        ),
                      ),
                      SizedBox(height: 16),
                      CustomTextField(
                        margin: false,
                        controller: unlimitedUsageCouponController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter usage limit per coupon'.tr;
                          }
                          return null;
                        },
                        txKeyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        hintText: 'Unlimited Usage'.tr,
                      ),
                      SizedBox(height: 16),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          'Usage Limit Per User'.tr,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w400),
                        ),
                      ),
                      SizedBox(height: 16),
                      CustomTextField(
                        margin: false,
                        controller: unlimitedUsageUserController,
                        txKeyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter usage limit per user'.tr;
                          }
                          return null;
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        hintText: 'Unlimited Usage'.tr,
                      ),
                      SizedBox(height: 16),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          'Featured Image'.tr,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w400),
                        ),
                      ),

                      SizedBox(height: 16),
                      if (featuredImage != null)
                        Image.file(
                            height: 140,
                            width: 250,
                            File(featuredImage!.path),
                            fit: BoxFit.fill),
                      ElevatedButton.icon(
                        onPressed: () {
                          pickImage();
                        },
                        label: Text(featuredImage != null
                            ? "Change Image".tr
                            : "Upload image".tr),
                        icon: Icon(Icons.upload),
                      ),
                      SizedBox(height: 16),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          'Content Status'.tr,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w400),
                        ),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: contentStatus,
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
                                BorderSide(color: AppColors.primary, width: 2.0),
                          ),
                        ),
                        items: ["publish", "draft"].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value.toString(),
                            child: Text(value.toString()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          contentStatus = value.toString();
                          setState(() {});
                        },
                      ),
                      SizedBox(height: 32),
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            log("dasa");
                            if (_formKey.currentState!.validate()) {
                              if (featuredImage == null) {
                                return EasyLoading.showToast(
                                    "Please select Image".tr,
                                    maskType: EasyLoadingMaskType.black);
                              }

                              setState(() {
                                loading = true;
                              });
                              bool check = await itemProvider.addVendorCoupon(
                                code: unquieCodeController.text,
                                name: unquieNameController.text,
                                amount: unquieAmountController.text,
                                discountType: discountType,
                                endDate: selectEndDate.toString(),
                                minTotal: minimumSpendController.text,
                                maxTotal: maximumSpendController.text,
                                services: manageServices,
                                quantityLimit:
                                    unlimitedUsageCouponController.text,
                                limitPerUser: unlimitedUsageUserController.text,
                                status: contentStatus,
                                image: File(featuredImage!.path),
                              );

                              setState(() {
                                loading = false;
                              });
                              if (check) {
                                await itemProvider.fetchVendorCoupons();
                                Navigator.pop(context);
                              }
                              // if (result['success']) {
                              //   EasyLoading.showToast('Coupon added successfully');
                              //   Navigator.pop(context);
                              // } else {
                              //   EasyLoading.showToast('Failed to add coupon');
                              // }
                            }
                          },
                          child: Text("Save".tr,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18)),
                        ),
                      ),
                      SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
