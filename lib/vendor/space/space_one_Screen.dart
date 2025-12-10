import 'dart:developer';
import 'dart:io';

import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Provider/space_provider.dart';
import 'package:moonbnd/vendor/space/space_two_screen.dart';
import 'package:moonbnd/widgets/elevatedbuttonicon.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:html_editor_plus/html_editor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SpaceOneScreen extends StatefulWidget {
  @override
  _SpaceOneScreenState createState() => _SpaceOneScreenState();
}

class _SpaceOneScreenState extends State<SpaceOneScreen> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      loading = true;
    });
    Provider.of<SpaceProvider>(context, listen: false)
        .fetchFacilites()
        .then((value) {
      // ignore: use_build_context_synchronously
      Provider.of<SpaceProvider>(context, listen: false)
          .fetchSpaceType()
          .then((onValue) {
        Provider.of<SpaceProvider>(context, listen: false).clear();
        loading = false;

        setState(() {});
      });
    });
  }

  void addFaq() {
    Provider.of<SpaceProvider>(context, listen: false).faqList.add(FaqClass(
        id: DateTime.now(),
        content: TextEditingController(),
        title: TextEditingController()));

    setState(() {});
  }

  void deleteFaq(DateTime? id) {
    Provider.of<SpaceProvider>(context, listen: false)
        .faqList
        .removeWhere((test) {
      return test.id == id;
    });

    setState(() {});
  }

  // Image picker function
  Future<void> pickImage({featureCheck = false}) async {
    final picker = ImagePicker();
    // log(featureCheck);

    final images = await picker.pickImage(source: ImageSource.gallery);
    if (featureCheck) {
      if (images != null) {
        setState(() {
          Provider.of<SpaceProvider>(context, listen: false).featuredImage =
              images;
        });
      }
    } else {
      if (images != null) {
        setState(() {
          Provider.of<SpaceProvider>(context, listen: false).bannerImage =
              images;
        });
      }
    }
  }

  Future<void> pickImageGalleryImage() async {
    final picker = ImagePicker();

    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        Provider.of<SpaceProvider>(context, listen: false)
            .galleryImages
            .addAll(images);
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    Provider.of<SpaceProvider>(context, listen: false)
        .contentController
        .clear();
  }

  @override
  Widget build(BuildContext context) {
    final spaceProvider = Provider.of<SpaceProvider>(context, listen: true);
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        spaceProvider.clear();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              spaceProvider.clear();
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        ? 'assets/haven/level1_ar.png'
                        : 'assets/haven/level.png',
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, bottom: 10),
                    child: Text(
                      "Space Content".tr,
                      style: TextStyle(
                          fontFamily: "inter",
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  // Title Input
                  Padding(
                    padding: const EdgeInsets.only(left: 10, bottom: 4),
                    child: Text(
                      "Title".tr,
                      style: TextStyle(fontFamily: "inter", fontSize: 14),
                    ),
                  ),
                  CustomTextField(
                    controller: spaceProvider.titleController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Title'.tr;
                      }
                      return null;
                    },
                    hintText: "Title".tr,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, bottom: 4),
                    child: Text(
                      "Content".tr,
                      style: TextStyle(fontFamily: "inter", fontSize: 14),
                    ),
                  ),
                  // Content Input
                  HtmlEditor(
                    controller: spaceProvider.contentController, //required

                    htmlEditorOptions: HtmlEditorOptions(
                      inputType: HtmlInputType.text,

                      adjustHeightForKeyboard: true,

                      //initalText: "text content initial, if any",
                    ),
                    otherOptions: OtherOptions(
                      height: 400,
                    ),
                  ),
                  // CustomTextField(
                  //   controller: contentController,
                  //   maxCheck: 5,
                  //   hintText: "Special Requirment".tr,
                  // ),
                  // Youtube Video Input
                  Padding(
                    padding: const EdgeInsets.only(left: 10, bottom: 4),
                    child: Text(
                      "Youtube Video".tr,
                      style: TextStyle(fontFamily: "inter", fontSize: 14),
                    ),
                  ),
                  CustomTextField(
                    controller: spaceProvider.youtubeVideoController,
                    // validator: (value) {
                    //   if (value == null || value.isEmpty) {
                    //     return 'Please enter youtube'.tr;
                    //   }
                    //   return null;
                    // },
                    hintText: "Youtube Video".tr,
                  ),
                  // FAQ section
                  Padding(
                    padding: const EdgeInsets.only(left: 10, bottom: 4),
                    child: Text(
                      "FAQs".tr,
                      style: TextStyle(fontFamily: "inter", fontSize: 14),
                    ),
                  ),

                  ...(spaceProvider.faqList).map((element) {
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
                              deleteFaq(element.id);
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
                            addFaq();
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
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      "Banner Image".tr,
                      style: TextStyle(fontFamily: "inter", fontSize: 14),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),

                  /// Banner Image
                  if (spaceProvider.bannerImage != null)
                    SizedBox(
                      width: double.infinity,
                      child: Image.file(
                        File(spaceProvider.bannerImage!.path),
                        height: 150,
                        width: 200,
                        fit: BoxFit.fill,
                      ),
                    ),
                  SizedBox(height: 20),
                  // Banner Image Upload
                  TextIconButtom(
                      icon: Icon(
                        Icons.upload,
                        color: Colors.white,
                      ),
                      text: 'Upload Images'.tr,
                      press: () => pickImage()),
                  // SizedBox(
                  //   width: 20,
                  //   child: TextIconButtom(
                  //     icon: Icon(
                  //       Icons.upload,
                  //       color: Colors.white,
                  //     ),
                  //     press: () {
                  //       pickImage();
                  //     },
                  //     text: "Upload Image",
                  //   ),
                  // ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      "Gallery".tr,
                      style: TextStyle(fontFamily: "inter", fontSize: 14),
                    ),
                  ),

                  if (spaceProvider.galleryImages.isNotEmpty)
                    ...(spaceProvider.galleryImages).map((element) {
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
                    press: () => pickImageGalleryImage(),
                  ),

                  Divider(
                    thickness: 2,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, top: 10),
                    child: Text(
                      "Extra Info".tr,
                      style: TextStyle(
                          fontFamily: "inter",
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  // Extra Info
                  Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 4),
                    child: Text(
                      "No. Bed".tr,
                      style: TextStyle(fontFamily: "inter", fontSize: 14),
                    ),
                  ),
                  SizedBox(height: 10),
                  CustomTextField(
                    margin: false,
                    txKeyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    // validator: (value) {
                    //   if (value == null || value.isEmpty) {
                    //     return 'Please enter no of bed'.tr;
                    //   }
                    //   return null;
                    // },
                    controller: spaceProvider.noOfBedController,
                    hintText: 'Ex: 3'.tr,
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 4, top: 16),
                    child: Text(
                      "No. Bathroom".tr,
                      style: TextStyle(fontFamily: "inter", fontSize: 14),
                    ),
                  ),

                  CustomTextField(
                    margin: false,
                    controller: spaceProvider.noOfBathroomController,
                    txKeyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    // validator: (value) {
                    //   if (value == null || value.isEmpty) {
                    //     return 'Please enter No. of Bathroom'.tr;
                    //   }
                    //   return null;
                    // },
                    hintText: 'Ex: 5',
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 4, top: 16),
                    child: Text(
                      "Minimum Advance Reservations".tr,
                      style: TextStyle(fontFamily: "inter", fontSize: 14),
                    ),
                  ),
                  CustomTextField(
                    margin: false,
                    txKeyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    // validator: (value) {
                    //   if (value == null || value.isEmpty) {
                    //     return 'Please Minimum Advance Reservations'.tr;
                    //   }
                    //   return null;
                    // },
                    controller:
                        spaceProvider.minimumAdvanceReservationController,
                    hintText: 'Ex: 3'.tr,
                  ),

                  Text(
                    "Leave blank if you don't need to use the min day option"
                        .tr,
                    style: TextStyle(fontFamily: "inter", fontSize: 12),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 4, top: 16),
                    child: Text(
                      "Minimum day stay requirements".tr,
                      style: TextStyle(fontFamily: "inter", fontSize: 14),
                    ),
                  ),
                  CustomTextField(
                    margin: false,
                    txKeyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    // validator: (value) {
                    //   if (value == null || value.isEmpty) {
                    //     return 'Please Minimum day stay requirements'.tr;
                    //   }
                    //   return null;
                    // },
                    controller: spaceProvider.minimumDayStayController,
                    hintText: 'Ex: 2'.tr,
                  ),

                  // Featured Image Upload
                  Text(
                    "Leave blank if you don’t need to set minimum day stay option"
                        .tr,
                    style: TextStyle(fontFamily: "inter", fontSize: 12),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 4, top: 16),
                    child: Text(
                      "Featured Image".tr,
                      style: TextStyle(fontFamily: "inter", fontSize: 14),
                    ),
                  ),
                  if (spaceProvider.featuredImage != null)
                    SizedBox(
                      width: double.infinity,
                      child: Image.file(
                        File(spaceProvider.featuredImage!.path),
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
                    press: () => pickImage(featureCheck: true),
                  ),
                  SizedBox(height: 20),
                  TertiaryButton(
                    press: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        String contentSend =
                            await spaceProvider.contentController.getText();
                        log('$contentSend sennndd');

                        if (contentSend.isEmpty) {
                          return showErrorToast("content can't be empty".tr);
                        }

                        if (spaceProvider.bannerImage == null ||
                            spaceProvider.featuredImage == null ||
                            spaceProvider.galleryImages.isEmpty) {
                          return showErrorToast(
                              "please select all type of image".tr);
                        }
                        // if (spaceProvider.faqList.isEmpty) {
                        //   return showErrorToast(
                        //       "please select atleast one faq");
                        // }

                        Navigator.push(
                          // ignore: use_build_context_synchronously
                          context,
                          MaterialPageRoute(
                              builder: (context) => SpaceLocationScreenTwo(
                                    title: spaceProvider.titleController.text,
                                    content: contentSend.toString(),
                                    youtubeVideoText: spaceProvider
                                        .youtubeVideoController.text,
                                    faqList: spaceProvider.faqList,
                                    bannerimage: spaceProvider.bannerImage !=
                                            null
                                        ? File(spaceProvider.bannerImage!.path)
                                        : null,
                                    featuredimage: spaceProvider
                                                .featuredImage !=
                                            null
                                        ? File(
                                            spaceProvider.featuredImage!.path)
                                        : null,
                                    pickedImagefile: spaceProvider.galleryImages
                                        .map((e) => File(e.path))
                                        .toList(),
                                    minimumDayBeforeBooking: spaceProvider
                                        .minimumAdvanceReservationController
                                        .text,
                                    minimumdaystaycontroller: spaceProvider
                                        .minimumDayStayController.text,
                                    bed: spaceProvider.noOfBedController.text,
                                    bathroom: spaceProvider
                                        .noOfBathroomController.text,
                                  )),
                        );
                      }
                    },
                    text: 'Save & Next'.tr,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
