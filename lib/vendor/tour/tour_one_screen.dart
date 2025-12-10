import 'dart:developer';
import 'dart:io';

import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Provider/vendor_tour_provider.dart';
import 'package:moonbnd/vendor/tour/tour_location_screen.dart';
import 'package:moonbnd/widgets/addimagecomponent.dart';
import 'package:moonbnd/widgets/elevatedbuttonicon.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:html_editor_plus/html_editor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class TourOneScreen extends StatefulWidget {
  final String? id;

  TourOneScreen({this.id});

  @override
  _TourOneScreenState createState() => _TourOneScreenState();
}

class FAQ {
  String? title;
  String? content;

  FAQ({this.title, this.content});
}

class _TourOneScreenState extends State<TourOneScreen> {
  final _formKey = GlobalKey<FormState>();

  // Variables to store form data
  String? title;
  String? content;
  String? youtubeVideo;
  String? faqTitle;
  String? faqContent;

  // Image picker function
  // Future<void> pickImage(ImageSource source, bool isGallery) async {
  //   final picker = ImagePicker();
  //   if (isGallery) {
  //     final images = await picker.pickMultiImage();
  //     if (images.isNotEmpty) {
  //       setState(() {
  //         galleryImages = images;
  //       });
  //     }
  //   } else {
  //     final pickedFile = await picker.pickImage(source: source);
  //     if (pickedFile != null) {
  //       setState(() {
  //         bannerImage = pickedFile;
  //       });
  //     }
  //   }
  // }

  bool loading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      loading = true;
    });

    // Clear all previous data
    final provider = Provider.of<VendorTourProvider>(context, listen: false);
    final item = Provider.of<VendorTourProvider>(context, listen: false);
    // provider.clearAllData();

    // Fetch categories
    provider.categorytypetourvendor().then((value) {
      item.titlecontroller.clear();
      item.contentcontroller.clear();
      item.youtubecontroller.clear();
      provider.maxpeoplecontroller = TextEditingController();
      provider.categoryId = null;

      item.enablePersonTypes = false;
      provider.personTypes = [];
      provider.enableExtraPrice = false;
      provider.extraPrices = [];

      item.bannerimage = null;
      item.featuredimage = null;
      item.pickedImagefile.clear();

      item.edu = [];
      item.health = [];
      provider.durationcontroller = TextEditingController();
      item.transform = [];
      item.addresscontroller.text = '';
      item.addresscontroller = TextEditingController();

      provider.selectedfacilitytypeIds = [];

      // Clear location data
      item.locationid = null;
      item.addresscontroller.clear();

      // Clear pricing data
      item.pricecontroller.clear();

      // Clear lists
      item.faq.clear();

      provider.faq = [];

      item.edu.clear();
      item.health.clear();
      item.transform.clear();

      // Clear selected IDs
      item.selectedfacilitytypeIds.clear();

      // Reset other controllers
      item.minimumcontroller.clear();
      item.minimumdaystaycontroller.clear();
      // Clear all the controllers and data

      item.youtubecontroller.clear();
      item.bannerimage = null;
      item.featuredimage = null;
      item.pickedImagefile.clear();

      item.itineraryImageIds.clear();
      item.itineraryImagefile.clear();
      item.categoryId = null;
      // Clear location data

      item.mapLat = null;
      item.mapLng = null;
      item.mapZoom = null;
      item.addresscontroller = TextEditingController();

      // Clear pricing data
      item.pricecontroller.clear();
      item.salePricecontroller.clear();

      // Clear lists
      item.faq.clear();
      item.includes.clear();
      item.excludes.clear();
      item.itinerary.clear();
      provider.itineraryImagefile = [];
      item.edu.clear();
      item.health.clear();
      item.transform.clear();

      // Clear selected IDs
      item.selectedtraveltypeIds.clear();
      item.selectedfacilitytypeIds.clear();

      // Reset other controllers
      item.minimumcontroller.clear();
      item.minimumdaystaycontroller.clear();
      item.icalimporturlcontroller.clear();
      item.durationcontroller.clear();
      item.maxpeoplecontroller.clear();
      setState(() {
        loading = false;
      });
    });
  }

  // Image picker function for itinerary
  // Future<void> pickItineraryImage(int index) async {
  //   final provider = Provider.of<VendorTourProvider>(context, listen: false);
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     await provider.pickitineraryimage(index);
  //   }
  // }

  void _saveAndNext() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final provider = Provider.of<VendorTourProvider>(context, listen: false);

      // Update basic info
      provider.updateBasicInfo(
        categoryId: provider.categories?.data?.first.id.toString() ?? '',
        duration: provider.durationcontroller.text,
        minPeople: provider.minimumcontroller.text,
        maxPeople: provider.maxpeoplecontroller.text,
        youtube: provider.youtubecontroller.text,
        minDayBeforeBooking: provider.minimumdaystaycontroller.text,
      );

      String contentSend = await provider.contentcontroller.getText();

      // Update images

      if (provider.bannerimage == null ||
          provider.featuredimage == null ||
          provider.pickedImagefile.isEmpty) {
        Get.snackbar("Error".tr, "Please fill all types of images".tr);
        return;
      }

      if (contentSend.isEmpty) {
        Get.snackbar("Error".tr, "Please fill content".tr);
        return;
      }
      // if (provider.faq.isEmpty) {
      //   Get.snackbar("Error".tr, "Please add at least one FAQ.".tr);
      //   return;
      // }
      if (provider.includes.isEmpty) {
        Get.snackbar("Error".tr, "Please add at least one Include.".tr);
        return;
      }
      if (provider.excludes.isEmpty) {
        Get.snackbar("Error".tr, "Please add at least one Exclude.".tr);
        return;
      }
      // if (provider.itinerary.isEmpty) {
      //   Get.snackbar("Error", "Please add at least one itinerary.");
      //   return;
      // }
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => TourLocationScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VendorTourProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              // Clear all the controllers and data
            });
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10, bottom: 10),
                  child: Text(
                    "Add New Tour".tr,
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
                  hintText: "Title".tr,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Title'.tr;
                    }
                    return null;
                  },
                  controller: provider.titlecontroller,
                  onChanged: (value) {
                    provider.titlecontroller.text = value;
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
                  controller: provider.contentcontroller, //required

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
                //   maxCheck: 5,
                //   hintText: "Special Requirment".tr,
                //   controller: provider.contentcontroller,
                //   onChanged: (value) {
                //     provider.contentcontroller.text = value;
                //   },
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
                        value: provider.categoryId,
                        items: provider.categories?.data?.map((category) {
                              return DropdownMenuItem<String>(
                                value: category.id.toString(),
                                child: Text(category.name ?? ""),
                              );
                            }).toList() ??
                            [],
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() {
                              provider.categoryId = value;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 4),
                  child: Text(
                    "Minimum Advance Reservations".tr,
                    style: TextStyle(fontFamily: "inter", fontSize: 14),
                  ),
                ),
                CustomTextField(
                  hintText: "Ex.3".tr,
                  txKeyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Please enter Minimum Advance Reservations'.tr;
                  //   }
                  //   return null;
                  // },
                  controller: provider.minimumdaystaycontroller,
                  onChanged: (value) {
                    provider.minimumdaystaycontroller.text = value;
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
                  hintText: "Ex.3".tr,
                  txKeyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Duration'.tr;
                    }
                    return null;
                  },
                  controller: provider.durationcontroller,
                  onChanged: (value) {
                    provider.durationcontroller.text = value;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 4),
                  child: Text(
                    "Tour Min People".tr,
                    style: TextStyle(fontFamily: "inter", fontSize: 14),
                  ),
                ),
                CustomTextField(
                  hintText: "Tour Min People".tr,
                  controller: provider.minimumcontroller,
                  txKeyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Please enter your Min Tour People'.tr;
                  //   }
                  //   return null;
                  // },
                  onChanged: (value) {
                    provider.minimumcontroller.text = value;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 4),
                  child: Text(
                    "Tour Max People".tr,
                    style: TextStyle(fontFamily: "inter", fontSize: 14),
                  ),
                ),
                CustomTextField(
                  hintText: "Tour Max People".tr,
                  controller: provider.maxpeoplecontroller,
                  txKeyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Max Tour People'.tr;
                    }
                    return null;
                  },
                  onChanged: (value) {
                    provider.maxpeoplecontroller.text = value;
                  },
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
                  hintText: "Youtube Video".tr,
                  controller: provider.youtubecontroller,
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Please enter Youtube Video'.tr;
                  //   }
                  //   return null;
                  // },
                  onChanged: (value) {
                    provider.youtubecontroller.text = value;
                  },
                ),

                // FAQ section
                Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 4),
                  child: Text(
                    "FAQs".tr,
                    style: TextStyle(fontFamily: "inter", fontSize: 14),
                  ),
                ),
                for (int index = 0; index < provider.faq.length; index++)
                  Column(
                    children: [
                      CustomTextField(
                        controller: TextEditingController(
                            text: provider.faq[index].title),
                        hintText: "Title".tr,
                        onChanged: (value) {
                          provider.faq[index].title = value;
                        },
                      ),
                      CustomTextField(
                        controller: TextEditingController(
                            text: provider.faq[index].content),
                        hintText: "Content".tr,
                        onChanged: (value) {
                          provider.faq[index].content = value;
                          print("faq${provider.faq[index].content}");
                        },
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
                                  provider.removefaq(index);
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
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: TextIconButtom(
                        press: () {
                          setState(() {
                            provider.addfaq();
                          });
                        },
                        icon: Icon(
                          Icons.upload,
                          color: Colors.white,
                        ),
                        text: "Add Item".tr,
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4, left: 10),
                  child: Text(
                    "Include".tr,
                    style: TextStyle(fontFamily: "inter", fontSize: 14),
                  ),
                ),
                for (int index = 0; index < provider.includes.length; index++)
                  Column(
                    children: [
                      CustomTextField(
                        controller: TextEditingController(
                            text: provider.includes[index].title),
                        hintText: 'Title'.tr,
                        onChanged: (value) {
                          provider.includes[index].title = value;
                        },
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
                                  provider.removeinclude(index);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                SizedBox(
                  height: 8,
                ),
                // Banner Image Upload
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: TextIconButtom(
                        press: () {
                          setState(() {
                            provider.addinclude();
                          });
                        },
                        icon: Icon(
                          Icons.upload,
                          color: Colors.white,
                        ),
                        text: "Add Item".tr,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4, left: 10),
                  child: Text(
                    "Exclude".tr,
                    style: TextStyle(fontFamily: "inter", fontSize: 14),
                  ),
                ),
                for (int index = 0; index < provider.excludes.length; index++)
                  Column(
                    children: [
                      CustomTextField(
                        controller: TextEditingController(
                            text: provider.excludes[index].title),
                        hintText: 'Title'.tr,
                        onChanged: (value) {
                          provider.excludes[index].title = value;
                        },
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
                                  provider.removeexclude(index);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                SizedBox(
                  height: 8,
                ),
                // Banner Image Upload
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: TextIconButtom(
                        press: () {
                          setState(() {
                            provider.addexclude();
                          });
                        },
                        icon: Icon(
                          Icons.upload,
                          color: Colors.white,
                        ),
                        text: "Add Item".tr,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, left: 16, top: 10),
                  child: Text(
                    "Itinerary".tr,
                    style: TextStyle(fontFamily: "inter", fontSize: 14),
                  ),
                ),

                for (int index = 0; index < provider.itinerary.length; index++)
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: 10, left: 16, top: 10),
                            child: Text(
                              "Image".tr,
                              style:
                                  TextStyle(fontFamily: "inter", fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: AddImageComponent(
                          imageArr: provider.itineraryImagefile.isNotEmpty &&
                                  provider.itineraryImagefile.length > index &&
                                  provider
                                      .itineraryImagefile[index].path.isNotEmpty
                              ? [provider.itineraryImagefile[index]]
                              : [],
                          onTapAdd: () async {
                            await Provider.of<VendorTourProvider>(context,
                                    listen: false)
                                .pickitineraryimage(index);
                          },
                          onTapRemove: (int imageIndex) {
                            setState(() {
                              if (index < provider.itineraryImagefile.length) {
                                // Create a new empty file instead of removing
                                provider.itineraryImagefile[index] = File('');
                                provider.itinerary[index]['image_id'] = '';
                                provider.notifyListeners();
                              }
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      CustomTextField(
                        controller: TextEditingController(
                            text:
                                provider.itinerary[index]['title'].toString()),
                        hintText: 'Title'.tr,
                        onChanged: (value) {
                          provider.itinerary[index]['title'] = value;
                        },
                      ),
                      CustomTextField(
                        controller: TextEditingController(
                            text: provider.itinerary[index]['desc'].toString()),
                        hintText: 'Description'.tr,
                        onChanged: (value) {
                          provider.itinerary[index]['desc'] = value;
                        },
                      ),
                      CustomTextField(
                        controller: TextEditingController(
                            text: provider.itinerary[index]['content']
                                .toString()),
                        hintText: 'Content'.tr,
                        onChanged: (value) {
                          provider.itinerary[index]['content'] = value;
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              provider.itinerary.removeAt(index);
                              if (index < provider.itineraryImagefile.length) {
                                provider.itineraryImagefile.removeAt(index);
                              }
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: TextIconButtom(
                        press: () {
                          setState(() {
                            provider.additinerary();
                          });
                        },
                        icon: Icon(
                          Icons.upload,
                          color: Colors.white,
                        ),
                        text: "Add Item".tr,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4, top: 10),
                  child: Text(
                    "Banner Image".tr,
                    style: TextStyle(fontFamily: "inter", fontSize: 14),
                  ),
                ),

                // Gallery Upload
                provider.bannerimage != null
                    ? Stack(
                        children: [
                          Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: Image.file(
                                  provider.bannerimage!,
                                  // Set a height for the image
                                  width: double
                                      .infinity, // Set width to fill the container
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    provider.bannerimage = null;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Center(child: Icon(Icons.close)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Stack(
                          children: [
                            Container(
                              child: TextIconButtom(
                                icon: Icon(
                                  Icons.upload,
                                  color: Colors.white,
                                ),
                                press: () {
                                  provider.pickImagebanner();
                                },
                                text: "Upload Image".tr,
                              ),
                            ),
                          ],
                        ),
                      ),

                SizedBox(
                  height: 10,
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 4, top: 10),
                  child: Text(
                    "Gallery".tr,
                    style: TextStyle(fontFamily: "inter", fontSize: 14),
                  ),
                ),

                // Gallery Upload
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: AddImageComponent(
                    imageArr: provider.pickedImagefile,
                    onTapAdd: () {
                      provider.pickimage();
                    },
                    onTapRemove: (int index) {
                      setState(() {
                        provider.pickedImagefile.removeAt(index);
                      });
                    },
                  ),
                ),

                SizedBox(
                  height: 10,
                ),
                Divider(
                  thickness: 2,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 2, bottom: 4, top: 16),
                  child: Text(
                    "Featured Image".tr,
                    style: TextStyle(fontFamily: "inter", fontSize: 14),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                provider.featuredimage != null
                    ? Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.file(
                              provider.featuredimage!,
                              width: double
                                  .infinity, // Set width to fill the container
                              fit: BoxFit.fill,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    provider.featuredimage = null;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Center(child: Icon(Icons.close)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : TextIconButtom(
                        icon: Icon(Icons.upload),
                        text: "Upload Image".tr,
                        press: () {
                          provider.pickImagefeatured();
                        },
                      ),
                SizedBox(height: 20),
                TertiaryButton(
                  press: _saveAndNext,
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
