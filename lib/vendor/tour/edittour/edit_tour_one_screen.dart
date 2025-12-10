import 'dart:developer';
import 'dart:io';

import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Provider/vendor_tour_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/vendor/tour/edittour/edit_tour_location_screen.dart';
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
class EditTourOneScreen extends StatefulWidget {
  String id;
  EditTourOneScreen({super.key, this.id = ""});
  @override
  // ignore: library_private_types_in_public_api
  _EditTourOneScreenState createState() => _EditTourOneScreenState();
}

class _EditTourOneScreenState extends State<EditTourOneScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool isLoading2 = false;

  // Variables to store form data
  TextEditingController titleController = TextEditingController();
  // TextEditingController contentController = TextEditingController();
  HtmlEditorController contentController = HtmlEditorController();
  TextEditingController youtubeVideoController = TextEditingController();
  List<FaqClass> faqList = [];
  List<ItineraryClass> itineraryList = [];
  List<IncludeClass> Include = [];
  List<ExcludeClass> Exclude = [];
  XFile? bannerImage;
  XFile? featuredImage;
  XFile? itineryImage;
  List<XFile> galleryImages = [];
  TextEditingController durationController = TextEditingController();
  TextEditingController minimumPeopleController = TextEditingController();

  TextEditingController minimumAdvanceReservationController =
      TextEditingController();
  TextEditingController maximumPeopleController = TextEditingController();

  // String categoryId = "";
// Variables already exist
  String bannerImageInput = "";
  List<String> galleryImageInput = [];
  String featureImageInput = "";
  String image = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      isLoading = true;
    });
    log(widget.id);
    Provider.of<VendorTourProvider>(context, listen: false)
        .fetchalltourdetailvendor(widget.id)
        .then((value) {
      update();
      setState(() {
        isLoading = false;
      });
    });
    // Clear all previous data
    final provider = Provider.of<VendorTourProvider>(context, listen: false);
    // provider.clearAllData();

    // Fetch categories
    provider.categorytypetourvendor().then((value) {
      setState(() {
        isLoading2 = false;
      });
    });
  }

  void update() {
    final tourProvider =
        Provider.of<VendorTourProvider>(context, listen: false);
    titleController = TextEditingController(
        text: tourProvider.tourlistdetails?.data?[0].title);
    Future.delayed(Duration(seconds: 3)).then((value) {
      contentController
          .setText(tourProvider.tourlistdetails?.data?[0].content ?? "");
      log('content Tour${tourProvider.tourlistdetails?.data?[0].content ?? ''}');
    });
    youtubeVideoController = TextEditingController(
        text: tourProvider.tourlistdetails?.data?[0].video);

    tourProvider.categoryId =
        tourProvider.tourlistdetails?.data?[0].category?.id?.toString() ?? "";

    tourProvider.tourlistdetails?.data?[0].faqs?.forEach((element) {
      return faqList.add(FaqClass(
        id: DateTime.now().add(Duration(seconds: 5)),
        content: TextEditingController(text: element.content),
        title: TextEditingController(text: element.title),
      ));
    });
    bannerImageInput = tourProvider.tourlistdetails?.data?[0].bannerImage ?? "";

    tourProvider.tourlistdetails?.data?[0].gallery?.forEach((element) {
      return galleryImageInput.add(element);
    });

    durationController = TextEditingController(
        text: "${tourProvider.tourlistdetails?.data?[0].duration}");
    minimumPeopleController = TextEditingController(
        text: "${tourProvider.tourlistdetails?.data?[0].minPeople}");
    minimumAdvanceReservationController = TextEditingController(
        text: "${tourProvider.tourlistdetails?.data?[0].minDayBeforeBooking}");
    maximumPeopleController = TextEditingController(
        text: "${tourProvider.tourlistdetails?.data?[0].maxPeople}");

    featureImageInput = tourProvider.tourlistdetails?.data?[0].image ?? "";
    tourProvider.tourlistdetails?.data?[0].include?.forEach((element) {
      return Include.add(IncludeClass(
          id: DateTime.now(),
          title: TextEditingController(text: element.title)));
    });
    tourProvider.tourlistdetails?.data?[0].exclude?.forEach((element) {
      return Exclude.add(ExcludeClass(
          id: DateTime.now(),
          title: TextEditingController(text: element.title)));
    });
    tourProvider.tourlistdetails?.data?[0].itinerary?.forEach((element) {
      itineraryList.add(ItineraryClass(
        id: DateTime.now(),
        title: TextEditingController(text: element.title),
        desc: TextEditingController(text: element.desc),
        content: TextEditingController(text: element.content),
        imageId: element.imageId,
        image: element.image, // Add image URL
      ));

      // Log the details of each itinerary
      log("Title: ${element.title}");
      log("Description: ${element.desc}");
      log("Content: ${element.content}");
      log("Image Path: ${element.image}");
    });

    // Log the full itinerary list
    log("Itinerary List: ${tourProvider.tourlistdetails?.data?[0].itinerary}");

    log("message${tourProvider.tourlistdetails?.data?[0].itinerary}");

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

  void addInclude() {
    Include.add(
        IncludeClass(id: DateTime.now(), title: TextEditingController()));

    setState(() {});
  }

  void deleteInclude(DateTime? id) {
    Include.removeWhere((test) {
      return test.id == id;
    });

    setState(() {});
  }

  void addExclude() {
    Exclude.add(
        ExcludeClass(id: DateTime.now(), title: TextEditingController()));

    setState(() {});
  }

  void deleteExclude(DateTime? id) {
    Exclude.removeWhere((test) {
      return test.id == id;
    });

    setState(() {});
  }

  void addItinerary() async {
    final tourProvider =
        Provider.of<VendorTourProvider>(context, listen: false);
    String? imageId;

    // final picker = ImagePicker();
    // final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    // if (pickedImage != null) {
    //   imageId = await tourProvider.uploadImage(File(pickedImage.path));
    // }

    itineraryList.add(ItineraryClass(
      id: DateTime.now(),
      title: TextEditingController(),
      desc: TextEditingController(),
      content: TextEditingController(),
      imageId: imageId,
      // image: pickedImage?.path,
    ));

    setState(() {});
  }

  void deleteItinerary(DateTime? id) {
    itineraryList.removeWhere((test) {
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
    final tourProvider = Provider.of<VendorTourProvider>(context, listen: true);

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
                          "Update Tour".tr,
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
                          "Tour Content".tr,
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
                      // CustomTextField(
                      //   controller: contentController,
                      //   maxCheck: 5,
                      //   hintText: "Special Requirment".tr,
                      // ),
                      // Youtube Video Input

                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 4),
                        child: Text(
                          "Category".tr,
                          style: TextStyle(fontFamily: "inter", fontSize: 14),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: Text("Select Category".tr),
                              value: tourProvider.categoryId,
                              items: tourProvider.categories?.data
                                      ?.map((category) {
                                    return DropdownMenuItem<String>(
                                      value: category.id.toString(),
                                      child: Text(category.name ?? ""),
                                    );
                                  }).toList() ??
                                  [],
                              onChanged: (String? value) {
                                if (value != null) {
                                  setState(() {
                                    tourProvider.categoryId = value;
                                    log("Category ID: ${tourProvider.categoryId}");
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ),
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
                        // validator: (value) {
                        //   if (value == null || value.isEmpty) {
                        //     return 'Please enter Youtube Video'.tr;
                        //   }
                        //   return null;
                        // },
                      ),
                      // Extra Info
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 4),
                        child: Text(
                          "Minimum Advance Reservation".tr,
                          style: TextStyle(fontFamily: "inter", fontSize: 14),
                        ),
                      ),
                      SizedBox(height: 10),
                      CustomTextField(
                        margin: true,
                        controller: minimumAdvanceReservationController,
                        hintText: 'Ex: 3'.tr,
                        txKeyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Minimum Advance Reservations'
                                .tr;
                          }
                          return null;
                        },
                      ),

                      Padding(
                        padding:
                            const EdgeInsets.only(left: 10, bottom: 4, top: 16),
                        child: Text(
                          "Duration (hour)".tr,
                          style: TextStyle(fontFamily: "inter", fontSize: 14),
                        ),
                      ),

                      CustomTextField(
                        margin: true,
                        controller: durationController,
                        hintText: 'Ex: 5'.tr,
                        txKeyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp("[0-9\:]")),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Duration'.tr;
                          }
                          return null;
                        },
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 10, bottom: 4, top: 16),
                        child: Text(
                          "Tour Min People".tr,
                          style: TextStyle(fontFamily: "inter", fontSize: 14),
                        ),
                      ),
                      CustomTextField(
                        margin: true,
                        controller: minimumPeopleController,
                        hintText: 'Ex: 3'.tr,
                        txKeyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Min Tour People'.tr;
                          }
                          return null;
                        },
                      ),

                      Padding(
                        padding:
                            const EdgeInsets.only(left: 10, bottom: 4, top: 16),
                        child: Text(
                          "Tour Max People".tr,
                          style: TextStyle(fontFamily: "inter", fontSize: 14),
                        ),
                      ),
                      CustomTextField(
                        margin: true,
                        controller: maximumPeopleController,
                        hintText: 'Ex: 2'.tr,
                        txKeyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Max Tour People'.tr;
                          }
                          return null;
                        },
                      ),

                      // Featured Image Upload
                      SizedBox(
                        height: 10,
                      ),

                      SizedBox(
                        height: 8,
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
                      SizedBox(
                        height: 8,
                      ),
                      // FAQ section
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 4),
                        child: Text(
                          "Include".tr,
                          style: TextStyle(fontFamily: "inter", fontSize: 14),
                        ),
                      ),

                      ...(Include).map((element) {
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
                            Container(
                              margin: EdgeInsets.only(left: 20),
                              decoration: BoxDecoration(
                                color: Colors.red, // Red background color
                                borderRadius: BorderRadius.circular(
                                    12), // Slightly rounded corners
                              ),
                              child: IconButton(
                                onPressed: () {
                                  deleteInclude(element.id);
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
                                addInclude();
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
                      SizedBox(
                        height: 8,
                      ),
                      // FAQ section
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 4),
                        child: Text(
                          "Exclude".tr,
                          style: TextStyle(fontFamily: "inter", fontSize: 14),
                        ),
                      ),

                      ...(Exclude).map((element) {
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
                            Container(
                              margin: EdgeInsets.only(left: 20),
                              decoration: BoxDecoration(
                                color: Colors.red, // Red background color
                                borderRadius: BorderRadius.circular(
                                    12), // Slightly rounded corners
                              ),
                              child: IconButton(
                                onPressed: () {
                                  deleteExclude(element.id);
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
                                addExclude();
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
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 4),
                        child: Text(
                          "Itinerary".tr,
                          style: TextStyle(fontFamily: "inter", fontSize: 14),
                        ),
                      ),
                      ...(itineraryList).map((element) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 10, left: 16, top: 10),
                                  child: Text(
                                    "Image".tr,
                                    style: TextStyle(
                                        fontFamily: "inter", fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            Provider.of<VendorTourProvider>(context,
                                                listen: true)
                                            .itineraryImagefile
                                            .length >
                                        itineraryList.indexOf(element) &&
                                    Provider.of<VendorTourProvider>(context,
                                            listen: true)
                                        .itineraryImagefile[
                                            itineraryList.indexOf(element)]
                                        .path
                                        .isNotEmpty
                                ? SizedBox(
                                    width: double.infinity,
                                    child: Image.file(
                                      Provider.of<VendorTourProvider>(context,
                                                  listen: false)
                                              .itineraryImagefile[
                                          itineraryList.indexOf(element)],
                                      height: 150,
                                      width: 200,
                                      fit: BoxFit.fill,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          height: 150,
                                          width: 200,
                                          color: Colors.grey[300],
                                          child: Icon(Icons.error),
                                        );
                                      },
                                    ),
                                  )
                                : element.image != null &&
                                        element.image!.isNotEmpty
                                    ? Column(
                                        children: element.image!
                                            .split(',')
                                            .map((imagePath) {
                                          return SizedBox(
                                            width: double.infinity,
                                            child: Image.network(
                                              imagePath.trim(),
                                              height: 150,
                                              width: 200,
                                              fit: BoxFit.fill,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Container(
                                                  height: 150,
                                                  width: 200,
                                                  color: Colors.grey[300],
                                                  child: Center(
                                                      child:
                                                          CircularProgressIndicator(color: kSecondaryColor)),
                                                );
                                              },
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  height: 150,
                                                  width: 200,
                                                  color: Colors.grey[300],
                                                  child: Icon(Icons.error),
                                                );
                                              },
                                            ),
                                          );
                                        }).toList(),
                                      )
                                    : SizedBox(),
                            SizedBox(height: 20),
                            // Upload Button
                            SizedBox(
                              width: 300,
                              child: TextIconButtom(
                                icon: Icon(
                                  Icons.upload,
                                  color: Colors.white,
                                ),
                                press: () async {
                                  var result =
                                      await Provider.of<VendorTourProvider>(
                                              context,
                                              listen: false)
                                          .pickitineraryimage(
                                              itineraryList.indexOf(element));
                                  if (result.isNotEmpty) {
                                    itineraryList[
                                            itineraryList.indexOf(element)]
                                        .imageId = result['imageId'];
                                    itineraryList[
                                            itineraryList.indexOf(element)]
                                        .image = result['image'];
                                  }
                                },
                                text: "Upload Image".tr,
                              ),
                            ),

                            SizedBox(height: 10),
                            CustomTextField(
                              controller: element.title,
                              hintText: 'Title'.tr,
                            ),
                            CustomTextField(
                              controller: element.desc,
                              hintText: 'Description'.tr,
                            ),
                            CustomTextField(
                              controller: element.content,
                              hintText: 'Content'.tr,
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 20),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  deleteItinerary(element.id);
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
                                addItinerary();
                              },
                              icon: Icon(Icons.upload),
                              text: 'Add Item'.tr,
                            ),
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
                        height: 10,
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
                              bool check = await tourProvider.deleteImage(
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
                          // Add logging statements before navigation

                          print(
                              'itineryimage ids: ${itineraryList.map((itinerary) => itinerary.imageId).join(', ')}');
                          log('minpeople: ${minimumPeopleController.text}');
                          log('maxpeople: ${maximumPeopleController.text}');

                          if (
                              // featuredImage == null ||
                              //       bannerImage == null ||
                              //       galleryImages.isEmpty ||
                              titleController.text.isEmpty || // Check for title
                                  await contentController.getText() ==
                                      "" || // Check for content
                                  // youtubeVideoController.text.isEmpty
                                  //  ||
                                  minimumAdvanceReservationController
                                      .text.isEmpty ||
                                  durationController.text.isEmpty ||
                                  minimumPeopleController.text.isEmpty ||
                                  maximumPeopleController
                                      .text.isEmpty // Check for YouTube video
                              /*provider.hotelreleatedid.text.isEmpty*/) {
                            // Check for hotel related IDs
                            showErrorToast(
                                "Please fill all fields and upload all images"
                                    .tr);
                          } else {
                            String contentSend =
                                await contentController.getText();
                            log('$contentSend sennndd');
                            Navigator.push(
                              // ignore: use_build_context_synchronously

                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditTourLocationScreen(
                                        tourId: widget.id,
                                        categoryId:
                                            tourProvider.categoryId ?? '',
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
                                        minimumPeople:
                                            minimumPeopleController.text,
                                        maximumPeople:
                                            maximumPeopleController.text,
                                        itineraryList: itineraryList,
                                        duration: durationController.text,
                                        Include: Include,
                                        Exclude: Exclude,
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
