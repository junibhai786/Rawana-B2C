import 'dart:developer';
import 'dart:io';

import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Provider/hotel_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/vendor/hotel/edit/edit_hotel_two_screen.dart';

import 'package:moonbnd/widgets/elevatedbuttonicon.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:html_editor_plus/html_editor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditHotelScreen extends StatefulWidget {
  String id;
  EditHotelScreen({super.key, this.id = ""});
  @override
  // ignore: library_private_types_in_public_api
  _SpaceOneScreenState createState() => _SpaceOneScreenState();
}

class _SpaceOneScreenState extends State<EditHotelScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  // Variables to store form data
  TextEditingController titleController = TextEditingController();
  // TextEditingController contentController = TextEditingController();
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
    // TODO: implement initState
    super.initState();

    setState(() {
      isLoading = true;
    });

    log(widget.id);

    Provider.of<VendorHotelProvider>(context, listen: false)
        .fetchallhoteldetailvendor(widget.id)
        .then((value) {
      update();
      setState(() {
        isLoading = false;
      });
    });
  }

  void update() {
    final spaceProvider =
        Provider.of<VendorHotelProvider>(context, listen: false);
    titleController = TextEditingController(
        text: spaceProvider.hotellistdetails?.data?[0].title);
    Future.delayed(Duration(seconds: 3)).then((value) {
      contentController
          .setText(spaceProvider.hotellistdetails?.data?[0].content ?? "");
      log('content hotel${spaceProvider.hotellistdetails?.data?[0].content ?? ''}');
    });

    spaceProvider.selectpassanger =
        "${spaceProvider.hotellistdetails?.data?[0].starRate}";

    spaceProvider.hotelreleatedid = TextEditingController(
        text: "${spaceProvider.hotellistdetails?.data?[0].relatedIds}");

    spaceProvider.isShowPassword =
        spaceProvider.hotellistdetails?.data?[0].enableExtraPrice == "0"
            ? false
            : true;

    youtubeVideoController = TextEditingController(
        text: spaceProvider.hotellistdetails?.data?[0].video);
    spaceProvider.hotellistdetails?.data?[0].policy?.forEach((element) {
      return faqList.add(FaqClass(
        id: DateTime.now().add(Duration(seconds: 5)),
        content: TextEditingController(text: element.content),
        title: TextEditingController(text: element.title),
      ));
    });
    bannerImageInput =
        spaceProvider.hotellistdetails?.data?[0].bannerImage ?? "";

    spaceProvider.hotellistdetails?.data?[0].gallery?.forEach((element) {
      return galleryImageInput.add(element);
    });

    // noOfBedController = TextEditingController(
    //     text: "${spaceProvider.hotellistdetails?.data?[0].starRate}");
    // noOfBathroomController = TextEditingController(
    //     text: "${spaceProvider.hotellistdetails?.data?[0].related?[0].id}");
    minimumAdvanceReservationController = TextEditingController(
        text:
            "${spaceProvider.hotellistdetails?.data?[0].minDayBeforeBooking}");
    // minimumDayStayController = TextEditingController(
    //     text: "${spaceProvider.hotellistdetails?.data?[0].related?[0].id}");

    featureImageInput = spaceProvider.hotellistdetails?.data?[0].image ?? "";

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
    setState(() {
      galleryImages.addAll(images);
    });
  }

  @override
  Widget build(BuildContext context) {
    final spaceProvider =
        Provider.of<VendorHotelProvider>(context, listen: true);
    log("${faqList.length} length");
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: InkWell(
              onTap: () {
                final provider =
                    Provider.of<VendorHotelProvider>(context, listen: false);
                Provider.of<VendorHotelProvider>(context, listen: false)
                    .titlecontroller
                    .clear();

                Provider.of<VendorHotelProvider>(context, listen: false)
                    .youtubecontroller
                    .clear();
                provider.selectpassanger = "";
                Provider.of<VendorHotelProvider>(context, listen: false)
                    .bannerimage = null;
                Provider.of<VendorHotelProvider>(context, listen: false)
                    .featuredimage = null;
                Provider.of<VendorHotelProvider>(context, listen: false)
                    .pickedImagefile
                    .clear();
                provider.selectpassanger = null;
                provider.isShowPassword = false;
                provider.timechecincontroller.clear();
                provider.timechecoutcontroller.clear();
                provider.selectreservations = null;
                provider.selectrequirements = null;

                provider.edu = [];
                provider.health = [];

                provider.latitude = null;
                provider.longitude = null;
                provider.transform = [];
                provider.addresscontroller.text = '';
                provider.addresscontroller = TextEditingController();
                provider.price = [];
                provider.selectedpropertytypeIds = [];
                provider.selectedfacilitytypeIds = [];
                provider.selectedservicetypeIds = [];
                // Clear location data
                Provider.of<VendorHotelProvider>(context, listen: false)
                    .locationid = null;
                Provider.of<VendorHotelProvider>(context, listen: false)
                    .addresscontroller
                    .clear();

                // Clear pricing data
                Provider.of<VendorHotelProvider>(context, listen: false)
                    .pricecontroller
                    .clear();

                // Clear lists
                Provider.of<VendorHotelProvider>(context, listen: false)
                    .faq
                    .clear();

                provider.hotelreleatedid.clear();

                provider.faq = [];

                Provider.of<VendorHotelProvider>(context, listen: false)
                    .edu
                    .clear();
                Provider.of<VendorHotelProvider>(context, listen: false)
                    .health
                    .clear();
                Provider.of<VendorHotelProvider>(context, listen: false)
                    .transform
                    .clear();

                // Clear selected IDs
                Provider.of<VendorHotelProvider>(context, listen: false)
                    .selectedfacilitytypeIds
                    .clear();

                // Reset other controllers
                Provider.of<VendorHotelProvider>(context, listen: false)
                    .minimumcontroller
                    .clear();
                Provider.of<VendorHotelProvider>(context, listen: false)
                    .minimumdaystaycontroller
                    .clear();
                setState(() {});
                Navigator.of(context).pop();
              },
              child: Icon(Icons.arrow_back)),
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
                          "Update Hotel".tr,
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
                          "Hotel Content".tr,
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
                        controller: contentController,
                        htmlEditorOptions: HtmlEditorOptions(
                          hint: "Your text here...",
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
                        controller: youtubeVideoController,
                        hintText: "Youtube Video".tr,
                      ),
                      // FAQ section
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
                        text: 'Upload Image'.tr,
                        press: () => pickImageGalleryImage(),
                      ),

                      Divider(
                        thickness: 2,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10, top: 10),
                        child: Text(
                          "Hotel Policy".tr,
                          style: TextStyle(
                              fontFamily: "inter",
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      // Extra Info
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 2, bottom: 4),
                      //   child: Text(
                      //     "Hotel Rating Standard".tr,
                      //     style: TextStyle(fontFamily: "inter", fontSize: 14),
                      //   ),
                      // ),

                      // SizedBox(height: 10),
                      // CustomTextField(
                      //   margin: false,
                      //   controller: noOfBedController,
                      //   hintText: 'Ex: 3',
                      // ),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 10, right: 10, bottom: 5),
                        child: Text('Hotel Rating Standard'.tr,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w400)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: spaceProvider
                                    .selectpassanger, // Current selected value
                                hint: Text("Ex :1".tr), // Placeholder text
                                onChanged: (String? newValue) {
                                  setState(() {
                                    spaceProvider.selectpassanger =
                                        newValue; // Update the selected value
                                  });
                                },
                                items: <String>[
                                  '1',
                                  '2',
                                  '3',
                                  '4',
                                  '5'
                                ] // Dropdown items
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 4),
                        child: Text(
                          "Policy".tr,
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
                          SizedBox(width: 20),
                        ],
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
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 2, bottom: 4, top: 16),
                        child: Text(
                          "Hotel related IDs".tr,
                          style: TextStyle(fontFamily: "inter", fontSize: 14),
                        ),
                      ),
                      CustomTextField(
                        margin: false,
                        controller: spaceProvider.hotelreleatedid,
                        txKeyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        hintText: 'Ex: 2',
                      ),

                      // Featured Image Upload

                      SizedBox(height: 20),
                      TertiaryButton(
                        press: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();

                            String contentSend =
                                await contentController.getText();

                            if (contentSend.isEmpty) {
                              return showErrorToast("Please write content");
                            }
                            if (spaceProvider.selectpassanger == null) {
                              return showErrorToast(
                                  "Please select hotel rating");
                            }

                            // log("${spaceProvider.featuredimage}");
                            // log(featureImageInput);
                            // log("${spaceProvider.bannerimage}");
                            // log(bannerImageInput);
                            // log("${spaceProvider.pickedImagefile.length}");
                            // log("${galleryImageInput.length}");

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

                            if (faqList.isEmpty) {
                              return showErrorToast(
                                  "Please select atleast one policy");
                            }

                            Navigator.push(
                              // ignore: use_build_context_synchronously
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      EditHotelLocationScreenState(
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
