import 'dart:developer';
import 'dart:io';

import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Provider/event_provider.dart';
import 'package:moonbnd/Provider/space_provider.dart';
import 'package:moonbnd/vendor/event/event_two_screen.dart';
import 'package:moonbnd/widgets/elevatedbuttonicon.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:html_editor_plus/html_editor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EventOneScreen extends StatefulWidget {
  @override
  _SpaceOneScreenState createState() => _SpaceOneScreenState();
}

class _SpaceOneScreenState extends State<EventOneScreen> {
  final _formKey = GlobalKey<FormState>();

  // Variables to store form data

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<EventProvider>(context, listen: false)
        .fetchEventCatagories()
        .then((onValue) {});
    Provider.of<EventProvider>(context, listen: false).clear();
  }

  void addFaq() {
    Provider.of<EventProvider>(context, listen: false).faqList.add(FaqClass(
        id: DateTime.now(),
        content: TextEditingController(),
        title: TextEditingController()));

    setState(() {});
  }

  void deleteFaq(DateTime? id) {
    Provider.of<EventProvider>(context, listen: false)
        .faqList
        .removeWhere((test) {
      return test.id == id;
    });

    setState(() {});
  }

  // Image picker function
  Future<void> pickImage({featureCheck = false}) async {
    final picker = ImagePicker();

    final images = await picker.pickImage(source: ImageSource.gallery);
    if (featureCheck) {
      if (images != null) {
        setState(() {
          Provider.of<EventProvider>(context, listen: false).featuredImage =
              images;
        });
      }
    } else {
      if (images != null) {
        setState(() {
          Provider.of<EventProvider>(context, listen: false).bannerImage =
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
        Provider.of<EventProvider>(context, listen: false)
            .galleryImages
            .addAll(images);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context, listen: true);
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 10),
                  child: Text(
                    "Add New Event".tr,
                    style: TextStyle(
                        fontFamily: "inter",
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
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
                  padding: const EdgeInsets.only(left: 10, bottom: 10),
                  child: Text(
                    "Event Content".tr,
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
                  controller: Provider.of<EventProvider>(context, listen: false)
                      .titleController,
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
                  controller: Provider.of<EventProvider>(context, listen: false)
                      .contentController, //required
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
                // Youtube Video Input
                Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 4),
                  child: Text(
                    "Youtube Video".tr,
                    style: TextStyle(fontFamily: "inter", fontSize: 14),
                  ),
                ),
                CustomTextField(
                  controller: Provider.of<EventProvider>(context, listen: false)
                      .youtubeVideoController,
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Please enter youtube'.tr;
                  //   }
                  //   return null;
                  // },
                  hintText: "Youtube Video".tr,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 4),
                  child: Text(
                    "Start Time".tr,
                    style: TextStyle(fontFamily: "inter", fontSize: 14),
                  ),
                ),
                CustomTextField(
                  controller: Provider.of<EventProvider>(context, listen: false)
                      .startTimeController,
                  hintText: "Start Time".tr,
                  txKeyboardType: TextInputType.numberWithOptions(signed: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9:]+')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select start time'.tr;
                    }
                    return null;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 4),
                  child: Text(
                    "Duration (hour)".tr,
                    style: TextStyle(fontFamily: "inter", fontSize: 14),
                  ),
                ),
                CustomTextField(
                  controller: Provider.of<EventProvider>(context, listen: false)
                      .durationController,
                  txKeyboardType: TextInputType.numberWithOptions(signed: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9:]+')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select Duration'.tr;
                    }
                    return null;
                  },
                  hintText: "Ex: 5".tr,
                ),
                // FAQ section
                Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 4),
                  child: Text(
                    "FAQs".tr,
                    style: TextStyle(fontFamily: "inter", fontSize: 14),
                  ),
                ),

                ...(Provider.of<EventProvider>(context, listen: false).faqList)
                    .map((element) {
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
                }).toList(),

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
                if (Provider.of<EventProvider>(context, listen: false)
                        .bannerImage !=
                    null)
                  Container(
                    width: double.infinity,
                    child: Image.file(
                      File(Provider.of<EventProvider>(context, listen: false)
                          .bannerImage!
                          .path),
                      height: 150,
                      width: 200,
                      fit: BoxFit.fill,
                    ),
                  ),
                SizedBox(height: 20),
                // Banner Image Upload
                SizedBox(
                  width: 400,
                  child: TextIconButtom(
                    icon: Icon(
                      Icons.upload,
                      color: Colors.white,
                    ),
                    press: () {
                      pickImage();
                    },
                    text: "Upload Image".tr,
                  ),
                ),
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

                // Gallery Upload

                if (Provider.of<EventProvider>(context, listen: false)
                    .galleryImages
                    .isNotEmpty)
                  ...(Provider.of<EventProvider>(context, listen: false)
                          .galleryImages)
                      .map((element) {
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

                // Featured Image Upload

                Padding(
                  padding: const EdgeInsets.only(left: 2, bottom: 4, top: 16),
                  child: Text(
                    "Featured Image".tr,
                    style: TextStyle(fontFamily: "inter", fontSize: 14),
                  ),
                ),
                if (Provider.of<EventProvider>(context, listen: false)
                        .featuredImage !=
                    null)
                  Container(
                    width: double.infinity,
                    child: Image.file(
                      File(Provider.of<EventProvider>(context, listen: false)
                          .featuredImage!
                          .path),
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
                          await eventProvider.contentController.getText();
                      log('$contentSend sennndd');

                      if (contentSend.isEmpty) {
                        return showErrorToast("content can't be empty".tr);
                      }

                      if (eventProvider.bannerImage == null ||
                          eventProvider.featuredImage == null ||
                          eventProvider.galleryImages.isEmpty) {
                        return showErrorToast(
                            "please select all type of image".tr);
                      }

                      // if (eventProvider.faqList.isEmpty) {
                      //   return showErrorToast("please select atleast one faq");
                      // }

                      Navigator.push(
                        // ignore: use_build_context_synchronously
                        context,
                        MaterialPageRoute(
                            builder: (context) => EventLocationScreenTwo(
                                  title: Provider.of<EventProvider>(context,
                                          listen: false)
                                      .titleController
                                      .text,
                                  content: contentSend,
                                  youtubeVideoText: Provider.of<EventProvider>(
                                          context,
                                          listen: false)
                                      .youtubeVideoController
                                      .text,
                                  faqList: Provider.of<EventProvider>(context,
                                          listen: false)
                                      .faqList,
                                  bannerimage: Provider.of<EventProvider>(
                                                  context,
                                                  listen: false)
                                              .bannerImage !=
                                          null
                                      ? File(Provider.of<EventProvider>(context,
                                              listen: false)
                                          .bannerImage!
                                          .path)
                                      : null,
                                  featuredimage: Provider.of<EventProvider>(
                                                  context,
                                                  listen: false)
                                              .featuredImage !=
                                          null
                                      ? File(Provider.of<EventProvider>(context,
                                              listen: false)
                                          .featuredImage!
                                          .path)
                                      : null,
                                  pickedImagefile: Provider.of<EventProvider>(
                                          context,
                                          listen: false)
                                      .galleryImages
                                      .map((e) => File(e.path))
                                      .toList(),
                                  duration: Provider.of<EventProvider>(context,
                                          listen: false)
                                      .durationController
                                      .text,
                                  startTime: Provider.of<EventProvider>(context,
                                          listen: false)
                                      .startTimeController
                                      .text,
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
    );
  }
}
