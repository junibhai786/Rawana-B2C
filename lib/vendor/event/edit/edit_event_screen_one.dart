import 'dart:developer';
import 'dart:io';

import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Provider/event_provider.dart';
import 'package:moonbnd/Provider/space_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/vendor/event/edit/edit_event_screen_two.dart';
import 'package:moonbnd/widgets/elevatedbuttonicon.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:html_editor_plus/html_editor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class EventEditOneScreen extends StatefulWidget {
  String id;
  EventEditOneScreen({super.key, this.id = ""});
  @override
  _SpaceOneScreenState createState() => _SpaceOneScreenState();
}

class _SpaceOneScreenState extends State<EventEditOneScreen> {
  final _formKey = GlobalKey<FormState>();
  HtmlEditorController contentController = HtmlEditorController();

  // Variables to store form data
  TextEditingController titleController = TextEditingController();

  TextEditingController youtubeVideoController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  List<FaqClass> faqList = [];
  XFile? bannerImage;
  XFile? featuredImage;
  List<XFile> galleryImages = [];
  bool isLoading = false;
  String bannerImageInput = "";
  List<String> galleryImageInput = [];
  String featureImageInput = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      isLoading = true;
    });

    log(widget.id);

    Provider.of<EventProvider>(context, listen: false)
        .fetchEventDetailsEditById(widget.id)
        .then((value) {
      update();
      setState(() {
        isLoading = false;
      });
    });
  }

  void update() {
    final spaceProvider = Provider.of<EventProvider>(context, listen: false);
    titleController = TextEditingController(
        text: spaceProvider.eventDetailsVendor?.data[0].title);

    Future.delayed(Duration(seconds: 3)).then((calue) {
      contentController
          .setText(spaceProvider.eventDetailsVendor!.data[0].content);
    });

    youtubeVideoController = TextEditingController(
        text: spaceProvider.eventDetailsVendor?.data[0].video);
    startTimeController = TextEditingController(
        text: spaceProvider.eventDetailsVendor?.data[0].startTime);
    durationController = TextEditingController(
        text: spaceProvider.eventDetailsVendor?.data[0].duration);
    spaceProvider.eventDetailsVendor?.data[0].faqs.forEach((element) {
      return faqList.add(FaqClass(
        id: DateTime.now().add(Duration(seconds: 5)),
        content: TextEditingController(text: element.content),
        title: TextEditingController(text: element.title),
      ));
    });
    bannerImageInput =
        spaceProvider.eventDetailsVendor?.data[0].bannerImage ?? "";

    spaceProvider.eventDetailsVendor?.data[0].gallery.forEach((element) {
      return galleryImageInput.add(element);
    });

    featureImageInput = spaceProvider.eventDetailsVendor?.data[0].image ?? "";

    setState(() {});
  }

  void addFaq() {
    faqList.add(FaqClass(
        id: DateTime.now(),
        content: TextEditingController(),
        title: TextEditingController()));

    setState(() {});
  }

  void deleteFaq(DateTime? id) {
    faqList.removeWhere((test) {
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
          featuredImage = images;
        });
      }
    } else {
      if (images != null) {
        setState(() {
          bannerImage = images;
        });
      }
    }
  }

  Future<void> pickImageGalleryImage() async {
    final picker = ImagePicker();

    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        galleryImages.addAll(images);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final spaceProvider = Provider.of<EventProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: kSecondaryColor))
          : Form(
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
                          "Edit New Event".tr,
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
                        controller: titleController,
                        hintText: "Title".tr,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Title'.tr;
                          }
                          return null;
                        },
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
                        controller: contentController, //required
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
                        controller: youtubeVideoController,
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
                        controller: startTimeController,
                        hintText: "Start Time".tr,
                        txKeyboardType:
                            TextInputType.numberWithOptions(signed: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[0-9:]+')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select Start Time'.tr;
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
                        controller: durationController,
                        txKeyboardType:
                            TextInputType.numberWithOptions(signed: true),
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

                      ...(faqList).map((element) {
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
                      bannerImage != null
                          ? Container(
                              width: double.infinity,
                              child: Image.file(
                                File(bannerImage!.path),
                                height: 150,
                                width: 200,
                                fit: BoxFit.fill,
                              ),
                            )
                          : Container(
                              width: double.infinity,
                              child: Image.network(
                                bannerImageInput,
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

                      if (galleryImages.isNotEmpty)
                        ...(galleryImages).map((element) {
                          return InkWell(
                            onTap: () {
                              galleryImages.removeWhere((test) {
                                return test == element;
                              });
                              setState(() {});
                            },
                            child: Stack(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  width: double.infinity,
                                  child: Image.file(
                                    File(element.path),
                                    height: 150,
                                    width: 200,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  child: Container(
                                    color: Colors.white,
                                    child:
                                        Icon(Icons.cancel, color: Colors.red),
                                  ),
                                )
                              ],
                            ),
                          );
                        }),

                      if (galleryImageInput.isNotEmpty)
                        ...(galleryImageInput).map((element) {
                          return InkWell(
                            onTap: () async {
                              log("message");
                              bool check = await spaceProvider.deleteImage(
                                  element, widget.id);

                              if (check) {
                                galleryImageInput.removeWhere((test) {
                                  return test == element;
                                });
                                setState(() {});
                              }
                            },
                            child: Stack(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  width: double.infinity,
                                  child: Image.network(
                                    element,
                                    height: 150,
                                    width: 200,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  child: Container(
                                    color: Colors.white,
                                    child:
                                        Icon(Icons.cancel, color: Colors.red),
                                  ),
                                )
                              ],
                            ),
                          );
                        }),

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
                        padding:
                            const EdgeInsets.only(left: 2, bottom: 4, top: 16),
                        child: Text(
                          "Featured Image".tr,
                          style: TextStyle(fontFamily: "inter", fontSize: 14),
                        ),
                      ),
                      featuredImage != null
                          ? Container(
                              width: double.infinity,
                              child: Image.file(
                                File(featuredImage!.path),
                                height: 150,
                                width: 200,
                                fit: BoxFit.fill,
                              ),
                            )
                          : Container(
                              width: double.infinity,
                              child: Image.network(
                                featureImageInput,
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
                                await contentController.getText();
                            log('$contentSend sennndd');

                            if (contentSend.isEmpty) {
                              return showErrorToast(
                                  "content can't be empty".tr);
                            }

                            if ((featuredImage == null &&
                                    featureImageInput.isEmpty) ||
                                (bannerImage == null &&
                                    bannerImageInput.isEmpty) ||
                                (galleryImages.isEmpty &&
                                    galleryImageInput.isEmpty)) {
                              // Check for hotel related IDs
                              return showErrorToast(
                                  "Please fill all Types of images".tr);
                            }

                            log('$contentSend sennndd');
                            Navigator.push(
                              // ignore: use_build_context_synchronously
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditEventTwoScreen(
                                        id: widget.id,
                                        title: titleController.text,
                                        content: contentSend,
                                        youtubeVideoText:
                                            youtubeVideoController.text,
                                        faqList: faqList,
                                        bannerimage: bannerImage != null
                                            ? File(bannerImage!.path)
                                            : null,
                                        featuredimage: featuredImage != null
                                            ? File(featuredImage!.path)
                                            : null,
                                        pickedImagefile: galleryImages
                                            .map((e) => File(e.path))
                                            .toList(),
                                        duration: durationController.text,
                                        startTime: startTimeController.text,
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
