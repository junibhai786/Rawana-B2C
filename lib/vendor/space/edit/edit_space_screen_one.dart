import 'dart:developer';
import 'dart:io';

import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Provider/space_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/vendor/space/edit/edit_space_screen_two.dart';
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
class EditSpaceOneScreen extends StatefulWidget {
  String id;
  EditSpaceOneScreen({super.key, this.id = ""});
  @override
  // ignore: library_private_types_in_public_api
  _SpaceOneScreenState createState() => _SpaceOneScreenState();
}

class _SpaceOneScreenState extends State<EditSpaceOneScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  // Variables to store form data
  TextEditingController titleController = TextEditingController();
  HtmlEditorController contentController = HtmlEditorController();
  TextEditingController youtubeVideoController = TextEditingController();
  List<FaqClass> faqList = [];
  XFile? bannerImage;
  XFile? featuredImage;
  List<XFile> galleryImages = [];
  TextEditingController noOfBedController = TextEditingController();
  TextEditingController noOfBathroomController = TextEditingController();
  TextEditingController minimumAdvanceReservationController =
      TextEditingController();
  TextEditingController minimumDayStayController = TextEditingController();
// Variables already exist
  String bannerImageInput = "";
  List<String> galleryImageInput = [];
  String featureImageInput = "";

  @override
  void initState() {
    super.initState();

    initialFun();
  }

  Future initialFun() async {
    setState(() {
      isLoading = true;
    });
    await Provider.of<SpaceProvider>(context, listen: false).fetchFacilites();
    // ignore: use_build_context_synchronously
    await Provider.of<SpaceProvider>(context, listen: false).fetchSpaceType();
    // ignore: use_build_context_synchronously
    await Provider.of<SpaceProvider>(context, listen: false)
        .fetchSpaceDetailsEditById(widget.id);
    update();
    setState(() {
      isLoading = false;
    });
  }

  void update() {
    final spaceProvider = Provider.of<SpaceProvider>(context, listen: false);

    titleController = TextEditingController(
        text: spaceProvider.spaceDetailsVendor?.data[0].title);

    // WidgetsBinding.instance.addPostFrameCallback((cal){

    // })

    Future.delayed(Duration(seconds: 3)).then((calue) {
      contentController
          .setText(spaceProvider.spaceDetailsVendor!.data[0].content);
    });

    youtubeVideoController = TextEditingController(
        text: spaceProvider.spaceDetailsVendor?.data[0].video);
    spaceProvider.spaceDetailsVendor?.data[0].faqs?.forEach((element) {
      return faqList.add(FaqClass(
        id: DateTime.now().add(Duration(seconds: 5)),
        content: TextEditingController(text: element.title),
        title: TextEditingController(text: element.name),
      ));
    });
    bannerImageInput =
        spaceProvider.spaceDetailsVendor?.data[0].bannerImage ?? "";

    spaceProvider.spaceDetailsVendor?.data[0].gallery.forEach((element) {
      return galleryImageInput.add(element);
    });

    noOfBedController = TextEditingController(
        text: "${spaceProvider.spaceDetailsVendor?.data[0].bed}");
    noOfBathroomController = TextEditingController(
        text: "${spaceProvider.spaceDetailsVendor?.data[0].bathroom}");
    minimumAdvanceReservationController = TextEditingController(
        text:
            "${spaceProvider.spaceDetailsVendor?.data[0].min_day_before_booking}");
    minimumDayStayController = TextEditingController(
        text: "${spaceProvider.spaceDetailsVendor?.data[0].min_day_stays}");

    featureImageInput = spaceProvider.spaceDetailsVendor?.data[0].image ?? "";
    if (spaceProvider.spaceDetailsVendor!.data[0].terms.length >= 1) {
      spaceProvider.space?.data?.forEach((element) {
        for (var i = 0;
            i <
                spaceProvider
                    .spaceDetailsVendor!.data[0].terms[0].child!.length;
            i++) {
          if (element.id ==
              spaceProvider.spaceDetailsVendor!.data[0].terms[0].child?[i].id) {
            element.value = true;
          }
        }
      });
    }

    if (spaceProvider.spaceDetailsVendor!.data[0].terms.length == 2) {
      spaceProvider.amenity?.data?.forEach((element) {
        for (var i = 0;
            i <
                spaceProvider
                    .spaceDetailsVendor!.data[0].terms[1].child!.length;
            i++) {
          if (element.id ==
              spaceProvider.spaceDetailsVendor!.data[0].terms[1].child?[i].id) {
            element.value = true;
          }
        }
      });
    }

    setState(() {});

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
    final spaceProvider = Provider.of<SpaceProvider>(context, listen: true);
    log("${faqList.length} length");
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
                          "Update Space".tr,
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
                          text: "Uplaod Image".tr,
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
                        controller: noOfBedController,
                        txKeyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        hintText: 'Ex: 3'.tr,
                      ),

                      Padding(
                        padding:
                            const EdgeInsets.only(left: 2, bottom: 4, top: 16),
                        child: Text(
                          "No. Bathroom".tr,
                          style: TextStyle(fontFamily: "inter", fontSize: 14),
                        ),
                      ),

                      CustomTextField(
                        margin: false,
                        controller: noOfBathroomController,
                        txKeyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        hintText: 'Ex: 5'.tr,
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 2, bottom: 4, top: 16),
                        child: Text(
                          "Minimum Advance Reservations".tr,
                          style: TextStyle(fontFamily: "inter", fontSize: 14),
                        ),
                      ),
                      CustomTextField(
                        margin: false,
                        controller: minimumAdvanceReservationController,
                        txKeyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        hintText: 'Ex: 3',
                      ),

                      Text(
                        "Leave blank if you don't need to use the min day option"
                            .tr,
                        style: TextStyle(fontFamily: "inter", fontSize: 12),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 2, bottom: 4, top: 16),
                        child: Text(
                          "Minimum day stay requirements".tr,
                          style: TextStyle(fontFamily: "inter", fontSize: 14),
                        ),
                      ),
                      CustomTextField(
                        margin: false,
                        controller: minimumDayStayController,
                        txKeyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        hintText: 'Ex: 2'.tr,
                      ),

                      // Featured Image Upload
                      Text(
                        "Leave blank if you don’t need to set minimum day stay option"
                            .tr,
                        style: TextStyle(fontFamily: "inter", fontSize: 12),
                      ),
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

                            if ((featuredImage == null &&
                                    featureImageInput.isEmpty) ||
                                (bannerImage == null &&
                                    bannerImageInput.isEmpty) ||
                                (galleryImages.isEmpty &&
                                    galleryImageInput.isEmpty)) {
                              // Check for hotel related IDs
                              return showErrorToast(
                                  "Please fill all Types of images");
                            }

                            Navigator.push(
                              // ignore: use_build_context_synchronously
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditSpaceTwoScreen(
                                        spaceId: widget.id,
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
                                        minimumDayBeforeBooking:
                                            minimumAdvanceReservationController
                                                .text,
                                        minimumdaystaycontroller:
                                            minimumDayStayController.text,
                                        bed: noOfBedController.text,
                                        bathroom: noOfBathroomController.text,
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
