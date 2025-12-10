import 'dart:developer';
import 'dart:io';

import 'package:moonbnd/Provider/vendor_boat_provider.dart';
import 'package:moonbnd/vendor/boat/boat_two_screen.dart';
import 'package:moonbnd/widgets/elevatedbuttonicon.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:html_editor_plus/html_editor.dart';
import 'package:provider/provider.dart';

class AddNewBoatScreen extends StatefulWidget {
  @override
  State<AddNewBoatScreen> createState() => _AddNewBoatScreenState();
}

class _AddNewBoatScreenState extends State<AddNewBoatScreen> {
  late VendorBoatProvider provider;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    provider = Provider.of<VendorBoatProvider>(context, listen: false);
    Provider.of<VendorBoatProvider>(context, listen: false).clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VendorBoatProvider>(builder: (context, provider, child) {
      return Scaffold(
        appBar: AppBar(),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Text('Add New Boat'.tr,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Image.asset(
                    Get.locale?.languageCode == 'ar'
                        ? 'assets/haven/eventlevel1_ar.png'
                        : 'assets/haven/eventlevel1.png',
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    child: Text('Boat Content'.tr,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                    child: Text('Title'.tr,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                  ),
                  CustomTextField(
                    controller: provider.titleController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Title'.tr;
                      }
                      return null;
                    },
                    hintText: "Title".tr,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                    child: Text('Content'.tr,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                  ),
                  HtmlEditor(
                    controller: provider.contentController, //required
                    htmlEditorOptions: HtmlEditorOptions(
                      hint: "Your text here...".tr,
                      inputType: HtmlInputType.text,

                      adjustHeightForKeyboard: true,

                      //initalText: "text content initial, if any",
                    ),
                    otherOptions: OtherOptions(
                      height: 400,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                    child: Text('Youtube Video'.tr,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                  ),
                  CustomTextField(
                    controller: provider.youtubeVideoController,
                    hintText: "Youtube Video".tr,
                    // validator: (value) {
                    //   if (value == null || value.isEmpty) {
                    //     return 'Please enter youtube'.tr;
                    //   }
                    //   return null;
                    // },
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                    child: Text('FAQs'.tr,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                  ),
                  ...(provider.faqList).map((element) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          controller: element.title,
                          hintText: 'Title'.tr,
                          // onSaved: (value) {
                          //   faqContent = value;
                          // },
                        ),
                        CustomTextField(
                          controller: element.content,
                          hintText: 'Content'.tr,
                          // onSaved: (value) {
                          //   faqContent = value;
                          // },
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 20),
                          decoration: BoxDecoration(
                            color: Colors.red, // Red background color
                            borderRadius: BorderRadius.circular(
                                12), // Slightly rounded corners
                          ),
                          child: IconButton(
                            onPressed: () {
                              provider.deleteFaq(element.id);
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    );
                  }),
                  Row(
                    children: [
                      SizedBox(
                        width: 150,
                        child: TextIconButtom(
                          press: () {
                            provider.addFaq();
                          },
                          icon: Icon(
                            Icons.upload,
                            color: Colors.white,
                          ),
                          text: "Add Item".tr,
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                    child: Text('Banner Image'.tr,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                  ),
                  if (provider.bannerImage != null)
                    Container(
                      width: double.infinity,
                      child: Image.file(
                        File(provider.bannerImage!.path),
                        height: 150,
                        width: 200,
                        fit: BoxFit.fill,
                      ),
                    ),
                  SizedBox(height: 20),
                  // Banner Image Upload
                  SizedBox(
                    width: 200,
                    child: TextIconButtom(
                      icon: Icon(
                        Icons.upload,
                        color: Colors.white,
                      ),
                      press: () {
                        provider.pickImage();
                      },
                      text: "Upload Image".tr,
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                    child: Text('Gallery'.tr,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                  ),
                  if (provider.galleryImages.isNotEmpty)
                    ...(provider.galleryImages).map((element) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 10),
                        width: double.infinity,
                        child: Image.file(
                          File(element.path),
                          height: 150,
                          width: 200,
                          fit: BoxFit.fill,
                        ),
                      );
                    }),
                  SizedBox(height: 20),
                  TextIconButtom(
                    icon: Icon(
                      Icons.upload,
                      color: Colors.white,
                    ),
                    text: 'Upload Images'.tr,
                    press: () => provider.pickGalleryImages(),
                  ),

                  Divider(
                    thickness: 2,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                    child: Text('Extra Info'.tr,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600)),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                    child: Text('Guest'.tr,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                  ),
                  SizedBox(height: 10),
                  CustomTextField(
                    margin: false,
                    controller: provider.guestController,
                    txKeyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter no of guests'.tr;
                      }
                      return null;
                    },
                    hintText: 'Ex: 3'.tr,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                    child: Text('Cabin'.tr,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                  ),
                  CustomTextField(
                    margin: false,
                    controller: provider.cabinController,
                    txKeyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    // validator: (value) {
                    //   if (value == null || value.isEmpty) {
                    //     return 'Please enter no of cabin'.tr;
                    //   }
                    //   return null;
                    // },
                    hintText: 'Ex: 5'.tr,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                    child: Text('Length'.tr,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                  ),
                  CustomTextField(
                    margin: false,
                    controller: provider.lengthController,
                    txKeyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter no of length'.tr;
                      }
                      return null;
                    },
                    hintText: 'Ex: 30m'.tr,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                    child: Text('Speed'.tr,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                  ),
                  CustomTextField(
                    margin: false,
                    controller: provider.speedController,
                    txKeyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter no of Speed'.tr;
                      }
                      return null;
                    },
                    hintText: 'Ex: 25 km/hr'.tr,
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                    child: Text('Specs'.tr,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  ...(provider.specsList).map((element) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.only(left: 10, right: 10, bottom: 5),
                          child: Text('Title'.tr,
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                        ),
                        CustomTextField(
                          margin: false,
                          controller: element.title,
                          hintText: 'Title'.tr,
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: 10, right: 10, bottom: 5),
                          child: Text('Content'.tr,
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                        ),
                        CustomTextField(
                          margin: false,
                          controller: element.content,
                          hintText: 'Content'.tr,
                        ),
                        SizedBox(height: 10),
                        Container(
                          margin: EdgeInsets.only(left: 20),
                          decoration: BoxDecoration(
                            color: Colors.red, // Red background color
                            borderRadius: BorderRadius.circular(
                                12), // Slightly rounded corners
                          ),
                          child: IconButton(
                            onPressed: () {
                              provider.deleteSpec(element.id);
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: TextIconButtom(
                            press: () {
                              provider.addSpec();
                            },
                            icon: Icon(
                              Icons.upload,
                              color: Colors.white,
                            ),
                            text: "Add Item".tr,
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text('Cancellation Policy'.tr,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                  ),
                  SizedBox(height: 10),
                  CustomTextField(
                    margin: false,
                    controller: provider.cancelPolicyController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter cancel policy'.tr;
                      }
                      return null;
                    },
                    hintText: 'Full refund upto 4 days prior'.tr,
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text('Additional Terms & Information'.tr,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                  ),
                  SizedBox(height: 10),
                  CustomTextField(
                    margin: false,
                    controller: provider.additionalTermsController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter additional terms and information'
                            .tr;
                      }
                      return null;
                    },
                    hintText: 'Type here...'.tr,
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text('Include Services'.tr,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                  ),
                  ...(provider.includeList).map((element) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          margin: false,
                          controller: element.title,
                          hintText: 'Title'.tr,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () {
                              provider.deleteInclude(element.id);
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: TextIconButtom(
                            press: () {
                              provider.addInclude();
                            },
                            icon: Icon(
                              Icons.upload,
                              color: Colors.white,
                            ),
                            text: "Add Item".tr,
                          ),
                        ),
                        SizedBox(width: 20),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text('Exclude Services'.tr,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                  ),
                  ...(provider.excludeList).map((element) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          margin: false,
                          controller: element.title,
                          hintText: 'Title'.tr,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () {
                              provider.deleteExclude(element.id);
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: TextIconButtom(
                            press: () {
                              provider.addExclude();
                            },
                            icon: Icon(
                              Icons.upload,
                              color: Colors.white,
                            ),
                            text: "Add Item".tr,
                          ),
                        ),
                        SizedBox(width: 20),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 10, right: 10, bottom: 5, top: 10),
                    child: Text('Featured Image'.tr,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                  ),
                  if (provider.featuredImage != null)
                    Container(
                      width: double.infinity,
                      child: Image.file(
                        File(provider.featuredImage!.path),
                        height: 150,
                        width: 200,
                        fit: BoxFit.fill,
                      ),
                    ),
                  SizedBox(height: 20),

                  SizedBox(
                    height: 10,
                  ),
                  TextIconButtom(
                    icon: Icon(Icons.upload),
                    text: 'Upload Image'.tr,
                    press: () => provider.pickImage(featureCheck: true),
                  ),
                  SizedBox(height: 20),
                  TertiaryButton(
                    press: () async {
                      final provider = Provider.of<VendorBoatProvider>(context,
                          listen: false);
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        String contentSend =
                            await provider.contentController.getText();

                        log("${provider.contentController.toString()} stringstring");

                        if (contentSend.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Please enter boat content'.tr)),
                          );
                          return;
                        }
                        if (provider.bannerImage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Please upload a banner image'.tr)),
                          );
                          return;
                        }

                        // Validate Specs (if any are added)
                        if (provider.specsList.isEmpty) {
                          Get.snackbar(
                              "Error".tr, "Please add at least one Specs.".tr);
                          return;
                        }

                        // Validate Include List (if any are added)
                        if (provider.includeList.isEmpty) {
                          Get.snackbar("Error".tr,
                              "Please add at least one Include.".tr);
                          return;
                        }
                        if (provider.excludeList.isEmpty) {
                          Get.snackbar("Error".tr,
                              "Please add at least one Exclude.".tr);
                          return;
                        }

                        // Validate Featured Image
                        if (provider.featuredImage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Please upload a featured image'.tr)),
                          );
                          return;
                        }
                        if (provider.galleryImages.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Please upload a gallery image'.tr)),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BoatLocationScreen(),
                          ),
                        );
                      }
                      // Get the provider

                      // Validate Title

                      // Validate Content

                      // Validate Banner Image

                      // Validate Guest

                      // Validate Length

                      // Validate FAQs (if any are added)

                      // If all validations pass, navigate to next screen
                    },
                    text: 'Save & Next'.tr,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDropdown(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 10, right: 10),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: (value) {},
      ),
    );
  }
}
